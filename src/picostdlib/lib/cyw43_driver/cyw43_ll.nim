##
##  This file is part of the cyw43-driver
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

{.push header: "cyw43_ll.h".}

##  External interface
## *
##  \addtogroup cyw43_ll
##
## !\{
## *
##   \file cyw43_ll.h
##   \brief Low Level CYW43 driver interface
##
##  IOCTL commands

const
  CYW43_IOCTL_GET_SSID* = (0x32)
  CYW43_IOCTL_GET_CHANNEL* = (0x3a)
  CYW43_IOCTL_SET_DISASSOC* = (0x69)
  CYW43_IOCTL_GET_ANTDIV* = (0x7e)
  CYW43_IOCTL_SET_ANTDIV* = (0x81)
  CYW43_IOCTL_SET_MONITOR* = (0xd9)
  CYW43_IOCTL_GET_VAR* = (0x20c)
  CYW43_IOCTL_SET_VAR* = (0x20f)

##  Async events, event_type field

const
  CYW43_EV_SET_SSID* = (0)
  CYW43_EV_JOIN* = (1)
  CYW43_EV_AUTH* = (3)
  CYW43_EV_DEAUTH* = (5)
  CYW43_EV_DEAUTH_IND* = (6)
  CYW43_EV_ASSOC* = (7)
  CYW43_EV_DISASSOC* = (11)
  CYW43_EV_DISASSOC_IND* = (12)
  CYW43_EV_LINK* = (16)
  CYW43_EV_PRUNE* = (23)
  CYW43_EV_PSK_SUP* = (46)
  CYW43_EV_ESCAN_RESULT* = (69)
  CYW43_EV_CSA_COMPLETE_IND* = (80)
  CYW43_EV_ASSOC_REQ_IE* = (87)
  CYW43_EV_ASSOC_RESP_IE* = (88)

##  Event status values

const
  CYW43_STATUS_SUCCESS* = (0)
  CYW43_STATUS_FAIL* = (1)
  CYW43_STATUS_TIMEOUT* = (2)
  CYW43_STATUS_NO_NETWORKS* = (3)
  CYW43_STATUS_ABORT* = (4)
  CYW43_STATUS_NO_ACK* = (5)
  CYW43_STATUS_UNSOLICITED* = (6)
  CYW43_STATUS_ATTEMPT* = (7)
  CYW43_STATUS_PARTIAL* = (8)
  CYW43_STATUS_NEWSCAN* = (9)
  CYW43_STATUS_NEWASSOC* = (10)

##  Values used for STA and AP auth settings

const
  CYW43_SUP_DISCONNECTED* = (0) ##  Disconnected
  CYW43_SUP_CONNECTING* = (1)   ##  Connecting
  CYW43_SUP_IDREQUIRED* = (2)   ##  ID Required
  CYW43_SUP_AUTHENTICATING* = (3) ##  Authenticating
  CYW43_SUP_AUTHENTICATED* = (4) ##  Authenticated
  CYW43_SUP_KEYXCHANGE* = (5)   ##  Key Exchange
  CYW43_SUP_KEYED* = (6)        ##  Key Exchanged
  CYW43_SUP_TIMEOUT* = (7)      ##  Timeout
  CYW43_SUP_LAST_BASIC_STATE* = (8) ##  Last Basic State
  CYW43_SUP_KEYXCHANGE_WAIT_M1* = CYW43_SUP_AUTHENTICATED
  CYW43_SUP_KEYXCHANGE_PREP_M2* = CYW43_SUP_KEYXCHANGE
  CYW43_SUP_KEYXCHANGE_WAIT_M3* = CYW43_SUP_LAST_BASIC_STATE
  CYW43_SUP_KEYXCHANGE_PREP_M4* = (9) ##  Preparing to send handshake msg M4
  CYW43_SUP_KEYXCHANGE_WAIT_G1* = (10) ##  Waiting to receive handshake msg G1
  CYW43_SUP_KEYXCHANGE_PREP_G2* = (11) ##  Preparing to send handshake msg G2

##  Values for AP auth setting

const
  CYW43_REASON_INITIAL_ASSOC* = (0) ##  initial assoc
  CYW43_REASON_LOW_RSSI* = (1)  ##  roamed due to low RSSI
  CYW43_REASON_DEAUTH* = (2)    ##  roamed due to DEAUTH indication
  CYW43_REASON_DISASSOC* = (3)  ##  roamed due to DISASSOC indication
  CYW43_REASON_BCNS_LOST* = (4) ##  roamed due to lost beacons
  CYW43_REASON_FAST_ROAM_FAILED* = (5) ##  roamed due to fast roam failure
  CYW43_REASON_DIRECTED_ROAM* = (6) ##  roamed due to request by AP
  CYW43_REASON_TSPEC_REJECTED* = (7) ##  roamed due to TSPEC rejection
  CYW43_REASON_BETTER_AP* = (8) ##  roamed due to finding better AP

