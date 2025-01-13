import std/deques
import ./pico/async_context
import std/asyncmacro
import std/asyncfutures

export async_context, asyncfutures, asyncmacro

var currentAsyncContext*: ptr AsyncContext
var whenPendingWorker = AsyncWhenPendingWorker()


proc sleepAsync*(ms: int): owned Future[void] =
  # Leaks memory if atTimeWorkerCb is never called (async context is deinited for example)
  var retFuture = newFuture[void]("sleepAsync")
  if currentAsyncContext.isNil:
    raise newException(CatchableError, "No AsyncContext provided")

  var worker = new(AsyncAtTimeWorker)

  worker.userData = cast[pointer](retFuture)
  worker.doWork = proc (context: ptr AsyncContext; worker: ptr AsyncAtTimeWorker) {.cdecl.} =
    let worker = cast[ref AsyncAtTimeWorker](worker)
    let future = cast[Future[void]](worker.userData)
    future.complete()
    GC_unref(worker)
    GC_unref(future)

  let time = makeTimeoutTimeMs(ms.uint32)
  discard currentAsyncContext.addAtTimeWorkerAt(cast[ptr AsyncAtTimeWorker](worker), time)
  GC_ref(worker)
  GC_ref(retFuture)
  return retFuture

type
  Dispatcher = ref object of RootObj
    callbacks*: Deque[proc () {.gcsafe.}]

proc newDispatcher(): owned Dispatcher =
  new result
  result.callbacks = initDeque[proc () {.closure, gcsafe.}]()

var asyncDispatcher {.threadvar.}: Dispatcher
var asyncDidSomeWork {.threadvar.}: bool

proc getDispatcher(): Dispatcher =
  if asyncDispatcher.isNil:
    asyncDispatcher = newDispatcher()
  result = asyncDispatcher


proc processPendingCallbacks(dispatcher: Dispatcher; didSomeWork: var bool) =
  # echo "processing ", dispatcher.callbacks.len, " callback(s)"
  while dispatcher.callbacks.len > 0:
    var cb = dispatcher.callbacks.popFirst()
    cb()
    didSomeWork = true

proc whenWorkPendingCb(context: ptr AsyncContext; worker: ptr AsyncWhenPendingWorker) {.cdecl.} =
  getDispatcher().processPendingCallbacks(asyncDidSomeWork)

proc asyncContextCallSoon(cbproc: proc () {.gcsafe.}) =
  # echo "call soon!"
  let dispatcher = getDispatcher()
  dispatcher.callbacks.addLast(cbproc)

  if currentAsyncContext.isNil:
    dispatcher.processPendingCallbacks(asyncDidSomeWork)
  else:
    whenPendingWorker.doWork = whenWorkPendingCb
    discard currentAsyncContext.addWhenPendingWorker(whenPendingWorker.addr)
    currentAsyncContext.setWorkPending(whenPendingWorker.addr)

asyncfutures.setCallSoonProc(asyncContextCallSoon)

proc runOnce(timeout: int): bool =
  let dispatcher = getDispatcher()

  var didSomeWork = false
  if currentAsyncContext.isNil:
    dispatcher.processPendingCallbacks(didSomeWork)
  else:
    asyncDidSomeWork = false
    currentAsyncContext.waitForWorkMs(timeout.uint32)
    currentAsyncContext.poll()
    didSomeWork = asyncDidSomeWork
  return didSomeWork

proc poll*(timeout = 500) =
  ## Waits for completion events and processes them.
  discard runOnce(timeout)

proc runForever*() =
  ## Begins a never ending global dispatcher poll loop.
  while true:
    poll()

proc waitFor*[T](fut: Future[T]): T =
  ## **Blocks** the current thread until the specified future completes.
  while not fut.finished:
    poll()

  fut.read

proc withTimeout*[T](fut: Future[T], timeout: int): owned(Future[bool]) =
  ## Returns a future which will complete once `fut` completes or after
  ## `timeout` milliseconds has elapsed.
  ##
  ## If `fut` completes first the returned future will hold true,
  ## otherwise, if `timeout` milliseconds has elapsed first, the returned
  ## future will hold false.

  var retFuture = newFuture[bool]("withTimeout")
  var timeoutFuture = sleepAsync(timeout)
  fut.addCallback(proc () =
    if not retFuture.finished:
      if fut.failed:
        retFuture.fail(fut.error)
      else:
        retFuture.complete(true)
  )
  timeoutFuture.callback =
    proc () =
      if not retFuture.finished:
        retFuture.complete(false)
  return retFuture
