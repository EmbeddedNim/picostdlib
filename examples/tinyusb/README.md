# TinyUSB example

This folder contains an example which implements a composite USB device
consisting of:

  1. HID interface with composite report (keyboard, mouse, consumer device and
     gamepad)

  2. CDC interface (serial port)

Note: Most of the app logic has been wrapped in Nim. However, most of the USB
descriptor definition, as well as TinyUSB configuration, must currently be
defined in C. This is implemented in the 2 files `usb_descriptors.c` and
`tusb_config.h`.

These files must be included in the C compilation process, a CMakeLists file is
included with this example for this purpose.

Follow these instructions to build the example:

  1. Run `piconim init tinyusb` to create a new pico project.
  
  2. Copy the files `tinyusb.nim`, `usb_descriptors.c` and `tusb_config.h`
     provided in this example to the `src` directory of the project (overwrite
     the existing nim file created by piconim).

  4. Replace the CMakeLists.txt file in the `csource` directory of the project
     with the CMakeLists.txt file included with this example.

  5. run `piconim build tinyusb.nim`.