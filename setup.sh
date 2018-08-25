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

blkid
echo "vault UUID= none luks" /etc/crypttab

ln -sf /usr/share/zoneinfo/"${CONFIG[timezone]}" /etc/localtime
hwclock --systohc --utc

echo LANG="${CONFIG[locale]}" > /etc/locale.conf
echo KEYMAP="${CONFIG[keymap]}" > /etc/vconsole.conf
locale-gen

echo "127.0.1.1   ${CONFIG[hostname]}.localdomain   ${CONFIG[hostname]}" >> /etc/hosts
