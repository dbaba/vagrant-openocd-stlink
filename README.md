arm-scons-project-template
===

The project offers a project template for developing software running on STM32F4*, which includes:

1. ARM toolchain with Vagrant (Modifying [ARM-toolchain-vagrant](https://github.com/adafruit/ARM-toolchain-vagrant))

## Vagrant

The Vagrantfile includes a USB configuration for the vagrant instance in order to connect ST-Link.

    (Disconnect ST-Link2/On-Board-STLink!)
    $ vagrant up && vagrant reload
    $ vagrant ssh

`vagrant reload` is required.

### Checking if ST-Link is available

    (Connect ST-Link2/On-Board-STLink)
    $ lsusb

Then you'll see the following output:

    Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
    Bus 002 Device 002: ID 0483:374b STMicroelectronics ST-LINK/V2.1 (Nucleo-F103RB)
    Bus 002 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub


### On Halting VM

    $ vagrant halt

### On Starting Halted VM

    $ vagrant up

## How to flash

    $ st-flash write path/to/bin <address>

    (e.g.)
    $ st-flash write build/STM32F401-Nucleo/my-sketch.bin 0x8000000

## How to on-board-debug

    (vagrant ssh -- terminal1)
    $ openocd -f /vagrant/vendor/openocd/stm32f401nucleo.cfg

    (vagrant ssh -- terminal2)
    $ arm-none-eabi-gdb build/STM32F401-Nucleo/my-skecth.elf
    (gdb) target remote :3333
    (gdb) monitor reset init

# References

* [ARM-toolchain-vagrant](https://github.com/adafruit/ARM-toolchain-vagrant)
* [#5774 Prevent duplicate VirtualBox usbfilters from being added](https://github.com/mitchellh/vagrant/issues/5774)

# Revision History
* 1.0.0
  - Initial Release
