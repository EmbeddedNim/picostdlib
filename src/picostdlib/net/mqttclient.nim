import ../lib/lwip_apps
import ../pico/cyw43_arch
import ./common

export common

export MqttConnectClientInfoT
export MqttConnectionStatusT
export ErrEnumT

{.emit: "// picostdlib import: pico_lwip_mqtt".}

when not defined(release) or defined(debugMqtt):
  template debugv(text: string) = echo text
else:
  template debugv(text: string) = discard

type
  MqttClient* = ref object
    client: ptr MqttClientT
    connectCb: MqttConnectCb
    requests: array[MQTT_REQ_MAX_IN_FLIGHT, MqttRequest]
    inpubCb: MqttInpubCb

  MqttRequest* = object
    topic: string
    cb: MqttRequestCb

  MqttConnectCb* = proc (connStatus: MqttConnectionStatusT)
  MqttRequestCb* = proc (err: ErrEnumT)
  MqttInpubCb* = proc (topic: string; totLen: uint32)

proc `=destroy`*(self: typeof(MqttClient()[])) =
  echo "Destroying MQTT client"
  let selfptr = self.addr
  `=destroy`(selfptr.connectCb)
  # `=destroy`(selfptr.requests)
  if self.client != nil:
    mqttDisconnect(self.client)
    mqtt_client_free(self.client)
    `=destroy`(selfptr.client)

proc newMqttClient*(): MqttClient =
  result = MqttClient()
  result.client = mqttClientNew()

proc mqttConnectionCb(client: ptr MqttClientT; arg: pointer; status: MqttConnectionStatusT) {.cdecl.} =
  assert(arg != nil)
  let self = cast[MqttClient](arg)
  assert(self.client == client)
  debugv(":mqtt connect status: " & $status)
  let cb = self.connectCb
  self.connectCb = nil
  GC_unref(self)
  if cb != nil:
    cb(status)

proc mqttRequestCb(arg: pointer; err: ErrT) {.cdecl.} =
  assert(arg != nil)
  let request = cast[ptr MqttRequest](arg)
  assert(request != nil)
  assert(request.cb != nil)
  request.cb(err.ErrEnumT)

proc mqttInpubCb(arg: pointer; topic: cstring; totLen: uint32) {.cdecl.} =
  echo topic, " ", totLen

proc mqttDataCb(arg: pointer; data: ptr uint8; len: uint16; flags: uint8) {.cdecl.} =
  echo len
  var str = newString(len)
  copyMem(str[0].addr, data, len)
  echo str
  echo flags

proc connect*(self: MqttClient; ipaddr: ptr IpAddrT; port: Port = Port(LWIP_IANA_PORT_MQTT); cb: MqttConnectCb; clientInfo: MqttConnectClientInfoT): bool =
  assert(self.connectCb == nil)
  withLwipLock:
    debugv(":mqtt connecting to " & $ipaddr & ":" & $port)
    self.connectCb = cb
    GC_ref(self)
    let err = mqttClientConnect(self.client, ipaddr, port.uint16, mqttConnectionCb, cast[pointer](self), clientInfo.unsafeAddr).ErrEnumT
    if err != ErrOk:
      GC_unref(self)
      debugv(":mqtt connect error: " & $err)
      return false
  return true

proc disconnect*(self: MqttClient) =
  withLwipLock:
    mqttDisconnect(self.client)

proc setInpubCallback*(self: MqttClient; cb: MqttInpubCb) =
  self.inpubCb = cb
  if cb != nil:
    mqttSetInpubCallback(self.client, mqttInpubCb, mqttDataCb, cast[pointer](self))
  else:
    mqttSetInpubCallback(self.client, nil, nil, nil)

proc subscribe*(self: MqttClient; topic: string; qos: uint8 = 0; cb: MqttRequestCb): bool =
  withLwipLock:
    var pos = -1
    for i, req in self.requests:
      if req.cb == nil:
        pos = i
        break
    if pos == -1:
      debugv(":mqtt subscribe list full")
      return false

    self.requests[pos].topic = topic
    self.requests[pos].cb = cb
    debugv(":mqtt subscribing " & repr self.requests[pos])
    let err = mqttSubscribe(self.client, topic, qos, mqttRequestCb, self.requests[pos].addr).ErrEnumT
    if err != ErrOk:
      self.requests[pos].reset()
      debugv(":mqtt subscribe error " & topic & ": " & $err)
      return false

    GC_ref(self)

  return true

proc unsubscribe*(self: MqttClient; topic: string): bool =
  withLwipLock:
    for i, request in self.requests:
      if request.topic == topic:
        debugv(":mqtt unsubscribing " & repr request)
        let err = mqttUnsubscribe(self.client, request.topic, mqttRequestCb, request.addr).ErrEnumT
        if err != ErrOk:
          debugv(":mqtt unsubscribe error: " & $err)
          return false
        self.requests[i].reset()
  return true
