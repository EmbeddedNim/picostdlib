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

importc:
  sysPath futhark.getClangIncludePath()
  sysPath picoSdkPath / "lib/btstack/src"
  path cmakeSourceDir
  path getProjectPath()

  compilerArg "-fshort-enums"

  renameCallback futharkRenameCallback

  "ad_parser.h"
  "bluetooth_company_id.h"
  "bluetooth_data_types.h"
  "bluetooth_gatt.h"
  "bluetooth.h"
  "bluetooth_psm.h"
  "bluetooth_sdp.h"
  "btstack_audio.h"
  "btstack_base64_decoder.h"
  "btstack_bool.h"
  "btstack_chipset.h"
  "btstack_control.h"
  "btstack_crypto.h"
  "btstack_debug.h"
  "btstack_defines.h"
  "btstack_em9304_spi.h"
  "btstack_event.h"
  "btstack.h"
  "btstack_hid.h"
  "btstack_hid_parser.h"
  "btstack_lc3_google.h"
  "btstack_lc3.h"
  "btstack_linked_list.h"
  "btstack_linked_queue.h"
  "btstack_memory.h"
  "btstack_memory_pool.h"
  "btstack_network.h"
  "btstack_resample.h"
  "btstack_ring_buffer.h"
  "btstack_run_loop_base.h"
  "btstack_run_loop.h"
  "btstack_sample_rate_compensation.h"
  "btstack_sco_transport.h"
  "btstack_slip.h"
  "btstack_stdin.h"
  "btstack_tlv.h"
  "btstack_tlv_none.h"
  "btstack_uart_block.h"
  "btstack_uart.h"
  "btstack_uart_slip_wrapper.h"
  "btstack_util.h"

  "gap.h"
  "hci_cmd.h"
  "hci_dump.h"
  "hci.h"
  "hci_transport_em9304_spi.h"
  "hci_transport.h"
  "hci_transport_h4.h"
  "hci_transport_h5.h"
  "hci_transport_usb.h"
  "l2cap.h"
  "l2cap_signaling.h"



