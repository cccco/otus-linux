# Задание №03

## Работа с LVM

### Делаем первоначальные настройки (от пользователя root)
```bash
# Переключаемся на пользователя root
        sudo su
# Редактируем Vagrantfile. Решаем проблему: "GuestAdditions seems to be installed (6.0.6) correctly, but not running." (https://github.com/dotless-de/vagrant-vbguest/issues/335)
        sed -i '/config\.vbguest\.auto_update/s/#*c/c/' /vagrant/Vagrantfile
# Добавляем информацию о монтировании /vagrant в файл fstab. Решаем проблему монтирования /vagrant после 'shutdown -r now' в виртуалке.
        modprobe vboxsf && echo 'vagrant /vagrant vboxsf uid=1000,gid=1000 0 0' >> /etc/fstab
# Копируем ключ
        mkdir -p ~root/.ssh
        cp ~vagrant/.ssh/auth* ~root/.ssh
# Устанавливаем необходимые пакеты
        yum install -y mdadm smartmontools hdparm gdisk
```

### Отключаем SELinux и перегружаем систему (от пользователя root)
```bash
# Правим конфиг SELinux
        sed -i /SELINUX=e/s/enforcing/disabled/ /etc/selinux/config
# Перегружаемся
        shutdown -r now
```

### Перенос root / на временный уменьшенный раздел (от пользователя root)
```bash
# Переключаемся на пользователя root
        sudo su
# Сохраняем вывод команды lsblk до переноса системы на уменьшенный раздел
        lsblk > /vagrant/lsblk_begin
# Создаём physical volume для временного уменьшенного системного раздела
        pvcreate /dev/$(lsblk | grep 10G | awk '{print $1}')
# Создаём volume group для временного уменьшенного системного раздела
        vgcreate vg_root /dev/$(lsblk | grep 10G | awk '{print $1}')
# Создаём local volume для временного уменьшенного системного раздела
        lvcreate -l 100%FREE vg_root -n lv_root
# Создаём файловую систему на local volume временного уменьшенного системного раздела
        mkfs.xfs /dev/vg_root/lv_root
# Монтируем файловую систему временного уменьшенного системного раздела в папку /mnt
        mount /dev/vg_root/lv_root /mnt
# Копируем систему на временный уменьшенный раздел
        xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
```

### Делаем chroot, обновляем конфиг grub и имидж initramfs для временного раздела, перегружаемся во временную систему (от пользователя root)
```bash
# Монтируем необходимые файловый системы
        for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
# Делаем chroot во временную систему
        chroot /mnt/
# Редактируем fstab для монтирования в / временного уменьшенного раздела
        sed -i 's*/dev/mapper/VolGroup00-LogVol00*/dev/mapper/vg_root-lv_root*' /etc/fstab
# Редактируем файл настроек grub, чтобы при загрузке выбирался временный корневой раздел
        sed -i 's*VolGroup00/LogVol00*vg_root/lv_root*' /etc/default/grub
# Обновляем конфиг grub с новыми настройками
        grub2-mkconfig -o /boot/grub2/grub.cfg
# Обновляем имидж initramfs
        cd /boot; for i in `ls initramfs-*img`; do dracut -v $i `echo $i | sed "s/initramfs-//g; s/.img//g"` --force; done
# Перегружаемся во временную систему
        shutdown -r now
```

### Переносим root / на новый уменьшенный раздел (от пользователя root)
```bash
# Переключаемся на пользователя root
        sudo su
# Сохраняем вывод команды lsblk после переноса системы на временный уменьшенный раздел
        lsblk > /vagrant/lsblk_temp
# Удаляем старый большой системный раздел
        yes| lvremove /dev/VolGroup00/LogVol00
# Создаём local volume для нового уменьшенного системного раздела
        yes| lvcreate -L8G /dev/VolGroup00 -n VolGroup00/LogVol00
# Создаём файловую систему на local volume нового уменьшенного системного раздела
        mkfs.xfs /dev/VolGroup00/LogVol00
# Монтируем файловую систему нового уменьшенного системного раздела в папку /mnt
        mount /dev/VolGroup00/LogVol00 /mnt
# Копируем систему на новый уменьшенный раздел
        xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
```

### Делаем chroot, обновляем конфиг grub и имидж initramfs для нового уменьшенного системного раздела (от пользователя root)
```bash
# Монтируем необходимые файловый системы
        for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
# Делаем chroot в новую систему
        chroot /mnt/
# Редактируем fstab для монтирования в / нового уменьшенного раздела
        sed -i 's*/dev/mapper/vg_root-lv_root*/dev/mapper/VolGroup00-LogVol00*' /etc/fstab
# Редактируем файл настроек grub, чтобы при загрузке выбирался новый корневой раздел
        sed -i 's*vg_root/lv_root*VolGroup00/LogVol00*' /etc/default/grub
# Обновляем конфиг grub с новыми настройками
        grub2-mkconfig -o /boot/grub2/grub.cfg
# Обновляем имидж initramfs
        cd /boot; for i in `ls initramfs-*img`; do dracut -v $i `echo $i | sed "s/initramfs-//g; s/.img//g"` --force; done
```