##  prune reason codes

const
  CYW43_REASON_PRUNE_ENCR_MISMATCH* = (1) ##  encryption mismatch
  CYW43_REASON_PRUNE_BCAST_BSSID* = (2) ##  AP uses a broadcast BSSID
  CYW43_REASON_PRUNE_MAC_DENY* = (3) ##  STA's MAC addr is in AP's MAC deny list
  CYW43_REASON_PRUNE_MAC_NA* = (4) ##  STA's MAC addr is not in AP's MAC allow list
  CYW43_REASON_PRUNE_REG_PASSV* = (5) ##  AP not allowed due to regulatory restriction
  CYW43_REASON_PRUNE_SPCT_MGMT* = (6) ##  AP does not support STA locale spectrum mgmt
  CYW43_REASON_PRUNE_RADAR* = (7) ##  AP is on a radar channel of STA locale
  CYW43_REASON_RSN_MISMATCH* = (8) ##  STA does not support AP's RSN
  CYW43_REASON_PRUNE_NO_COMMON_RATES* = (9) ##  No rates in common with AP
  CYW43_REASON_PRUNE_BASIC_RATES* = (10) ##  STA does not support all basic rates of BSS
  CYW43_REASON_PRUNE_CCXFAST_PREVAP* = (11) ##  CCX FAST ROAM: prune previous AP
  CYW43_REASON_PRUNE_CIPHER_NA* = (12) ##  BSS's cipher not supported
  CYW43_REASON_PRUNE_KNOWN_STA* = (13) ##  AP is already known to us as a STA
  CYW43_REASON_PRUNE_CCXFAST_DROAM* = (14) ##  CCX FAST ROAM: prune unqualified AP
  CYW43_REASON_PRUNE_WDS_PEER* = (15) ##  AP is already known to us as a WDS peer
  CYW43_REASON_PRUNE_QBSS_LOAD* = (16) ##  QBSS LOAD - AAC is too low
  CYW43_REASON_PRUNE_HOME_AP* = (17) ##  prune home AP
  CYW43_REASON_PRUNE_AP_BLOCKED* = (18) ##  prune blocked AP
  CYW43_REASON_PRUNE_NO_DIAG_SUPPORT* = (19) ##  prune due to diagnostic mode not supported

##  WPA failure reason codes carried in the WLC_E_PSK_SUP event

const
  CYW43_REASON_SUP_OTHER* = (0) ##  Other reason
  CYW43_REASON_SUP_DECRYPT_KEY_DATA* = (1) ##  Decryption of key data failed
  CYW43_REASON_SUP_BAD_UCAST_WEP128* = (2) ##  Illegal use of ucast WEP128
  CYW43_REASON_SUP_BAD_UCAST_WEP40* = (3) ##  Illegal use of ucast WEP40
  CYW43_REASON_SUP_UNSUP_KEY_LEN* = (4) ##  Unsupported key length
  CYW43_REASON_SUP_PW_KEY_CIPHER* = (5) ##  Unicast cipher mismatch in pairwise key
  CYW43_REASON_SUP_MSG3_TOO_MANY_IE* = (6) ##  WPA IE contains > 1 RSN IE in key msg 3
  CYW43_REASON_SUP_MSG3_IE_MISMATCH* = (7) ##  WPA IE mismatch in key message 3
  CYW43_REASON_SUP_NO_INSTALL_FLAG* = (8) ##  INSTALL flag unset in 4-way msg
  CYW43_REASON_SUP_MSG3_NO_GTK* = (9) ##  encapsulated GTK missing from msg 3
  CYW43_REASON_SUP_GRP_KEY_CIPHER* = (10) ##  Multicast cipher mismatch in group key
  CYW43_REASON_SUP_GRP_MSG1_NO_GTK* = (11) ##  encapsulated GTK missing from group msg 1
  CYW43_REASON_SUP_GTK_DECRYPT_FAIL* = (12) ##  GTK decrypt failure
  CYW43_REASON_SUP_SEND_FAIL* = (13) ##  message send failure
  CYW43_REASON_SUP_DEAUTH* = (14) ##  received FC_DEAUTH
  CYW43_REASON_SUP_WPA_PSK_TMO* = (15) ##  WPA PSK 4-way handshake timeout

##  Values used for STA and AP auth settings

