{.warning[UnusedImport]:off.}

# stdlib
import picostdlib

import picostdlib/hardware/regs/clocks as hardware_regs_clocks
import picostdlib/hardware/regs/intctrl as hardware_regs_intctrl
import picostdlib/hardware/regs/resets as hardware_regs_resets
import picostdlib/hardware/regs/spi as hardware_regs_spi

import picostdlib/hardware/structs/clocks as hardware_structs_clocks
import picostdlib/hardware/structs/i2c as hardware_structs_i2c
import picostdlib/hardware/structs/interp as hardware_structs_interp
import picostdlib/hardware/structs/rosc as hardware_structs_rosc
import picostdlib/hardware/structs/spi as hardware_structs_spi
import picostdlib/hardware/structs/uart as hardware_structs_uart

import picostdlib/hardware/adc
import picostdlib/hardware/base
import picostdlib/hardware/claim
import picostdlib/hardware/clocks as hardware_clocks
block:
  discard clockGetHz(Sys)
import picostdlib/hardware/divider as hardware_divider
import picostdlib/hardware/dma
import picostdlib/hardware/exception
block:
  exceptionRestoreHandler(SVCallException, exceptionSetExclusiveHandler(SVCallException, proc() {.cdecl.} = discard))
import picostdlib/hardware/flash
import picostdlib/hardware/gpio
import picostdlib/hardware/i2c
import picostdlib/hardware/interp
import picostdlib/hardware/irq
import picostdlib/hardware/pio
import picostdlib/hardware/pll
import picostdlib/hardware/pwm
import picostdlib/hardware/resets
import picostdlib/hardware/rtc
import picostdlib/hardware/spi
import picostdlib/hardware/sync as hardware_sync
import picostdlib/hardware/timer
import picostdlib/hardware/uart
import picostdlib/hardware/vreg
import picostdlib/hardware/watchdog
import picostdlib/hardware/xosc

import picostdlib/pico/util/datetime
import picostdlib/pico/util/pheap
import picostdlib/pico/util/queue

import picostdlib/pico/async_context
import picostdlib/pico/binary_info
block:
  bi_decl_include()
  bi_decl(bi_block_device(BINARY_INFO_MAKE_TAG('N', 'I'), "\"Nim\"", 0x1000, 1024, nil, {FlagRead, FlagWrite, FlagPtUnknown}))
import picostdlib/pico/bit_ops
import picostdlib/pico/bootrom
import picostdlib/pico/critical_section
import picostdlib/pico/divider
import picostdlib/pico/double
import picostdlib/pico/error
import picostdlib/pico/flash
import picostdlib/pico/"float"
import picostdlib/pico/i2c_slave
import picostdlib/pico/lock_core
import picostdlib/pico/multicore
import picostdlib/pico/mutex
import picostdlib/pico/platform
import picostdlib/pico/rand
import picostdlib/pico/sem
import picostdlib/pico/stdio
import picostdlib/pico/sync
import picostdlib/pico/time
import picostdlib/pico/types
import picostdlib/pico/unique_id
import picostdlib/pico/version

# misc
import picostdlib/memoryinfo
import picostdlib/sevensegdisplay

# futhark stuff
import picostdlib/lib/littlefs

# examples
import ../examples/blink
import ../examples/adc/hello_adc
import ../examples/adc/onboard_temperature
import ../examples/clocks/hello_48mhz
import ../examples/clocks/hello_gpout
import ../examples/clocks/hello_resus
import ../examples/dma/hello_dma
import ../examples/flash/hello_littlefs
import ../examples/gpio/hello_gpio_irq
import ../examples/i2c/bus_scan
import ../examples/multicore/hello_multicore
import ../examples/pwm/hello_pwm
import ../examples/pwm/pwm_led_fade
import ../examples/reset/hello_reset
import ../examples/rtc/hello_rtc
import ../examples/rtc/rtc_alarm
import ../examples/system/unique_board_id
import ../examples/timer/hello_timer
import ../examples/uart/hello_uart
import ../examples/watchdog/hello_watchdog
import ../examples/hello_serial
import ../examples/hello_stdio
import ../examples/hello_timestart

# include blink from template
include ../src/picostdlib/build_utils/"template"/src/blink
