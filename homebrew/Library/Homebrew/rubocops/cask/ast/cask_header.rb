# frozen_string_literal: true

module RuboCop
  module Cask
    module AST
      # This class wraps the AST method node that represents the cask header. It
      # includes various helper methods to aid cops in their analysis.
      class CaskHeader
        def initialize(method_node)
          @method_node = method_node
        end

        attr_reader :method_node

        def dsl_version?
          hash_node
        end

        def header_str
          @header_str ||= source_range.source
        end

        def source_range
          @source_range ||= method_node.loc.expression
        end

        def preferred_header_str
          "cask '#{cask_token}'"
        end

        def cask_token
          @cask_token ||= pair_node.val_node.children.first
        end

        def hash_node
          @hash_node ||= method_node.each_child_node(:hash).first
        end

        def pair_node
          @pair_node ||= hash_node.each_child_node(:pair).first
        end
      end
    end
  end
end
