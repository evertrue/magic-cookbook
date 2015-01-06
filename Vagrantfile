#!/usr/bin/env ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure('2') do |config|
  config.omnibus.chef_version = '11.16.4'
  config.berkshelf.enabled = true
  config.vm.define 'vagrant' do |node|
    node.vm.box = 'chef/ubuntu-14.04'
    node.vm.hostname = 'vagrant'
    node.vm.provision :chef_solo do |chef|
      chef.log_level = :debug
      chef.json = {}
      chef.run_list = %w(
        recipe[apt]
        recipe[magic::test]
      )
    end
  end
end