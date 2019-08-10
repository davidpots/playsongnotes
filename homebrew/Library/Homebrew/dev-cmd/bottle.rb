# Uses ERB so can't use Frozen String Literals until >=Ruby 2.4:
# https://bugs.ruby-lang.org/issues/12031
# frozen_string_literal: false

require "formula"
require "utils/bottles"
require "tab"
require "keg"
require "formula_versions"
require "cli/parser"
require "utils/inreplace"
require "erb"

BOTTLE_ERB = <<-EOS.freeze
  bottle do
    <% if !root_url.start_with?(HOMEBREW_BOTTLE_DEFAULT_DOMAIN) %>
    root_url "<%= root_url %>"
    <% end %>
    <% if ![Homebrew::DEFAULT_PREFIX, "/usr/local"].include?(prefix) %>
    prefix "<%= prefix %>"
    <% end %>
    <% if cellar.is_a? Symbol %>
    cellar :<%= cellar %>
    <% elsif ![Homebrew::DEFAULT_CELLAR, "/usr/local/Cellar"].include?(cellar) %>
    cellar "<%= cellar %>"
    <% end %>
    <% if rebuild.positive? %>
    rebuild <%= rebuild %>
    <% end %>
    <% checksums.each do |checksum_type, checksum_values| %>
    <% checksum_values.each do |checksum_value| %>
    <% checksum, macos = checksum_value.shift %>
    <%= checksum_type %> "<%= checksum %>" => :<%= macos %><%= "_or_later" if Homebrew.args.or_later? %>
    <% end %>
    <% end %>
  end
EOS

MAXIMUM_STRING_MATCHES = 100

