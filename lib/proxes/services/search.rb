require 'proxes/services/es'

# TODO: This needs to be filtered.

module ProxES
  module Services
    module Search
      class << self
        include ES

        def indices
          client.indices.get_mapping(index: '_all').keys
        end

        def fields(index: '_all', names_only: false)
          fields = {}
          client.indices.get_mapping(index: index).each do |_idx, index_map|
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
          result = client.search index: index, body: { size: 0, aggs: { values: { terms: { field: field, size: size } } } }
          result['aggregations']['values']['buckets'].map { |e| e['key'] }
        end

        def search(qs, options = {})
          client.search options.merge(q: qs) # , explain: true
        end
      end
    end
  end
end
