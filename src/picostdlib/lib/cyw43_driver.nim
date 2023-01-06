
import std/os, std/macros

import ../private

import futhark

import ./lwip
export lwip

import ./cyw43_driver/cyw43_country
export cyw43_country

type
  Cyw43TraceFlag* {.pure.} = enum
    ## Trace flags
    TraceAsyncEv = (0x0001)
    TraceEthTx = (0x0002)
    TraceEthRx = (0x0004)
    TraceEthFull = (0x0008)
    TraceMac = (0x0010)

  Cyw43LinkStatus* {.pure, size: sizeof(cint).} = enum
    LinkBadauth = -3    ## Authenticatation failure
    LinkNonet = -2      ## No matching SSID found (could be out of range, or down)
    LinkFail = -1       ## Connection failed
    LinkDown = 0        ## link is down
    LinkJoin = 1        ## Connected to wifi
    LinkNoip = 2        ## Connected to wifi, but no IP address
    LinkUp = 3          ## Connect to wifi with an IP address

type
  Cyw43Ioctl* {.pure.} = enum
    ##  IOCTL commands
    GetSsid = (0x32)
    GetChannel = (0x3a)
    SetDisassoc = (0x69)
    GetAntdiv = (0x7e)
    SetAntdiv = (0x81)
    SetMonitor = (0xd9)
    GetVar = (0x20c)
    SetVar = (0x20f)

  Cyw43EventType* {.pure.} = enum
    ##  Async events, event_type field
    TypeSetSsid = (0)
    TypeJoin = (1)
    TypeAuth = (3)
    TypeDeauth = (5)
    TypeDeauthInd = (6)
    TypeAssoc = (7)
    TypeDisassoc = (11)
    TypeDisassocInd = (12)
    TypeLink = (16)
    TypePrune = (23)
    TypePskSup = (46)
    TypeEscanResult = (69)
    TypeCsaCompleteInd = (80)
    TypeAssocReqIe = (87)
    TypeAssonRespIe = (88)

  Cyw43EventStatus* {.pure.} = enum
    ##  Event status values
    StatusSuccess = (0)
    StatusFail = (1)
    StatusTimeout = (2)
    StatusNoNetworks = (3)
    StatusAbort = (4)
    StatusNoAck = (5)
    StatusUnsolicited = (6)
    StatusAttempt = (7)
    StatusPartial = (8)
    StatusNewscan = (9)
    StatusNewassoc = (10)

  Cyw43AuthReason* {.pure.} = enum
    ##  Values for AP auth setting
    AuthReasonInitialAssoc = (0) ##  initial assoc
    AuthReasonLowRssi = (1)  ##  roamed due to low RSSI
    AuthReasonDeauth = (2)    ##  roamed due to DEAUTH indication
    AuthReasonDisassoc = (3)  ##  roamed due to DISASSOC indication
    AuthReasonBcnsLost = (4) ##  roamed due to lost beacons
    AuthReasonFastRoamFailed = (5) ##  roamed due to fast roam failure
    AuthReasonDirectedRoam = (6) ##  roamed due to request by AP
    AuthReasonTspecRejected = (7) ##  roamed due to TSPEC rejection
    AuthReasonBetterAp = (8) ##  roamed due to finding better AP

  Cyw43PruneReason* {.pure.} = enum
    ##  prune reason codes
    PruneReasonEncrMismatch = (1) ##  encryption mismatch
    PruneReasonBcastBssid = (2) ##  AP uses a broadcast BSSID
    PruneReasonMacDeny = (3) ##  STA's MAC addr is in AP's MAC deny list
    PruneReasonMacNa = (4) ##  STA's MAC addr is not in AP's MAC allow list
    PruneReasonRegPassv = (5) ##  AP not allowed due to regulatory restriction
    PruneReasonSpctMgmt = (6) ##  AP does not support STA locale spectrum mgmt
    PruneReasonRadar = (7) ##  AP is on a radar channel of STA locale
    PruneReasonRsnMismatch = (8) ##  STA does not support AP's RSN
    PruneReasonNoCommonRates = (9) ##  No rates in common with AP
    PruneReasonBasicRates = (10) ##  STA does not support all basic rates of BSS
    PruneReasonCcxfastPrevap = (11) ##  CCX FAST ROAM: prune previous AP
    PruneReasonCipherNa = (12) ##  BSS's cipher not supported
    PruneReasonKnownSta = (13) ##  AP is already known to us as a STA
    PruneReasonCcxfastDroam = (14) ##  CCX FAST ROAM: prune unqualified AP
    PruneReasonWdsPeer = (15) ##  AP is already known to us as a WDS peer
    PruneReasonQbssLoad = (16) ##  QBSS LOAD - AAC is too low
    PruneReasonHomeAp = (17) ##  prune home AP
    PruneReasonApBlocked = (18) ##  prune blocked AP
    PruneReasonNoDiagSupport = (19) ##  prune due to diagnostic mode not supported

  Cyw43ReasonSup* {.pure.} = enum
    ##  WPA failure reason codes carried in the WLC_E_PSK_SUP event
    ReasonSupOther = (0) ##  Other reason
    ReasonSupDecryptKeyData = (1) ##  Decryption of key data failed
    ReasonSupBadUcastWep128 = (2) ##  Illegal use of ucast WEP128
    ReasonSupBadUcastWep40 = (3) ##  Illegal use of ucast WEP40
    ReasonSupUnsupKeyLen = (4) ##  Unsupported key length
    ReasonSupPwKeyCipher = (5) ##  Unicast cipher mismatch in pairwise key
    ReasonSupMsg3TooManyIe = (6) ##  WPA IE contains > 1 RSN IE in key msg 3
    ReasonSupMsg3IeMismatch = (7) ##  WPA IE mismatch in key message 3
    ReasonSupNoInstallFlag = (8) ##  INSTALL flag unset in 4-way msg
    ReasonSupMsg3NoGtk = (9) ##  encapsulated GTK missing from msg 3
    ReasonSupGrpKeyCipher = (10) ##  Multicast cipher mismatch in group key
    ReasonSupGrpMsg1NoGtk = (11) ##  encapsulated GTK missing from group msg 1
    ReasonSupGtkDecryptFail = (12) ##  GTK decrypt failure
    ReasonSupSendFail = (13) ##  message send failure
    ReasonSupDeauth = (14) ##  received FC_DEAUTH
    ReasonSupWpaPskTmo = (15) ##  WPA PSK 4-way handshake timeout

  Cyw43Auth* {.pure.} = enum
    ##  Values used for STA and AP auth settings
    WpaAuthPsk = (0x0004)
    Wpa2AuthPsk = (0x0080)

  Cyw43AuthType* {.pure, size: sizeof(uint32).} = enum
    ## Authorization types
    ## Used when setting up an access point, or connecting to an access point
    AuthOpen = (0)                   ## No authorisation required (open)
    AuthWpaTkipPsk = (0x00200002)    ## WPA authorisation
    AuthWpa2AesPsk = (0x00400004)    ## WPA2 authorisation (preferred)
    AuthWpa2MixedPsk = (0x00400006)  ## WPA2/WPA mixed authorisation

  Cyw43Itf* {.pure.} = enum
    ## Network interface types
    ItfSta = 0          ## Client interface STA mode
    ItfAp = 1           ## Access point (AP) interface mode

  Cyw43PowersaveMode* = distinct uint32
    ## Power save mode paramter passed to cyw43_ll_wifi_pm

