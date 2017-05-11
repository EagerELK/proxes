module ProxES
  class Container
    class ContainerError < StandardError; end

    # A thread safe cache class, offering only #[] and #[]= methods,
    # each protected by a mutex.
    # Ripped off from Roda - https://github.com/jeremyevans/roda
    class PluginCache
      # Create a new thread safe cache.
      def initialize
        @mutex = Mutex.new
        @hash = {}
      end

      # Make getting value from underlying hash thread safe.
      def [](key)
        @mutex.synchronize { @hash[key] }
      end

      # Make setting value in underlying hash thread safe.
      def []=(key, value)
        @mutex.synchronize { @hash[key] = value }
      end

      def map(&block)
        @mutex.synchronize { @hash.map(&block) }
      end

      def inject(memo, &block)
        @mutex.synchronize { @hash.inject(memo, &block) }
      end
    end

    # Ripped off from Roda - https://github.com/jeremyevans/roda
    module Plugins
      # Stores registered plugins
      @plugins = PluginCache.new

      # If the registered plugin already exists, use it.  Otherwise,
      # require it and return it.  This raises a LoadError if such a
      # plugin doesn't exist, or a ContainerError if it exists but it does
      # not register itself correctly.
      def self.load_plugin(name)
        h = @plugins
        unless plugin = h[name]
          require "proxes/plugins/#{name}"
          raise ContainerError, "Plugin #{name} did not register itself correctly in ProxES::Container::Plugins" unless plugin = h[name]
        end
        plugin
      end

      # Register the given plugin with Container, so that it can be loaded using #plugin
      # with a symbol.  Should be used by plugin files. Example:
      #
      #   ProxES::Container::Plugins.register_plugin(:plugin_name, PluginModule)
      def self.register_plugin(name, mod)
        @plugins[name] = mod
      end

      def self.plugins
        @plugins
      end

      module Base
        module ClassMethods
          # Load a new plugin into the current class.  A plugin can be a module
          # which is used directly, or a symbol represented a registered plugin
          # which will be required and then used. Returns nil.
          #
          #   Container.plugin PluginModule
          #   Container.plugin :csrf
          def plugin(plugin, *args, &block)
            raise ContainerError, 'Cannot add a plugin to a frozen Container class' if frozen?
            plugin = Plugins.load_plugin(plugin) if plugin.is_a?(Symbol)
            plugin.load_dependencies(self, *args, &block) if plugin.respond_to?(:load_dependencies)
            include(plugin::InstanceMethods) if defined?(plugin::InstanceMethods)
            extend(plugin::ClassMethods) if defined?(plugin::ClassMethods)
            plugin.configure(self, *args, &block) if plugin.respond_to?(:configure)

            # One option is to add controllers / nav on registration:
            @controllers.merge(plugin.controllers) if plugin.respond_to?(:controllers)
            @navigation << plugin.navigation if plugin.respond_to?(:navigation)

            nil
          end

          # Return a hash of controllers with their routes as keys: `{ '/users' => ProxES::Controllers::Users }`
          def routes
            Plugins.plugins.inject({}) do |memo, plugin|
              memo.merge!(plugin[1].route_mappings) if plugin[1].respond_to?(:route_mappings)
            end
          end

          # Return an ordered list of navigation items:
          # `[{order:0, link:'/users/', text:'Users'}, {order:1, link:'/roles/', text:'Roles'}]
          def navigation
            Plugins.plugins.map do |_key, plugin|
              plugin.nav_items if plugin.respond_to?(:nav_items)
            end.compact.flatten.sort_by { |h| h[:order] }
          end

          def migrations
            Plugins.plugins.map do |_key, plugin|
              plugin.migration_folder if plugin.respond_to?(:migration_folder)
            end.compact
          end

          def seeders
            Plugins.plugins.map do |_key, plugin|
              plugin.seeder if plugin.respond_to?(:seeder)
            end.compact
          end

          def workers
            Plugins.plugins.map do |_key, plugin|
              plugin.run_workers if plugin.respond_to?(:run_workers)
            end.compact
          end
        end

        module InstanceMethods
        end
      end
    end

    extend Plugins::Base::ClassMethods
    plugin Plugins::Base
  end
end
