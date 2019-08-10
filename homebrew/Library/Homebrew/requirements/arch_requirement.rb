# frozen_string_literal: true

require "requirement"

class ArchRequirement < Requirement
  fatal true

  def initialize(tags)
    @arch = tags.shift
    super(tags)
  end

  satisfy(build_env: false) do
    case @arch
    when :x86_64 then Hardware::CPU.is_64_bit?
    when :intel, :ppc then Hardware::CPU.type == @arch
    end
  end

  def message
    "This formula requires an #{@arch} architecture."
  end

  def display_s
    "#{@arch} architecture"
  end
end
