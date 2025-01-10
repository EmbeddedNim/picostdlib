import ./pico/async_context
import ./lib/promise

export promise, async_context

var promiseAsyncContext*: ptr AsyncContext
var whenPendingWorker = AsyncWhenPendingWorker()
var isWorking: bool

type
  TimeWorkerState* = ref object
    worker: AsyncAtTimeWorker
    callback: proc (value: bool) {.closure.}

proc atTimeWorkerCb(context: ptr AsyncContext; worker: ptr AsyncAtTimeWorker) {.cdecl.} =
  let state = cast[TimeWorkerState](worker.userData)
  state.callback(true)
  state.callback = nil
  GC_unref(state)

proc sleepAsync*(ms: int): Promise[bool] =
  # TODO: Make this return Promise[void]
  # Leaks memory if atTimeWorkerCb is never called (async context is deinited for example)
  return newPromise[bool](proc (resolve: proc (value: bool), reject: proc (reason: ref PromiseError)) =
    if promiseAsyncContext.isNil:
      reject(newException(PromiseError, "No AsyncContext provided"))
      return
    let state = TimeWorkerState()
    state.callback = resolve
    state.worker.userData = cast[pointer](state)
    state.worker.doWork = atTimeWorkerCb
    discard promiseAsyncContext.addAtTimeWorkerInMs(state.worker.addr, ms.uint32)
    GC_ref(state)
  )

proc whenWorkPendingCb(context: ptr AsyncContext; worker: ptr AsyncWhenPendingWorker) {.cdecl.} =
  isWorking = true
  defer: isWorking = false
  while promiseHaveWork():
    promiseProcess()

whenPendingWorker.doWork = whenWorkPendingCb

promiseNotifyWork = proc () =
  if promiseAsyncContext.isNil:
    isWorking = false
    return
  if isWorking: return
  discard promiseAsyncContext.addWhenPendingWorker(whenPendingWorker.addr)
  promiseAsyncContext.setWorkPending(whenPendingWorker.addr)

