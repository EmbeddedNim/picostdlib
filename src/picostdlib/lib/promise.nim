import std/deques
import std/sequtils

type
  PromiseError* = object of CatchableError

  PromiseState* = enum
    Pending
    Resolved
    Rejected

  PromiseOnResolveCb*[T] = proc (value: T): T
  PromiseOnRejectCb* = proc (reason: ref PromiseError): ref PromiseError
  PromiseResolveFn*[T] = proc (value: T)
  PromiseRejectFn* = proc (reason: ref PromiseError)

  PromiseCallback[T] = object
    onResolveCb: PromiseOnResolveCb[T]
    onRejectCb: PromiseOnRejectCb
    resolveFn: PromiseResolveFn[T]
    rejectFn: PromiseRejectFn

  Promise*[T] = ref object
    state: PromiseState
    value: T
    reason: ref PromiseError
    callbacks: Deque[PromiseCallback[T]]

var asyncNotify = initDeque[proc ()]()
var promiseNotifyWork*: proc ()

proc state*(self: Promise): PromiseState = return self.state

proc value*[T](self: Promise[T]): T = return self.value
proc reason*[T](self: Promise[T]): ref PromiseError = return self.reason

proc notify(self: Promise)

proc resolve*[T](self: Promise[T]; value: T) =
  if self.state != Pending:
    raise newException(ValueError, "This promise already has state " & $self.state)
  self.value = value
  self.state = Resolved
  self.notify()

proc reject*(self: Promise; reason: ref PromiseError) =
  if self.state != Pending:
    raise newException(ValueError, "This promise already has state " & $self.state)
  self.reason = reason
  self.state = Rejected
  self.notify()

proc newPromise*[T](fn: proc(resolve: PromiseResolveFn[T]; reject: PromiseRejectFn)): Promise[T] =
  let promise = Promise[T](state: Pending, callbacks: initDeque[PromiseCallback[T]](2))
  try:
    fn(proc (value: T) =
      promise.resolve(value)
    , proc (reason: ref PromiseError) =
      promise.reject(reason)
    )
  except PromiseError as reason:
    promise.reject(reason)
  return promise

proc then*[T](self: Promise[T]; onResolved: PromiseOnResolveCb[T] = nil; onRejected: PromiseOnRejectCb = nil): Promise[T] =
  let promise = self
  return newPromise(proc(resolve: proc (val: T), reject: proc(reason: ref PromiseError)) =
    promise.callbacks.addLast(PromiseCallback[T](onResolveCb: onResolved, onRejectCb: onRejected, resolveFn: resolve, rejectFn: reject))
    promise.notify()
  )

proc catch*[T](self: Promise[T]; onReject: PromiseOnRejectCb): Promise[T] =
  return self.then(nil, onReject)

proc resolve*[T](_: typedesc[Promise[T]]; value: T): Promise[T] =
  return newPromise[T](proc (resolve: PromiseResolveFn[T]; reject: PromiseRejectFn) =
    resolve(value)
  )

proc reject*[T](_: typedesc[Promise[T]]; reason: ref PromiseError): Promise[T] =
  return newPromise[T](proc (resolve: PromiseResolveFn[T]; reject: PromiseRejectFn) =
    reject(reason)
  )

proc notify(self: Promise) =
  var promise = self
  asyncNotify.addLast(proc () =
    if promise.state == Pending: return
    while promise.callbacks.len > 0:
      let callback = promise.callbacks.popFirst
      try:
        if promise.state == Resolved:
          if not callback.onResolveCb.isNil:
            callback.resolveFn(callback.onResolveCb(promise.value))
          else:
            callback.resolveFn(promise.value)
        else:
          if not callback.onRejectCb.isNil:
            callback.rejectFn(callback.onRejectCb(promise.reason))
          else:
            callback.rejectFn(promise.reason)
      except PromiseError as reason:
        callback.rejectFn(reason)
  )
  if not promiseNotifyWork.isNil:
    promiseNotifyWork()

