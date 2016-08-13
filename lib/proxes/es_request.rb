require 'rack'

# See https://www.elastic.co/guide/en/elasticsearch/reference/current/api-conventions.html

module ProxES
  class ESRequest < Rack::Request
    attr_reader :user
    attr_writer :path_parts

    def endpoint
      @endpoint ||= begin
        return 'root' if path == '/'
        return path_parts[1] if path_parts[1][0] == '_' && path_parts[1] != '_all'
        nil
      end
    end

    def index
      @index ||= begin
        return nil if path_parts[1].nil?
        return path_parts[1] if path_parts[1] == '_all' || path_parts[1][0] != '_'
        nil
      end
    end

    def index=(value)
      index ? path_parts[1] = value : path_parts.insert(1, value)

      env['PATH_INFO'] = env['REQUEST_PATH'] = path_parts.join('/')
      env['REQUEST_URI'] = fullpath
    end

    def type
      @type ||= begin
        return nil unless index
        return nil if path_parts[2].nil?
        return path_parts[2] if path_parts[2] == '_all' || path_parts[2][0] != '_'
        nil
      end
    end

    def id
      @id ||= begin
        return nil unless type
        return nil if path_parts[3].nil?
        return path_parts[3] if path_parts[3][0] != '_'
        nil
      end
    end

    def action
      @action ||= begin
        return nil if path_parts[-1] == endpoint
        return path_parts[-1] if endpoint
        return nil if (path_parts[-1][0] != '_' || path_parts[-1] == '_all')
        path_parts[-1]
      end
    end

    def path_parts
      @path_parts ||= path.split('/')
    end

    def has_indices?
      ['_stats', '_search'].include? endpoint
    end
  end
end