const
  Cyw43NoPowersaveMode* = (0).Cyw43PowersaveMode ##  No Powersave mode
  Cyw43Pm1PowersaveMode* = (1).Cyw43PowersaveMode ##  Powersave mode on specified interface without regard for throughput reduction
  Cyw43Pm2PowersaveMode* = (2).Cyw43PowersaveMode ##  Powersave mode on specified interface with High throughput

const
  ##  Values used for STA and AP auth settings
  Cyw43SupDisconnected* = (0) ##  Disconnected
  Cyw43SupConnecting* = (1)   ##  Connecting
  Cyw43SupIdRequired* = (2)   ##  ID Required
  Cyw43SupAuthenticating* = (3) ##  Authenticating
  Cyw43SupAuthenticated* = (4) ##  Authenticated
  Cyw43SupKeyxchange* = (5)   ##  Key Exchange
  Cyw43SupKeyed* = (6)        ##  Key Exchanged
  Cyw43SupTimeout* = (7)      ##  Timeout
  Cyw43SupLastBasicState* = (8) ##  Last Basic State
  Cyw43SupKeyxchangeWaitM1* = Cyw43SupAuthenticated
  Cyw43SupKeyxchangePrepM2* = Cyw43SupKeyxchange
  Cyw43SupKeyxchangeWaitM3* = Cyw43SupLastBasicState
  Cyw43SupKeyxchangePrepM4* = (9) ##  Preparing to send handshake msg M4
  Cyw43SupKeyxchangeWaitG1* = (10) ##  Waiting to receive handshake msg G1
  Cyw43SupKeyxchangePrepG2* = (11) ##  Preparing to send handshake msg G2