module Homebrew
  module_function

  def bottle_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS.freeze
        `bottle` [<options>] <formula>

        Generate a bottle (binary package) from a formula that was installed with
        `--build-bottle`.
        If the formula specifies a rebuild version, it will be incremented in the
        generated DSL. Passing `--keep-old` will attempt to keep it at its original
        value, while `--no-rebuild` will remove it.
      EOS
      switch "--skip-relocation",
             description: "Do not check if the bottle can be marked as relocatable."
      switch "--or-later",
             description: "Append `_or_later` to the bottle tag."
      switch "--force-core-tap",
             description: "Build a bottle even if <formula> is not in `homebrew/core` or any installed taps."
      switch "--no-rebuild",
             description: "If the formula specifies a rebuild version, remove it from the generated DSL."
      switch "--keep-old",
             description: "If the formula specifies a rebuild version, attempt to preserve its value in the "\
                          "generated DSL."
      switch "--json",
             description: "Write bottle information to a JSON file, which can be used as the argument for "\
                          "`--merge`."
      switch "--merge",
             description: "Generate an updated bottle block for a formula and optionally merge it into the "\
                          "formula file. Instead of a formula name, requires a JSON file generated with "\
                          "`brew bottle --json` <formula>."
      switch "--write",
             depends_on:  "--merge",
             description: "Write the changes to the formula file. A new commit will be generated unless "\
                          "`--no-commit` is passed."
      switch "--no-commit",
             depends_on:  "--write",
             description: "When passed with `--write`, a new commit will not generated after writing changes "\
                          "to the formula file."
      flag   "--root-url=",
             description: "Use the specified <URL> as the root of the bottle's URL instead of Homebrew's default."
      switch :verbose
      switch :debug
      conflicts "--no-rebuild", "--keep-old"
    end
  end

  def bottle
    bottle_args.parse

    return merge if args.merge?

    ensure_relocation_formulae_installed!
    ARGV.resolved_formulae.each do |f|
      bottle_formula f
    end
  end

  def ensure_relocation_formulae_installed!
    Keg.relocation_formulae.each do |f|
      next if Formula[f].installed?

      ohai "Installing #{f}..."
      safe_system HOMEBREW_BREW_FILE, "install", f
    end
  end

  def keg_contain?(string, keg, ignores, formula_and_runtime_deps_names = nil)
    @put_string_exists_header, @put_filenames = nil

    print_filename = lambda do |str, filename|
      unless @put_string_exists_header
        opoo "String '#{str}' still exists in these files:"
        @put_string_exists_header = true
      end

      @put_filenames ||= []

      return if @put_filenames.include?(filename)

      puts Formatter.error(filename.to_s)
      @put_filenames << filename
    end

    result = false

    keg.each_unique_file_matching(string) do |file|
      next if Metafiles::EXTENSIONS.include?(file.extname) # Skip document files.

      linked_libraries = Keg.file_linked_libraries(file, string)
      result ||= !linked_libraries.empty?

      if args.verbose?
        print_filename.call(string, file) unless linked_libraries.empty?
        linked_libraries.each do |lib|
          puts " #{Tty.bold}-->#{Tty.reset} links to #{lib}"
        end
      end

      text_matches = []

      # Use strings to search through the file for each string
      Utils.popen_read("strings", "-t", "x", "-", file.to_s) do |io|
        until io.eof?
          str = io.readline.chomp
          next if ignores.any? { |i| i =~ str }
          next unless str.include? string

          offset, match = str.split(" ", 2)
          next if linked_libraries.include? match # Don't bother reporting a string if it was found by otool

          # Do not report matches to files that do not exist.
          next unless File.exist? match

          # Do not report matches to build dependencies.
          if formula_and_runtime_deps_names.present?
            begin
              keg_name = Keg.for(Pathname.new(match)).name
              next unless formula_and_runtime_deps_names.include? keg_name
            rescue NotAKegError
              nil
            end
          end

          result = true
          text_matches << [match, offset]
        end
      end

      next unless args.verbose? && !text_matches.empty?

      print_filename.call(string, file)
      text_matches.first(MAXIMUM_STRING_MATCHES).each do |match, offset|
        puts " #{Tty.bold}-->#{Tty.reset} match '#{match}' at offset #{Tty.bold}0x#{offset}#{Tty.reset}"
      end

      if text_matches.size > MAXIMUM_STRING_MATCHES
        puts "Only the first #{MAXIMUM_STRING_MATCHES} matches were output"
      end
    end

    keg_contain_absolute_symlink_starting_with?(string, keg) || result
  end

  def keg_contain_absolute_symlink_starting_with?(string, keg)
    absolute_symlinks_start_with_string = []
    keg.find do |pn|
      next unless pn.symlink? && (link = pn.readlink).absolute?

      absolute_symlinks_start_with_string << pn if link.to_s.start_with?(string)
    end

    if args.verbose?
      unless absolute_symlinks_start_with_string.empty?
        opoo "Absolute symlink starting with #{string}:"
        absolute_symlinks_start_with_string.each do |pn|
          puts "  #{pn} -> #{pn.resolved_path}"
        end
      end
    end

    !absolute_symlinks_start_with_string.empty?
  end

  def bottle_output(bottle)
    erb = ERB.new BOTTLE_ERB
    erb.result(bottle.instance_eval { binding }).gsub(/^\s*$\n/, "")
  end

  def bottle_formula(f)
    return ofail "Formula not installed or up-to-date: #{f.full_name}" unless f.installed?

    unless tap = f.tap
      return ofail "Formula not from core or any installed taps: #{f.full_name}" unless args.force_core_tap?

      tap = CoreTap.instance
    end

    if f.bottle_disabled?
      ofail "Formula has disabled bottle: #{f.full_name}"
      puts f.bottle_disable_reason
      return
    end

    return ofail "Formula not installed with '--build-bottle': #{f.full_name}" unless Utils::Bottles.built_as? f

    return ofail "Formula has no stable version: #{f.full_name}" unless f.stable

    if args.no_rebuild? || !f.tap
      rebuild = 0
    elsif args.keep_old?
      rebuild = f.bottle_specification.rebuild
    else
      ohai "Determining #{f.full_name} bottle rebuild..."
      versions = FormulaVersions.new(f)
      rebuilds = versions.bottle_version_map("origin/master")[f.pkg_version]
      rebuilds.pop if rebuilds.last.to_i.positive?
      rebuild = rebuilds.empty? ? 0 : rebuilds.max.to_i + 1
    end

    filename = Bottle::Filename.create(f, Utils::Bottles.tag, rebuild)
    bottle_path = Pathname.pwd/filename

    tar_filename = filename.to_s.sub(/.gz$/, "")
    tar_path = Pathname.pwd/tar_filename

    prefix = HOMEBREW_PREFIX.to_s
    repository = HOMEBREW_REPOSITORY.to_s
    cellar = HOMEBREW_CELLAR.to_s

    ohai "Bottling #{filename}..."

    formula_and_runtime_deps_names = [f.name] + f.runtime_dependencies.map(&:name)
    keg = Keg.new(f.prefix)
    relocatable = false
    skip_relocation = false

    keg.lock do
      original_tab = nil
      changed_files = nil

      begin
        keg.delete_pyc_files!

        changed_files = keg.replace_locations_with_placeholders unless args.skip_relocation?

        Tab.clear_cache
        tab = Tab.for_keg(keg)
        original_tab = tab.dup
        tab.poured_from_bottle = false
        tab.HEAD = nil
        tab.time = nil
        tab.changed_files = changed_files
        tab.write

        keg.find do |file|
          if file.symlink?
            # Ruby does not support `File.lutime` yet.
            # Shellout using `touch` to change modified time of symlink itself.
            system "/usr/bin/touch", "-h",
                   "-t", tab.source_modified_time.strftime("%Y%m%d%H%M.%S"), file
          else
            file.utime(tab.source_modified_time, tab.source_modified_time)
          end
        end

        cd cellar do
          safe_system "tar", "cf", tar_path, "#{f.name}/#{f.pkg_version}"
          tar_path.utime(tab.source_modified_time, tab.source_modified_time)
          relocatable_tar_path = "#{f}-bottle.tar"
          mv tar_path, relocatable_tar_path
          # Use gzip, faster to compress than bzip2, faster to uncompress than bzip2
          # or an uncompressed tarball (and more bandwidth friendly).
          safe_system "gzip", "-f", relocatable_tar_path
          mv "#{relocatable_tar_path}.gz", bottle_path
        end

        ohai "Detecting if #{filename} is relocatable..." if bottle_path.size > 1 * 1024 * 1024

        if Homebrew.default_prefix?(prefix)
          prefix_check = File.join(prefix, "opt")
        else
          prefix_check = prefix
        end

        # Ignore matches to source code, which is not required at run time.
        # These matches may be caused by debugging symbols.
        ignores = [%r{/include/|\.(c|cc|cpp|h|hpp)$}]
        any_go_deps = f.deps.any? do |dep|
          dep.name =~ Version.formula_optionally_versioned_regex(:go)
        end
        if any_go_deps
          go_regex =
            Version.formula_optionally_versioned_regex(:go, full: false)
          ignores << %r{#{Regexp.escape(HOMEBREW_CELLAR)}/#{go_regex}/[\d\.]+/libexec}
        end

        relocatable = true
        if args.skip_relocation?
          skip_relocation = true
        else
          relocatable = false if keg_contain?(prefix_check, keg, ignores, formula_and_runtime_deps_names)
          relocatable = false if keg_contain?(repository, keg, ignores)
          relocatable = false if keg_contain?(cellar, keg, ignores, formula_and_runtime_deps_names)
          if prefix != prefix_check
            relocatable = false if keg_contain_absolute_symlink_starting_with?(prefix, keg)
            relocatable = false if keg_contain?("#{prefix}/etc", keg, ignores)
            relocatable = false if keg_contain?("#{prefix}/var", keg, ignores)
            relocatable = false if keg_contain?("#{prefix}/share/vim", keg, ignores)
          end
          skip_relocation = relocatable && !keg.require_relocation?
        end
        puts if !relocatable && args.verbose?
      rescue Interrupt
        ignore_interrupts { bottle_path.unlink if bottle_path.exist? }
        raise
      ensure
        ignore_interrupts do
          original_tab&.write
          keg.replace_placeholders_with_locations changed_files unless args.skip_relocation?
        end
      end
    end

    root_url = args.root_url

    bottle = BottleSpecification.new
    bottle.tap = tap
    bottle.root_url(root_url) if root_url
    if relocatable
      if skip_relocation
        bottle.cellar :any_skip_relocation
      else
        bottle.cellar :any
      end
    else
      bottle.cellar cellar
      bottle.prefix prefix
    end
    bottle.rebuild rebuild
    sha256 = bottle_path.sha256
    bottle.sha256 sha256 => Utils::Bottles.tag

    old_spec = f.bottle_specification
    if args.keep_old? && !old_spec.checksums.empty?
      mismatches = [:root_url, :prefix, :cellar, :rebuild].reject do |key|
        old_spec.send(key) == bottle.send(key)
      end
      if old_spec.cellar == :any && bottle.cellar == :any_skip_relocation
        mismatches.delete(:cellar)
        bottle.cellar :any
      end
      unless mismatches.empty?
        bottle_path.unlink if bottle_path.exist?

        mismatches.map! do |key|
          old_value = old_spec.send(key).inspect
          value = bottle.send(key).inspect
          "#{key}: old: #{old_value}, new: #{value}"
        end

        odie <<~EOS.freeze
          --keep-old was passed but there are changes in:
          #{mismatches.join("\n")}
        EOS
      end
    end

    output = bottle_output bottle

    puts "./#{filename}"
    puts output

    return unless args.json?

    tag = Utils::Bottles.tag.to_s
    tag += "_or_later" if args.or_later?
    json = {
      f.full_name => {
        "formula" => {
          "pkg_version" => f.pkg_version.to_s,
          "path"        => f.path.to_s.delete_prefix("#{HOMEBREW_REPOSITORY}/"),
        },
        "bottle"  => {
          "root_url" => bottle.root_url,
          "prefix"   => bottle.prefix,
          "cellar"   => bottle.cellar.to_s,
          "rebuild"  => bottle.rebuild,
          "tags"     => {
            tag => {
              "filename"       => filename.bintray,
              "local_filename" => filename.to_s,
              "sha256"         => sha256,
            },
          },
        },
        "bintray" => {
          "package"    => Utils::Bottles::Bintray.package(f.name),
          "repository" => Utils::Bottles::Bintray.repository(tap),
        },
      },
    }
    File.open(filename.json, "w") do |file|
      file.write JSON.generate json
    end
  end

  def merge
    write = args.write?

    bottles_hash = ARGV.named.reduce({}) do |hash, json_file|
      hash.deep_merge(JSON.parse(IO.read(json_file)))
    end

    bottles_hash.each do |formula_name, bottle_hash|
      ohai formula_name

      bottle = BottleSpecification.new
      bottle.root_url bottle_hash["bottle"]["root_url"]
      cellar = bottle_hash["bottle"]["cellar"]
      cellar = cellar.to_sym if ["any", "any_skip_relocation"].include?(cellar)
      bottle.cellar cellar
      bottle.prefix bottle_hash["bottle"]["prefix"]
      bottle.rebuild bottle_hash["bottle"]["rebuild"]
      bottle_hash["bottle"]["tags"].each do |tag, tag_hash|
        bottle.sha256 tag_hash["sha256"] => tag.to_sym
      end

      output = bottle_output bottle

      if write
        path = Pathname.new((HOMEBREW_REPOSITORY/bottle_hash["formula"]["path"]).to_s)
        update_or_add = nil

        Utils::Inreplace.inreplace(path) do |s|
          if s.include? "bottle do"
            update_or_add = "update"
            if args.keep_old?
              mismatches = []
              bottle_block_contents = s[/  bottle do(.+?)end\n/m, 1]
              bottle_block_contents.lines.each do |line|
                line = line.strip
                next if line.empty?

                key, old_value_original, _, tag = line.split " ", 4
                valid_key = %w[root_url prefix cellar rebuild sha1 sha256].include? key
                next unless valid_key

                old_value = old_value_original.to_s.delete "'\""
                old_value = old_value.to_s.delete ":" if key != "root_url"
                tag = tag.to_s.delete ":"

                unless tag.empty?
                  if bottle_hash["bottle"]["tags"][tag].present?
                    mismatches << "#{key} => #{tag}"
                  else
                    bottle.send(key, old_value => tag.to_sym)
                  end
                  next
                end

                value_original = bottle_hash["bottle"][key]
                value = value_original.to_s
                next if key == "cellar" && old_value == "any" && value == "any_skip_relocation"
                next unless old_value.empty? || value != old_value

                old_value = old_value_original.inspect
                value = value_original.inspect
                mismatches << "#{key}: old: #{old_value}, new: #{value}"
              end

              unless mismatches.empty?
                odie <<~EOS.freeze
                  --keep-old was passed but there are changes in:
                  #{mismatches.join("\n")}
                EOS
              end
              output = bottle_output bottle
            end
            puts output
            string = s.sub!(/  bottle do.+?end\n/m, output)
            odie "Bottle block update failed!" unless string
          else
            odie "--keep-old was passed but there was no existing bottle block!" if args.keep_old?
            puts output
            update_or_add = "add"
            if s.include? "stable do"
              indent = s.slice(/^( +)stable do/, 1).length
              string = s.sub!(/^ {#{indent}}stable do(.|\n)+?^ {#{indent}}end\n/m, '\0' + output + "\n")
            else
              pattern = /(
                  (\ {2}\#[^\n]*\n)*                                             # comments
                  \ {2}(                                                         # two spaces at the beginning
                    (url|head)\ ['"][\S\ ]+['"]                                  # url or head with a string
                    (
                      ,[\S\ ]*$                                                  # url may have options
                      (\n^\ {3}[\S\ ]+$)*                                        # options can be in multiple lines
                    )?|
                    (homepage|desc|sha1|sha256|version|mirror)\ ['"][\S\ ]+['"]| # specs with a string
                    (revision|version_scheme)\ \d+                               # revision with a number
                  )\n+                                                           # multiple empty lines
                 )+
               /mx
              string = s.sub!(pattern, '\0' + output + "\n")
            end
            odie "Bottle block addition failed!" unless string
          end
        end

        unless args.no_commit?
          if ENV["HOMEBREW_GIT_NAME"]
            ENV["GIT_AUTHOR_NAME"] =
              ENV["GIT_COMMITTER_NAME"] =
                ENV["HOMEBREW_GIT_NAME"]
          end
          if ENV["HOMEBREW_GIT_EMAIL"]
            ENV["GIT_AUTHOR_EMAIL"] =
              ENV["GIT_COMMITTER_EMAIL"] =
                ENV["HOMEBREW_GIT_EMAIL"]
          end

          short_name = formula_name.split("/", -1).last
          pkg_version = bottle_hash["formula"]["pkg_version"]

          path.parent.cd do
            safe_system "git", "commit", "--no-edit", "--verbose",
                        "--message=#{short_name}: #{update_or_add} #{pkg_version} bottle.",
                        "--", path
          end
        end
      else
        puts output
      end
    end
  end
end
