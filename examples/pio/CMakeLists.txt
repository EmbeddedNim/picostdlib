cmake_minimum_required(VERSION 3.13)

# initialize the SDK based on PICO_SDK_PATH

# note: this must happen before project()
include(pico_sdk_import.cmake)

project(hello_pio)

# initialize the Raspberry Pi Pico SDK
pico_sdk_init()

# add program file(s)
file(GLOB MyCSources *.c)
add_executable(hello_pio ${MyCSources})

pico_generate_pio_header(hello_pio ${CMAKE_CURRENT_LIST_DIR}/../src/hello.pio)

# pull in our pico_stdlib which pulls in commonly used features
# hardware_adc tinyusb_device tinyusb_board Currently supported.
target_link_libraries(hello_pio pico_stdlib hardware_pio)

# enable usb output, disable uart output
pico_enable_stdio_usb(hello_pio 1)
pico_enable_stdio_uart(hello_pio 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(hello_pio)

# add url via pico_set_program_url
pico_set_program_url(hello_pio 1)
