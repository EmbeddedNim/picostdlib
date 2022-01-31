# WS2812 PIO Example

This example uses a PIO program to set the color of multiple WS2812 (or
similar) addressable RGB(W) LEDs. It is based on the pico-sdk
[ws2812](https://github.com/raspberrypi/pico-examples/tree/master/pio/ws2812)
example, which is also discussed in detail in the pico SDK documentation.

Note: this example has not actually been tested with ws2812 LEDs, but rather
with Inolux IN-PI55 series RGBW LEDs, which use a very similar protocol with
slightly different timings. The IN-PI55 timing values are commented out in
the `ws2812.pio` file.

# CMakeLists

The following additions to the piconim default CMakeLists.txt file are required
to run this example.

First, the following line needs to be added after the executable has been
defined, in order to compile the PIO program with `PIOASM` and generate the
header file:

```cmake
pico_generate_pio_header(hello_pio ${CMAKE_CURRENT_LIST_DIR}/../src/ws2812.pio)
```

Second, `hardware_pio` needs to be added to the `target_link_libraries()`
call.

A CMakeLists.txt file with these changes is provided with this example.
