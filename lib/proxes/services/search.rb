# frozen_string_literal: true

require 'proxes/services/es'

# TODO: This needs to be filtered.

module ProxES
  module Services
    class Search
      include ES

      attr_reader :user

      def initialize(user: nil)
        @user = user
      end

      def indices
        search_client.indices.get_mapping(index: '_all', ignore: 404).keys
      end

      def fields(index: '_all', names_only: false)
        fields = {}
        search_client.indices.get_mapping(index: index).each do |_idx, index_map|
          index_map['mappings'].each do |_type, type_map|
            next if type_map['properties'].nil?

            type_map['properties'].each do |name, details|
              if details['type'] != 'keyword' && details['fields'] && (names_only == false)
                keyword = details['fields'].find do |v|
                  v[1]['type'] == 'keyword'
                end
                fields["#{name}.#{keyword[0]}"] ||= keyword[1]['type'] if keyword
              end
              fields[name] ||= details['type'] unless details['type'].nil?
            end
          end.to_h
        end
        fields
      end

      def values(field, index = '_all', size = 25)
        result = search_client.search index: index, body: { size: 0, aggs: { values: { terms: { field: field, size: size } } } }
        result['aggregations']['values']['buckets'].map { |e| e['key'] }
      end

      def search(qs, options = {})
        search_client.search options.merge(q: qs) # , explain: true
      end

      def search_client
        client.transport.connections.get_connection.connection.options.context = { user_id: user&.id }
        client
      end
    end
  end
end
