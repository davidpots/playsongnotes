# frozen_string_literal: true

# Contains backports from newer versions of Ruby
require "backports/2.4.0/string/match"
require "backports/2.5.0/string/delete_prefix"
require "active_support/core_ext/object/blank"

class String
  # String.chomp, but if result is empty: returns nil instead.
  # Allows `chuzzle || foo` short-circuits.
  # TODO: Deprecate.
  def chuzzle
    s = chomp
    s unless s.empty?
  end
end

class NilClass
  # TODO: Deprecate.
  def chuzzle; end
end

# Used by the inreplace function (in `utils.rb`).
module StringInreplaceExtension
  attr_accessor :errors

  def self.extended(str)
    str.errors = []
  end

  def sub!(before, after)
    result = super
    errors << "expected replacement of #{before.inspect} with #{after.inspect}" unless result
    result
  end

  # Warn if nothing was replaced
  def gsub!(before, after, audit_result = true)
    result = super(before, after)
    errors << "expected replacement of #{before.inspect} with #{after.inspect}" if audit_result && result.nil?
    result
  end

  # Looks for Makefile style variable definitions and replaces the
  # value with "new_value", or removes the definition entirely.
  def change_make_var!(flag, new_value)
    return if gsub!(/^#{Regexp.escape(flag)}[ \t]*=[ \t]*(.*)$/, "#{flag}=#{new_value}", false)

    errors << "expected to change #{flag.inspect} to #{new_value.inspect}"
  end

  # Removes variable assignments completely.
  def remove_make_var!(flags)
    Array(flags).each do |flag|
      # Also remove trailing \n, if present.
      errors << "expected to remove #{flag.inspect}" unless gsub!(/^#{Regexp.escape(flag)}[ \t]*=.*$\n?/, "", false)
    end
  end

  # Finds the specified variable
  def get_make_var(flag)
    self[/^#{Regexp.escape(flag)}[ \t]*=[ \t]*(.*)$/, 1]
  end
end
