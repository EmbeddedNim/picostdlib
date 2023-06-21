import ./types
export types

{.push header: "pico/async_context.h".}

type
  AsyncContext* {.importc: "async_context_t".} = object
    ## Base structure type of all async_contexts. For details about its use, see \ref pico_async_context.
    ## 
    ## Individual async_context_types with additional state, should contain this structure at the start.
    `type`*: ptr AsyncContextType
    whenPendingList* {.importc: "when_pending_list".}: ptr AsyncWhenPendingWorker
    atTimeList* {.importc: "async_at_time_worker_t".}: ptr AsyncAtTimeWorker
    nextTime* {.importc: "next_time".}: AbsoluteTime
    flags*: uint16
    coreNum* {.importc: "core_num".}: uint8

  AsyncAtTimeWorker* {.importc: "async_at_time_worker_t".} = object
    ## A "timeout" instance used by an async_context
    ##  \ingroup pico_async_context
    ##
    ## A "timeout" represents some future action that must be taken at a specific time.
    ## Its methods are called from the async_context under lock at the given time
    ##
    ## \see async_context_add_worker_at
    ## \see async_context_add_worker_in_ms
    next*: ptr AsyncAtTimeWorker
      ## private link list pointer
    doWork* {.importc: "do_work".}: proc (context: ptr AsyncContext; timeout: ptr AsyncAtTimeWorker)
      ## Method called when the timeout is reached; may not be NULL
      ##
      ## Note, that when this method is called, the timeout has been removed from the async_context, so
      ## if you want the timeout to repeat, you should re-add it during this callback
      ## @param context
      ## @param timeout
    nextTime* {.importc: "next_time".}: AbsoluteTime
      ## The next timeout time; this should only be modified during the above methods
      ## or via async_context methods
    userData* {.importc: "user_data".}: pointer
      ## User data associated with the timeout instance
  
  AsyncWhenPendingWorker* {.importc: "async_when_pending_worker_t".} = object
    ## A "worker" instance used by an async_context
    ##  \ingroup pico_async_context
    ##
    ## A "worker" represents some external entity that must do work in response
    ##  to some external stimulus (usually an IRQ).
    ## Its methods are called from the async_context under lock at the given time
    ##
    ## \see async_context_add_worker_at
    ## \see async_context_add_worker_in_ms
    next*: ptr AsyncWhenPendingWorker
      ## private link list pointer
    doWork* {.importc: "do_work".}: proc (context: ptr AsyncContext; worker: ptr AsyncWhenPendingWorker) {.cdecl.}
      ## Called by the async_context when the worker has been marked as having "work pending"
      ## @param context the async_context
      ## @param worker the function to be called when work is pending
    workPending* {.importc: "work_pending".}: bool
      ## True if the worker need do_work called
    userData* {.importc: "user_data".}: pointer
      ## User data associated with the worker instance
  
  AsyncContextType* {.importc: "async_context_type_t".} = object
    ## Implementation of an async_context type, providing methods common to that type
    `type`*: uint16
    # see wrapper functions for documentation
    acquireLockBlocking* {.importc: "acquire_lock_blocking".}: proc (self: ptr AsyncContext) {.cdecl.}
    releaseLock* {.importc: "release_lock".}: proc (self: ptr AsyncContext) {.cdecl.}
    lockCheck* {.importc: "lock_check".}: proc (self: ptr AsyncContext) {.cdecl.}
    executeSync* {.importc: "execute_sync".}: proc (self: ptr AsyncContext; `func`: proc (param: pointer): uint32 {.cdecl.}; param: pointer) {.cdecl.}
    addAtTimeWorker* {.importc: "add_at_time_worker".}: proc (self: ptr AsyncContext; worker: ptr AsyncAtTimeWorker) {.cdecl.}
    removeAtTimeWorker* {.importc: "remove_at_time_worker".}: proc (self: ptr AsyncContext; worker: ptr AsyncAtTimeWorker) {.cdecl.}
    addWhenPendingWorker* {.importc: "add_when_pending_worker".}: proc (self: ptr AsyncContext; worker: ptr AsyncWhenPendingWorker) {.cdecl.}
    removeWhenPendingWorker* {.importc: "remove_when_pending_worker".}: proc (self: ptr AsyncContext; worker: ptr AsyncWhenPendingWorker) {.cdecl.}
    setWorkPending* {.importc: "set_work_pending".}: proc (self: ptr AsyncContext; worker: ptr AsyncWhenPendingWorker) {.cdecl.}
    poll*: proc (self: ptr AsyncContext) {.cdecl.}  # may be NULL
    waitUntil* {.importc: "wait_until".}: proc (self: ptr AsyncContext; until: AbsoluteTime) {.cdecl.}
    waitForWorkUntil* {.importc: "wait_for_work_until".}: proc (self: ptr AsyncContext; until: AbsoluteTime) {.cdecl.}
    deinit*: proc (self: ptr AsyncContext) {.cdecl.}

