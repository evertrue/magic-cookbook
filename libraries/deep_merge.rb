require 'chef/mixin/deep_merge'

class Hash
  def deep_merge other
    Chef::Mixin::DeepMerge.deep_merge self, other
  end

  def deep_merge! other
    merge! deep_merge(other)
  end
end