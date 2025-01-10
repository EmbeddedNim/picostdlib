import picostdlib
import picostdlib/pico/async_context
import picostdlib/async

stdioInitAll()

type
  State = object
    counter: int

let led = DefaultLedPin
led.init()
led.setDir(Out)

var state: State

proc atTimeWorkerCb(context: ptr AsyncContext; worker: ptr AsyncAtTimeWorker) {.cdecl.} =
  let state = cast[ptr State](worker.userData)
  inc(state.counter)
  echo "at time worker fired! ", state.counter

proc performTest(context: ptr AsyncContext; blocking: bool) =
  var complete = false

  var atTimeWorker = AsyncAtTimeWorker(userData: state.addr, doWork: atTimeWorkerCb)
  assert context.addAtTimeWorkerInMs(atTimeWorker.addr, 2000)

  discard sleepAsync(5_000).then(proc (value: bool): bool =
    echo "timer complete!"
    complete = true
  )

  discard co[bool](value):
    echo "blinking led..."
    echo await Promise.resolve(123) # can await any type
    var i = 0
    while true:
      discard await sleepAsync(500)
      led.put(High)
      echo "blink! ", i
      discard await sleepAsync(200)
      led.put(Low)
      inc(i)

  if blocking:
    while not complete:
      wfe()
  else:
    while true:
      context.waitForWorkMs(10_000)
      echo "polling"
      context.poll()
      if complete: break

  # just in case...
  while promiseHaveWork():
    promiseProcess()

  echo "test complete!!"

proc testPollingAsync() =
  var asyncPoll: AsyncContextPoll

  assert asyncPoll.addr.init()
  let context = asyncPoll.core.addr
  defer: context.deinit() # noop for polling context
  defer: promiseAsyncContext = nil
  promiseAsyncContext = context

  echo "running test using AsyncContextPoll"
  performTest(context, false)

proc testBackgroundThreadAsync() =
  var asyncThread: AsyncContextThreadsafeBackground
  var cfg = asyncContextThreadsafeBackgroundDefaultConfig()

  assert asyncThread.addr.init(cfg.addr)
  let context = asyncThread.core.addr
  defer: context.deinit()
  defer: promiseAsyncContext = nil

  promiseAsyncContext = context

  echo "running test using AsyncContextThreadsafeBackground"

  performTest(context, true)

while true:
  testPollingAsync()

  testBackgroundThreadAsync()