const
  CYW43_WPA_AUTH_PSK* = (0x0004)
  CYW43_WPA2_AUTH_PSK* = (0x0080)

## *
##  \name Authorization types
##  \brief Used when setting up an access point, or connecting to an access point
##  \anchor CYW43_AUTH_
##
## !\{

const
  CYW43_AUTH_OPEN* = (0)        ## /< No authorisation required (open)
  CYW43_AUTH_WPA_TKIP_PSK* = (0x00200002) ## /< WPA authorisation
  CYW43_AUTH_WPA2_AES_PSK* = (0x00400004) ## /< WPA2 authorisation (preferred)
  CYW43_AUTH_WPA2_MIXED_PSK* = (0x00400006) ## /< WPA2/WPA mixed authorisation
                                         ## !\}

## !
##  \brief Power save mode paramter passed to cyw43_ll_wifi_pm
##

const
  CYW43_NO_POWERSAVE_MODE* = (0) ## /< No Powersave mode
  CYW43_PM1_POWERSAVE_MODE* = (1) ## /< Powersave mode on specified interface without regard for throughput reduction
  CYW43_PM2_POWERSAVE_MODE* = (2) ## /< Powersave mode on specified interface with High throughput

## !
##  \brief Network interface types
##  \anchor CYW43_ITF_
##
## !\{

const
  CYW43_ITF_STA* = 0            ## /< Client interface STA mode
  CYW43_ITF_AP* = 1             ## /< Access point (AP) interface mode

## !\}
## !
##  \brief Structure to return wifi scan results
##
## !\{

type
  Cyw43EvScanResultT* {.importc: "cyw43_ev_scan_result_t", bycopy.} = object
    `0`* {.importc: "_0".}: array[5, uint32]
    bssid* {.importc: "bssid".}: array[6, uint8] ## /< access point mac address
    `1`* {.importc: "_1".}: array[2, uint16]
    ssidLen* {.importc: "ssid_len".}: uint8 ## /< length of wlan access point name
    ssid* {.importc: "ssid".}: array[32, uint8] ## /< wlan access point name
    `2`* {.importc: "_2".}: array[5, uint32]
    channel* {.importc: "channel".}: uint16 ## /< wifi channel
    `3`* {.importc: "_3".}: uint16
    authMode* {.importc: "auth_mode".}: uint8 ## /< wifi auth mode \ref CYW43_AUTH_
    rssi* {.importc: "rssi".}: int16 ## /< signal strength


## !\}

type
  INNER_C_UNION_cyw43_ll_222* {.importc: "cyw43_async_event_t::no_name", bycopy, union.} = object
    scanResult* {.importc: "scan_result".}: Cyw43EvScanResultT

  Cyw43AsyncEventT* {.importc: "cyw43_async_event_t", bycopy.} = object
    `0`* {.importc: "_0".}: uint16
    flags* {.importc: "flags".}: uint16
    eventType* {.importc: "event_type".}: uint32
    status* {.importc: "status".}: uint32
    reason* {.importc: "reason".}: uint32
    `1`* {.importc: "_1".}: array[30, uint8]
    `interface`* {.importc: "interface".}: uint8
    `2`* {.importc: "_2".}: uint8
    u* {.importc: "u".}: INNER_C_UNION_cyw43_ll_222


## !
##  \brief wifi scan options passed to cyw43_wifi_scan
##
## !\{

type
  Cyw43WifiScanOptionsT* {.importc: "cyw43_wifi_scan_options_t", bycopy.} = object
    version* {.importc: "version".}: uint32 ## /< version (not used)
    action* {.importc: "action".}: uint16 ## /< action (not used)
    _* {.importc: "_".}: uint16 ## /< not used
    ssidLen* {.importc: "ssid_len".}: uint32 ## /< ssid length, 0=all
    ssid* {.importc: "ssid".}: array[32, uint8] ## /< ssid name
    bssid* {.importc: "bssid".}: array[6, uint8] ## /< bssid (not used)
    bssType* {.importc: "bss_type".}: int8 ## /< bssid type (not used)
    scanType* {.importc: "scan_type".}: int8 ## /< scan type 0=active, 1=passive
    nprobes* {.importc: "nprobes".}: int32 ## /< number of probes (not used)
    activeTime* {.importc: "active_time".}: int32 ## /< active time (not used)
    passiveTime* {.importc: "passive_time".}: int32 ## /< passive time (not used)
    homeTime* {.importc: "home_time".}: int32 ## /< home time (not used)
    channelNum* {.importc: "channel_num".}: int32 ## /< number of channels (not used)
    channelList* {.importc: "channel_list".}: array[1, uint16] ## /< channel list (not used)


## !\}

