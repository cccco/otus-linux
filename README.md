# Задание №02

## Создание рейда, новых разделов на нём и монтирование этих разделов

```bash
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
