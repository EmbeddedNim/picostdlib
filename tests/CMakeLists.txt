cmake_minimum_required(VERSION 3.13)

# Set CMake build type. Debug, Release, MinSizeRel, RelWithDebInfo
set(CMAKE_BUILD_TYPE Debug)

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

project(tests C CXX ASM)

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

if(NOT PICO_CYW43_SUPPORTED)
  include(test_pico.cmake)
else()
  include(test_pico_w.cmake)
endif()
