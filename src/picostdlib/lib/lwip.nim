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
import ../private

import futhark

importc:
  sysPath futhark.getClangIncludePath()
  sysPath picoSdkPath / "src/rp2040/hardware_regs/include"
  sysPath picoSdkPath / "lib/lwip/contrib/ports/freertos/include"
  sysPath picoSdkPath / "src/common/pico_base/include"
  sysPath picoSdkPath / "src/rp2_common/pico_platform/include"
  sysPath picoSdkPath / "src/rp2_common/pico_rand/include"
  sysPath picoSdkPath / "src/rp2_common/pico_cyw43_driver/include"
  sysPath cmakeBinaryDir / "generated/pico_base"
  path picoSdkPath / "lib/mbedtls/include"
  path picoSdkPath / "src/rp2_common/pico_lwip/include"
  path picoSdkPath / "lib/lwip/src/include"
  path cmakeSourceDir
  path getProjectPath()

  compilerArg "-fshort-enums"

  renameCallback futharkRenameCallback

  "lwip/acd.h"
  "lwip/altcp.h"
  "lwip/altcp_tcp.h"
  "lwip/altcp_tls.h"
  "lwip/api.h"
  "lwip/arch.h"
  "lwip/autoip.h"
  "lwip/debug.h"
  "lwip/def.h"
  "lwip/dhcp.h"
  "lwip/dhcp6.h"
  "lwip/dns.h"
  "lwip/err.h"
  "lwip/errno.h"
  "lwip/etharp.h"
  "lwip/ethip6.h"
  "lwip/icmp.h"
  "lwip/icmp6.h"
  "lwip/if_api.h"
  "lwip/igmp.h"
  "lwip/inet.h"
  "lwip/inet_chksum.h"
  "lwip/init.h"
  "lwip/ip.h"
  "lwip/ip4.h"
  "lwip/ip4_addr.h"
  "lwip/ip4_frag.h"
  "lwip/ip6.h"
  "lwip/ip6_addr.h"
  "lwip/ip6_frag.h"
  "lwip/ip6_zone.h"
  "lwip/ip_addr.h"
  "lwip/mem.h"
  "lwip/memp.h"
  "lwip/mld6.h"
  "lwip/nd6.h"
  "lwip/netbuf.h"
  "lwip/netdb.h"
  "lwip/netif.h"
  "lwip/netifapi.h"
  "lwip/opt.h"
  "lwip/pbuf.h"
  "lwip/raw.h"
  "lwip/sio.h"
  "lwip/snmp.h"
  "lwip/sockets.h"
  "lwip/stats.h"
  "lwip/sys.h"
  "lwip/tcp.h"
  "lwip/tcpbase.h"
  "lwip/tcpip.h"
  "lwip/timeouts.h"
  "lwip/udp.h"

##  Nim helpers

const PBUF_NOT_FOUND* = uint16.high

proc pbufMemcmp*(p: ptr Pbuf; offset: int|uint16; s2: string): uint16 {.inline.} =
  assert(s2.len > 0)
  var cs2 = s2.cstring
  return p.pbufMemcmp(offset.uint16, cast[pointer](cs2[0].addr), cs2.len.uint16)

proc pbufMemfind*(p: ptr Pbuf; mem: string; startOffset: int|uint16): uint16 {.inline.} =
  assert(mem.len > 0)
  var cmem = mem.cstring
  return p.pbufMemfind(cast[pointer](cmem[0].addr), cmem.len.uint16, startOffset.uint16)


when declared(ip4addrntoa) and declared(ip6addrntoa):
  discard
elif declared(ip4addrntoa):
  proc `$`*(ip: ptr IpAddrT): string = $(ip4addrntoa(ip))

  proc `$`*(ip: var IpAddrT): string = $(ip4addrntoa(addr(ip)))

elif declared(ip6addrntoa):
  proc `$`*(ip: ptr IpAddrT): string = $(ip6addrntoa(ip))

  proc `$`*(ip: var IpAddrT): string = $(ip6addrntoa(addr(ip)))

when declared(ip4addrAton):
  template ipaddrAton*(cp, `addr`: untyped): untyped =
    ip4addrAton(cp, `addr`)
else:
  template ipaddrAton*(cp, `addr`: untyped): untyped =
    ip6addrAton(cp, `addr`)

let
  TCP_SND_BUF* {.importc: "TCP_SND_BUF", header: "lwipopts.h".}: cint

template altcpListenWithBacklog*(conn, backlog: untyped): untyped = altcpListenWithBacklogAndErr(conn, backlog, nil)
template altcpListen*(conn: untyped): untyped = altcpListenWithBacklogAndErr(conn, TcpDefaultListenBacklog, nil)

template altcpTcpNew*(): untyped = altcpTcpNewIpType(IpAddrTypeV4.uint8)
template altcpTcpNewIp6*(): untyped = altcpTcpNewIpType(IpAddrTypeV6.uint8)
