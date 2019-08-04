sudo su
curl https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.2.6.tar.xz --output linux-5.2.6.tar.xz
tar -xf linux-5.2.6.tar.xz -C /usr/src/kernels
cp /boot/config-3.10.0-957.12.2.el7.x86_64 /usr/src/kernels/linux-5.2.6/.config
cd /usr/src/kernels/linux-5.2.6/
yum install gcc flex bison openssl-devel bc elfutils-libelf-devel
make olddefconfig
make
make modules_install
make install
