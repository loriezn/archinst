# archinst

Configure mkinitcpio by adding encrypt and btrfs hooks before filesystems.
Add btrfs executable to binaries to be able to use btrfs-check if necessary.
Then regenerate the ramfs.
--> /etc/mkinitcpio.conf
    BINARIES="/usr/bin/btrfs"
    HOOKS="... block encrypt btrfs ... filesystems ..."
mkinitcpio -p linux

Update the root password.
passwd

If you have an Intel CPU, it is recommended to install the intel-ucode
package to enable microcode updates. Also, install GRUB bootloader and
efibootmgr for UEFI compatibility.
pacman -S intel-ucode grub efibootmgr

Configure GRUB to recognize the LUKS encrypted boot partition and unlock
the root LVM one at boot.
--> /etc/default/grub
    GRUB_CMDLINE_LINUX="... cryptdevice=UUID=</dev/sda3 UUID>:cryptbtrfs ..."
    GRUB_ENABLE_CRYPTODISK=y

Install GRUB to the mounted ESP then generate a config file for it
(BEWARE: the first command is a one liner). It may happen that a warning
about lvmetad is thrown at you: don't panic, as this happens due to /run
not being available in chroot environment. Just ignore it.
https://wiki.archlinux.org/index.php/GRUB#Warning_when_installing_in_chroot
grub-install --target=x86_64-efi
             --efi-directory=/boot/efi
             --bootloader-id=<chosen entry name>
             --recheck
grub-mkconfig -o /boot/grub/grub.cfg

Installation is finished: exit chroot, unmount all drives then reboot.
exit
umount -R /mnt
reboot
