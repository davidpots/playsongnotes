# frozen_string_literal: true

require "rubocops/extend/formula"

module RuboCop
  module Cop
    module FormulaAudit
      # This cop audits `options` in Formulae.
      class Options < FormulaCop
        DEPRECATION_MSG = "macOS has been 64-bit only since 10.6 so 32-bit options are deprecated."
        UNI_DEPRECATION_MSG = "macOS has been 64-bit only since 10.6 so universal options are deprecated."

        DEP_OPTION = "Formulae should not use `deprecated_option`"
        OPTION = "Formulae should not have an `option`"

        def audit_formula(_node, _class_node, _parent_class_node, body_node)
          option_call_nodes = find_every_method_call_by_name(body_node, :option)
          option_call_nodes.each do |option_call|
            option = parameters(option_call).first
            problem DEPRECATION_MSG if regex_match_group(option, /32-bit/)
          end

          option_call_nodes.each do |option_call|
            offending_node(option_call)
            option = string_content(parameters(option_call).first)
            problem UNI_DEPRECATION_MSG if option == "universal"

            if option !~ /with(out)?-/ &&
               option != "cxx11" &&
               option != "universal"
              problem "Options should begin with with/without."\
                      " Migrate '--#{option}' with `deprecated_option`."
            end

            next unless option =~ /^with(out)?-(?:checks?|tests)$/
            next if depends_on?("check", :optional, :recommended)

            problem "Use '--with#{Regexp.last_match(1)}-test' instead of '--#{option}'."\
                    " Migrate '--#{option}' with `deprecated_option`."
          end

          return unless formula_tap == "homebrew-core"

          problem DEP_OPTION if method_called_ever?(body_node, :deprecated_option)
          problem OPTION if method_called_ever?(body_node, :option)
        end
      end
    end

    # Keep this (empty) module and class around in case we need it later to
    # avoid deleting all the NewFormulaAudit referencing logic.
    module NewFormulaAudit
      class Options < FormulaCop
      end
    end
  end
end