proc asyncContextAcquireLockBlocking*(context: ptr AsyncContext) {.importc: "async_context_acquire_lock_blocking".}
  ## Acquire the async_context lock
  ## \ingroup pico_async_context
  ##
  ## The owner of the async_context lock is the logic owner of the async_context
  ## and other work related to this async_context will not happen concurrently.
  ##
  ## This method may be called in a nested fashion by the the lock owner.
  ##
  ## \note the async_context lock is nestable by the same caller, so an internal count is maintained
  ##
  ## \note for async_contexts that provide locking (not async_context_poll), this method is threadsafe. and may be called from within any 
  ## worker method called by the async_context or from any other non-IRQ context.
  ##
  ## \param context the async_context
  ##
  ## \see async_context_release_lock

proc asyncContextReleaseLock*(context: ptr AsyncContext) {.importc: "async_context_release_lock".}
  ## Release the async_context lock
  ## \ingroup pico_async_context
  ##
  ## \note the async_context lock may be called in a nested fashion, so an internal count is maintained. On the outermost
  ## release, When the outermost lock is released, a check is made for work which might have been skipped while the lock was held,
  ## and any such work may be performed during this call IF the call is made from the same core that the async_context belongs to.
  ##
  ## \note for async_contexts that provide locking (not async_context_poll), this method is threadsafe. and may be called from within any 
  ## worker method called by the async_context or from any other non-IRQ context.
  ##
  ## \param context the async_context
  ##
  ## \see async_context_acquire_lock_blocking

proc asyncContextLockCheck*(context: ptr AsyncContext) {.importc: "async_context_lock_check".}
  ## Assert if the caller does not own the lock for the async_context
  ## \ingroup pico_async_context
  ## \note this method is thread-safe
  ##
  ## \param context the async_context

proc asyncContextExecuteSync*(context: ptr AsyncContext; `func`: proc (param: pointer): uint32 {.cdecl.}; param: pointer): uint32 {.importc: "async_context_execute_sync".}
  ## Execute work synchronously on the core the async_context belongs to.
  ## \ingroup pico_async_context
  ##
  ## This method is intended for code external to the async_context (e.g. another thread/task) to
  ## execute a function with the same guarantees (single core, logical thread of execution) that
  ## async_context workers are called with.
  ##
  ## \note you should NOT call this method while holding the async_context's lock
  ##
  ## \param context the async_context
  ## \param func the function to call
  ## \param param the paramter to pass to the function
  ## \return the return value from func

proc asyncContextAddAtTimeWorker*(context: ptr AsyncContext; worker: ptr AsyncAtTimeWorker): bool {.importc: "async_context_add_at_time_worker".}
  ## Add an "at time" worker to a context
  ## \ingroup pico_async_context
  ##
  ## An "at time" worker will run at or after a specific point in time, and is automatically when (just before) it runs.
  ##
  ## The time to fire is specified in the next_time field of the worker.
  ##
  ## \note for async_contexts that provide locking (not async_context_poll), this method is threadsafe. and may be called from within any 
  ## worker method called by the async_context or from any other non-IRQ context.
  ##
  ## \param context the async_context
  ## \param worker the "at time" worker to add
  ## \return true if the worker was added, false if the worker was already present.

proc asyncContextAddAtTimeWorkerAt*(context: ptr AsyncContext; worker: ptr AsyncAtTimeWorker; at: AbsoluteTime): bool {.importc: "async_context_add_at_time_worker_at".}
  ## Add an "at time" worker to a context
  ## \ingroup pico_async_context
  ##
  ## An "at time" worker will run at or after a specific point in time, and is automatically when (just before) it runs.
  ##
  ## The time to fire is specified by the at parameter.
  ##
  ## \note for async_contexts that provide locking (not async_context_poll), this method is threadsafe. and may be called from within any 
  ## worker method called by the async_context or from any other non-IRQ context.
  ##
  ## \param context the async_context
  ## \param worker the "at time" worker to add
  ## \param at the time to fire at
  ## \return true if the worker was added, false if the worker was already present.

proc asyncContextAddAtTimeWorkerInMs*(context: ptr AsyncContext; worker: ptr AsyncAtTimeWorker; ms: uint32): bool {.importc: "async_context_add_at_time_worker_in_ms".}
  ## Add an "at time" worker to a context
  ## \ingroup pico_async_context
  ##
  ## An "at time" worker will run at or after a specific point in time, and is automatically when (just before) it runs.
  ##
  ## The time to fire is specified by a delay via the ms parameter 
  ##
  ## \note for async_contexts that provide locking (not async_context_poll), this method is threadsafe. and may be called from within any 
  ## worker method called by the async_context or from any other non-IRQ context.
  ##
  ## \param context the async_context
  ## \param worker the "at time" worker to add
  ## \param ms the number of milliseconds from now to fire after
  ## \return true if the worker was added, false if the worker was already present.

