В Vagrantfile добавлена опция vb.gui = true для возможности управления процессом загрузки.

## Попасть в систему без пароля

Опции описаны в dracut.cmdline(7)

### 1. Использование командной строки dracut в конце обработки initramfs
При загрузке нажать клавишу e, отредактировать опции ядра:  
убрать опцию "console=ttyS0,115200n8"  
добавить опции "rd.break enforcing=0"  
Загрузить систему (Ctrl-x)  

Появится приглашение switch_root:/#  

    mount -o remount,rw /sysroot
    chroot /sysroot

Поменять пароль root (passwd)  
Выйти из chroot и switch_root (exit exit), загрузка системы продолжится.  
Зайти в систему с новым паролем, восстановить метки selinux:  

    restorecon /etc/shadow  

Перезагрузить систему.  

### 2. Замена init после загрузки initramfs
При загрузке нажать клавишу e, отредактировать опции ядра:  
убрать опцию "console=ttyS0,115200n8"  
заменить опцию "ro" на "rw"  
добавить опцию "init=/bin/bash"  

Загрузить систему (Ctrl-x)  
Поменять пароль root (passwd)  
Создать файл автоматического восстановления меток selinux:  

    touch /.autorelabel  

Перезагрузить систему:  

    exec /sbin/init 6  


## Переименовать VG

* [typescript_rename_vg](typescript_rename_vg) - typescript переименования VG

Краткое описание:

    vgrename VolGroup00 VolGroup01
    sed -i 's/VolGroup00/VolGroup01/g' /etc/fstab
    sed -i 's/VolGroup00/VolGroup01/g' /etc/default/grub
    sed -i 's/VolGroup00/VolGroup01/g' /boot/grub2/grub.cfg 
    mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)


## Добавить модуль в initrd

* [module-setup.sh](module-setup.sh) - скрипт установки модуля
* [test.sh](test.sh) - скрипт вывода пингвина
* [typescript_dracut_module](typescript_dracut_module) - typescript работы

![результат добавления модуля](dracut_module.png)
