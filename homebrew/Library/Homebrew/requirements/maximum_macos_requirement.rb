# frozen_string_literal: true

require "requirement"

class MaximumMacOSRequirement < Requirement
  fatal true

  def initialize(tags)
    @version = MacOS::Version.from_symbol(tags.shift)
    super(tags)
  end

  satisfy(build_env: false) { MacOS.version <= @version }

  def message
    <<~EOS
      This formula either does not compile or function as expected on macOS
      versions newer than #{@version.pretty_name} due to an upstream incompatibility.
    EOS
  end

  def display_s
    "macOS <= #{@version}"
  end
end
