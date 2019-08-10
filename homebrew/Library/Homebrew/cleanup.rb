# frozen_string_literal: true

require "utils/bottles"
require "utils/gems"
require "formula"
require "cask/cask_loader"
require "set"

CLEANUP_DEFAULT_DAYS = 30
CLEANUP_MAX_AGE_DAYS = 120

module CleanupRefinement
  refine Pathname do
    def incomplete?
      extname.end_with?(".incomplete")
    end

    def nested_cache?
      directory? && %w[cargo_cache go_cache glide_home java_cache npm_cache gclient_cache].include?(basename.to_s)
    end

    def go_cache_directory?
      # Go makes its cache contents read-only to ensure cache integrity,
      # which makes sense but is something we need to undo for cleanup.
      directory? && %w[go_cache].include?(basename.to_s)
    end

    def prune?(days)
      return false unless days
      return true if days.zero?

      return true if symlink? && !exist?

      mtime < days.days.ago && ctime < days.days.ago
    end

    def stale?(scrub = false)
      return false unless resolved_path.file?

      if dirname.basename.to_s == "Cask"
        stale_cask?(scrub)
      else
        stale_formula?(scrub)
      end
    end

    private

    def stale_formula?(scrub)
      return false unless HOMEBREW_CELLAR.directory?

      version = if to_s.match?(Pathname::BOTTLE_EXTNAME_RX)
        begin
          Utils::Bottles.resolve_version(self)
        rescue
          nil
        end
      end

      version ||= basename.to_s[/\A.*(?:\-\-.*?)*\-\-(.*?)#{Regexp.escape(extname)}\Z/, 1]
      version ||= basename.to_s[/\A.*\-\-?(.*?)#{Regexp.escape(extname)}\Z/, 1]

      return false unless version

      version = Version.new(version)

      return false unless formula_name = basename.to_s[/\A(.*?)(?:\-\-.*?)*\-\-?(?:#{Regexp.escape(version)})/, 1]

      formula = begin
        Formulary.from_rack(HOMEBREW_CELLAR/formula_name)
      rescue FormulaUnavailableError, TapFormulaAmbiguityError, TapFormulaWithOldnameAmbiguityError
        return false
      end

      resource_name = basename.to_s[/\A.*?\-\-(.*?)\-\-?(?:#{Regexp.escape(version)})/, 1]

      if resource_name == "patch"
        patch_hashes = formula.stable&.patches&.select(&:external?)&.map(&:resource)&.map(&:version)
        return true unless patch_hashes&.include?(Checksum.new(:sha256, version.to_s))
      elsif resource_name && resource_version = formula.stable&.resources&.dig(resource_name)&.version
        return true if resource_version != version
      elsif version.is_a?(PkgVersion)
        return true if formula.pkg_version > version
      elsif formula.version > version
        return true
      end

      return true if scrub && !formula.installed?

      return true if Utils::Bottles.file_outdated?(formula, self)

      false
    end

    def stale_cask?(scrub)
      return false unless name = basename.to_s[/\A(.*?)\-\-/, 1]

      cask = begin
        Cask::CaskLoader.load(name)
      rescue Cask::CaskUnavailableError
        return false
      end

      return true unless basename.to_s.match?(/\A#{Regexp.escape(name)}\-\-#{Regexp.escape(cask.version)}\b/)

      return true if scrub && !cask.versions.include?(cask.version)

      if cask.version.latest?
        return mtime < CLEANUP_DEFAULT_DAYS.days.ago &&
               ctime < CLEANUP_DEFAULT_DAYS.days.ago
      end

      false
    end
  end
end

using CleanupRefinement

module Homebrew
  class Cleanup
    extend Predicable

    PERIODIC_CLEAN_FILE = (HOMEBREW_CACHE/".cleaned").freeze

    attr_predicate :dry_run?, :scrub?
    attr_reader :args, :days, :cache
    attr_reader :disk_cleanup_size

    def initialize(*args, dry_run: false, scrub: false, days: nil, cache: HOMEBREW_CACHE)
      @disk_cleanup_size = 0
      @args = args
      @dry_run = dry_run
      @scrub = scrub
      @days = days || CLEANUP_MAX_AGE_DAYS
      @cache = cache
      @cleaned_up_paths = Set.new
    end

    def self.install_formula_clean!(f)
      return if ENV["HOMEBREW_NO_INSTALL_CLEANUP"]

      cleanup = Cleanup.new
      if cleanup.periodic_clean_due?
        cleanup.periodic_clean!
      elsif f.installed?
        cleanup.cleanup_formula(f)
      end
    end

    def periodic_clean_due?
      return false if ENV["HOMEBREW_NO_INSTALL_CLEANUP"]
      return true unless PERIODIC_CLEAN_FILE.exist?

      PERIODIC_CLEAN_FILE.mtime < CLEANUP_DEFAULT_DAYS.days.ago
    end

    def periodic_clean!
      return false unless periodic_clean_due?

      ohai "`brew cleanup` has not been run in #{CLEANUP_DEFAULT_DAYS} days, running now..."
      clean!(quiet: true, periodic: true)
    end

    def clean!(quiet: false, periodic: false)
      if args.empty?
        Formula.installed.sort_by(&:name).each do |formula|
          cleanup_formula(formula, quiet: quiet)
        end
        cleanup_cache
        cleanup_logs
        cleanup_lockfiles
        prune_prefix_symlinks_and_directories

        unless dry_run?
          cleanup_old_cache_db
          rm_ds_store
          HOMEBREW_CACHE.mkpath
          FileUtils.touch PERIODIC_CLEAN_FILE
        end

        # Cleaning up Ruby needs to be done last to avoid requiring additional
        # files afterwards. Additionally, don't allow it on periodic cleans to
        # avoid having to try to do a `brew install` when we've just deleted
        # the running Ruby process...
        return if periodic

        cleanup_portable_ruby
      else
        args.each do |arg|
          formula = begin
            Formulary.resolve(arg)
          rescue FormulaUnavailableError, TapFormulaAmbiguityError, TapFormulaWithOldnameAmbiguityError
            nil
          end

          cask = begin
            Cask::CaskLoader.load(arg)
          rescue Cask::CaskUnavailableError
            nil
          end

          cleanup_formula(formula) if formula
          cleanup_cask(cask) if cask
        end
      end
    end

    def unremovable_kegs
      @unremovable_kegs ||= []
    end

    def cleanup_formula(formula, quiet: false)
      formula.eligible_kegs_for_cleanup(quiet: quiet)
             .each(&method(:cleanup_keg))
      cleanup_cache(Pathname.glob(cache/"#{formula.name}--*"))
      rm_ds_store([formula.rack])
      cleanup_lockfiles(FormulaLock.new(formula.name).path)
    end

    def cleanup_cask(cask)
      cleanup_cache(Pathname.glob(cache/"Cask/#{cask.token}--*"))
      rm_ds_store([cask.caskroom_path])
      cleanup_lockfiles(CaskLock.new(cask.token).path)
    end

    def cleanup_keg(keg)
      cleanup_path(keg) { keg.uninstall }
    rescue Errno::EACCES => e
      opoo e.message
      unremovable_kegs << keg
    end

    def cleanup_logs
      return unless HOMEBREW_LOGS.directory?

      logs_days = if days > CLEANUP_DEFAULT_DAYS
        CLEANUP_DEFAULT_DAYS
      else
        days
      end

      HOMEBREW_LOGS.subdirs.each do |dir|
        cleanup_path(dir) { dir.rmtree } if dir.prune?(logs_days)
      end
    end

    def cleanup_unreferenced_downloads
      return if dry_run?
      return unless (cache/"downloads").directory?

      downloads = (cache/"downloads").children

      referenced_downloads = [cache, cache/"Cask"].select(&:directory?)
                                                  .flat_map(&:children)
                                                  .select(&:symlink?)
                                                  .map(&:resolved_path)

      (downloads - referenced_downloads).each do |download|
        if download.incomplete?
          begin
            LockFile.new(download.basename).with_lock do
              download.unlink
            end
          rescue OperationInProgressError
            # Skip incomplete downloads which are still in progress.
            next
          end
        elsif download.directory?
          FileUtils.rm_rf download
        else
          download.unlink
        end
      end
    end

    def cleanup_cache(entries = nil)
      entries ||= [cache, cache/"Cask"].select(&:directory?).flat_map(&:children)

      entries.each do |path|
        next if path == PERIODIC_CLEAN_FILE

        FileUtils.chmod_R 0755, path if path.go_cache_directory? && !dry_run?
        next cleanup_path(path) { path.unlink } if path.incomplete?
        next cleanup_path(path) { FileUtils.rm_rf path } if path.nested_cache?

        if path.prune?(days)
          if path.file? || path.symlink?
            cleanup_path(path) { path.unlink }
          elsif path.directory? && path.to_s.include?("--")
            cleanup_path(path) { FileUtils.rm_rf path }
          end
          next
        end

        next cleanup_path(path) { path.unlink } if path.stale?(scrub?)
      end

      cleanup_unreferenced_downloads
    end

    def cleanup_path(path)
      return unless @cleaned_up_paths.add?(path)

      disk_usage = path.disk_usage

      if dry_run?
        puts "Would remove: #{path} (#{path.abv})"
        @disk_cleanup_size += disk_usage
      else
        puts "Removing: #{path}... (#{path.abv})"
        yield
        @disk_cleanup_size += disk_usage - path.disk_usage
      end
    end

    def cleanup_lockfiles(*lockfiles)
      return if dry_run?

      lockfiles = HOMEBREW_LOCKS.children.select(&:file?) if lockfiles.empty? && HOMEBREW_LOCKS.directory?

      lockfiles.each do |file|
        next unless file.readable?
        next unless file.open(File::RDWR).flock(File::LOCK_EX | File::LOCK_NB)

        begin
          file.unlink
        ensure
          file.open(File::RDWR).flock(File::LOCK_UN) if file.exist?
        end
      end
    end

    def cleanup_portable_ruby
      system_ruby_version =
        Utils.popen_read("/usr/bin/ruby", "-e", "puts RUBY_VERSION")
             .chomp
      use_system_ruby = (
        Gem::Version.new(system_ruby_version) >= Gem::Version.new(RUBY_VERSION)
      ) && ENV["HOMEBREW_FORCE_VENDOR_RUBY"].nil?
      vendor_path = HOMEBREW_LIBRARY/"Homebrew/vendor"
      portable_ruby_version_file = vendor_path/"portable-ruby-version"
      portable_ruby_version = if portable_ruby_version_file.exist?
        portable_ruby_version_file.read
                                  .chomp
      end

      portable_ruby_path = vendor_path/"portable-ruby"
      portable_ruby_glob = "#{portable_ruby_path}/*.*"
      Pathname.glob(portable_ruby_glob).each do |path|
        next if !use_system_ruby && portable_ruby_version == path.basename.to_s

        if dry_run?
          puts "Would remove: #{path} (#{path.abv})"
        else
          FileUtils.rm_rf path
        end
      end

      return unless Dir.glob(portable_ruby_glob).empty?
      return unless portable_ruby_path.exist?

      bundler_path = vendor_path/"bundle/ruby"
      if dry_run?
        puts "Would remove: #{bundler_path} (#{bundler_path.abv})"
        puts "Would remove: #{portable_ruby_path} (#{portable_ruby_path.abv})"
      else
        FileUtils.rm_rf [bundler_path, portable_ruby_path]
      end
    end

    def cleanup_old_cache_db
      FileUtils.rm_rf [
        cache/"desc_cache.json",
        cache/"linkage.db",
        cache/"linkage.db.db",
      ]
    end

    def rm_ds_store(dirs = nil)
      dirs ||= begin
        Keg::MUST_EXIST_DIRECTORIES + [
          HOMEBREW_PREFIX/"Caskroom",
        ]
      end
      dirs.select(&:directory?).each do |dir|
        system_command "find",
                       args:         [dir, "-name", ".DS_Store", "-delete"],
                       print_stderr: false
      end
    end

    def prune_prefix_symlinks_and_directories
      ObserverPathnameExtension.reset_counts!

      dirs = []

      Keg::MUST_EXIST_SUBDIRECTORIES.each do |dir|
        next unless dir.directory?

        dir.find do |path|
          path.extend(ObserverPathnameExtension)
          if path.symlink?
            unless path.resolved_path_exists?
              if path.to_s =~ Keg::INFOFILE_RX
                path.uninstall_info unless dry_run?
              end

              if dry_run?
                puts "Would remove (broken link): #{path}"
              else
                path.unlink
              end
            end
          elsif path.directory? && !Keg::MUST_EXIST_SUBDIRECTORIES.include?(path)
            dirs << path
          end
        end
      end

      dirs.reverse_each do |d|
        if dry_run? && d.children.empty?
          puts "Would remove (empty directory): #{d}"
        else
          d.rmdir_if_possible
        end
      end

      return if dry_run?

      return if ObserverPathnameExtension.total.zero?

      n, d = ObserverPathnameExtension.counts
      print "Pruned #{n} symbolic links "
      print "and #{d} directories " if d.positive?
      puts "from #{HOMEBREW_PREFIX}"
    end
  end
end
