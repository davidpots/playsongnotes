# frozen_string_literal: true

require "digest/md5"
require "extend/cachable"

# The Formulary is responsible for creating instances of {Formula}.
# It is not meant to be used directly from formulae.

module Formulary
  extend Cachable

  def self.formula_class_defined?(path)
    cache.key?(path)
  end

  def self.formula_class_get(path)
    cache.fetch(path)
  end

  def self.load_formula(name, path, contents, namespace)
    raise "Formula loading disabled by HOMEBREW_DISABLE_LOAD_FORMULA!" if ENV["HOMEBREW_DISABLE_LOAD_FORMULA"]

    mod = Module.new
    const_set(namespace, mod)
    begin
      mod.module_eval(contents, path)
    rescue NameError, ArgumentError, ScriptError => e
      raise FormulaUnreadableError.new(name, e)
    end
    class_name = class_s(name)

    begin
      mod.const_get(class_name)
    rescue NameError => e
      class_list = mod.constants
                      .map { |const_name| mod.const_get(const_name) }
                      .select { |const| const.is_a?(Class) }
      new_exception = FormulaClassUnavailableError.new(name, path, class_name, class_list)
      raise new_exception, "", e.backtrace
    end
  end

  def self.load_formula_from_path(name, path)
    contents = path.open("r") { |f| ensure_utf8_encoding(f).read }
    namespace = "FormulaNamespace#{Digest::MD5.hexdigest(path.to_s)}"
    klass = load_formula(name, path, contents, namespace)
    cache[path] = klass
  end

  def self.resolve(name, spec: nil)
    if name.include?("/") || File.exist?(name)
      f = factory(name, *spec)
      if f.any_version_installed?
        tab = Tab.for_formula(f)
        resolved_spec = spec || tab.spec
        f.active_spec = resolved_spec if f.send(resolved_spec)
        f.build = tab
        if f.head? && tab.tabfile
          k = Keg.new(tab.tabfile.parent)
          f.version.update_commit(k.version.version.commit) if k.version.head?
        end
      end
    else
      rack = to_rack(name)
      alias_path = factory(name).alias_path
      f = from_rack(rack, *spec, alias_path: alias_path)
    end

    # If this formula was installed with an alias that has since changed,
    # then it was specified explicitly in ARGV. (Using the alias would
    # instead have found the new formula.)
    #
    # Because of this, the user is referring to this specific formula,
    # not any formula targetted by the same alias, so in this context
    # the formula shouldn't be considered outdated if the alias used to
    # install it has changed.
    f.follow_installed_alias = false

    f
  end

  def self.ensure_utf8_encoding(io)
    io.set_encoding(Encoding::UTF_8)
  end

  def self.class_s(name)
    class_name = name.capitalize
    class_name.gsub!(/[-_.\s]([a-zA-Z0-9])/) { Regexp.last_match(1).upcase }
    class_name.tr!("+", "x")
    class_name.sub!(/(.)@(\d)/, "\\1AT\\2")
    class_name
  end

  # A FormulaLoader returns instances of formulae.
  # Subclasses implement loaders for particular sources of formulae.
  class FormulaLoader
    # The formula's name
    attr_reader :name
    # The formula's ruby file's path or filename
    attr_reader :path
    # The name used to install the formula
    attr_reader :alias_path

    def initialize(name, path)
      @name = name
      @path = path.resolved_path
    end

    # Gets the formula instance.
    #
    # `alias_path` can be overridden here in case an alias was used to refer to
    # a formula that was loaded in another way.
    def get_formula(spec, alias_path: nil)
      klass.new(name, path, spec, alias_path: alias_path || self.alias_path)
    end

    def klass
      load_file unless Formulary.formula_class_defined?(path)
      Formulary.formula_class_get(path)
    end

    private

    def load_file
      $stderr.puts "#{$PROGRAM_NAME} (#{self.class.name}): loading #{path}" if ARGV.debug?
      raise FormulaUnavailableError, name unless path.file?

      Formulary.load_formula_from_path(name, path)
    end
  end

  # Loads formulae from bottles.
  class BottleLoader < FormulaLoader
    def initialize(bottle_name)
      case bottle_name
      when %r{(https?|ftp|file)://}
        # The name of the formula is found between the last slash and the last hyphen.
        formula_name = File.basename(bottle_name)[/(.+)-/, 1]
        resource = Resource.new(formula_name) { url bottle_name }
        resource.specs[:bottle] = true
        downloader = resource.downloader
        cached = downloader.cached_location.exist?
        downloader.fetch
        ohai "Pouring the cached bottle" if cached
        @bottle_filename = downloader.cached_location
      else
        @bottle_filename = Pathname(bottle_name).realpath
      end
      name, full_name = Utils::Bottles.resolve_formula_names @bottle_filename
      super name, Formulary.path(full_name)
    end

    def get_formula(spec, **)
      contents = Utils::Bottles.formula_contents @bottle_filename, name: name
      formula = begin
        Formulary.from_contents name, @bottle_filename, contents, spec
      rescue FormulaUnreadableError => e
        opoo <<~EOS
          Unreadable formula in #{@bottle_filename}:
          #{e}
        EOS
        super
      end
      formula.local_bottle_path = @bottle_filename
      formula
    end
  end

  class AliasLoader < FormulaLoader
    def initialize(alias_path)
      path = alias_path.resolved_path
      name = path.basename(".rb").to_s
      super name, path
      @alias_path = alias_path.to_s
    end
  end

  # Loads formulae from disk using a path.
  class FromPathLoader < FormulaLoader
    def initialize(path)
      path = Pathname.new(path).expand_path
      super path.basename(".rb").to_s, path
    end
  end

  # Loads formulae from URLs.
  class FromUrlLoader < FormulaLoader
    attr_reader :url

    def initialize(url)
      @url = url
      uri = URI(url)
      formula = File.basename(uri.path, ".rb")
      super formula, HOMEBREW_CACHE_FORMULA/File.basename(uri.path)
    end

    def load_file
      if url =~ %r{githubusercontent.com/[\w-]+/[\w-]+/[a-f0-9]{40}(/Formula)?/([\w+-.@]+).rb}
        formula_name = Regexp.last_match(2)
        ohai "Consider using `brew extract #{formula_name} ...`!"
        puts <<~EOS
          This will extract your desired #{formula_name} version to a stable tap instead of
          installing from an unstable URL!

        EOS
      end
      HOMEBREW_CACHE_FORMULA.mkpath
      FileUtils.rm_f(path)
      curl_download url, to: path
      super
    rescue MethodDeprecatedError => e
      if url =~ %r{github.com/([\w-]+)/homebrew-([\w-]+)/}
        e.issues_url = "https://github.com/#{Regexp.last_match(1)}/homebrew-#{Regexp.last_match(2)}/issues/new"
      end
      raise
    end
  end

  # Loads tapped formulae.
  class TapLoader < FormulaLoader
    attr_reader :tap

    def initialize(tapped_name, from: nil)
      warn = ![:keg, :rack].include?(from)
      name, path = formula_name_path(tapped_name, warn: warn)
      super name, path
    end

    def formula_name_path(tapped_name, warn: true)
      user, repo, name = tapped_name.split("/", 3).map(&:downcase)
      @tap = Tap.fetch user, repo
      formula_dir = @tap.formula_dir || @tap.path
      path = formula_dir/"#{name}.rb"

      unless path.file?
        if (possible_alias = @tap.alias_dir/name).file?
          path = possible_alias.resolved_path
          name = path.basename(".rb").to_s
        elsif (new_name = @tap.formula_renames[name]) &&
              (new_path = formula_dir/"#{new_name}.rb").file?
          old_name = name
          path = new_path
          name = new_name
          new_name = @tap.core_tap? ? name : "#{@tap}/#{name}"
        elsif (new_tap_name = @tap.tap_migrations[name])
          new_tap_user, new_tap_repo, = new_tap_name.split("/")
          new_tap_name = "#{new_tap_user}/#{new_tap_repo}"
          new_tap = Tap.fetch new_tap_name
          new_tap.install unless new_tap.installed?
          new_tapped_name = "#{new_tap_name}/#{name}"
          name, path = formula_name_path(new_tapped_name, warn: false)
          old_name = tapped_name
          new_name = new_tap.core_tap? ? name : new_tapped_name
        end

        opoo "Use #{new_name} instead of deprecated #{old_name}" if warn && old_name && new_name
      end

      [name, path]
    end

    def get_formula(spec, alias_path: nil)
      super
    rescue FormulaUnreadableError => e
      raise TapFormulaUnreadableError.new(tap, name, e.formula_error), "", e.backtrace
    rescue FormulaClassUnavailableError => e
      raise TapFormulaClassUnavailableError.new(tap, name, e.path, e.class_name, e.class_list), "", e.backtrace
    rescue FormulaUnavailableError => e
      raise TapFormulaUnavailableError.new(tap, name), "", e.backtrace
    end

    def load_file
      super
    rescue MethodDeprecatedError => e
      e.issues_url = tap.issues_url || tap.to_s
      raise
    end
  end

  class NullLoader < FormulaLoader
    def initialize(name)
      super name, Formulary.core_path(name)
    end

    def get_formula(*)
      raise FormulaUnavailableError, name
    end
  end

  # Load formulae directly from their contents.
  class FormulaContentsLoader < FormulaLoader
    # The formula's contents
    attr_reader :contents

    def initialize(name, path, contents)
      @contents = contents
      super name, path
    end

    def klass
      $stderr.puts "#{$PROGRAM_NAME} (#{self.class.name}): loading #{path}" if ARGV.debug?
      namespace = "FormulaNamespace#{Digest::MD5.hexdigest(contents)}"
      Formulary.load_formula(name, path, contents, namespace)
    end
  end

  # Return a Formula instance for the given reference.
  # `ref` is a string containing:
  #
  # * a formula name
  # * a formula pathname
  # * a formula URL
  # * a local bottle reference
  def self.factory(ref, spec = :stable, alias_path: nil, from: nil)
    raise ArgumentError, "Formulae must have a ref!" unless ref

    loader_for(ref, from: from).get_formula(spec, alias_path: alias_path)
  end

  # Return a Formula instance for the given rack.
  # It will auto resolve formula's spec when requested spec is nil
  #
  # The :alias_path option will be used if the formula is found not to be
  # installed, and discarded if it is installed because the alias_path used
  # to install the formula will be set instead.
  def self.from_rack(rack, spec = nil, alias_path: nil)
    kegs = rack.directory? ? rack.subdirs.map { |d| Keg.new(d) } : []
    keg = kegs.find(&:linked?) || kegs.find(&:optlinked?) || kegs.max_by(&:version)

    if keg
      from_keg(keg, spec, alias_path: alias_path)
    else
      factory(rack.basename.to_s, spec || :stable, alias_path: alias_path, from: :rack)
    end
  end

  # Return whether given rack is keg-only
  def self.keg_only?(rack)
    Formulary.from_rack(rack).keg_only?
  rescue FormulaUnavailableError, TapFormulaAmbiguityError, TapFormulaWithOldnameAmbiguityError
    false
  end

  # Return a Formula instance for the given keg.
  # It will auto resolve formula's spec when requested spec is nil
  def self.from_keg(keg, spec = nil, alias_path: nil)
    tab = Tab.for_keg(keg)
    tap = tab.tap
    spec ||= tab.spec

    f = if tap.nil?
      factory(keg.rack.basename.to_s, spec, alias_path: alias_path, from: :keg)
    else
      begin
        factory("#{tap}/#{keg.rack.basename}", spec, alias_path: alias_path, from: :keg)
      rescue FormulaUnavailableError
        # formula may be migrated to different tap. Try to search in core and all taps.
        factory(keg.rack.basename.to_s, spec, alias_path: alias_path, from: :keg)
      end
    end
    f.build = tab
    f.build.used_options = Tab.remap_deprecated_options(f.deprecated_options, tab.used_options).as_flags
    f.version.update_commit(keg.version.version.commit) if f.head? && keg.version.head?
    f
  end

  # Return a Formula instance directly from contents
  def self.from_contents(name, path, contents, spec = :stable)
    FormulaContentsLoader.new(name, path, contents).get_formula(spec)
  end

  def self.to_rack(ref)
    # If using a fully-scoped reference, check if the formula can be resolved.
    factory(ref) if ref.include? "/"

    # Check whether the rack with the given name exists.
    if (rack = HOMEBREW_CELLAR/File.basename(ref, ".rb")).directory?
      return rack.resolved_path
    end

    # Use canonical name to locate rack.
    (HOMEBREW_CELLAR/canonical_name(ref)).resolved_path
  end

  def self.canonical_name(ref)
    loader_for(ref).name
  rescue TapFormulaAmbiguityError
    # If there are multiple tap formulae with the name of ref,
    # then ref is the canonical name
    ref.downcase
  end

  def self.path(ref)
    loader_for(ref).path
  end

  def self.loader_for(ref, from: nil)
    case ref
    when Pathname::BOTTLE_EXTNAME_RX
      return BottleLoader.new(ref)
    when %r{(https?|ftp|file)://}
      return FromUrlLoader.new(ref)
    when HOMEBREW_TAP_FORMULA_REGEX
      return TapLoader.new(ref, from: from)
    end

    return FromPathLoader.new(ref) if File.extname(ref) == ".rb" && Pathname.new(ref).expand_path.exist?

    formula_with_that_name = core_path(ref)
    return FormulaLoader.new(ref, formula_with_that_name) if formula_with_that_name.file?

    possible_alias = CoreTap.instance.alias_dir/ref
    return AliasLoader.new(possible_alias) if possible_alias.file?

    possible_tap_formulae = tap_paths(ref)
    raise TapFormulaAmbiguityError.new(ref, possible_tap_formulae) if possible_tap_formulae.size > 1

    if possible_tap_formulae.size == 1
      path = possible_tap_formulae.first.resolved_path
      name = path.basename(".rb").to_s
      return FormulaLoader.new(name, path)
    end

    if newref = CoreTap.instance.formula_renames[ref]
      formula_with_that_oldname = core_path(newref)
      return FormulaLoader.new(newref, formula_with_that_oldname) if formula_with_that_oldname.file?
    end

    possible_tap_newname_formulae = []
    Tap.each do |tap|
      if newref = tap.formula_renames[ref]
        possible_tap_newname_formulae << "#{tap.name}/#{newref}"
      end
    end

    if possible_tap_newname_formulae.size > 1
      raise TapFormulaWithOldnameAmbiguityError.new(ref, possible_tap_newname_formulae)
    end

    return TapLoader.new(possible_tap_newname_formulae.first, from: from) unless possible_tap_newname_formulae.empty?

    possible_keg_formula = Pathname.new("#{HOMEBREW_PREFIX}/opt/#{ref}/.brew/#{ref}.rb")
    return FormulaLoader.new(ref, possible_keg_formula) if possible_keg_formula.file?

    possible_cached_formula = Pathname.new("#{HOMEBREW_CACHE_FORMULA}/#{ref}.rb")
    return FormulaLoader.new(ref, possible_cached_formula) if possible_cached_formula.file?

    NullLoader.new(ref)
  end

  def self.core_path(name)
    CoreTap.instance.formula_dir/"#{name.to_s.downcase}.rb"
  end

  def self.tap_paths(name, taps = Dir[HOMEBREW_LIBRARY/"Taps/*/*/"])
    name = name.to_s.downcase
    taps.map do |tap|
      Pathname.glob([
                      "#{tap}Formula/#{name}.rb",
                      "#{tap}HomebrewFormula/#{name}.rb",
                      "#{tap}#{name}.rb",
                      "#{tap}Aliases/#{name}",
                    ]).find(&:file?)
    end.compact
  end

  def self.find_with_priority(ref, spec = :stable)
    possible_pinned_tap_formulae = tap_paths(ref, Dir["#{HOMEBREW_LIBRARY}/PinnedTaps/*/*/"]).map(&:realpath)
    raise TapFormulaAmbiguityError.new(ref, possible_pinned_tap_formulae) if possible_pinned_tap_formulae.size > 1

    if possible_pinned_tap_formulae.size == 1
      selected_formula = factory(possible_pinned_tap_formulae.first, spec)
      if core_path(ref).file?
        odeprecated "brew tap-pin user/tap",
                    "fully-scoped user/tap/formula naming"
        opoo <<~EOS
          #{ref} is provided by core, but is now shadowed by #{selected_formula.full_name}.
          This behaviour is deprecated and will be removed in Homebrew 2.2.0.
          To refer to the core formula, use Homebrew/core/#{ref} instead.
          To refer to the tap formula, use #{selected_formula.full_name} instead.
        EOS
      end
      selected_formula
    else
      factory(ref, spec)
    end
  end
end
