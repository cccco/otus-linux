# -*- mode: ruby -*-
# vim: set ft=ruby :

HOME = ENV['HOME'] # Используем глобальную переменную $HOME

MACHINES = {
        :otuslinux => {
                :box_name => "centos/7",
                :ip_addr => '192.168.11.101',
                :ram_mb => "4096",
                :cpu_count => "4",
                :disks => {
                        :scsi1 => {
                                :dfile => HOME + '/VirtualBox VMs/scsi1.vmdk',
                                :size => 8192, # Megabytes
                                :port => 1 # начинаем с 1 порта, т.к. 0 порт - scsi контроллер
                        },
                        :scsi2 => {
                                :dfile => HOME + '/VirtualBox VMs/scsi2.vmdk',
                                :size => 8192, # Megabytes
                                :port => 2
                        },
                        :scsi3 => {
                                :dfile => HOME + '/VirtualBox VMs/scsi3.vmdk',
                                :size => 8192, # Megabytes
                                :port => 3
                        },
                        :scsi4 => {
                                :dfile => HOME + '/VirtualBox VMs/scsi4.vmdk',
                                :size => 8192, # Megabytes
                                :port => 4
                        },
                        :scsi5 => {
                                :dfile => HOME + '/VirtualBox VMs/scsi5.vmdk',
                                :size => 8192, # Megabytes
                                :port => 5
                        },
                },
        },
}

Vagrant.configure("2") do |config|
        MACHINES.each do |boxname, boxconfig|
                # В боксе "centos/7" (v1901.01) применяется синхронизация папок "rsinc", поэтому в боксе не установлены VirtualBox Guest Additions,
                # которые требуются для автоматической синхронизации "virtualbox" (https://blog.centos.org/2019/02/updated-centos-vagrant-images-available-v1901-01/).
                # Настроить автоматическую синхронизацию можно 3-мя способами:

                # 1. Устанавливаем VirtualBox Guest Additions через локальную установку плагина "vagrant-vbguest" для автоматической синхронизации "virtualbox".
                config.vagrant.plugins = "vagrant-vbguest"
                config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
                # Решаем проблему: "GuestAdditions seems to be installed (6.0.6) correctly, but not running." (https://github.com/dotless-de/vagrant-vbguest/issues/335)
                #config.vbguest.auto_update = false
                config.trigger.after :destroy do |t|
                        t.info = "Edit Vagrantfile"
                        # Вариант sed для macOS. Для GNU нужно убрать '' после -i
                        t.run = {inline: "sed -i '' '/config\.vbguest\.auto_update/s/#*c/\#c/' Vagrantfile"}
                end
                
                # 2. Автоматическая синхронизация "nfs". Не нужно ставить плагин, но постоянно требует ввести на macOS root-пароль при старте/стопе виртуалки.
                #config.vm.synced_folder ".", "/vagrant", type: "nfs"

                config.vm.define boxname do |box|
                        box.vm.box = boxconfig[:box_name]
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
=begin
                        # 3. Устанавливаем VirtualBox Guest Additions самостоятельно в виртуалке для автоматической синхронизации "virtualbox". Не сработало!
                        box.trigger.after :provisioner_run, type: :hook do |t| # Почему-то триггер не запускается при разворачивании виртуалки.
                                t.info = "Reboot after provisioning"
                                t.run = {inline: "vagrant reload"} # Тут также надо добавить в Vagranfile строку: config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
                        end
                        box.vm.provision "shell" do |s|
                                s.name = "Install VirtualBox Guest Additions"
                                s.inline = <<-SHELL
                                        yum install -y gcc make perl wget
                                        yum install -y kernel-devel-$(uname -r)
                                        VB_VERSION=$(curl -s http://download.virtualbox.org/virtualbox/LATEST-STABLE.TXT | cat -)
                                        wget -q http://download.virtualbox.org/virtualbox/$VB_VERSION/VBoxGuestAdditions_$VB_VERSION.iso
                                        mount -o loop ./VBoxGuestAdditions_$VB_VERSION.iso /mnt
                                        yes|sh /mnt/VBoxLinuxAdditions.run
                                        umount /mnt
                                        rm ./VBoxGuestAdditions_$VB_VERSION.iso
                                        yum remove -y kernel-devel-$(uname -r)
                                        yum remove -y gcc make perl
                                SHELL
                                #s.reboot = true
                        end
=end
                        box.vm.provision "Configure RAID", type: "shell", inline: <<-SHELL
                                echo "Edit Vagrantfile"
                                        sed -i '/config\.vbguest\.auto_update/s/#*c/c/' /vagrant/Vagrantfile
                                echo "Add records of /vagrant to fstab"
                                        modprobe vboxsf && echo 'vagrant /vagrant vboxsf uid=1000,gid=1000 0 0' >> /etc/fstab
                                echo "Copy ssh key"
                                        mkdir -p ~root/.ssh
                                        cp ~vagrant/.ssh/auth* ~root/.ssh
                                echo "Install packages"
                                        yum install -y mdadm smartmontools hdparm gdisk
                                echo "Erase superblock"
                                        mdadm --zero-superblock --force /dev/sd{b,c,d,e}
                                echo "Create RAID-10"
                                        mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}
                                echo "Save RAID config"
                                        mkdir -p /etc/mdadm
                                        echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
                                        mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
                                echo "Make patition table"
                                        parted -s /dev/md0 mklabel gpt
                                echo "Make 5 patitions"
                                        parted -a none /dev/md0 mkpart primary xfs 0% 2%
                                        parted -a none /dev/md0 mkpart primary xfs 2% 52%
                                        parted -a none /dev/md0 mkpart primary xfs 52% 68%
                                        parted -a none /dev/md0 mkpart primary xfs 68% 84%
                                        parted -a none /dev/md0 mkpart primary xfs 84% 100%
                                echo "Make FS on 5 patitions"
                                        for i in $(seq 1 5); do mkfs.xfs -f /dev/md0p$i; done
                                echo "Make 5 mount points"
                                        mkdir -p /raid/part{1,2,3,4,5}
                                echo "Mount patitions to mount points"
                                        for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done
                                echo "Add records of patitions to fstab"
                                        for i in $(seq 1 5); do blkid /dev/md0p$i | sed -e 's/"//g; s/TYPE=//' | awk -v i=/raid/part$i '{ print $2, i, $3, "defaults 0 0" }' >> /etc/fstab; done
                        SHELL
                end
        end
end

