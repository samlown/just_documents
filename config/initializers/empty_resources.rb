### HACK to allow resources without names!
module ActionController
  module Resources
    class Resource
      def path_segment_with_slash
        path_segment.blank? ? '' : "/#{path_segment}"
      end

      def path
        @path ||= path_prefix.to_s + path_segment_with_slash
      end

      def member_path
        @member_path ||= "#{shallow_path_prefix}#{path_segment_with_slash}/:id"
      end

      def nesting_path_prefix
        @nesting_path_prefix ||= "#{shallow_path_prefix}#{path_segment_with_slash}/:#{singular}_id"
      end
    end
  end
end
