import types
import lock_core

{.push header: "pico/mutex.h".}

type
  RecursiveMutex* {.bycopy, importc: "recursive_mutex_t".} = object
    ## recursive mutex instance
    core* {.importc.}: LockCore
    owner* {.importc.}: LockOwnerId  # owner id LOCK_INVALID_OWNER_ID for unowned
    enterCount* {.importc: "enter_count".}: uint8  # ownership count
  
  Mutex* {.bycopy, importc: "mutex_t".} = object
    ## regular (non recursive) mutex instance
    core* {.importc.}: LockCore
    owner* {.importc.}: LockOwnerId  # owner id LOCK_INVALID_OWNER_ID for unowned


proc mutexInit*(mtx: ptr Mutex) {.importc: "mutex_init".}
  ## ```
  ##   ! \brief  Initialise a mutex structure
  ##     \ingroup mutex
  ##   
  ##    \param mtx Pointer to mutex structure
  ## ```

proc recursiveMutexInit*(mtx: ptr Mutex) {.importc: "recursive_mutex_init".}
  ## ```
  ##   ! \brief  Initialise a recursive mutex structure
  ##     \ingroup mutex
  ##   
  ##    A recursive mutex may be entered in a nested fashion by the same owner
  ##   
  ##    \param mtx Pointer to recursive mutex structure
  ## ```

proc mutexEnterBlocking*(mtx: ptr Mutex) {.importc: "mutex_enter_blocking".}
  ## ```
  ##   ! \brief  Take ownership of a mutex
  ##     \ingroup mutex
  ##   
  ##    This function will block until the caller can be granted ownership of the mutex.
  ##    On return the caller owns the mutex
  ##   
  ##    \param mtx Pointer to mutex structure
  ## ```

proc recursiveMutexEnterBlocking*(mtx: ptr Mutex) {.importc: "recursive_mutex_enter_blocking".}
  ## ```
  ##   ! \brief  Take ownership of a recursive mutex
  ##     \ingroup mutex
  ##   
  ##    This function will block until the caller can be granted ownership of the mutex.
  ##    On return the caller owns the mutex
  ##   
  ##    \param mtx Pointer to recursive mutex structure
  ## ```

proc mutexTryEnter*(mtx: ptr Mutex; ownerOut: ptr uint32): bool {.importc: "mutex_try_enter".}
  ## ```
  ##   ! \brief Attempt to take ownership of a mutex
  ##     \ingroup mutex
  ##   
  ##    If the mutex wasn't owned, this will claim the mutex for the caller and return true.
  ##    Otherwise (if the mutex was already owned) this will return false and the
  ##    caller will NOT own the mutex.
  ##   
  ##    \param mtx Pointer to mutex structure
  ##    \param owner_out If mutex was already owned, and this pointer is non-zero, it will be filled in with the owner id of the current owner of the mutex
  ##    \return true if mutex now owned, false otherwise
  ## ```

proc mutexTryEnterBlockUntil*(mtx: ptr Mutex; until: AbsoluteTime): bool {.importc: "mutex_try_enter_block_until".}
  ##  \brief Attempt to take ownership of a mutex until the specified time
  ##  \ingroup mutex
  ##
  ## If the mutex wasn't owned, this method will immediately claim the mutex for the caller and return true.
  ## If the mutex is owned by the caller, this method will immediately return false,
  ## If the mutex is owned by someone else, this method will try to claim it until the specified time, returning
  ## true if it succeeds, or false on timeout
  ##
  ## \param mtx Pointer to mutex structure
  ## \param until The time after which to return if the caller cannot be granted ownership of the mutex
  ## \return true if mutex now owned, false otherwise

proc recursiveMutexTryEnter*(mtx: ptr Mutex; ownerOut: ptr uint32): bool {.importc: "recursive_mutex_try_enter".}
  ## ```
  ##   ! \brief Attempt to take ownership of a recursive mutex
  ##     \ingroup mutex
  ##   
  ##    If the mutex wasn't owned or was owned by the caller, this will claim the mutex and return true.
  ##    Otherwise (if the mutex was already owned by another owner) this will return false and the
  ##    caller will NOT own the mutex.
  ##   
  ##    \param mtx Pointer to recursive mutex structure
  ##    \param owner_out If mutex was already owned by another owner, and this pointer is non-zero,
  ##                     it will be filled in with the owner id of the current owner of the mutex
  ##    \return true if the recursive mutex (now) owned, false otherwise
  ## ```

proc mutexEnterTimeoutMs*(mtx: ptr Mutex; timeoutMs: uint32): bool {.importc: "mutex_enter_timeout_ms".}
  ## ```
  ##   ! \brief Wait for mutex with timeout
  ##     \ingroup mutex
  ##   
  ##    Wait for up to the specific time to take ownership of the mutex. If the caller
  ##    can be granted ownership of the mutex before the timeout expires, then true will be returned
  ##    and the caller will own the mutex, otherwise false will be returned and the caller will NOT own the mutex.
  ##   
  ##    \param mtx Pointer to mutex structure
  ##    \param timeout_ms The timeout in milliseconds.
  ##    \return true if mutex now owned, false if timeout occurred before ownership could be granted
  ## ```

