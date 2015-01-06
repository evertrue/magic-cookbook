module Reification
  def reify resource, spec, notifications=[], actions=[]
    spec = ::Mash.new(spec.to_hash)
    name = spec.delete 'name'
    send resource.to_sym, name do
      spec.each do |k, v|
        send k.to_sym, v
      end
      notifications.each do |notify_spec|
        raise 'Not a valid notification spec' unless notify_spec.is_a?(Array)
        notify_action   = notify_spec.shift.to_sym
        notify_resource = notify_spec.shift
        notify_timing   = notify_spec.shift || :delayed
        send :notifies, \
          notify_action, notify_resource, notify_timing
      end
      actions = [ actions ] unless actions.is_a?(Array)
      actions.each do |action|
        send :action, action.to_sym
      end
    end
  end

  def reify_packages packages
    packages.to_hash.each do |name, spec|
      package name do
        spec.each do |k, v|
          send k.to_sym, v
        end
      end if spec
    end
  end
end

class Chef
  class Recipe
    include Reification
  end
end

class Chef
  class Resource
    include Reification
  end
end