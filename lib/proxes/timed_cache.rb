# frozen_string_literal: true

module ProxES
  class TimedCache
    attr_reader :timeout

    def initialize(default = nil, timeout = 60)
      @store = block_given? ? Hash.new(&Proc.new) : Hash.new(default)
      @timeout = timeout
    end

    def [](key)
      return store[key] if store.has_key?(key) && age(key) < timeout

      store.delete(key)
      last_fetched[key] = Time.now
      store[key]
    end

    def []=(key, value)
      last_fetched[key] = Time.now
      store[key] = value
    end

    def last_fetched
      @last_fetched ||= {}
    end

    def age(key)
      return 0 unless last_fetched.has_key?(key)

      Time.now - last_fetched[key]
    end

    def method_missing(method, *args, &block)
      return super unless respond_to_missing?(method)

      store.send(method, *args, &block)
    end

    def respond_to_missing?(method, _include_private = false)
      store.respond_to? method
    end

    private

    attr_reader :store
  end
end
