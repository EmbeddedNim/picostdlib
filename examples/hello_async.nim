import picostdlib
import picostdlib/pico/async_context

stdioInitAll()

type
  State = object
    counter: int
    complete: bool

proc atTimeWorkerCb(context: ptr AsyncContext; worker: ptr AsyncAtTimeWorker) {.cdecl.} =
  let state = cast[ptr State](worker.userData)
  inc(state.counter)
  echo "at time worker fired! ", state.counter
  state.complete = true

var state = State()

proc testPollingAsync() =
  var asyncPoll: AsyncContextPoll

  assert asyncPoll.addr.init()
  let context = asyncPoll.core.addr
  defer: context.deinit() # noop for polling context

  state.complete = false

  var atTimeWorker = AsyncAtTimeWorker(userData: state.addr, doWork: atTimeWorkerCb)
  assert context.addAtTimeWorkerInMs(atTimeWorker.addr, 2000)

  echo "starting poll loop async test"
  while not state.complete:
    context.waitForWorkMs(300)
    echo "polling"
    context.poll()

  echo "polling complete!!"

proc testBackgroundThreadAsync() =
  var asyncThread: AsyncContextThreadsafeBackground
  var cfg = asyncContextThreadsafeBackgroundDefaultConfig()

  assert asyncThread.addr.init(cfg.addr)
  let context = asyncThread.core.addr
  defer: context.deinit()

  state.complete = false

  var atTimeWorker = AsyncAtTimeWorker(userData: state.addr, doWork: atTimeWorkerCb)
  assert context.addAtTimeWorkerInMs(atTimeWorker.addr, 2000)

  echo "starting background thread async test"
  while not state.complete:
    echo "waiting"
    context.waitForWorkMs(300)
    #sleepMs(300)

  echo "background thread complete!!"

while true:
  testPollingAsync()

  testBackgroundThreadAsync()

