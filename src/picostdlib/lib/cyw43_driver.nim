##
##  Copyright (C) 2019-2022 George Robotics Pty Ltd
##
##  Redistribution and use in source and binary forms, with or without
##  modification, are permitted provided that the following conditions are met:
##
##  1. Redistributions of source code must retain the above copyright notice,
##     this list of conditions and the following disclaimer.
##  2. Redistributions in binary form must reproduce the above copyright notice,
##     this list of conditions and the following disclaimer in the documentation
##     and/or other materials provided with the distribution.
##  3. Any redistribution, use, or modification in source or binary form is done
##     solely for personal benefit and not for any commercial purpose or for
##     monetary gain.
##
##  THIS SOFTWARE IS PROVIDED BY THE LICENSOR AND COPYRIGHT OWNER "AS IS" AND ANY
##  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
##  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
##  DISCLAIMED. IN NO EVENT SHALL THE LICENSOR OR COPYRIGHT OWNER BE LIABLE FOR
##  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
##  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
##  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
##  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
##  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
##  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
##  This software is also available for use with certain devices under different
##  terms, as set out in the top level LICENSE file.  For commercial licensing
##  options please email contact@georgerobotics.com.au.
##

import std/os, std/macros
import ../helpers

import futhark

import ./lwip
export lwip

import ./cyw43_driver/cyw43_country
export cyw43_country

type
  # Declared before futhark importc to be able to use it as its own type
  Cyw43PowersaveMode* = distinct uint32
    ## Power save mode paramter passed to cyw43_ll_wifi_pm

const
  Cyw43NoPowersaveMode* = (0).Cyw43PowersaveMode ##  No Powersave mode
  Cyw43Pm1PowersaveMode* = (1).Cyw43PowersaveMode ##  Powersave mode on specified interface without regard for throughput reduction
  Cyw43Pm2PowersaveMode* = (2).Cyw43PowersaveMode ##  Powersave mode on specified interface with High throughput


importc:
  compilerArg "--target=arm-none-eabi"
  compilerArg "-mthumb"
  compilerArg "-mcpu=cortex-m0plus"
  compilerArg "-fsigned-char"

  sysPath futhark.getClangIncludePath()
  sysPath armSysrootInclude
  sysPath armInstallInclude
  sysPath cmakeBinaryDir / "generated/pico_base"
  sysPath picoSdkPath / "src/common/pico_base/include"
  sysPath picoSdkPath / "src/rp2040/hardware_regs/include"
  sysPath picoSdkPath / "src/rp2040/hardware_structs/include"
  sysPath picoSdkPath / "src/rp2_common/hardware_base/include"
  sysPath picoSdkPath / "src/rp2_common/hardware_irq/include"
  sysPath picoSdkPath / "src/rp2_common/hardware_gpio/include"
  sysPath picoSdkPath / "src/rp2_common/hardware_timer/include"
  sysPath picoSdkPath / "src/rp2_common/pico_rand/include"
  sysPath picoSdkPath / "src/rp2_common/pico_platform/include"
  sysPath picoSdkPath / "src/common/pico_time/include"
  sysPath picoSdkPath / "src/rp2_common/pico_cyw43_driver/include"
  sysPath picoSdkPath / "src/rp2_common/pico_lwip/include"
  sysPath picoSdkPath / "src/rp2_common/pico_cyw43_arch/include"
  sysPath picoSdkPath / "lib/lwip/src/include"
  path picoSdkPath / "lib/cyw43-driver/src"
  path piconimCsourceDir
  path getProjectPath()

  # TODO: Make this configurable
  define PICO_CYW43_ARCH_THREADSAFE_BACKGROUND

  define "MBEDTLS_USER_CONFIG_FILE \"mbedtls_config.h\""

  renameCallback futharkRenameCallback

  "cyw43.h"