proc promiseHaveWork*(): bool = asyncNotify.len > 0

proc promiseProcess*() =
  let count = asyncNotify.len
  for i in 0 ..< count:
    let cb = asyncNotify.popFirst()
    cb()

proc all*[T](_: typedesc[Promise[T]]; promises: varargs[Promise[T]]): Promise[seq[T]] =
  var promises = promises.toSeq()
  return newPromise[seq[T]](proc (resolve: PromiseResolveFn[seq[T]]; reject: PromiseRejectFn) =
    var results = newSeq[T]()
    let promiseCount = promises.len
    var promisesResolved = 0
    results.setLen(promiseCount)
    for i, promise in promises.pairs:
      discard promise.then(proc (value: T): T =
        results[i] = value
        inc(promisesResolved)
        if promisesResolved == promiseCount:
          resolve(results)
        return value
      , proc (reason: ref PromiseError): ref PromiseError = reject(reason); return reason)
  )

proc race*[T](_: typedesc[Promise[T]]; promises: varargs[Promise[T]]): Promise[T] =
  var promises = promises.toSeq()
  return newPromise[T](proc (resolve: PromiseResolveFn[T]; reject: PromiseRejectFn) =
    let promiseCount = promises.len
    var promiseResolved = false
    for i, promise in promises.pairs:
      discard promise.then(proc (value: T): T =
        if not promiseResolved:
          promiseResolved = true
          resolve(promise)
        return value
      , proc (reason: ref PromiseError): ref PromiseError = reject(reason); return reason)
  )

# TODO: Make coroutines work with any Promise type
proc coroutine*[T](fn: iterator (value: T): Promise[T]): Promise[T] =
  return newPromise[T](proc (resolve: proc (value: T), reject: proc (reason: ref PromiseError)) =
    var initial: T
    let ctx = fn
    proc next(val: T) =
      var p: Promise[T]
      if not ctx.finished:
        p = ctx(val)
      if ctx.finished:
        if p.isNil:
          resolve(val)
          return
        else:
          if p.state == Resolved:
            resolve(p.value)
            return
          elif p.state == Rejected:
            reject(p.reason)
            return
      discard p.then(proc (v: T): T = next(v); return v, proc(r: ref PromiseError): ref PromiseError = reject(r))
    next(initial)
  )

template co*[T](valueName: untyped; body: untyped): Promise[T] =
  coroutine(iterator (valueName: T): Promise[T] =
    body
  )

template await*[T](promise: Promise[T]) =
  yield promise



when isMainModule or defined(nimcheck):
  let p = newPromise[int](proc(resolve: proc (value: int); reject: proc (reason: ref PromiseError)) =
    ## reject(newException(PromiseError, "Rejected"))
  )

  let p2 = p.then(proc (value: int): int =
    echo "got value ", value
    value + 2
  ).then(proc (value: int): int =
    echo "got value again!", value
    value
  ).catch(proc (reason: ref PromiseError): ref PromiseError =
    echo "got rejected! ", reason.msg
  )

  echo repr p

  discard Promise[int].all(Promise.resolve(10), p2).then(proc (values: seq[int]): seq[int] =
    echo "got ints! ", values
  ).catch(proc (reason: ref PromiseError): ref PromiseError =
    echo "failed to get all ints"
  )

  p.resolve(5)

  echo repr p

  let p3 = newPromise[int](proc (resolve: proc (val: int); reject: proc (reason: ref PromiseError)) = discard)

  var p4 = co[int](value):
    echo "hello co!"
    await Promise.resolve(6)
    echo value
    # await Promise[int].reject(newException(PromiseError, "aaaa"))
    echo "woo"
    return p3

  discard p4.then(proc (value: int): int =
    echo "co completed!", value
    return value
  , proc (reason: ref PromiseError): ref PromiseError =
    echo "co failed! ", reason.msg
  )
