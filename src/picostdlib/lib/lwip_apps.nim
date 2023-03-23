##
##  Copyright (c) 2017 Simon Goldschmidt
##  All rights reserved.
##
##  Redistribution and use in source and binary forms, with or without modification,
##  are permitted provided that the following conditions are met:
##
##  1. Redistributions of source code must retain the above copyright notice,
##     this list of conditions and the following disclaimer.
##  2. Redistributions in binary form must reproduce the above copyright notice,
##     this list of conditions and the following disclaimer in the documentation
##     and/or other materials provided with the distribution.
##  3. The name of the author may not be used to endorse or promote products
##     derived from this software without specific prior written permission.
##
##  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
##  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
##  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
##  SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
##  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
##  OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
##  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
##  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
##  IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
##  OF SUCH DAMAGE.
##


import std/os, std/macros
import ../helpers
import futhark

import ./lwip
export lwip


importc:
  compilerArg "--target=arm-none-eabi"
  compilerArg "-mthumb"
  compilerArg "-mcpu=cortex-m0plus"

  sysPath armSysrootInclude
  sysPath armInstallInclude
  sysPath picoSdkPath / "src/rp2040/hardware_regs/include"
  sysPath picoSdkPath / "src/common/pico_base/include"
  sysPath picoSdkPath / "src/rp2_common/pico_platform/include"
  sysPath picoSdkPath / "src/rp2_common/pico_rand/include"
  sysPath cmakeBinaryDir / "generated/pico_base"
  path picoSdkPath / "src/rp2_common/pico_lwip/include"
  path picoSdkPath / "lib/lwip/src/include"
  path cmakeSourceDir
  path getProjectPath()

  define "MBEDTLS_USER_CONFIG_FILE \"mbedtls_config.h\""

  renameCallback futharkRenameCallback

  "lwip/apps/altcp_proxyconnect.h"
  "lwip/apps/http_client.h"
  "lwip/apps/httpd.h"
  "lwip/apps/lwiperf.h"
  "lwip/apps/mdns.h"
  "lwip/apps/mqtt.h"
  "lwip/apps/netbiosns.h"
  "lwip/apps/smtp.h"
  "lwip/apps/snmp.h"
  "lwip/apps/snmpv3.h"
  "lwip/apps/sntp.h"
  "lwip/apps/tftp_client.h"
  "lwip/apps/tftp_server.h"
