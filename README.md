# Задание №02

## Создание рейда, новых разделов на нём и монтирование этих разделов

```bash
# Редактируем Vagrantfile. Решаем проблему: "GuestAdditions seems to be installed (6.0.6) correctly, but not running." (https://github.com/dotless-de/vagrant-vbguest/issues/335)
        sed -i '/config\.vbguest\.auto_update/s/#*c/c/' /vagrant/Vagrantfile
# Добавляем информацию о монтировании /vagrant в файл fstab. Решаем проблему монтирования /vagrant после 'shutdown -r now' в виртуалке.
        modprobe vboxsf && echo 'vagrant /vagrant vboxsf uid=1000,gid=1000 0 0' >> /etc/fstab
# Копируем ключ
        mkdir -p ~root/.ssh
        cp ~vagrant/.ssh/auth* ~root/.ssh
# Устанавливаем необходимые пакеты
        yum install -y mdadm smartmontools hdparm gdisk
# Зануляем суперблок у новых дисков
        mdadm --zero-superblock --force /dev/sd{b,c,d,e}
# Создаём RAID-10
        mdadm --create --verbose /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}
# Сохраняем конфиг рейда
        mkdir -p /etc/mdadm
        echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
        mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
# Создаём таблицу разделов gpt на рейде
        parted -s /dev/md0 mklabel gpt
# Создаём 5 разделов
        parted -a none /dev/md0 mkpart primary xfs 0% 2%
        parted -a none /dev/md0 mkpart primary xfs 2% 52%
        parted -a none /dev/md0 mkpart primary xfs 52% 68%
        parted -a none /dev/md0 mkpart primary xfs 68% 84%
        parted -a none /dev/md0 mkpart primary xfs 84% 100%
# На новых разделах создаём файловую систему xfs
        for i in $(seq 1 5); do mkfs.xfs -f /dev/md0p$i; done
# Создаём папки для монтирования новых разделов
        mkdir -p /raid/part{1,2,3,4,5}
# Монтируем новые разделы в созданых папках
        for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done
# Добавляем информацию о монтировании новых разделов в файл fstab
        for i in $(seq 1 5); do blkid /dev/md0p$i | sed -e 's/"//g; s/TYPE=//' | awk -v i=/raid/part$i '{ print $2, i, $3, "defaults 0 0" }' >> /etc/fstab; done
```

## Перенос системы на RAID-1

(Примечание: постоянно пользуемся утилитами: `lsblk` и `blkid` для выяснения и контроля имён устройств и их UUID.)

### Отключаем SELinux
```bash
# Временно в текущем сеансе (действует до перезагрузки)
        sudo setenforce 0
# Постоянно (действует после перезагрузки)
        sudo sed -i /SELINUX=e/s/enforcing/disabled/ /etc/selinux/config
# Проверяем статус
        sestatus
# Перегружаем систему
        shutdown -r now
```

### Подготавливаем новый диск
```bash
# Создаём таблицу разделов msdos на новом диске /dev/sdd
        sudo parted -s /dev/sdd mklabel msdos
# Создаём на новом диске новый раздел /dev/sdd1
        sudo parted /dev/sdd mkpart primary 0% 100%
# Очищаем суперблоки RAID
        sudo mdadm --zero-superblock /dev/sdd1
# Создаём RAID-1 пока только из одного раздела /dev/sdd1
        sudo mdadm  --create /dev/md1 --level=1 --raid-disk=2 missing /dev/sdd1
# Заново сохраняем конфиг рейдов
        sudo su -c 'echo "DEVICE partitions" > /etc/mdadm/mdadm.conf'
        sudo su -c "mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf"
# На новом рейде /dev/md1 создаём файловую систему xfs
        sudo mkfs.xfs -f /dev/md1
```

### Копируем данные со старого диска на новый (делаем под рутом)
```bash
# Переходим в режим рута
        sudo su
# Создаём точку монтирования для нового диска
        mkdir /mnt/md1
# Монтируем новый диск
        mount /dev/md1 /mnt/md1
# Синхрогизируем данные
        rsync -auxHAXS --exclude=/dev/* --exclude=/proc/* --exclude=/sys/* --exclude=/tmp/* --exclude=/mnt/* /* /mnt/md1
```

### Подготавливаемся к chroot и переходим в контекст нового диска
```bash
# Присоединяем необходимые виртуальные системы
        mount --bind /proc /mnt/md1/proc
        mount --bind /sys /mnt/md1/sys
        mount --bind /dev /mnt/md1/dev
        mount --bind /run /mnt/md1/run
# Делаем chroot
        chroot /mnt/md1/
```

