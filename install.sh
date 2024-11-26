//
cryptsetup luksFormat --pbkdf pbkdf2 /dev/partition
cryptsetup open /dev/partition luks
mkfs.btrfs -f -L Arch /dev/mapper/luks
mount -t btrfs LABEL=Arch /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
btrfs sub create /mnt/@snapshots
btrfs sub create /mnt/@swap
