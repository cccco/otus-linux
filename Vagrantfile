# -*- mode: ruby -*-
# vim: set ft=ruby :

HOME = ENV['HOME'] # Используем глобальную переменную $HOME

MACHINES = {
        :otuslinux => {
                :box_name => "centos/7",
                :version => "1804.2",
                :ip_addr => '192.168.11.101',
                :ram_mb => "4096",
                :cpu_count => "4",
                :disks => {
                        :scsi0 => {
                                :dfile => HOME + '/VirtualBox VMs/otus-linux/scsi-0.vmdk',
                                :size => 10240, # Megabytes
                                :port => 0
                        },
                        :scsi1 => {
                                :dfile => HOME + '/VirtualBox VMs/otus-linux/scsi-1.vmdk',
                                :size => 2048, # Megabytes
                                :port => 1
                        },
                        :scsi2 => {
                                :dfile => HOME + '/VirtualBox VMs/otus-linux/scsi-2.vmdk',
                                :size => 1024, # Megabytes
                                :port => 2
                        },
                        :scsi3 => {
                                :dfile => HOME + '/VirtualBox VMs/otus-linux/scsi-3.vmdk',
                                :size => 1024, # Megabytes
                                :port => 3
                        },
                },
        },
}

Vagrant.configure("2") do |config|
        MACHINES.each do |boxname, boxconfig|
                # Устанавливаем VirtualBox Guest Additions через локальную установку плагина "vagrant-vbguest" для автоматической синхронизации "virtualbox".
                config.vagrant.plugins = "vagrant-vbguest"
                config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
                # Решаем проблему: "GuestAdditions seems to be installed (6.0.6) correctly, but not running." (https://github.com/dotless-de/vagrant-vbguest/issues/335)
                #config.vbguest.auto_update = false
                config.trigger.after :destroy do |t|
                        t.info = "Edit Vagrantfile"
                        # Вариант sed для macOS: после -i. Для GNU нужно убрать '' после -i
                        t.run = {inline: "sed -i '/config\.vbguest\.auto_update/s/#*c/\#c/' Vagrantfile"}
                end
                
                config.vm.define boxname do |box|
                        box.vm.box = boxconfig[:box_name]
                        box.vm.box_version = boxconfig[:version]
                        box.vm.host_name = boxname.to_s
                        box.vm.network "private_network", ip: boxconfig[:ip_addr]
                        box.vm.provider :virtualbox do |vb|
                                vb.name = boxname.to_s
                                vb.customize ["modifyvm", :id, "--memory", boxconfig[:ram_mb]]
                                vb.customize ["modifyvm", :id, "--cpus", boxconfig[:cpu_count]]

                                needsController = false

                                boxconfig[:disks].each do |dname, dconf|
                                        unless File.exist?(dconf[:dfile])
                                                vb.customize ['createhd', '--format', 'VMDK', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                                                needsController =  true
                                        end
                                end
                                if needsController == true
                                        vb.customize ["storagectl", :id, "--name", "SCSI", "--add", "scsi" ]
                                        boxconfig[:disks].each do |dname, dconf|
                                                vb.customize ['storageattach', :id,  '--storagectl', 'SCSI', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                                        end
                                end
                        end
                        box.vm.provision "Configure RAID", type: "shell", inline: <<-SHELL
                                echo "Edit Vagrantfile"
                                        sed -i '/config\.vbguest\.auto_update/s/#*c/c/' /vagrant/Vagrantfile
                                echo "Add records of /vagrant to fstab"
                                        modprobe vboxsf && echo 'vagrant /vagrant vboxsf uid=1000,gid=1000 0 0' >> /etc/fstab
                                echo "Copy ssh key"
                                        mkdir -p ~root/.ssh
                                        cp ~vagrant/.ssh/auth* ~root/.ssh
                                echo "Install packages"
                                        yum install -y mdadm smartmontools hdparm gdisk lvm2
                        SHELL
                end
        end
end