proc asyncContextRemoveAtTimeWorker*(context: ptr AsyncContext; worker: ptr AsyncAtTimeWorker): bool {.importc: "async_context_remove_at_time_worker".}
  ## Remove an "at time" worker from a context
  ## \ingroup pico_async_context
  ##
  ## \note for async_contexts that provide locking (not async_context_poll), this method is threadsafe. and may be called from within any 
  ## worker method called by the async_context or from any other non-IRQ context.
  ##
  ## \param context the async_context
  ## \param worker the "at time" worker to remove
  ## \return true if the worker was removed, false if the instance not present.

proc async_context_add_when_pending_worker*(context: ptr AsyncContext; worker: ptr AsyncWhenPendingWorker): bool {.importc: "async_context_add_when_pending_worker".}
  ## Add a "when pending" worker to a context
  ## \ingroup pico_async_context
  ##
  ## An "when pending" worker will run when it is pending (can be set via \ref async_context_set_work_pending), and
  ## is NOT automatically removed when it runs.
  ##
  ## The time to fire is specified by a delay via the ms parameter
  ##
  ## \note for async_contexts that provide locking (not async_context_poll), this method is threadsafe. and may be called from within any 
  ## worker method called by the async_context or from any other non-IRQ context.
  ##
  ## \param context the async_context
  ## \param worker the "when pending" worker to add
  ## \return true if the worker was added, false if the worker was already present.

proc asyncContextRemoveWhenPendingWorker*(context: ptr AsyncContext; worker: ptr AsyncWhenPendingWorker): bool {.importc: "async_context_remove_when_pending_worker".}
  ## Remove a "when pending" worker from a context
  ## \ingroup pico_async_context
  ##
  ## \note for async_contexts that provide locking (not async_context_poll), this method is threadsafe. and may be called from within any 
  ## worker method called by the async_context or from any other non-IRQ context.
  ##
  ## \param context the async_context
  ## \param worker the "when pending" worker to remove
  ## \return true if the worker was removed, false if the instance not present.

proc asyncContextSetWorkPending*(context: ptr AsyncContext; worker: ptr AsyncWhenPendingWorker) {.importc: "async_context_set_work_pending".}
  ## Mark a "when pending" worker as having work pending
  ## \ingroup pico_async_context
  ##
  ## The worker will be run from the async_context at a later time.
  ##
  ## \note this method may be called from any context including IRQs
  ##
  ## \param context the async_context
  ## \param worker the "when pending" worker to mark as pending.

proc asyncContextPoll*(context: ptr AsyncContext) {.importc: "async_context_poll".}
  ## Perform any pending work for polling style async_context
  ## \ingroup pico_async_context
  ##
  ## For a polled async_context (e.g. \ref async_context_poll) the user is responsible for calling this method
  ## periodically to perform any required work.
  ##
  ## This method may immediately perform outstanding work on other context types, but is not required to.
  ##
  ## \param context the async_context

proc asyncContextWaitUntil*(context: ptr AsyncContext; until: AbsoluteTime) {.importc: "async_context_wait_until".}
  ## sleep until the specified time in an async_context callback safe way
  ## \ingroup pico_async_context
  ##
  ## \note for async_contexts that provide locking (not async_context_poll), this method is threadsafe. and may be called from within any
  ## worker method called by the async_context or from any other non-IRQ context.
  ##
  ## \param context the async_context
  ## \param until the time to sleep until

proc asyncContextWaitForWorkUntil*(context: ptr AsyncContext; until: AbsoluteTime) {.importc: "async_context_wait_for_work_until".}
  ## Block until work needs to be done or the specified time has been reached
  ## \ingroup pico_async_context
  ##
  ## \note this method should not be called from a worker callback
  ##
  ## \param context the async_context
  ## \param until the time to return at if no work is required

proc asyncContextWaitForWorkMs*(context: ptr AsyncContext; ms: uint32) {.importc: "async_context_wait_for_work_ms".}
  ## Block until work needs to be done or the specified number of milliseconds have passed
  ## \ingroup pico_async_context
  ##
  ## \note this method should not be called from a worker callback
  ##
  ## \param context the async_context
  ## \param ms the number of milliseconds to return after if no work is required

proc asyncContextCoreNum*(context: ptr AsyncContext): cuint {.importc: "async_context_core_num".}
  ## Return the processor core this async_context belongs to
  ## \ingroup pico_async_context
  ##
  ## \param context the async_context
  ## \return the physical core number

proc asyncContextDeinit*(context: ptr AsyncContext) {.importc: "async_context_deinit".}
  ## End async_context processing, and free any resources
  ## \ingroup pico_async_context
  ##
  ## Note the user should clean up any resources associated with workers
  ## in the async_context themselves.
  ##
  ## Asynchronous (non-polled) async_contexts guarantee that no
  ## callback is being called once this method returns.
  ##
  ## \param context the async_context

{.pop.}
