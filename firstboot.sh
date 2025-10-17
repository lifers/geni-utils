#!/bin/bash
set -e

# Update package lists
apt-get update

# Add sbt repositories
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" > /etc/apt/sources.list.d/sbt.list
echo "deb https://repo.scala-sbt.org/scalasbt/debian /" > /etc/apt/sources.list.d/sbt_old.list

# Import sbt GPG key
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import
chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg

# Update and upgrade system
apt-get update -y
apt-get dist-upgrade -y

# Install OpenJDK 21, sbt, and growpart (in cloud-utils)
apt-get install openjdk-21-jdk sbt cloud-utils htop -y

# --- Additional disk setup for /dev/sdb to /local/datasets ---
# 1. Create a new GPT partition table on /dev/sdb
parted /dev/sdb --script mklabel gpt

# 2. Create a single Linux filesystem partition (use all space)
parted /dev/sdb --script mkpart primary ext4 0% 100%

# Wait for kernel to recognize the new partition
sleep 2

# 3. Format the new partition to ext4
mkfs.ext4 -F /dev/sdb1

# 4. Create mount point and mount
mkdir -p /local/datasets
mount /dev/sdb1 /local/datasets

# 5. Add to /etc/fstab for auto-mount on reboot
if ! grep -q "/dev/sdb1 /local/datasets ext4" /etc/fstab; then
    echo "/dev/sdb1 /local/datasets ext4 defaults 0 2" >> /etc/fstab
fi

echo "Disk /dev/sdb1 formatted and mounted to /local/datasets, and added to /etc/fstab."
