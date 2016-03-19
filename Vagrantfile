# -*- mode: ruby -*-
# vi: set ft=ruby :

OPENOCD_VERSION = "0.9.0"
STLINK_VERSION = "1.1.0"
GCC_ARM_URL = "https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q3-update/+download/gcc-arm-none-eabi-4_8-2014q3-20140805-linux.tar.bz2"

# https://github.com/mitchellh/vagrant/issues/5774
def usbfilter_exists(vendor_id, product_id)
  #
  # Determine if a usbfilter with the provided Vendor/Product ID combination
  # already exists on this VM.
  #
  # TODO: Use a more reliable way of retrieving this information.
  #
  # NOTE: The "machinereadable" output for usbfilters is more
  #       complicated to work with (due to variable names including
  #       the numeric filter index) so we don't use it here.
  #
  machine_id_filepath = File.join(".vagrant", "machines", "default", "virtualbox", "id")
  return false unless File.exists? machine_id_filepath

  vm_info = `VBoxManage showvminfo $(<#{machine_id_filepath})`.downcase
  filter_match = "VendorId:         #{vendor_id}\nProductId:        #{product_id}\n".downcase
  vm_info.include? filter_match
end

def better_usbfilter_add(vb, vendor_id, product_id, filter_name)
  #
  # This is a workaround for the fact VirtualBox doesn't provide
  # a way for preventing duplicate USB filters from being added.
  #
  # TODO: Implement this in a way that it doesn't get run multiple
  #       times on each Vagrantfile parsing.
  #
  unless usbfilter_exists(vendor_id, product_id)
    vb.customize ["usbfilter", "add", "0",
                  "--target", :id,
                  "--name", filter_name,
                  "--vendorid", vendor_id,
                  "--productid", product_id
                  ]
  end
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/trusty64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Turn on USB 2.0 support and add usb filter to attach STLink V2 programmer.
  # Note that the VirtualBox extension pack MUST be installed first from:
  #   https://www.virtualbox.org/wiki/Downloads
  # Also on Linux be sure to add your user to the vboxusers group, see:
  #   http://unix.stackexchange.com/questions/129305/how-can-i-enable-access-to-usb-devices-within-virtualbox-guests
   config.vm.provider :virtualbox do |vb|
     vb.customize ['modifyvm', :id, '--usb', 'on']
     vb.customize ['modifyvm', :id, '--usbehci', 'on']
     better_usbfilter_add vb, '0483', '3748', 'STLink'
     better_usbfilter_add vb, '0483', '374B', 'On-Board-STLink'
   end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
    export OPENOCD_VERSION=#{OPENOCD_VERSION}
    export STLINK_VERSION=#{STLINK_VERSION}
    export GCC_ARM_URL=#{GCC_ARM_URL}
    export HOMEDIR=/home/vagrant
    /vagrant/vendor/vagrant/provision.sh
  SHELL
end
