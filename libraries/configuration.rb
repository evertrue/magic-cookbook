module Configuration
  require 'shellwords'
  require 'yaml'
  require 'json'
  require 'erb'

  def desymbol obj
    if obj.is_a? Hash
      Hash[
        obj.map do |k,v|
          [ k.to_s, desymbol(v) ]
        end
      ]
    elsif obj.is_a? Array
      obj.map { |i| desymbol i }
    elsif obj.is_a? Symbol
      obj.to_s
    else
      obj
    end
  end

  def deep_hash obj
    obj.inject({}) do |h, (k,v)|
      h[k] = v.kind_of?(Hash) ? deep_hash(v) : v ; h
    end
  end

  def inline_config obj
    obj['lines'].join("\n") + "\n"
  end

  def yaml_config obj
    deep_hash(obj).to_yaml.strip
  end

  def hocon_config obj
    begin
      ::Hocon
    rescue NameError # Cute trick to install the gem at runtime
      r = Chef::Resource::ChefGem.new 'hocon', run_context
      r.run_action :install
      require 'hocon/config_value_factory'
    end
    ::Hocon::ConfigValueFactory.from_map(desymbol(obj)).render
  end

  def properties_config obj
    begin
      ::JavaProperties
    rescue NameError # Cute trick to install the gem at runtime
      r = Chef::Resource::ChefGem.new 'java-properties', run_context
      r.run_action :install
      require 'java-properties'
    end
    ::JavaProperties.generate obj
  end

  def json_config obj
    ::JSON.pretty_generate obj
  end

  def exports_raw_config obj
    obj.map do |k, v|
      "export #{k}=#{Shellwords.escape v.to_s}"
    end.join("\n")
  end

  def exports_config obj
    obj.map do |k, v|
      "export #{k}=#{Shellwords.escape v.to_s}"
    end.join("\n")
  end

  def toml_config obj
    begin
      ::TOML
    rescue NameError # Cute trick to install the gem at runtime
      r = Chef::Resource::ChefGem.new 'toml', run_context
      r.run_action :install
      require 'toml'
    end
    TOML::Generator.new(obj).body
  end

  def ini_config obj
    obj.map do |name, config|
      "[#{name}]\n" + \
      config.map do |k, v|
        "#{k}=#{v}"
      end.join("\n")
    end.join("\n\n")
  end

  def java_config obj, l=0
    if obj.is_a? Hash
      result = []
      len = obj.keys.length
      obj.keys.each_with_index do |k,i|
        v = obj[k]
        r = if v.is_a? Hash
          "#{'  '*l}#{k} {\n#{java_config(v, l+1)}\n#{'  '*l}}\n"
        else
          "#{'  '*l}#{k} = #{java_config(v)}"
        end
        r.rstrip! if i == len - 1
        result << r
      end
      result.join("\n")

    elsif obj.is_a? Array
      objs = obj.map { |o| java_config(o, l+1) }
      '[ %s ]' % objs.join(', ')

    elsif obj.is_a? Symbol
      obj.to_s

    else
      obj.inspect
    end
  end

  def quote_logstash obj
    case obj.class.to_s
    when /Array/
      '[ %s ]' % obj.map { |c| quote_logstash c }.join(', ')
    when /Regexp/
      "'%s'" % obj.to_s
    when /Symbol/
      obj.to_s
    when /TrueClass/
      'true'
    when /FalseClass/
      'false'
    else
      obj.inspect.gsub('\\\\', '\\')
    end
  end
end

class Chef
  class Recipe
    include Configuration
  end
end

class Chef
  class Resource
    include Configuration
  end
end
