cmake_minimum_required(VERSION 3.13)

# Set CMake build type. Debug, Release, MinSizeRel, RelWithDebInfo
set(CMAKE_BUILD_TYPE Release)

# Set standards
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# initialize pico-sdk from GIT
# (note this can come from environment, CMake cache etc)
#set(PICO_SDK_FETCH_FROM_GIT on)
#set(PICO_SDK_PATH ENV{PICO_SDK_PATH}) # Set by piconim

# Set board type here
if(NOT DEFINED PICO_BOARD)
  set(PICO_BOARD pico)
endif()

# Support C++ exceptions with Nim
set(PICO_CXX_ENABLE_EXCEPTIONS 1)

# Uncomment to disable picotool binary info
# set(PICO_NO_BINARY_INFO 1)


set(PICOSTDLIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../src")

# note: this must happen before project()
include(${PICOSTDLIB_DIR}/picostdlib/cmake/pico_sdk_import.cmake)

project(examples C CXX ASM)

# initialize the Raspberry Pi Pico SDK
pico_sdk_init()

# # fetch and initialize FreeRTOS-Kernel
# include(FetchContent)
# FetchContent_Declare( freertos_kernel
#   GIT_REPOSITORY https://github.com/FreeRTOS/FreeRTOS-Kernel.git
#   GIT_TAG        V10.5.1
# )
# FetchContent_Populate(freertos_kernel)
# set(FREERTOS_KERNEL_PATH ${freertos_kernel_SOURCE_DIR})
# include(${FREERTOS_KERNEL_PATH}/portable/ThirdParty/GCC/RP2040/FreeRTOS_Kernel_import.cmake)

include(${PICOSTDLIB_DIR}/picostdlib/cmake/picostdlib.cmake)

function(add_example name)
  set(target "${name}")

  add_executable(${target})

  picostdlib_target(${target} ${name})

  # set_target_properties(${target} PROPERTIES LINKER_LANGUAGE CXX)

  target_include_directories(${target} PRIVATE
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/../template/csource
  )

  # Additional libraries
  target_link_libraries(${target}
    # For wifi and tls/https
    # pico_cyw43_arch_lwip_threadsafe_background pico_lwip_mbedtls pico_mbedtls
  )
  # havent gotten sockets to work with freertos yet...
  # pico_cyw43_arch_lwip_sys_freertos FreeRTOS-Kernel-Heap3

  target_compile_definitions(${target} PRIVATE
    # CYW43_HOST_NAME="PicoW"
    PICO_STDIO_USB_CONNECT_WAIT_TIMEOUT_MS=2000
  )

  # enable usb output, disable uart output
  pico_enable_stdio_usb(${target} 1)
  pico_enable_stdio_uart(${target} 0)

  # create map/bin/hex/uf2 file etc.
  pico_add_extra_outputs(${target})

  # add url via pico_set_program_url
  # pico_set_program_url(${target} "")
endfunction()



if(PICO_CYW43_SUPPORTED)
  # wireless examples
  add_example(picow_blink)
  add_example(picow_ntp_client)
  add_example(picow_tcp_client)
  add_example(picow_tls_client)
  add_example(picow_wifi_scan)
else()
  # these uses DefaultLedPin and can't be compiled for pico w
  add_example(blink)
  add_example(hello_resus)
  add_example(onboard_temperature)
  add_example(hello_pio)
  add_example(hello_stdio)
  add_example(pwm_led_fade)

  # Regular pico board examples
  add_example(hello_adc)
  add_example(hello_48mhz)
  add_example(hello_gpout)
  add_example(hello_dma)
  add_example(hello_littlefs)
  add_example(hello_7segment)
  add_example(hello_gpio_irq)
  add_example(hello_serial)
  add_example(hello_timestart)
  add_example(bus_scan)
  # "joystickdisplay"
  # "lightsensor"
  add_example(hello_multicore)
  add_example(hello_pwm)
  add_example(hello_reset)
  add_example(hello_rtc)
  add_example(rtc_alarm)
  add_example(unique_board_id)
  add_example(hello_timer)
  # "tinyusb"
  add_example(hello_uart)
  add_example(hello_watchdog)
  # "ws2812_pio"
endif()
