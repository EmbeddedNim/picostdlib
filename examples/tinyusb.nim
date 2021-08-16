import picostdlib/[tusb]
import encode
type BlinkAmount = enum
  notMounted = 250u32
  mounted = 1000
  suspended = 2500


const deviceDesc = DeviceDescription(
  len: sizeof(DeviceDescription).byte,
  descType: device,
  binCodeUsb: 0x0200,
  class: 0x00,
  subclass: 0x00,
  protocol: 0x00,
  maxPacketSize: EndpointSize,
  vendorId: 0xcafe,
  productId: {UsbPid.hid},
  manufacturer: 0x01,
  product: 0x02,
  serialNumber: 0x03,
  configNumber: 0x01)

deviceDescriptorCallback:
  let a = deviceDesc
  return cast[ptr uint8](a.unsafeAddr)

deviceDescriptorReportCallback:
  let a = TudHidMouseReport
  return cast[ptr uint8](a.unsafeAddr)

var state = notMounted

mountCallback:
  state = mounted

unmountCallback:
  state = notMounted

suspendCallback(wakeUpEnabled):
  state = suspended

resumeCallback:
  state = mounted

const stringDesc = (($0x09) & ($0x04) & "TinyUSB" & "TinyUSB Device" & "123456")

deviceDescriptorStringCallback(index, langId):
  let res = stringDesc.toUtf16LE().cstring
  cast[ptr uint16](res[0].unsafeAddr)

proc blink() =
  var
    start = 0u32
    led = false

  if millis() - start > state.ord.uint32:
    start += state.ord.uint32
    ledWrite(led)
    led = not led

proc hidTask() =
  let interval = 10u32
  var start = 0u32
  if millis() - start >= interval:
    if usbSuspended():
      discard usbRemoteWakeup()

    if hidReady():
      let delta = 5u8
      discard mouseReport(MouseReportId, {}, delta, delta, 0u8, 0u8)
      delay(10)



proc main() =
  boardInit()
  discard usbInit()
  while true:
    usbTask()
    blink()
    hidTask()

main()
