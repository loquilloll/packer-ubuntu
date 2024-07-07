packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

variable "box_version" {
  type    = string
  default = "${env("VERSION")}"
}

source "qemu" "generic-ubuntu2204-libvirt-x64" {
  boot_command           = [
    "<tab><wait><tab><wait><tab><wait><tab><wait><tab><wait><tab><wait>",
    "<tab><wait><tab><wait><tab><wait><tab><wait><tab><wait><tab><wait>",
    "<tab><wait><tab><wait><tab><wait><tab><wait><tab><wait><tab><wait>",
    "<tab><wait><tab><wait><tab><wait><tab><wait><tab><wait><tab><wait>",
    "<tab><wait><tab><wait><tab><wait><tab><wait><tab><wait><tab><wait>",
    "<tab><wait><tab><wait><tab><wait><tab><wait><tab><wait><tab><wait>",
    "<tab><wait><tab><wait><tab><wait><tab><wait><tab><wait><tab><wait>",
    "<tab><wait><tab><wait><tab><wait><tab><wait><tab><wait><tab><wait>",
    "<tab><wait><tab><wait><tab><wait><tab><wait><tab><wait><tab><wait>",
    "<tab><wait><tab><wait><tab><wait><tab><wait><tab><wait><tab><wait>",
    "c<wait10>",
    "set gfxpayload=keep<enter><wait10>",
    "linux /casper/vmlinuz autoinstall quiet net.ifnames=0 biosdevname=0 ",
    "cloud-config-url=\"http://{{ .HTTPIP }}:{{ .HTTPPort }}/generic.ubuntu2204.vagrant.cfg\" --- <enter><wait10>",
    "initrd /casper/initrd<enter><wait10>",
    "boot<enter>"
  ]
  boot_keygroup_interval = "1s"
  boot_wait              = "3s"
  cpus                   = 2
  disk_cache             = "unsafe"
  disk_compression       = true
  disk_detect_zeroes     = "on"
  disk_discard           = "unmap"
  disk_image             = false
  disk_interface         = "virtio-scsi"
  disk_size              = "131072"
  format                 = "qcow2"
  headless               = true
  http_directory         = "http"
  iso_checksum           = "sha256:45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
  iso_url                = "https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
  memory                 = 2048
  net_device             = "virtio-net"
  output_directory       = "output/generic-ubuntu2204-libvirt-x64"
  qemu_binary            = "qemu-system-x86_64"
  shutdown_command       = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_handshake_attempts = 1000
  ssh_password           = "vagrant"
  ssh_port               = 22
  ssh_timeout            = "3600s"
  ssh_username           = "root"
  vm_name                = "generic-ubuntu2204-libvirt-x64"
}

build {
  sources = ["source.qemu.generic-ubuntu2204-libvirt-x64"]

  provisioner "shell" {
    expect_disconnect   = "true"
    scripts             = [
      "scripts/ubuntu2204/apt.sh",
      "scripts/ubuntu2204/floppy.sh",
      "scripts/ubuntu2204/fixkvp.sh",
      "scripts/ubuntu2204/network.sh"
    ]
    start_retry_timeout = "15m"
    timeout             = "2h0m0s"
  }

  provisioner "shell" {
    expect_disconnect   = "true"
    pause_before        = "2m0s"
    scripts             = [
      "scripts/ubuntu2204/vagrant.sh",
      "scripts/ubuntu2204/profile.sh",
      "scripts/ubuntu2204/motd.sh",
      "scripts/ubuntu2204/fixtty.sh",
      "scripts/ubuntu2204/qemu.sh",
      "scripts/ubuntu2204/cleanup.sh"
    ]
    start_retry_timeout = "15m"
    timeout             = "2h0m0s"
  }

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact  = false
      compression_level    = 9
      include              = ["metadata/info.json"]
      output               = "output/ubuntu2204.box"
      vagrantfile_template = "tpl/ubuntu2204.rb"
    }
    post-processor "checksum" {
      keep_input_artifact = false
      checksum_types      = ["sha256"]
      output              = "output/ubuntu2204.box.sha256"
    }
  }
}
