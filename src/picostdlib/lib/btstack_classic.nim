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

  "classic/a2dp.h"
  "classic/a2dp_sink.h"
  "classic/a2dp_source.h"
  "classic/avdtp_acceptor.h"
  "classic/avdtp.h"
  "classic/avdtp_initiator.h"
  "classic/avdtp_sink.h"
  "classic/avdtp_source.h"
  "classic/avdtp_util.h"
  "classic/avrcp_browsing_controller.h"
  "classic/avrcp_browsing.h"
  "classic/avrcp_browsing_target.h"
  "classic/avrcp_controller.h"
  "classic/avrcp.h"
  "classic/avrcp_media_item_iterator.h"
  "classic/avrcp_target.h"
  "classic/bnep.h"
  "classic/btstack_cvsd_plc.h"
  "classic/btstack_link_key_db.h"
  "classic/btstack_link_key_db_memory.h"
  "classic/btstack_link_key_db_static.h"
  "classic/btstack_link_key_db_tlv.h"
  "classic/btstack_sbc.h"
  "classic/btstack_sbc_plc.h"
  "classic/core.h"
  "classic/device_id_server.h"
  "classic/gatt_sdp.h"
  "classic/goep_client.h"
  "classic/goep_server.h"
  "classic/hfp_ag.h"
  "classic/hfp_gsm_model.h"
  "classic/hfp.h"
  "classic/hfp_hf.h"
  "classic/hfp_msbc.h"
  "classic/hid_device.h"
  "classic/hid_host.h"
  "classic/hsp_ag.h"
  "classic/hsp_hs.h"
  "classic/obex.h"
  "classic/obex_iterator.h"
  "classic/obex_message_builder.h"
  "classic/obex_parser.h"
  "classic/pan.h"
  "classic/pbap_client.h"
  "classic/pbap.h"
  "classic/rfcomm.h"
  "classic/sdp_client.h"
  "classic/sdp_client_rfcomm.h"
  "classic/sdp_server.h"
  "classic/sdp_util.h"
  "classic/spp_server.h"
