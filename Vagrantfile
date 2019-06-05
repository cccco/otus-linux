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
                # vagrant-vbguest - устанавливает VirtualBox Guest Additions, необходимые для автоматической синхронизации "virtualbox".
                # vagrant_reboot_linux - reboot capability implemention for linux guest vm.
                config.vagrant.plugins = ["vagrant-vbguest", "vagrant_reboot_linux"]
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
                        # Делаем первоначальные настройки
                        box.vm.provision "First configure", type: "shell", inline: <<-SHELL
                                echo "Edit Vagrantfile"
                                        sed -i '/config\.vbguest\.auto_update/s/#*c/c/' /vagrant/Vagrantfile
                                echo "Add records of /vagrant to fstab"
                                        modprobe vboxsf && echo 'vagrant /vagrant vboxsf uid=1000,gid=1000 0 0' >> /etc/fstab
                                echo "Copy ssh key"
                                        mkdir -p ~root/.ssh
                                        cp ~vagrant/.ssh/auth* ~root/.ssh
                                echo "Install packages"
                                        yum install -y mdadm smartmontools hdparm gdisk lvm2 xfsdump lsof
                        SHELL
                        # Отключаем SELinux
                        box.vm.provision "shell" do |selinux|
                                selinux.name = "Disable SELinux"
                                selinux.inline = <<-SHELL
                                        sed -i /SELINUX=e/s/enforcing/disabled/ /etc/selinux/config
                                SHELL
                                # This requires the guest to have a reboot capability implemented.
                                selinux.reboot = true
                        end
                        # Переносим root / на временный раздел
                        box.vm.provision "shell" do |temproot|
                                temproot.name = "Make temp root /"
                                temproot.inline = <<-SHELL
                                echo 'temproot: Save begin lsblk output'
                                        lsblk > /vagrant/lsblk_begin
                                echo 'temproot: Create physical volume for temp root /'
                                        pvcreate /dev/$(lsblk | grep 10G | awk '{print $1}')
                                echo 'temproot: Create volume group for temp root /'
                                        vgcreate vg_root /dev/$(lsblk | grep 10G | awk '{print $1}')
                                echo 'temproot: Create local volume for temp root /'
                                        lvcreate -l 100%FREE vg_root -n lv_root
                                echo 'temproot: Make file system for temp root /'
                                        mkfs.xfs /dev/vg_root/lv_root
                                echo 'temproot: Mount temp root /'
                                        mount /dev/vg_root/lv_root /mnt
                                echo 'temproot: Make dump data to temp root /'
                                        xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
                                SHELL
                        end
                        # Делаем chroot, обновляем конфиг grub и имидж initramfs для временного раздела
                        box.vm.provision "shell" do |grubcfgtmp|
                                grubcfgtmp.name = "Make config of grub and initramfs for temp root /"
                                grubcfgtmp.inline = <<-SHELL
                                echo 'grubcfgtmp: Mount virtual file systems for temp root /'
                                        for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
                                echo 'grubcfgtmp: Make script for chroot to temp root /'
                                        echo '#! /bin/sh' > /mnt/grubcfgtmp.sh
                                echo 'grubcfgtmp: Add edit fstab for temp root / command to script'
                                        echo "sed -i 's*/dev/mapper/VolGroup00-LogVol00*/dev/mapper/vg_root-lv_root*' /etc/fstab" >> /mnt/grubcfgtmp.sh
                                echo 'grubcfgtmp: Add edit /etc/default/grub for temp root / command to script'
                                        echo "sed -i 's*VolGroup00/LogVol00*vg_root/lv_root*' /etc/default/grub" >> /mnt/grubcfgtmp.sh
                                echo 'grubcfgtmp: Add update config of grub for temp root / command to script'
                                        echo 'grub2-mkconfig -o /boot/grub2/grub.cfg' >> /mnt/grubcfgtmp.sh
                                echo 'grubcfgtmp: Add update initramfs image for temp root / command to script'
                                        echo 'cd /boot; for i in `ls initramfs-*img`; do dracut -v $i `echo $i | sed "s/initramfs-//g; s/.img//g"` --force; done' >> /mnt/grubcfgtmp.sh
                                echo 'Exec script into chroot in temp root /'
                                        chmod +x /mnt/grubcfgtmp.sh
                                        chroot /mnt/ ./grubcfgtmp.sh
                                        rm /mnt/grubcfgtmp.sh
                                SHELL
                                grubcfgtmp.reboot = true
                        end
                        # Переносим root / на новый уменьшенный раздел
                        box.vm.provision "shell" do |newroot|
                                newroot.name = "Make new root /"
                                newroot.inline = <<-SHELL
                                echo 'newroot: Save temp lsblk output'
                                        lsblk > /vagrant/lsblk_temp
                                echo 'newroot: Remove old root /'
                                        yes| lvremove /dev/VolGroup00/LogVol00
                                echo 'newroot: Create local volume for new root /'
                                        yes| lvcreate -L8G /dev/VolGroup00 -n VolGroup00/LogVol00
                                echo 'newroot: Make file system for new root /'
                                        mkfs.xfs /dev/VolGroup00/LogVol00
                                echo 'newroot: Mount new root /'
                                        mount /dev/VolGroup00/LogVol00 /mnt
                                echo 'newroot: Make dump data to new root /'
                                        xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
                                SHELL
                        end
                        # Делаем chroot, обновляем конфиг grub и имидж initramfs для нового раздела
                        box.vm.provision "shell" do |grubcfgnew|
                                grubcfgnew.name = "Make config of grub and initramfs for new root /"
                                grubcfgnew.inline = <<-SHELL
                                echo 'grubcfgnew: Mount virtual file systems for new root /'
                                        for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
                                echo 'grubcfgnew: Make script for chroot to new root /'
                                        echo '#! /bin/sh' > /mnt/grubcfgnew.sh
                                echo 'grubcfgnew: Add edit fstab for new root / command to script'
                                        echo "sed -i 's*/dev/mapper/vg_root-lv_root*/dev/mapper/VolGroup00-LogVol00*' /etc/fstab" >> /mnt/grubcfgnew.sh
                                echo 'grubcfgnew: Add edit /etc/default/grub for new root / command to script'
                                        echo "sed -i 's*vg_root/lv_root*VolGroup00/LogVol00*' /etc/default/grub" >> /mnt/grubcfgnew.sh
                                echo 'grubcfgnew: Add update config of grub for new root / command to script'
                                        echo 'grub2-mkconfig -o /boot/grub2/grub.cfg' >> /mnt/grubcfgnew.sh
                                echo 'grubcfgnew: Add update initramfs image for new root / command to script'
                                        echo 'cd /boot; for i in `ls initramfs-*img`; do dracut -v $i `echo $i | sed "s/initramfs-//g; s/.img//g"` --force; done' >> /mnt/grubcfgnew.sh
                                echo 'Exec script into chroot in new root /'
                                        chmod +x /mnt/grubcfgnew.sh
                                        chroot /mnt/ ./grubcfgnew.sh
                                        rm /mnt/grubcfgnew.sh
                                SHELL
                        end
                        # Переносим /var на новый раздел
                        box.vm.provision "shell" do |newvar|
                                newvar.name = "Make new /var"
                                newvar.inline = <<-SHELL
                                echo 'grubcfgnew: Make script for chroot to new root / for /var'
                                        echo '#! /bin/sh' > /mnt/newvar.sh
                                echo 'newvar: Add create physical volumes for new /var command to script'
                                        echo 'for i in $(lsblk | grep "1G" | grep -v "part" | grep -v "lvm" | awk "{print \$1}"); do pvcreate /dev/$i; done' >> /mnt/newvar.sh
                                echo 'newvar: Add create volume group for new /var command to script'
                                        echo "vgcreate vg_var \`lsblk | grep 1G | grep -v 'part' | grep -v 'lvm' | awk '{ sum = sum\"/dev/\"\$1\" \"}; END { print sum }'\`" >> /mnt/newvar.sh
                                echo 'newvar: Add create local volume for new /var command to script'
                                        echo 'lvcreate -L 950M -m1 -n lv_var vg_var' >> /mnt/newvar.sh
                                echo 'newvar: Add make file system for new /var command to script'
                                        echo 'mkfs.ext4 /dev/vg_var/lv_var' >> /mnt/newvar.sh
                                echo 'newvar: Add mount new /var to /mnt command to script'
                                        echo 'mount /dev/vg_var/lv_var /mnt' >> /mnt/newvar.sh
                                echo 'newvar: Add make dump data to new /var command to script'
                                        echo 'rsync -avHPSAX /var/ /mnt/' >> /mnt/newvar.sh
                                echo 'newvar: Add make backup copy old /var command to script'
                                        echo 'mkdir /tmp/oldvar && mv /var/* /tmp/oldvar' >> /mnt/newvar.sh
                                echo 'newvar: Add unmount new /var from /mnt command to script'
                                        echo 'umount /mnt' >> /mnt/newvar.sh
                                echo 'newvar: Add mount new /var to /var command to script'
                                        echo 'mount /dev/vg_var/lv_var /var' >> /mnt/newvar.sh
                                echo 'newvar: Add add record about mounting new /var to fstab command to script'
                                        echo 'echo "`blkid | grep var: | cut -d\" \" -f2` /var ext4 defaults 0 0" >> /etc/fstab' >> /mnt/newvar.sh
                                echo 'Exec script into chroot in new root / for /var'
                                        chmod +x /mnt/newvar.sh
                                        chroot /mnt/ ./newvar.sh
                                        rm /mnt/newvar.sh
                                SHELL
                                newvar.reboot = true
                        end
                        # Удаляем временный root / раздел
                        box.vm.provision "shell" do |temprootdel|
                                temprootdel.name = "Remove temp root /"
                                temprootdel.inline = <<-SHELL
                                echo 'temprootdel: Remove local volume of temp root /'
                                        yes| lvremove /dev/vg_root/lv_root
                                echo 'temprootdel: Remove volume group of temp root /'
                                        vgremove /dev/vg_root
                                echo 'temprootdel: Remove physical volume of temp root /'
                                        pvremove /dev/$(lsblk | grep 10G | awk '{print $1}')
                                SHELL
                        end
                        # Переносим /home на новый раздел
                        box.vm.provision "shell" do |newhome|
                                newhome.name = "Make new /home"
                                newhome.inline = <<-SHELL
                                echo 'newhome: Create local volume for new /home'
                                        lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
                                echo 'newhome: Make file system for new /home'
                                        mkfs.xfs /dev/VolGroup00/LogVol_Home
                                echo 'newhome: Mount new /home to /mnt'
                                        mount /dev/VolGroup00/LogVol_Home /mnt/
                                echo 'newhome: Make dump data to new /home'
                                        cp -aR /home/* /mnt/
                                echo 'newhome: Remove data from old /home'
                                        rm -rf /home/*
                                echo 'newhome: Unmount new /home from /mnt'
                                        umount /mnt
                                echo 'newhome: Mount new /home to /home'
                                        mount /dev/VolGroup00/LogVol_Home /home/
                                echo 'newhome: Add record about mounting new /home to fstab'
                                        echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
                                echo 'newhome: Save end lsblk output'
                                        lsblk > /vagrant/lsblk_end
                                SHELL
                                newhome.reboot = true
                        end
                        # Генерация, удаление и восстановление файлов на разделе /home
                        box.vm.provision "shell" do |snaphome|
                                snaphome.name = "Working with /home snapshot"
                                snaphome.inline = <<-SHELL
                                echo 'snaphome: Create files on /home'
                                        touch /home/file{1..20}
                                echo 'snaphome: Inspect /home with created files'
                                        ls -l /home > /vagrant/ls_home_create
                                echo 'snaphome: Create snapshot local volume for /home'
                                        lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
                                echo 'snaphome: Remove part of files from /home'
                                        rm -f /home/file{11..20}
                                echo 'snaphome: Inspect /home with removed files'
                                        ls -l /home > /vagrant/ls_home_remove
                                echo 'snaphome: Unmount /home'
                                        lsof +D /home
                                        cd
                                        lsof +D /home
                                        for pid in `lsof +D /home | grep -v PID | awk '{print $2}'`; do kill -9 $pid; done
                                        umount -f /home
                                echo 'snaphome: Recover deleted files on /home'
                                        lvconvert --merge /dev/VolGroup00/home_snap
                                echo 'snaphome: Mount /home'
                                        mount /home
                                echo 'snaphome: Inspect /home with recovered files'
                                        ls -l /home > /vagrant/ls_home_recover
                                SHELL
                        end
                end
        end
end

