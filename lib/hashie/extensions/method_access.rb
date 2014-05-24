module Hashie
  module Extensions
    module MethodAccess
      ALLOWED_SUFFIXES = %w(? ! = _)
      SPLIT_REGEXP     = /([#{ALLOWED_SUFFIXES.join}])$/

      def self.included(base)
        base.send :include, PrettyInspect
        base.send :include, IndifferentAccess
      end

      def prefix_method?(method_name)
        method_name = method_name.to_s
        method_name.end_with?(*ALLOWED_SUFFIXES) && key?(method_name.chop)
      end

      def method_missing(method_name, *args, &blk)
        return self.[](method_name, &blk) if key?(method_name)
        name, suffix = method_suffix(method_name)
        case suffix
        when '='
          self[name] = args.first
        when '?'
          !!self[name]
        when '!'
          initializing_reader(name)
        when '_'
          underbang_reader(name)
        else
          default(method_name)
        end
      end

      def respond_to_missing?(method_name, *args)
        return true if key?(method_name)
        _, suffix = method_suffix(method_name)
        suffix.nil? ? super : true
      end

      # This is the bang method reader, it will return a new Mash
      # if there isn't a value already assigned to the key requested.
      def initializing_reader(key)
        self[key] = self.class.new unless key?(key)
        self[key]
      end

      # This is the under bang method reader, it will return a temporary new Mash
      # if there isn't a value already assigned to the key requested.
      def underbang_reader(key)
        if key?(key)
          self[key]
        else
          self.class.new
        end
      end

      protected

      def method_suffix(method_name)
        method_name.to_s.split(SPLIT_REGEXP)
      end
    end
  end
end
