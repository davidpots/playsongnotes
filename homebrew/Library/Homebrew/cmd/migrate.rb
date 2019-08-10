# frozen_string_literal: true

require "migrator"
require "cli/parser"

module Homebrew
  module_function

  def migrate_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `migrate` [<options>] <formula>

        Migrate renamed packages to new name, where <formula> are old names of
        packages.
      EOS
      switch :force,
             description: "Treat installed <formula> and passed <formula> like if they are from "\
                          "same taps and migrate them anyway."
      switch :verbose
      switch :debug
    end
  end

  def migrate
    migrate_args.parse

    raise FormulaUnspecifiedError if ARGV.named.empty?

    ARGV.resolved_formulae.each do |f|
      if f.oldname
        unless (rack = HOMEBREW_CELLAR/f.oldname).exist? && !rack.subdirs.empty?
          raise NoSuchKegError, f.oldname
        end
        raise "#{rack} is a symlink" if rack.symlink?
      end

      migrator = Migrator.new(f)
      migrator.migrate
    end
  end
end
