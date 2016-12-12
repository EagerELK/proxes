require 'rack'
require 'active_support'
require 'active_support/inflector'

module ProxES
  class Request
    class Base < Rack::Request
      def initialize(env)
        super
        parse
      end

      def endpoint
        '_' + ActiveSupport::Inflector.demodulize(self.class.name).downcase
      end

      def parse
        raise "#{endpoint} Not implemented"
      end

      def has_indices?
        raise "#{endpoint} Not implemented"
      end

      private
      def path_parts
        @path_parts ||= path[1..-1].split('/')
      end

      def check_part(val)
        return val if val.nil?
        return [] if [endpoint, '_all'].include? val
        val.split(',')
      end
    end
  end
end
