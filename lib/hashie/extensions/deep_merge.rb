module Hashie
  module Extensions
    module DeepMerge
      # Returns a new hash with +self+ and +other_hash+ merged recursively.
      def deep_merge(other_hash, &block)
        dup.deep_merge!(other_hash, &block)
      end

      # Returns a new hash with +self+ and +other_hash+ merged recursively.
      # Modifies the receiver in place.
      def deep_merge!(other_hash, &block)
        _recursive_merge(self, other_hash, &block)
        self
      end

      private

      def _recursive_merge(hash, other_hash, &block)
        return other_hash if !other_hash.is_a?(::Hash)
        other_hash.each_pair do |k, v|
          tv = hash[k]
          hash[k] = case tv
          when self.class, Hash
            _recursive_merge tv, v, &block
          when ::Hash
            _recursive_merge self.class[tv], v, &block
          else
            block_given? ? block.call(k, tv, v) : v
          end
        end
        hash
      end
    end
  end
end
