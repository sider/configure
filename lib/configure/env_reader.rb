module Configure
  module EnvReader
    def attr_env_reader(name, env_name)
      define_method(name) do
        env[env_name.to_s]&.strip.yield_self do |value|
          if value
            value.empty? ? nil : value
          end
        end
      end

      define_method(:"#{name}!") do
        __send__(name) or raise Error.new("Expected value for #{env_name}")
      end
    end
  end
end
