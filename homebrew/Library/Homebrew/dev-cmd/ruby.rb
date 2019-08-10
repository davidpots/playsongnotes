# frozen_string_literal: true

require "cli/parser"

module Homebrew
  module_function

  def ruby_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `ruby` [`-e`]:

        Run a Ruby instance with Homebrew's libraries loaded e.g.
        `brew ruby -e "puts :gcc.f.deps"` or `brew ruby script.rb`
      EOS
      switch "-e",
             description: "Execute the provided string argument as a script."
      switch :verbose
      switch :debug
    end
  end

  def ruby
    ruby_args.parse

    begin
      safe_system ENV["HOMEBREW_RUBY_PATH"],
                  "-I", $LOAD_PATH.join(File::PATH_SEPARATOR),
                  "-rglobal", "-rdev-cmd/irb",
                  *ARGV
    rescue ErrorDuringExecution => e
      exit e.status.exitstatus
    end
  end
end
