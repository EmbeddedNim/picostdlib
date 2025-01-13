import picostdlib
import picostdlib/pico/async_context
import picostdlib/async
import picostdlib/lib/promise

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

proc asyncable(): Future[int] {.async.} =
  echo "blinking led..."
  assert 4321 == await Promise.resolve(4321).toFuture()
  var i = 0
  while i < 5:
    await sleepAsync(400)
    led.put(High)
    echo "blink! ", i
    await sleepAsync(100)
    led.put(Low)
    inc(i)
  return 123

proc performTest(context: ptr AsyncContext; blocking: bool) =
  var complete = false

  var atTimeWorker = AsyncAtTimeWorker(userData: state.addr, doWork: atTimeWorkerCb)
  assert context.addAtTimeWorkerInMs(atTimeWorker.addr, 2000)

  # sleepAsync is called instantly
  var sl = sleepAsync(5_000)
  asyncCheck sl
  # careful, other methods may overwrite the callback:
  sl.addCallback(proc (fut: Future[void]) =
    echo "timer complete!"
    complete = true
  )

  echo "waiting for blinking"

  assert 123 == waitFor asyncable()

  echo "blinking complete"

  echo "waiting for complete..."

  if blocking:
    while not complete:
      wfe()
  else:
    while true:
      context.waitForWorkMs(10_000)
      echo "polling"
      context.poll()
      if complete: break

  echo "test complete!!"

proc testPollingAsync() =
  var asyncPoll: AsyncContextPoll

  assert asyncPoll.addr.init()
  let context = asyncPoll.core.addr
  defer: context.deinit() # noop for polling context
  defer: currentAsyncContext = nil
  currentAsyncContext = context

  echo "running test using AsyncContextPoll"
  performTest(context, false)

proc testBackgroundThreadAsync() =
  var asyncThread: AsyncContextThreadsafeBackground
  var cfg = asyncContextThreadsafeBackgroundDefaultConfig()

  assert asyncThread.addr.init(cfg.addr)
  let context = asyncThread.core.addr
  defer: context.deinit()
  defer: currentAsyncContext = nil

  currentAsyncContext = context

  echo "running test using AsyncContextThreadsafeBackground"

  performTest(context, true)

while true:
  testPollingAsync()

  testBackgroundThreadAsync()
