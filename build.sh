#!/bin/bash


# Cleanup
rm -rf output

# Remove box from vagrant
vagrant box remove loquilloll/ubuntu2204 --all 

# Remove box from virt-manager store
VOLUME=$(sudo virsh vol-list default | grep loquilloll-VAGRANTSLASH-ubuntu2204 | awk '{print $1}')
sudo virsh vol-delete --pool default $VOLUME

# Build box
packer build ubuntu2204-libvirt-x64.json.pkr.hcl

# Add new box to vagrant
vagrant box add output/ubuntu2204.box --name loquilloll/ubuntu2204

# Publish to vagrant cloud
CHECKSUM_VALUE=$(cat output/ubuntu2204.box.sha256 | awk '{print $1}')
vagrant cloud publish loquilloll/ubuntu2204 1.0.0 libvirt output/ubuntu2204.box \
  --checksum  $CHECKSUM_VALUE \
  --checksum-type sha256 \
  --release \
  --force