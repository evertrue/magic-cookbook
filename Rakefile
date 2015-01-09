require 'rubygems'
require 'bundler'
require 'rake'


def bump spec
  `bundle exec tony bump #{spec}`
  version = File.read('VERSION').strip
  `git add VERSION`
  `git commit -m "Version bump to #{version}"`
  `git tag -a v#{version} -m v#{version}`
  raise 'Could not add tag' unless $?.exitstatus.zero?
  puts 'Version is now "%s"' % version
end


namespace :version do
  namespace :bump do
    desc 'Bump major component of VERSION'
    task :major do
      bump :major
    end

    desc 'Bump minor component of VERSION'
    task :minor do
      bump :minor
    end

    task :patch do
      bump :patch
    end
  end

  desc 'Bump patch component of VERSION'
  task :bump => %w[ bump:patch ]
end


desc 'Tag and release a new version'
task :release do
  `git push`
  raise 'Push failed' unless $?.exitstatus.zero?
  `git push --tag`
  raise 'Tag push failed' unless $?.exitstatus.zero?
end