proc recursiveMutexEnterTimeoutMs*(mtx: ptr Mutex; timeoutMs: uint32): bool {.importc: "recursive_mutex_enter_timeout_ms".}
  ## ```
  ##   ! \brief Wait for recursive mutex with timeout
  ##     \ingroup mutex
  ##   
  ##    Wait for up to the specific time to take ownership of the recursive mutex. If the caller
  ##    already has ownership of the mutex or can be granted ownership of the mutex before the timeout expires,
  ##    then true will be returned and the caller will own the mutex, otherwise false will be returned and the caller
  ##    will NOT own the mutex.
  ##   
  ##    \param mtx Pointer to recursive mutex structure
  ##    \param timeout_ms The timeout in milliseconds.
  ##    \return true if the recursive mutex (now) owned, false if timeout occurred before ownership could be granted
  ## ```

proc mutexEnterTimeoutUs*(mtx: ptr Mutex; timeoutUs: uint32): bool {.importc: "mutex_enter_timeout_us".}
  ## ```
  ##   ! \brief Wait for mutex with timeout
  ##     \ingroup mutex
  ##   
  ##    Wait for up to the specific time to take ownership of the mutex. If the caller
  ##    can be granted ownership of the mutex before the timeout expires, then true will be returned
  ##    and the caller will own the mutex, otherwise false will be returned and the caller
  ##    will NOT own the mutex.
  ##   
  ##    \param mtx Pointer to mutex structure
  ##    \param timeout_us The timeout in microseconds.
  ##    \return true if mutex now owned, false if timeout occurred before ownership could be granted
  ## ```

proc recursiveMutexEnterTimeoutUs*(mtx: ptr Mutex; timeoutUs: uint32): bool {.importc: "recursive_mutex_enter_timeout_us".}
  ## ```
  ##   ! \brief Wait for recursive mutex with timeout
  ##     \ingroup mutex
  ##   
  ##    Wait for up to the specific time to take ownership of the recursive mutex. If the caller
  ##    already has ownership of the mutex or can be granted ownership of the mutex before the timeout expires,
  ##    then true will be returned and the caller will own the mutex, otherwise false will be returned and the caller
  ##    will NOT own the mutex.
  ##   
  ##    \param mtx Pointer to mutex structure
  ##    \param timeout_us The timeout in microseconds.
  ##    \return true if the recursive mutex (now) owned, false if timeout occurred before ownership could be granted
  ## ```

proc mutexEnterBlockUntil*(mtx: ptr Mutex; until: AbsoluteTime): bool {.importc: "mutex_enter_block_until".}
  ## ```
  ##   ! \brief Wait for mutex until a specific time
  ##     \ingroup mutex
  ##   
  ##    Wait until the specific time to take ownership of the mutex. If the caller
  ##    can be granted ownership of the mutex before the timeout expires, then true will be returned
  ##    and the caller will own the mutex, otherwise false will be returned and the caller
  ##    will NOT own the mutex.
  ##   
  ##    \param mtx Pointer to mutex structure
  ##    \param until The time after which to return if the caller cannot be granted ownership of the mutex
  ##    \return true if mutex now owned, false if timeout occurred before ownership could be granted
  ## ```

proc recursiveMutexEnterBlockUntil*(mtx: ptr Mutex; until: AbsoluteTime): bool {.importc: "recursive_mutex_enter_block_until".}
  ## ```
  ##   ! \brief Wait for mutex until a specific time
  ##     \ingroup mutex
  ##   
  ##    Wait until the specific time to take ownership of the mutex. If the caller
  ##    already has ownership of the mutex or can be granted ownership of the mutex before the timeout expires,
  ##    then true will be returned and the caller will own the mutex, otherwise false will be returned and the caller
  ##    will NOT own the mutex.
  ##   
  ##    \param mtx Pointer to recursive mutex structure
  ##    \param until The time after which to return if the caller cannot be granted ownership of the mutex
  ##    \return true if the recursive mutex (now) owned, false if timeout occurred before ownership could be granted
  ## ```

proc mutexExit*(mtx: ptr Mutex) {.importc: "mutex_exit".}
  ## ```
  ##   ! \brief  Release ownership of a mutex
  ##     \ingroup mutex
  ##   
  ##    \param mtx Pointer to mutex structure
  ## ```

proc recursiveMutexExit*(mtx: ptr Mutex) {.importc: "recursive_mutex_exit".}
  ## ```
  ##   ! \brief  Release ownership of a recursive mutex
  ##     \ingroup mutex
  ##   
  ##    \param mtx Pointer to recursive mutex structure
  ## ```

proc mutexIsInitialized*(mtx: ptr Mutex): bool {.importc: "mutex_is_initialized".}
  ## ```
  ##   ! \brief Test for mutex initialized state
  ##     \ingroup mutex
  ##   
  ##    \param mtx Pointer to mutex structure
  ##    \return true if the mutex is initialized, false otherwise
  ## ```

proc recursiveMutexIsInitialized*(mtx: ptr Mutex): bool {.importc: "recursive_mutex_is_initialized".}
  ## ```
  ##   ! \brief Test for recursive mutex initialized state
  ##     \ingroup mutex
  ##   
  ##    \param mtx Pointer to recursive mutex structure
  ##    \return true if the recursive mutex is initialized, false otherwise
  ## ```

{.pop.}
