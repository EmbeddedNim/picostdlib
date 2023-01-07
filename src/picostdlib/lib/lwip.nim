import std/os, std/macros
import ../private

import futhark

importc:
  sysPath CLANG_INCLUDE_PATH
  path PICO_SDK_PATH / "src/rp2_common/pico_lwip/include"
  path PICO_SDK_PATH / "lib/lwip/src/include"
  path getProjectPath()

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


when declared(ip4addrntoa):
  proc `$`*(ip: ptr IpAddrT): string = $(ip4addrntoa(ip))

  proc `$`*(ip: var IpAddrT): string = $(ip4addrntoa(addr(ip)))

elif declared(ip6addrntoa):
  proc `$`*(ip: ptr IpAddrT): string = $(ip6addrntoa(ip))

  proc `$`*(ip: var IpAddrT): string = $(ip6addrntoa(addr(ip)))

let
  TCP_SND_BUF* {.importc: "TCP_SND_BUF", header: "lwipopts.h".}: cint
