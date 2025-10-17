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

# Grow /dev/sda3 and resize file system to fill it
growpart /dev/sda 3
resize2fs /dev/sda3
