const examples = [
  "adc/hello_adc",
  "adc/onboard_temperature",
  "blink",
  "clocks/hello_48mhz",
  "clocks/hello_gpout",
  "clocks/hello_resus",
  "dma/hello_dma",
  "flash/hello_littlefs",
  "gpio/hello_7segment",
  "gpio/hello_gpio_irq",
  # "hello_pio/hello_pio",
  "hello_serial",
  "hello_stdio",
  "hello_timestart",
  "i2c/bus_scan",
  # "joystickdisplay",
  # "lightsensor",
  "multicore/hello_multicore",
  "pico_w/picow_blink",
  "pico_w/picow_ntp_client",
  "pico_w/picow_tls_client",
  "pico_w/picow_wifi_scan",
  "pwm/hello_pwm",
  "pwm/pwm_led_fade",
  "reset/hello_reset",
  "rtc/hello_rtc",
  "rtc/rtc_alarm",
  "system/unique_board_id",
  "timer/hello_timer",
  # "tinyusb/tinyusb",
  "uart/hello_uart",
  "watchdog/hello_watchdog",
  # "ws2812_pio/ws2812_pio",
]

exec "cmake -DPICO_SDK_FETCH_FROM_GIT=on -DPICO_BOARD=pico -S examples -B build/examples"
for ex in examples:
  exec "nim c examples/" & ex
exec "cmake --build build/examples -- -j4"
exec "cmake -DPICO_SDK_FETCH_FROM_GIT=on -DPICO_BOARD=pico_w -S examples -B build/examples"
exec "cmake --build build/examples -- -j4"
