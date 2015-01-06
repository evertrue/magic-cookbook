module Helpers
  def file_cache_path fp=nil
    if fp.nil?
      Chef::Config[:file_cache_path]
    else
      ::File.join Chef::Config[:file_cache_path], fp
    end
  end
end

class Chef
  class Recipe
    include Helpers
  end
end

class Chef
  class Resource
    include Helpers
  end
end