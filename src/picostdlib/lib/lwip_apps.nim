import std/os, std/macros
import ../private
import futhark

import ./lwip
export lwip


importc:
  sysPath clangIncludePath
  path picoSdkPath / "src/rp2_common/pico_lwip/include"
  path picoSdkPath / "lib/lwip/src/include"
  path getProjectPath()

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
