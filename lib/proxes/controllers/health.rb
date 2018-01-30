# require 'proxes/base'
# require 'rspec'
# require 'rspec/core/formatters/json_formatter'
# require 'json'

# module ProxES
#   class App < Base
#     plugin :multi_route

#     route 'health' do |r|
#       r.get do
#         RSpec.world.wants_to_quit = false
#         config = RSpec.configuration

#         formatter = RSpec::Core::Formatters::JsonFormatter.new(config.output_stream)

#         # create reporter with json formatter
#         reporter =  RSpec::Core::Reporter.new(config)
#         config.instance_variable_set(:@reporter, reporter)

#         # internal hack
#         # api may not be stable, make sure lock down Rspec version
#         loader = config.send(:formatter_loader)
#         notifications = loader.send(:notifications_for, RSpec::Core::Formatters::JsonFormatter)

#         reporter.register_listener(formatter, *notifications)

#         RSpec::Core::Runner.run(['proxes/lib/proxes/check_spec.rb'])

#         locals = {
#           title: 'Health Check',
#           result: formatter.output_hash,
#         }

#         RSpec.clear_examples
#         RSpec.world.wants_to_quit = true

#         view 'health/check', locals: locals, layout_opts: { locals: locals }
#       end
#     end
#   end
# end