### Редактируем fstab
(Примечание: далее находимся в контексте нового диска после chroot.)
```bash
# Добавляем звпись о монтировании нового диска в корень системы
        blkid /dev/md1 | sed -e 's/"//g; s/TYPE=//' | awk -v i=/ '{ print $2, i, $3, "defaults 0 0" }' >> /etc/fstab
# Комментируем запись о монтировании старого диска
        OLDROOT=$(sed -n '/UUID/=' /etc/fstab | head -n 1); sed -i "${OLDROOT}s/#*UUID/#UUID/" /etc/fstab
```

### Создаём новый имидж initramfs
```bash
# Делаем бекап старого имиджа
        cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r).img.bck
# Заново сохраняем конфиг рейдов
        echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
        mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
# Создаём имидж
        dracut --mdadmconf --fstab --add="mdraid" --filesystems "xfs ext4 ext3" --add-drivers="raid1" --force /boot/initramfs-$(uname -r).img $(uname -r) -M
```

### Подготавливаем и устанавливаем загрузчик на новый диск
```bash
# Редактируем файл /etc/default/grub
        sed -i '/GRUB_CMDLINE_LINUX/d' /etc/default/grub
        echo 'GRUB_CMDLINE_LINUX="crashkernel=auto rd.auto rd.auto=1 rhgb quiet"' >> /etc/default/grub
        echo 'GRUB_PRELOAD_MODULES="mdraid1x"' >> /etc/default/grub
# Создаём новый конфиг загрузчика
        grub2-mkconfig -o /boot/grub2/grub.cfg
# Устанавливаем загрузчик
        grub2-install /dev/sdd
```

### Перегружаем систему
(Примечание: загружаемся с нового диска.)
```bash
# Возвращаемся в контекст старого диска
        exit
# Останавливаем систему
        shutdown -h now
# Запускаем систему и выбираем в BIOS загрузку с нового диска
# После загрузки логинимся в систему уже в контексте нового диска
```

### Подготавливаем старый диск к вводу в рейд и вводим его в рейд
```bash
# Создаём новую таблицу разделов на старом диске /dev/sde
        sudo parted -s /dev/sde mklabel msdos
# Определяем начало для нового раздела на старом диске /dev/sde идентичный соответствующему разделу на новом диске /dev/sdd
        START=$(fdisk /dev/sdd -l | tail -n 1 - | sed 's/[[:space:]]\+/\t/g' - | cut -f2)
# Определяем конец для нового раздела на старом диске /dev/sde идентичный соответствующему разделу на новом диске /dev/sdd
        END=$(fdisk /dev/sdd -l | tail -n 1 - | sed 's/[[:space:]]\+/\t/g' - | cut -f3)
# Создаём новый раздел на старом диске /dev/sde идентичный соответствующему разделу на новом диске /dev/sdd
        sudo parted /dev/sde mkpart primary ${START}s ${END}s
# Смотрим информацию о разделах нового и старого дисков. Информация о соответствующих разделах должна совпадать.
        fdisk /dev/sdd -l
        fdisk /dev/sde -l
# Вводим новый раздел старого диска в рейд.
        sudo mdadm --manage /dev/md1 --add /dev/sde1
# Наблюдаем за синхронизацией рейда
        watch -n1 "cat /proc/mdstat"
# Устанавливаем загрузчик на старый диск /dev/sde
        sudo grub2-istall /dev/sde
```

### Пересоздаём заново свап-файл
(Примечание: при загрузке появлялось сообщение о ошибке связанной со свапом, поэтому, чтобы ошибку исправить, пришлось пересоздать заново свап-файл)
```bash
# Отключаем все свапы
        sudo swapoff -a
# Создаём новый занулённый файл размером 2Gb
        sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
# Создаём свап
        sudo mkswap /swapfile
# Включаем все свапы
        sudo swapon -a
# Проверяем, что свап включился
        swapon -s
```

### Загружаемся с системой перенесённой на RAID-1
(Примечание: загружаемся со старого диска.)
```bash
# Перегружаем систему
        sudo shutdown -r now
```

## Файлы

* [lsblk.1](lsblk.1) - вывод команды lsblk до переноса системы на RAID-1;
* [lsblk.2](lsblk.2) - вывод команды lsblk после переноса системы на RAID-1.