### Переносим /var на новый раздел и перегружаемся в новую уменьшенную систему (от пользователя root)
```bash
# Создаём physical volumes для нового раздела /var
        for i in $(lsblk | grep "1G" | grep -v "part" | grep -v "lvm" | awk "{print \$1}"); do pvcreate /dev/$i; done
# Создаём volume group для нового раздела /var
        vgcreate vg_var \`lsblk | grep 1G | grep -v 'part' | grep -v 'lvm' | awk '{ sum = sum\"/dev/\"\$1\" \"}; END { print sum }'\`
# Создаём local volume для нового раздела /var
        lvcreate -L 950M -m1 -n lv_var vg_var
# Создаём файловую систему на новом разделе /var
        mkfs.ext4 /dev/vg_var/lv_var
# Монтируем новую файловую систему /var в /mnt
        mount /dev/vg_var/lv_var /mnt
# Переносим данные со старого раздела /var на новый раздел /var
        rsync -avHPSAX /var/ /mnt/
# Создаём директорию для бекапа старого раздела /var и переносим туда старый раздел /var
        mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
# Отмантируем новый раздел /var от временной папки /mnt
        umount /mnt
# Монтируем новый раздел /var в папку /var
        mount /dev/vg_var/lv_var /var
# Добавляем в fstab монтирование раздела /var при загрузки системы
        echo "`blkid | grep var: | cut -d\" \" -f2` /var ext4 defaults 0 0" >> /etc/fstab
# Перегружаемся во временную систему
        shutdown -r now
```

### Удаляем временный root / раздел (от пользователя root)
```bash
# Переключаемся на пользователя root
        sudo su
# Удаляем local volume временного root /
        yes| lvremove /dev/vg_root/lv_root
# Удаляем volume group временного root /
        vgremove /dev/vg_root
# Удаляем physical volume временного root /
        pvremove /dev/$(lsblk | grep 10G | awk '{print $1}')
```

### Переносим /home на новый раздел (от пользователя root)
```bash
# Создаём local volume для нового раздела /home
        lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
# Создаём файловую систему на новом разделе /home
        mkfs.xfs /dev/VolGroup00/LogVol_Home
# Монтируем новый раздел /home в папку /mnt
        mount /dev/VolGroup00/LogVol_Home /mnt/
# Переносим данные из старой папки /home на новый раздел
        cp -aR /home/* /mnt/
# Удаляем данные со старой папки /home
        rm -rf /home/*
# Отмантируем новый раздел /home от временной папки /mnt
        umount /mnt
# Монтируем новый раздел /home в папку /home
        mount /dev/VolGroup00/LogVol_Home /home/
# Добавляем запись в fstab о мортировании нового раздела /home
        echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
# Сохраняем вывод команды lsblk после переноса системы на новый уменьшенный раздел, /var и /home на новые разделы
        lsblk > /vagrant/lsblk_end
```

### Генерация, удаление и восстановление файлов на разделе /home (от пользователя root)
```bash
# Создаём файлы в папке /home
        touch /home/file{1..20}
# Сохраняем вывод команды `ls /home` после создания файлов
        ls -l /home > /vagrant/ls_home_create
# Создаём snapshot local volume с папкой /home
        lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
# Удаляем часть созданных файлов из папки /home
        rm -f /home/file{11..20}
# Сохраняем вывод команды `ls /home` после удаления части файлов
        ls -l /home > /vagrant/ls_home_remove
# Отмонтируем раздел /home. Предварительно узнав, какие процессы удерживают файлы на разделе /home, и убив эти процессы.
        lsof +D /home
        cd
        lsof +D /home
        for pid in `lsof +D /home | grep -v PID | awk '{print $2}'`; do kill -9 $pid; done
        umount -f /home
# Восстанавливаем удалённые фалы, восстановив раздел с папкой /home из snapshot local volume
        lvconvert --merge /dev/VolGroup00/home_snap
# Монтируем раздел /home в папку /home
        mount /home
# Сохраняем вывод команды `ls /home` после восстановления удалённых файлов
        ls -l /home > /vagrant/ls_home_recover
```

## Файлы

* [lsblk_begin](lsblk_begin) - вывод команды `lsblk` до переноса системы на уменьшенный раздел;
* [lsblk_temp](lsblk_temp) - вывод команды `lsblk` после переноса системы на временный раздел.
* [lsblk_end](lsblk_end) - вывод команды `lsblk` после переноса системы на уменьшенный раздел, /var - на lvm-зеркало, /home - на новый раздел;
* [ls_home_create](ls_home_create) - вывод команды `ls /home` после после создания файлов.
* [ls_home_remove](ls_home_remove) - вывод команды `ls /home` после удаления части файлов;
* [ls_home_recover](ls_home_recover) - вывод команды `ls /home` после восстановления удалённых файлов.


