# -*- mode: ruby -*-
# vim: set ft=ruby :

BOX_RAM_MB = "4096"
BOX_CPU_COUNT = "4"
MACHINES = {
        :otuslinux => {
                :box_name => "centos/7",
        },
}

Vagrant.configure("2") do |config|
        MACHINES.each do |boxname, boxconfig|
                config.vm.define boxname do |box|
                        box.vm.box = boxconfig[:box_name]
                        box.vm.host_name = boxname.to_s
                        box.vm.provider :virtualbox do |vb|
                                vb.customize ["modifyvm", :id, "--memory", BOX_RAM_MB]
                                vb.customize ["modifyvm", :id, "--cpus", BOX_CPU_COUNT]
                        end
                        box.vm.provision "shell", inline: <<-SHELL
                                mkdir -p ~root/.ssh
                                cp ~vagrant/.ssh/auth* ~root/.ssh
                                yum install -y rpm-build elfutils-libelf-devel ncurses-devel make gcc bc openssl-devel wget bison flex
                        SHELL

                end
        end
end