importc:
  sysPath CLANG_INCLUDE_PATH
  sysPath CMAKE_BINARY_DIR / "generated/pico_base"
  sysPath PICO_SDK_PATH / "src/common/pico_base/include"
  sysPath PICO_SDK_PATH / "src/rp2040/hardware_regs/include"
  sysPath PICO_SDK_PATH / "src/rp2_common/pico_platform/include"
  sysPath PICO_SDK_PATH / "src/rp2_common/pico_lwip/include"
  sysPath PICO_SDK_PATH / "src/rp2_common/pico_cyw43_arch/include"
  sysPath PICO_SDK_PATH / "lib/lwip/src/include"
  path PICO_SDK_PATH / "lib/cyw43-driver/src"
  path getProjectPath()

  define PICO_CYW43_ARCH_THREADSAFE_BACKGROUND
  # TODO: Make this configurable

  renameCallback futharkRenameCallback

  "cyw43.h"

template cyw43WifiPm*(self: ptr Cyw43T; pm: Cyw43PowersaveMode): cint = cyw43WifiPm(self, pm.uint32)

proc cyw43WifiScanActive*(self: ptr Cyw43T): bool {.inline.} = self.wifi_scan_state == 1

proc cyw43WifiApGetSsid*(self: ptr Cyw43T; len: ptr csize_t; buf: ptr ptr uint8) {.inline.} =
  len[] = self.ap_ssid_len
  buf[] = self.ap_ssid[0].addr

proc cyw43WifiApSetChannel*(self: ptr Cyw43T; channel: uint32) {.inline.} =
  self.ap_channel = channel.uint8

proc cyw43WifiApSetSsid*(self: ptr Cyw43T; len: csize_t; buf: ptr uint8) {.inline.} =
  self.ap_ssid_len = min(len, self.ap_ssid.len.csize_t).uint8
  copyMem(self.ap_ssid[0].addr, buf, self.ap_ssid_len)

proc cyw43WifiApSetPassword*(self: ptr Cyw43T; len: csize_t; buf: ptr uint8) {.inline.} =
  self.ap_key_len = min(len, self.ap_key.len.csize_t).uint8
  copyMem(self.ap_key[0].addr, buf, self.ap_key_len)

proc cyw43WifiApSetAuth*(self: ptr Cyw43T; auth: uint32) {.inline.} =
  self.ap_auth = auth

proc cyw43IsInitialized*(self: ptr Cyw43T): bool {.inline.} = self.initted

func cyw43PmValue*(pmMode: Cyw43PowersaveMode; pm2SleepRetMs: uint16; liBeaconPeriod: uint8; liDtimPeriod: uint8; liAssoc: uint8): Cyw43PowersaveMode {.inline.} =
  return (
    liAssoc shl 20 or # listen interval sent to ap
    liDtimPeriod shl 16 or
    liBeaconPeriod shl 12 or
    (pm2SleepRetMs div 10) shl 4 or # cyw43_ll_wifi_pm multiplies this by 10
    pmMode.uint8 # CYW43_PM2_POWERSAVE_MODE etc
  ).Cyw43PowersaveMode

const
  Cyw43DefaultPm* = cyw43PmValue(Cyw43Pm2PowersaveMode, 200, 1, 1, 10)
    ## Default power management mode

  Cyw43AggressivePm* = cyw43PmValue(Cyw43Pm2PowersaveMode, 2000, 1, 1, 10)
    ##  Aggressive power management mode for optimial power usage at the cost of performance

  Cyw43PerformancePm* = cyw43PmValue(Cyw43Pm2PowersaveMode, 20, 1, 1, 1)
    ## Performance power management mode where more power is used to increase performance
