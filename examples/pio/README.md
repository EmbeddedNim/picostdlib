# Hello PIO Example

This example is based on the pico-sdk
[hello_pio](https://github.com/raspberrypi/pico-examples/tree/master/pio/hello_pio)
example. It uses a PIO program to blink the onboard LED.

# CMakeLists

The following additions to the piconim default CMakeLists.txt file are required
to run this example.

First, the following line needs to be added after the executable has been
defined, in order to compile the PIO program with `PIOASM` and generate the
header file:

```cmake
pico_generate_pio_header(hello_pio ${CMAKE_CURRENT_LIST_DIR}/../src/hello.pio)
```

Second, `hardware_pio` needs to be added to the `target_link_libraries()`
call.

A CMakeLists.txt file with these changes is provided with this example.
