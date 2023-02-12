##
## Copyright (C) 2009 BlueKitchen GmbH
## All rights reserved 
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
##
## 1. Redistributions of source code must retain the above copyright
##    notice, this list of conditions and the following disclaimer.
##
## 2. Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in the
##    documentation and/or other materials provided with the distribution.
##
## 3. Neither the name of the copyright holders nor the names of
##    contributors may be used to endorse or promote products derived
##    from this software without specific prior written permission.
##
## 4. Any redistribution, use, or modification is done solely for
##    personal benefit and not for any commercial purpose or for
##    monetary gain.
##
## THIS SOFTWARE IS PROVIDED BY BLUEKITCHEN GMBH AND CONTRIBUTORS
## ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
## LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
## FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BLUEKITCHEN 
## GMBH OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
## INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
## BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
## OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
## AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
## THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
## SUCH DAMAGE.
##
## Please inquire about commercial licensing options at 
## contact@bluekitchen-gmbh.com
##


import std/os, std/macros
import ../private

import futhark

import ./btstack
export btstack

importc:
  sysPath futhark.getClangIncludePath()
  sysPath picoSdkPath / "lib/btstack/src"
  sysPath cmakeSourceDir
  sysPath getProjectPath()

  compilerArg "-fshort-enums"

  renameCallback futharkRenameCallback

  "ble/att_db.h"
  "ble/att_db_util.h"
  "ble/att_dispatch.h"
  "ble/att_server.h"
  "ble/core.h"
  "ble/gatt_client.h"
  "ble/gatt-service/ancs_client.h"
  "ble/gatt-service/battery_service_client.h"
  "ble/gatt-service/battery_service_server.h"
  "ble/gatt-service/bond_management_service_server.h"
  "ble/gatt-service/cycling_power_service_server.h"
  "ble/gatt-service/cycling_speed_and_cadence_service_server.h"
  "ble/gatt-service/device_information_service_client.h"
  "ble/gatt-service/device_information_service_server.h"
  "ble/gatt-service/heart_rate_service_server.h"
  "ble/gatt-service/hids_client.h"
  "ble/gatt-service/hids_device.h"
  "ble/gatt-service/nordic_spp_service_server.h"
  "ble/gatt-service/scan_parameters_service_client.h"
  "ble/gatt-service/scan_parameters_service_server.h"
  "ble/gatt-service/tx_power_service_server.h"
  "ble/gatt-service/ublox_spp_service_server.h"
  "ble/le_device_db.h"
  "ble/le_device_db_tlv.h"
  "ble/sm.h"
