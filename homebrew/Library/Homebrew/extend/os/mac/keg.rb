# frozen_string_literal: true

class Keg
  GENERIC_KEG_LINK_DIRECTORIES = (remove_const :KEG_LINK_DIRECTORIES).freeze
  KEG_LINK_DIRECTORIES = (GENERIC_KEG_LINK_DIRECTORIES + ["Frameworks"]).freeze
end
