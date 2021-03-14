import std/macros

{.push header: "tusb.h".}
type
  HidReport* {.pure, importC: "hid_report_type_t".} = enum
    invalid, input, output, feature

  Protocol* {.pure, importC: "hid_protocol_type_t".} = enum
    none, mouse, keyboard

  SubClass* {.pure, importC: "hid_subclass_type_t".} = enum
    none, boot

  HidDescriptor* {.pure, importC: "hid_descriptor_type_t".} = enum
    hid = 0x21, report = 0x22, physical = 0x23

  HidRequest* {.pure, importC: "hid_request_type_t".} = enum
    getReport = 0x01,
    getIdle = 0x02,
    getProtocol = 0x03,
    setReport = 0x09,
    setIdle = 0x0a,
    setProtocol = 0x0b

  HidCountryCode* {.pure, importC: "hid_country_code_t".} = enum
    notSupported,
    arabic,
    belgian,
    canadianBilingual,
    canadianFrench,
    czechRepublic,
    dannish,
    finnish,
    french,
    german,
    greek,
    hebrew,
    hungary,
    international,
    italian,
    japanKatakana
    korean,
    latinAmerican,
    netherlandsDutch,
    norwegian,
    persianFarsi,
    poland,
    portuguese,
    russia,
    slovakia,
    spanish,
    sweedish,
    swissFrench,
    swissGerman,
    switzerland,
    taiwan,
    turkishQ,
    uk,
    us,
    yugoslavia,
    turkish_f

  MouseButton* {.pure, importC: "hid_mouse_button_bm_t".} = enum
    left, right, middle, back, forward

  MouseReport* {.packed, importC: "hid_mouse_report_t".} = object
    buttons: set[MouseButton]
    x, y, wheel, pan: byte

  KeyModifier* {.pure, importC: "hid_keyboard_modifier_bm_t".} = enum
    lCtrl, lShift, lAlt, lGui, rCtrl, rShift, rAlt, rGui

  KeyboardLed* {.pure, importC: "hid_keyboard_led_bm_t".} = enum
    numLock, capsLock, scrollLock, compose, kana

  KeyboardReport* {.packed, importC: "hid_keyboard_report_t".} = object
    modifier: set[KeyModifier]
    reserved: byte
    keycode: array[6, byte]


{.pop.}

template mountCallback*(body: untyped): untyped =
  proc tudMountCb{.exportC: "tud_mount_cb".} =
    body

template unmountCallback*(body: untyped): untyped =
  proc tudUnmountCb{.exportC: "tud_umount_cb".} =
    body

template suspendCallback*(boolName, body: untyped): untyped =
  proc tudMountCb(boolName: bool){.exportC: "tud_suspend_cb".} =
    body

template resumeCallback*(body: untyped): untyped =
  proc tudResumeCb*{.exportC: "tud_resume_cb".} =
    body

template getReportCb*(reportId, reportType, buffer, reqLen, body) =
  proc tudGetReportCb(reportId: byte, reportType: HidReport,
      buffer: ptr UncheckedArray[byte], reqLen: uint16): uint16{.
      exportC: "tud_hid_get_report_cb".} =
    body
