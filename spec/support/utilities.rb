def es_fixture(name)
  File.read("spec/fixtures/es/#{name}.json")
end

def stub_es(method, path)
  fixture = "#{method.to_s.upcase}#{path.gsub('/', '_')}"
  stub_request(method, "http://test.cluster:9200#{path}").
    to_return(body: es_fixture(fixture), headers: {'Content-Type' => 'application/json; charset=UTF-8' })
end
