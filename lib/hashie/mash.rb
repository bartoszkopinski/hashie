require 'hashie/hash'

module Hashie
  # Mash allows you to create pseudo-objects that have method-like
  # accessors for hash keys. This is useful for such implementations
  # as an API-accessing library that wants to fake robust objects
  # without the overhead of actually doing so. Think of it as OpenStruct
  # with some additional goodies.
  #
  # A Mash will look at the methods you pass it and perform operations
  # based on the following rules:
  #
  # * No punctuation: Returns the value of the hash for that key, or nil if none exists.
  # * Assignment (<tt>=</tt>): Sets the attribute of the given method name.
  # * Existence (<tt>?</tt>): Returns true or false depending on whether that key has been set.
  # * Bang (<tt>!</tt>): Forces the existence of this key, used for deep Mashes. Think of it as "touch" for mashes.
  # * Under Bang (<tt>_</tt>): Like Bang, but returns a new Mash rather than creating a key.  Used to test existance in deep Mashes.
  #
  # == Basic Example
  #
  #   mash = Mash.new
  #   mash.name? # => false
  #   mash.name = "Bob"
  #   mash.name # => "Bob"
  #   mash.name? # => true
  #
  # == Hash Conversion  Example
  #
  #   hash = {:a => {:b => 23, :d => {:e => "abc"}}, :f => [{:g => 44, :h => 29}, 12]}
  #   mash = Mash.new(hash)
  #   mash.a.b # => 23
  #   mash.a.d.e # => "abc"
  #   mash.f.first.g # => 44
  #   mash.f.last # => 12
  #
  # == Bang Example
  #
  #   mash = Mash.new
  #   mash.author # => nil
  #   mash.author! # => <Mash>
  #
  #   mash = Mash.new
  #   mash.author!.name = "Michael Bleigh"
  #   mash.author # => <Mash name="Michael Bleigh">
  #
  # == Under Bang Example
  #
  #   mash = Mash.new
  #   mash.author # => nil
  #   mash.author_ # => <Mash>
  #   mash.author_.name # => nil
  #
  #   mash = Mash.new
  #   mash.author_.name = "Michael Bleigh"  (assigned to temp object)
  #   mash.author # => <Mash>
  #
  class Mash < Hash
    include Hashie::Extensions::MethodAccess
    include Hashie::Extensions::DeepMerge

    alias_method :to_s, :inspect

    # If you pass in an existing hash, it will
    # convert it to a Mash including recursively
    # descending into arrays and hashes, converting
    # them as well.
    def initialize(source_hash = nil, default = nil, &blk)
      merge!(source_hash) if source_hash
      default ? super(default) : super(&blk)
    end

    def id #:nodoc:
      self['id']
    end

    def type #:nodoc:
      self['type']
    end

    # Retrieves an attribute set in the Mash. Will convert
    # any key passed in to a string before retrieving.
    def custom_reader(key)
      regular_reader(key).tap do |value|
        yield value if block_given?
      end
    end

    alias_method :regular_reader, :[]
    alias_method :[], :custom_reader

    alias_method :regular_dup, :dup
    # Duplicates the current mash as a new mash.
    def dup
      self.class.new(self, default)
    end

    alias_method :merge, :deep_merge
    alias_method :merge!, :deep_merge!
    alias_method :update, :merge!
    alias_method :deep_update, :merge!

    # Performs a shallow_update on a duplicate of the current mash
    def shallow_merge(other_hash)
      dup.shallow_update(other_hash)
    end

    # Merges (non-recursively) the hash from the argument,
    # changing the receiving hash
    def shallow_update(other_hash)
      other_hash.each_pair do |k, v|
        regular_writer(convert_key(k), convert_value(v))
      end
      self
    end
  end
end
