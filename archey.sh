setfont ter-122n

systemctl start iwd.service
iwctl station wlan0 get-networks
printf "Type your Network's name: "
read $WiFi
iwctl station wlan0 connect $WiFi

ping -c 2 google.com
pacman -Sy reflector --noconfirm
reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

lsblk
printf "Type Carefully Hard-Drive's name: "
read $drive
echo -e "g\nw" | fdisk /dev/$drive
echo -e "Make THREE partitions in this order (Root, EFI, Swap)!\nPress Enter to proceed..."
read x
cgdisk /dev/$drive
mkfs.ext4 /dev/$drive"p1"
mkfs.vfat -F32 /dev/$drive"p2"
mkswap /dev/$drive"p3"
swapon /dev/$drive"p3"

mount /dev/$drive"p1" /mnt
mkdir /mnt/boot
mount /dev/$drive"p2" /mnt/boot

pacstrap /mnt base base-devel linux linux-firmware efibootmgr intel-ucode mtools gptfdisk ntfs-3g ntfsprogs arch-install-scripts iwd nano dhcpcd wpa_supplicant git reflector bash-completion terminus-font lm_sensors axel cronie rsync

cp /var/lib/iwd/$WiFi".psk" /mnt/var/lib/iwd/

genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt

systemctl enable dhcpcd.service
systemctl enable iwd.service

reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist

ln -sf /usr/share/zoneinfo/Asia/Riyadh /etc/localtime

nano /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "FONT=ter-124n" > /etc/vconsole.conf

echo Archy > /etc/hostname
echo -e "127.0.0.1\tlocalhost\n::1\tlocalhost\n127.0.1.1\tArchey.domain Archey" >> /etc/hosts

echo -e "[archlinuxfr]\nSigLevel = Never\nServer = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf
pacman -Sy

echo -e "Add ( consolefont ) into HOOKS!\nPress Enter to proceed..."
read y
nano /etc/mkinitcpio.conf
mkinitcpio -P

bootctl --path=/boot install
echo -e "default\tarchey\nconsole-mode\tmax\neditor\tno\ntimeout\t0" > /boot/loader/loader.conf
partuuid=$(lsblk -o PARTUUID /dev/$drive"p1")
partuuid=${partuuid: 9}
echo -e "title\t\tArch Linux\nlinux\t\t/vmlinuz-linux\ninitrd\t\t/intel-ucode.img\ninitrd\t\tinitramfs-linux.img\noptions\t\troot=PARTUUID=\"$partuuid\" rw pcie_aspm=off ec_sys.write_support=1\n#quiet splash" > /boot/loader/entries/archey.conf

echo -e "blacklist\tnouveau" > /etc/modprobe.d/blacklist.conf

printf "Type NEW user name: "
read user_name
printf "Type NEW user password: "
read user_pass
useradd -mg users -G audio,video,games,storage,optical,wheel,power,scanner,lp -s /bin/bash $user_name
echo -e "$user_pass\n$user_pass" | passswd $user_name
echo -e "$user_pass\n$user_pass" | passswd
echo -e "\n## $user_name'\'s' modifications\n$user_name ALL=(ALL) ALL\n%sudo ALL=(ALL) ALL" >> /etc/sudoers

echo -e "\n[Settings]\nAutoConnect=true" >> /var/lib/iwd/$WiFi".psk"

echo -e "$user_pass" | su $user_name
cd
git clone https://aur.archlinux.org/pikaur.git
cd pikaur
makepkg -si
########### needs code
pikaur -S isw
############# needs code
isw -w 16Q2EMS1
sensors-detect
############## needs code

exit
systemctl enable isw@16Q2EMS1.service
exit

cp /mnt/etc/isw.conf /mnt/etc/isw.conf.backup
cp ./archey/isw /mnt/etc/isw.conf
echo "$(cat ./archey/aliases)" >> /mnt/home/$user_name/.bashrc

reboot
