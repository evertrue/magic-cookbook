require 'rubygems'
require 'bundler'
require 'rake'


def realm?
  `git ls-files` =~ /\bBerksfile\.lock\b/
end


def bump spec
  `bundle exec tony bump #{spec}`
  if realm?
    `bundle exec berks`
    `git add Berksfile.lock`
  end
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


desc 'Constrain an environment with the local locks'
task :constrain, [ :env ] do |_, args|
  if realm?
    `git tag -a #{args[:env]} -m #{args[:env]} --force`
    `git push --tag --force`
  end
end