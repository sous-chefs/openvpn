class Chef
  module Mixin
    module Template
      class TemplateContext
        def render_push_options(push_options)
          push_options.each_with_object([]) do |(option, conf), m|
            case conf
            when Chef::Node::ImmutableArray, Array
              conf.each { |o| m << "push \"#{option} #{o}\"" }
            when String
              m << "push \"#{option} #{conf}\""
            else
              fail "Push option data type #{conf.class} not supported"
            end
          end
        end
      end
    end
  end
end
