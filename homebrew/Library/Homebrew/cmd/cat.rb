# frozen_string_literal: true

require "cli/parser"

module Homebrew
  module_function

  def cat_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `cat` <formula>

        Display the source of <formula>.
      EOS
    end
  end

  def cat
    cat_args.parse
    # do not "fix" this to support multiple arguments, the output would be
    # unparsable, if the user wants to cat multiple formula they can call
    # brew cat multiple times.
    formulae = ARGV.formulae
    raise FormulaUnspecifiedError if formulae.empty?
    raise "`brew cat` doesn't support multiple arguments" if args.remaining.size > 1

    cd HOMEBREW_REPOSITORY
    safe_system "cat", formulae.first.path, *ARGV.options_only
  end
end
