# encoding: utf-8
# vim: ft=ruby expandtab shiftwidth=2 tabstop=2

require 'yaml'

Vagrant.require_version '>= 1.8.6'

Vagrant.configure(2) do |config|

  vccw_version = '3.18.0';

  _conf = YAML.load(
    File.open(
      File.join(File.dirname(__FILE__), 'default.yml'),
      File::RDONLY
    ).read
  )

  # forcing config variables
  _conf["vagrant_dir"] = "/vagrant"

  config.vm.define _conf['hostname'] do |v|
  end

  config.vm.box = ENV['box'] || _conf['box']
  config.ssh.forward_agent = true

  config.vm.box_check_update = true

  config.vm.hostname = _conf['hostname']
  config.vm.network :private_network, ip: _conf['ip']

  config.vm.synced_folder _conf['synced_folder'],
      _conf['document_root'], :create => "true", :owner => 'www-data', :mount_options => ['dmode=755', 'fmode=644']

  if Vagrant.has_plugin?('vagrant-hostsupdater')
    config.hostsupdater.remove_on_suspend = true
  end

  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = false
  end

  config.vm.provider :virtualbox do |vb|
    vb.linked_clone = _conf['linked_clone']
    vb.name = _conf['hostname']
    vb.memory = _conf['memory'].to_i
    vb.cpus = _conf['cpus'].to_i
    if 1 < _conf['cpus'].to_i
      vb.customize ['modifyvm', :id, '--ioapic', 'on']
    end
    vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    vb.customize ['setextradata', :id, 'VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled', 0]
  end

  config.vm.provision :shell, :path => "provision.sh"

end
