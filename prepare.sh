#!/bin/bash

set -e
set -o xtrace


CONFIG=(
	username 	loki
	shell			bash
	hostname	zer0bytes
	timezone	Australia/Sydney
	locale		"en_US.UTF-8 UTF-8"
	keymap		us
	font			sun12x22
	drive			/dev/nvme0n1
	efi				/dev/nvme0n1p1
	btrfs			/dev/nvme0n1p2
	vault			/dev/mapper/vault
)

wifi-menu
timedatectl set-ntp true
timedatectl status



sgdisk -zog "${CONFIG[drive]}"
sgdisk --new=1:0:+512M -c 1:"EFI System Partition" -t 1:ef00 "${CONFIG[drive]}"
sgdisk --new=2:0:0 -c 3:"Linux System Partition" -t 3:8304 "${CONFIG[drive]}"

mkfs.fat -F32 "${CONFIG[efi]}"

cryptsetup benchmark

echo "Set hash:"
read -e HASH

echo "Set cipher:"
read -e CIPHER

echo "Set key-size:"
read -e KEYSIZE


cryptsetup luksFormat --hash="$HASH" --cipher="$CIPHER" --key-size="$KEYSIZE" --verify-passphrase "${CONFIG[btrfs]}"
cryptsetup open "${CONFIG[btrfs]}" vault

mkfs.btrfs "${CONFIG[vault]}"
mount "${CONFIG[vault]}" /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@boot
btrfs subvolume create /mnt/@home
umount /mnt

mount -o compress=lzo,subvol=@ "${CONFIG[vault]}" /mnt
mkdir /mnt/boot
mount -o compress=lzo,subvol=@boot "${CONFIG[vault]}" /mnt/boot
mkdir /mnt/home
mount -o compress=lzo,subvol=@home "${CONFIG[vault]}" /mnt/home

mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi

pacstrap /mnt base base-devel btrfs-progs

genfstab -U /mnt > /mnt/etc/fstab

arch-chroot /mnt