type
  Cyw43LlT* {.importc: "cyw43_ll_t", bycopy.} = object
    opaque* {.importc: "opaque".}: array[526 + 7, uint32] ##  note: array of words


proc cyw43LlInit*(self: ptr Cyw43LlT; cbData: pointer) {.importc: "cyw43_ll_init".}
proc cyw43LlDeinit*(self: ptr Cyw43LlT) {.importc: "cyw43_ll_deinit".}
proc cyw43LlBusInit*(self: ptr Cyw43LlT; mac: ptr uint8): cint {.importc: "cyw43_ll_bus_init".}
proc cyw43LlBusSleep*(self: ptr Cyw43LlT; canSleep: bool) {.importc: "cyw43_ll_bus_sleep".}
proc cyw43LlProcessPackets*(self: ptr Cyw43LlT) {.importc: "cyw43_ll_process_packets".}
proc cyw43LlIoctl*(self: ptr Cyw43LlT; cmd: uint32; len: csize_t; buf: ptr uint8;
                  iface: uint32): cint {.importc: "cyw43_ll_ioctl".}
proc cyw43LlSendEthernet*(self: ptr Cyw43LlT; itf: cint; len: csize_t; buf: pointer;
                         isPbuf: bool): cint {.importc: "cyw43_ll_send_ethernet".}
proc cyw43LlWifiOn*(self: ptr Cyw43LlT; country: uint32): cint {.importc: "cyw43_ll_wifi_on".}
proc cyw43LlWifiPm*(self: ptr Cyw43LlT; pm: uint32; pmSleepRet: uint32;
                   liBcn: uint32; liDtim: uint32; liAssoc: uint32): cint {.importc: "cyw43_ll_wifi_pm".}
proc cyw43LlWifiScan*(self: ptr Cyw43LlT; opts: ptr Cyw43WifiScanOptionsT): cint {.importc: "cyw43_ll_wifi_scan".}
proc cyw43LlWifiJoin*(self: ptr Cyw43LlT; ssidLen: csize_t; ssid: ptr uint8;
                     keyLen: csize_t; key: ptr uint8; authType: uint32;
                     bssid: ptr uint8; channel: uint32): cint {.importc: "cyw43_ll_wifi_join".}
proc cyw43LlWifiSetWpaAuth*(self: ptr Cyw43LlT) {.importc: "cyw43_ll_wifi_set_wpa_auth".}
proc cyw43LlWifiRejoin*(self: ptr Cyw43LlT) {.importc: "cyw43_ll_wifi_rejoin".}
proc cyw43LlWifiApInit*(self: ptr Cyw43LlT; ssidLen: csize_t; ssid: ptr uint8;
                       auth: uint32; keyLen: csize_t; key: ptr uint8;
                       channel: uint32): cint {.importc: "cyw43_ll_wifi_ap_init".}
proc cyw43LlWifiApSetUp*(self: ptr Cyw43LlT; up: bool): cint {.importc: "cyw43_ll_wifi_ap_set_up".}
proc cyw43LlWifiApGetStas*(self: ptr Cyw43LlT; numStas: ptr cint; macs: ptr uint8): cint {.importc: "cyw43_ll_wifi_ap_get_stas".}

when defined(cyw43Gpio):
  proc cyw43LlGpioSet*(self: ptr Cyw43LlT; gpioN: cint; gpioEn: bool): cint {.importc: "cyw43_ll_gpio_set".}
  proc cyw43LlGpioGet*(selfIn: ptr Cyw43LlT; gpioN: cint; gpioEn: ptr bool): cint {.importc: "cyw43_ll_gpio_get".}

##  Get mac address
proc cyw43LlWifiGetMac*(selfIn: ptr Cyw43LlT; `addr`: ptr uint8): cint {.importc: "cyw43_ll_wifi_get_mac".}

##  Returns true while there's work to do
proc cyw43LlHasWork*(self: ptr Cyw43LlT): bool {.importc: "cyw43_ll_has_work".}

##  Callbacks to be provided by mid-level interface
proc cyw43CbReadHostInterruptPin*(cbData: pointer): cint {.importc: "cyw43_cb_read_host_interrupt_pin".}
proc cyw43CbEnsureAwake*(cbData: pointer) {.importc: "cyw43_cb_ensure_awake".}
proc cyw43CbProcessAsyncEvent*(cbData: pointer; ev: ptr Cyw43AsyncEventT) {.importc: "cyw43_cb_process_async_event".}
proc cyw43CbProcessEthernet*(cbData: pointer; itf: cint; len: csize_t; buf: ptr uint8) {.importc: "cyw43_cb_process_ethernet".}


{.pop.}