type
  Cyw43TraceFlag* {.pure.} = enum
    ## Trace flags
    TraceAsyncEv = Cyw43TraceAsyncEv
    TraceEthTx = Cyw43TraceEthTx
    TraceEthRx = Cyw43TraceEthRx
    TraceEthFull = Cyw43TraceEthFull
    TraceMac = Cyw43TraceMac

  Cyw43LinkStatus* {.pure.} = enum
    LinkBadauth = Cyw43LinkBadauth  ## Authenticatation failure
    LinkNonet = Cyw43LinkNonet      ## No matching SSID found (could be out of range, or down)
    LinkFail = Cyw43LinkFail        ## Connection failed
    LinkDown = Cyw43LinkDown        ## link is down
    LinkJoin = Cyw43LinkJoin        ## Connected to wifi
    LinkNoip = Cyw43LinkNoip        ## Connected to wifi, but no IP address
    LinkUp = Cyw43LinkUp            ## Connect to wifi with an IP address

  Cyw43Ioctl* {.pure.} = enum
    ## IOCTL commands
    GetSsid = Cyw43IoctlGetSsid
    GetChannel = Cyw43IoctlGetChannel
    SetDisassoc = Cyw43IoctlSetDisassoc
    GetAntdiv = Cyw43IoctlGetAntdiv
    SetAntdiv = Cyw43IoctlSetAntdiv
    SetMonitor = Cyw43IoctlSetMonitor
    GetVar = Cyw43IoctlGetVar
    SetVar = Cyw43IoctlSetVar

  Cyw43EventType* {.pure.} = enum
    ## Async events, event_type field
    EvSetSsid = Cyw43evsetssid
    EvJoin = Cyw43evjoin
    EvAuth = Cyw43evauth
    EvDeauth = Cyw43EvDeauth
    EvDeauthInd = Cyw43EvDeauthInd
    EvAssoc = Cyw43EvAssoc
    EvDisassoc = Cyw43EvDisassoc
    EvDisassocInd = Cyw43EvDisassocInd
    EvLink = Cyw43EvLink
    EvPrune = Cyw43EvPrune
    EvPskSup = Cyw43EvPskSup
    EvEscanResult = Cyw43EvEscanResult
    EvCsaCompleteInd = Cyw43EvCsaCompleteInd
    EvAssocReqIe = Cyw43EvAssocReqIe
    EvAssocRespIe = Cyw43EvAssocRespIe

  Cyw43EventStatus* {.pure.} = enum
    ## Event status values
    StatusSuccess = Cyw43StatusSuccess
    StatusFail = Cyw43StatusFail
    StatusTimeout = Cyw43StatusTimeout
    StatusNoNetworks = Cyw43StatusNoNetworks
    StatusAbort = Cyw43StatusAbort
    StatusNoAck = Cyw43StatusNoAck
    StatusUnsolicited = Cyw43StatusUnsolicited
    StatusAttempt = Cyw43StatusAttempt
    StatusPartial = Cyw43StatusPartial
    StatusNewscan = Cyw43StatusNewscan
    StatusNewassoc = Cyw43StatusNewassoc

  Cyw43AuthReason* {.pure.} = enum
    ## Values for AP auth setting
    AuthReasonInitialAssoc = Cyw43ReasonInitialAssoc ##  initial assoc
    AuthReasonLowRssi = Cyw43ReasonLowRssi  ##  roamed due to low RSSI
    AuthReasonDeauth = Cyw43ReasonDeauth    ##  roamed due to DEAUTH indication
    AuthReasonDisassoc = Cyw43ReasonDisassoc  ##  roamed due to DISASSOC indication
    AuthReasonBcnsLost = Cyw43ReasonBcnsLost ##  roamed due to lost beacons
    AuthReasonFastRoamFailed = Cyw43ReasonFastRoamFailed ##  roamed due to fast roam failure
    AuthReasonDirectedRoam = Cyw43ReasonDirectedRoam ##  roamed due to request by AP
    AuthReasonTspecRejected = Cyw43ReasonTspecRejected ##  roamed due to TSPEC rejection
    AuthReasonBetterAp = Cyw43ReasonBetterAp ##  roamed due to finding better AP

  Cyw43PruneReason* {.pure.} = enum
    ##  prune reason codes
    PruneReasonEncrMismatch = Cyw43ReasonPruneEncrMismatch ##  encryption mismatch
    PruneReasonBcastBssid = Cyw43ReasonPruneBcastBssid ##  AP uses a broadcast BSSID
    PruneReasonMacDeny = Cyw43ReasonPruneMacDeny ##  STA's MAC addr is in AP's MAC deny list
    PruneReasonMacNa = Cyw43ReasonPruneMacNa ##  STA's MAC addr is not in AP's MAC allow list
    PruneReasonRegPassv = Cyw43ReasonPruneRegPassv ##  AP not allowed due to regulatory restriction
    PruneReasonSpctMgmt = Cyw43ReasonPruneSpctMgmt ##  AP does not support STA locale spectrum mgmt
    PruneReasonRadar = Cyw43ReasonPruneRadar ##  AP is on a radar channel of STA locale
    PruneReasonRsnMismatch = Cyw43ReasonRsnMismatch ##  STA does not support AP's RSN
    PruneReasonNoCommonRates = Cyw43ReasonPruneNoCommonRates ##  No rates in common with AP
    PruneReasonBasicRates = Cyw43ReasonPruneBasicRates ##  STA does not support all basic rates of BSS
    PruneReasonCcxfastPrevap = Cyw43ReasonPruneCcxfastPrevap ##  CCX FAST ROAM: prune previous AP
    PruneReasonCipherNa = Cyw43ReasonPruneCipherNa ##  BSS's cipher not supported
    PruneReasonKnownSta = Cyw43ReasonPruneKnownSta ##  AP is already known to us as a STA
    PruneReasonCcxfastDroam = Cyw43ReasonPruneCcxfastDroam ##  CCX FAST ROAM: prune unqualified AP
    PruneReasonWdsPeer = Cyw43ReasonPruneWdsPeer ##  AP is already known to us as a WDS peer
    PruneReasonQbssLoad = Cyw43ReasonPruneQbssLoad ##  QBSS LOAD - AAC is too low
    PruneReasonHomeAp = Cyw43ReasonPruneHomeAp ##  prune home AP
    PruneReasonApBlocked = Cyw43ReasonPruneApBlocked ##  prune blocked AP
    PruneReasonNoDiagSupport = Cyw43ReasonPruneNoDiagSupport ##  prune due to diagnostic mode not supported

  Cyw43ReasonSup* {.pure.} = enum
    ## WPA failure reason codes carried in the WLC_E_PSK_SUP event
    ReasonSupOther = Cyw43ReasonSupOther ##  Other reason
    ReasonSupDecryptKeyData = Cyw43ReasonSupDecryptKeyData ##  Decryption of key data failed
    ReasonSupBadUcastWep128 = Cyw43ReasonSupBadUcastWep128 ##  Illegal use of ucast WEP128
    ReasonSupBadUcastWep40 = Cyw43ReasonSupBadUcastWep40 ##  Illegal use of ucast WEP40
    ReasonSupUnsupKeyLen = Cyw43ReasonSupUnsupKeyLen ##  Unsupported key length
    ReasonSupPwKeyCipher = Cyw43ReasonSupPwKeyCipher ##  Unicast cipher mismatch in pairwise key
    ReasonSupMsg3TooManyIe = Cyw43ReasonSupMsg3TooManyIe ##  WPA IE contains > 1 RSN IE in key msg 3
    ReasonSupMsg3IeMismatch = Cyw43ReasonSupMsg3IeMismatch ##  WPA IE mismatch in key message 3
    ReasonSupNoInstallFlag = Cyw43ReasonSupNoInstallFlag ##  INSTALL flag unset in 4-way msg
    ReasonSupMsg3NoGtk = Cyw43ReasonSupMsg3NoGtk ##  encapsulated GTK missing from msg 3
    ReasonSupGrpKeyCipher = Cyw43ReasonSupGrpKeyCipher ##  Multicast cipher mismatch in group key
    ReasonSupGrpMsg1NoGtk = Cyw43ReasonSupGrpMsg1NoGtk ##  encapsulated GTK missing from group msg 1
    ReasonSupGtkDecryptFail = Cyw43ReasonSupGtkDecryptFail ##  GTK decrypt failure
    ReasonSupSendFail = Cyw43ReasonSupSendFail ##  message send failure
    ReasonSupDeauth = Cyw43ReasonSupDeauth ##  received FC_DEAUTH
    ReasonSupWpaPskTmo = Cyw43ReasonSupWpaPskTmo ##  WPA PSK 4-way handshake timeout

  Cyw43Auth* {.pure.} = enum
    ## Values used for STA and AP auth settings
    WpaAuthPsk = Cyw43WpaAuthPsk
    Wpa2AuthPsk = Cyw43Wpa2AuthPsk

  Cyw43AuthType* {.pure, size: sizeof(uint32).} = enum
    ## Authorization types
    ## Used when setting up an access point, or connecting to an access point
    AuthOpen = Cyw43AuthOpen                  ## No authorisation required (open)
    AuthWpaTkipPsk = Cyw43AuthWpaTkipPsk      ## WPA authorisation
    AuthWpa2AesPsk = Cyw43AuthWpa2AesPsk      ## WPA2 authorisation (preferred)
    AuthWpa2MixedPsk = Cyw43AuthWpa2MixedPsk  ## WPA2/WPA mixed authorisation

  Cyw43Itf* {.pure, size: sizeof(cuint).} = enum
    ## Network interface types
    ItfSta = Cyw43itfsta         ## Client interface STA mode
    ItfAp = Cyw43itfap           ## Access point (AP) interface mode
  

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

# TODO: When pico-sdk updates, remove the uint8 here
# Current stable pico-sdk uses a version of cyw43_driver that has it set to uint8
# For now, make it compile with both
proc cyw43WifiApSetAuth*(self: ptr Cyw43T; auth: uint32|uint8) {.inline.} =
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
    ## Aggressive power management mode for optimial power usage at the cost of performance

  Cyw43PerformancePm* = cyw43PmValue(Cyw43Pm2PowersaveMode, 20, 1, 1, 1)
    ## Performance power management mode where more power is used to increase performance
