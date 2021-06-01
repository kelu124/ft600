# icezero-blinky
Simple Blinky sketch for the IceZero FPGA board

## Prerequisites

To install the programming software:

```
  sudo apt-get install fpga-icestorm arachne-pnr yosys
  git clone https://github.com/thekroko/icotools.git
  cd icotools/examples/icezero
  make icezprog
  sudo make install_icezprog
```

## How to flash this sketch

To flash this sketch:

```
icezprog blinky.bin 
```

The output should look similar to this:

```
icezprog icezero.bin
Flash ID: C8 40 13 C8 40 13 C8 40 13 C8 40 13 C8 40 13 C8 40 13 C8 40
Writing 0x000000 .. 0x00ffff: [erasing] [writing................] [readback................]
Writing 0x010000 .. 0x01ffff: [erasing] [writing................] [readback................]
Writing 0x020000 .. 0x020fbb: [erasing] [writing.] [readback.]
DONE.
```

## How to change this sketch

To change this sketch, edit blinky.v, and then call:

```
make blinky.prog
```

This will synthesize and flash the sketch. It might take a minute or two.
