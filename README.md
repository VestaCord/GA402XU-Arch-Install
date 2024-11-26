# GA402XU Arch Install Dual Boot. 
Install for Zephyrus G14 GA402XU with existing ubuntu and windows partition with btrfs, luks, auto-snapshots, no noise fan curves.

## Table of contents

- [Table of contents](#table-of-contents)
- [Basic Install](#basic-install)
  - [First Steps](#first-steps)
	- [Format Disk](#format-disk)
	- [Create encrypted filesystem](#create-encrypted-filesystem)
	- [Create and Mount btrfs Subvolumes](#create-and-mount-btrfs-subvolumes)
	- [Create a btrfs swapfile and remount subvols](#create-a-btrfs-swapfile-and-remount-subvols)
	- [Install the system using pacstrap](#install-the-system-using-pacstrap)
	- [Chroot into the new system and change language settings](#chroot-into-the-new-system-and-change-language-settings)
	- [Add btrfs and encrypt to Initramfs](#add-btrfs-and-encrypt-to-initramfs)
	- [Install Systemd Bootloader](#install-systemd-bootloader)
	- [Blacklist Nouveau](#blacklist-nouveau)
	- [Leave Chroot and Reboot](#leave-chroot-and-reboot)

 Further reading for fine tuning
 https://github.com/k-amin07/G14Arch


# Basic Install
## First Steps
To get wireless networking, keymaps, time zone setup, follow [Arch Wiki from 1.1 to 1.9.](https://wiki.archlinux.org/title/Installation_guide)

## Formatting
Leave nvme0n1p1 intact (/boot). We will be mounting this to /mnt/boot. In Ubuntu systems it is mounted at /boot/efi.
Running `gdisk nvme0n1` should return `MBR protective` and `GPT present`.  With your existing linux install, you can use the disks utility to format the desired partition. Otherwise, you can run `gdisk`. `8300` is the gdisk code for EXT4.



### [Create encrypted file system]((https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Encrypted_boot_partition_(GRUB))
Use LUKS2 with PBKDF2 for partition as GRUB has limited support.
Unlock luks partition with name luks.
```
cryptsetup luksFormat --pbkdf pbkdf2 /dev/partition
cryptsetup open /dev/partition luks
```
### [Create and mount btrfs subvolumes](https://wiki.archlinux.org/title/Btrfs#File_system_creation)
*F*orcefully create a btrfs partition with label Arch
```
mkfs.btrfs -f -L Arch /dev/mapper/luks
```
To to use multiple Btrfs devices in a pool, we must btrfs in the `/etc/mkinitcpio.conf` later on.

Create subvolumes. If you want to use timeshift, subvolumes must be labeled as @, @home etc. No custom names.

```
mount -t btrfs LABEL=Arch /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
btrfs sub create /mnt/@snapshots
btrfs sub create /mnt/@swap
```



