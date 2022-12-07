cmake_minimum_required(VERSION 3.13)

if(NOT DEFINED OUTPUT_NAME)
  set(OUTPUT_NAME blink)
endif()

# initialize pico-sdk from GIT
# (note this can come from environment, CMake cache etc)
#set(PICO_SDK_FETCH_FROM_GIT on)

# Set board type here
# set(PICO_BOARD pico_w)

# Support C++ exceptions with Nim
set(PICO_CXX_ENABLE_EXCEPTIONS 1)

# Uncomment to disable picotool binary info
# set(PICO_NO_BINARY_INFO 1)

# pico_sdk_import.cmake is a single file copied from this SDK
# note: this must happen before project()
include(pico_sdk_import.cmake)

project(${OUTPUT_NAME})

# Set standards
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# initialize the Raspberry Pi Pico SDK
pico_sdk_init()

set(NIMCACHE_DIR "${CMAKE_SOURCE_DIR}/../build/nimcache")
set(NIMCACHE_JSON_FILE "${NIMCACHE_DIR}/${OUTPUT_NAME}.cached.json")

set_directory_properties(PROPERTIES CMAKE_CONFIGURE_DEPENDS ${NIMCACHE_JSON_FILE})
set_directory_properties(PROPERTIES CMAKE_CONFIGURE_DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/imports.cmake)

if(EXISTS ${NIMCACHE_JSON_FILE})
  # Read the nimcache JSON file to get the source files
  set(NimSources "")
  file(READ "${NIMCACHE_JSON_FILE}" NIMCACHE_JSON_DATA)
  string(JSON cfilelength LENGTH "${NIMCACHE_JSON_DATA}" compile)
  math(EXPR cfilelength "${cfilelength} - 1")
  foreach(IDX RANGE ${cfilelength})
      string(JSON CUR_FILE GET "${NIMCACHE_JSON_DATA}" compile ${IDX} 0)
      list(APPEND NimSources ${CUR_FILE})
  endforeach()
endif()

# Suppress gcc warnings for nim-generated files
set_source_files_properties(${NimSources} PROPERTIES COMPILE_OPTIONS "-w")

add_executable(${OUTPUT_NAME} ${NimSources})

# Add directory containing this CMakeLists file to include search path.
# This is required so that the lwipopts.h file is found. Other headers
# required for a project can also be placed here.
target_include_directories(${OUTPUT_NAME} PUBLIC ${CMAKE_CURRENT_LIST_DIR})

# Get the Nim include path to get nimbase.h
execute_process(
  COMMAND nim "--verbosity:0" "--eval:import std/os; echo getCurrentCompilerExe().parentDir.parentDir / \"lib\""
  OUTPUT_VARIABLE NIM_INCLUDE_PATH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
target_include_directories(${OUTPUT_NAME} PUBLIC "${NIM_INCLUDE_PATH}")

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/imports.cmake)
  include(imports.cmake) # Include our generated file
  link_imported_libs(${OUTPUT_NAME}) # call our generated function to import all libs we're using
endif()

# Add additional libraries, such as the wifi package. It's not automatically loaded
# target_link_libraries(${OUTPUT_NAME} pico_cyw43_arch_lwip_threadsafe_background)

# enable usb output, disable uart output
# add_compile_definitions(PICO_STDIO_USB_CONNECT_WAIT_TIMEOUT_MS=2000)
pico_enable_stdio_usb(${OUTPUT_NAME} 1)
pico_enable_stdio_uart(${OUTPUT_NAME} 0)

# create map/bin/hex/uf2 file etc.
pico_add_extra_outputs(${OUTPUT_NAME})

# add url via pico_set_program_url
#pico_set_program_url(${OUTPUT_NAME} "")
