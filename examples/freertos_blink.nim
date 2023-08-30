import picostdlib
import picostdlib/lib/freertos

let led = DefaultLedPin

const mainTaskPriority = tskIDLE_PRIORITY + 2
const blinkTaskPriority = tskIDLE_PRIORITY + 1

proc blinkTask(params: pointer) {.cdecl.} =
  let blinkDelay = cast[ptr uint32](params)[]
  while true:
    led.put(High)
    vTaskDelay(blinkDelay)
    led.put(Low)
    vTaskDelay(blinkDelay)

proc mainTask(params: pointer) {.cdecl.} =
  led.init()
  led.setDir(Out)

  var blink1TaskHandle: TaskHandleT
  var blink1Delay: uint32 = 500
  discard xTaskCreate(blinkTask, "BlinkTask1", 128, blink1Delay.addr, blinkTaskPriority, blink1TaskHandle.addr)

  while true:
    vTaskDelay(1000)

  led.deinit()

proc vLaunch() =
  var mainTaskHandle: TaskHandleT
  discard xTaskCreate(mainTask, "MainTask", 128, nil, mainTaskPriority, mainTaskHandle.addr)

  vTaskStartScheduler()

  while true:
    tightLoopContents()

vLaunch()
