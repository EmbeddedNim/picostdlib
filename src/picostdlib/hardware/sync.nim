{.push header: "hardware/sync.h".}

type
  SpinLock* {.importc: "spin_lock_t".} = uint32
    ## A spin lock identifier

const
  PicoSpinlockIdIrq* = 9
  PicoSpinlockIdTimer* = 10
  PicoSpinlockIdHardwareClaim* = 11
  PicoSpinlockIdOs1* = 14
  PicoSpinlockIdOs2* = 15
  PicoSpinlockIdStripedFirst* = 16
  PicoSpinlockIdStripedLast* = 23
  PicoSpinlockIdClaimFreeFirst* = 24
  PicoSpinlockIdClaimFreeLast* = 31

proc saveAndDisableInterrupts*(): uint32 {.importc: "save_and_disable_interrupts".}
  ## Save and disable interrupts
  ##     \ingroup hardware_sync
  ##   
  ##    \return The prior interrupt enable status for restoration later via restore_interrupts()

proc restoreInterrupts*(status: uint32) {.importc: "restore_interrupts".}
  ## Restore interrupts to a specified state
  ##     \ingroup hardware_sync
  ##   
  ##    \param status Previous interrupt status from save_and_disable_interrupts()

proc spinLockInstance*(lockNum: cuint): ptr SpinLock {.importc: "spin_lock_instance".}
  ## Get HW Spinlock instance from number
  ##     \ingroup hardware_sync
  ##   
  ##    \param lock_num Spinlock ID
  ##    \return The spinlock instance

proc spinLockGetNum*(lock: ptr SpinLock): cuint {.importc: "spin_lock_get_num".}
  ## Get HW Spinlock number from instance
  ##     \ingroup hardware_sync
  ##   
  ##    \param lock The Spinlock instance
  ##    \return The Spinlock ID

proc spinLockUnsafeBlocking*(lock: ptr SpinLock) {.importc: "spin_lock_unsafe_blocking".}
  ## Acquire a spin lock without disabling interrupts (hence unsafe)
  ##     \ingroup hardware_sync
  ##   
  ##    \param lock Spinlock instance

proc spinUnlockUnsafe*(lock: ptr SpinLock) {.importc: "spin_unlock_unsafe".}
  ## Release a spin lock without re-enabling interrupts
  ##     \ingroup hardware_sync
  ##   
  ##    \param lock Spinlock instance

proc spinLockBlocking*(lock: ptr SpinLock): uint32 {.importc: "spin_lock_blocking".}
  ## Acquire a spin lock safely
  ##     \ingroup hardware_sync
  ##   
  ##    This function will disable interrupts prior to acquiring the spinlock
  ##   
  ##    \param lock Spinlock instance
  ##    \return interrupt status to be used when unlocking, to restore to original state

proc isSpinLocked*(lock: ptr SpinLock): bool {.importc: "is_spin_locked".}
  ## Check to see if a spinlock is currently acquired elsewhere.
  ##     \ingroup hardware_sync
  ##   
  ##    \param lock Spinlock instance

proc spinUnlock*(lock: ptr SpinLock, savedIrq: uint32) {.importc: "spin_unlock".}
  ## Release a spin lock safely
  ##     \ingroup hardware_sync
  ##   
  ##    This function will re-enable interrupts according to the parameters.
  ##   
  ##    \param lock Spinlock instance
  ##    \param saved_irq Return value from the \ref spin_lock_blocking() function.
  ##    \return interrupt status to be used when unlocking, to restore to original state
  ##   
  ##    \sa spin_lock_blocking()

proc spinLockInit*(lockNum: cuint): ptr SpinLock {.importc: "spin_lock_init".}
  ## Initialise a spin lock
  ##     \ingroup hardware_sync
  ##   
  ##    The spin lock is initially unlocked
  ##   
  ##    \param lock_num The spin lock number
  ##    \return The spin lock instance

proc spinLocksReset*() {.importc: "spin_locks_reset".}
  ## Release all spin locks
  ##     \ingroup hardware_sync

proc nextStripedSpinLockNum*(): uint {.importc: "next_striped_spin_lock_num".}
  ## Return a spin lock number from the _striped_ range
  ##     \ingroup hardware_sync
  ##   
  ##    Returns a spin lock number in the range PICO_SPINLOCK_ID_STRIPED_FIRST to PICO_SPINLOCK_ID_STRIPED_LAST
  ##    in a round robin fashion. This does not grant the caller exclusive access to the spin lock, so the caller
  ##    must:
  ##   
  ##    -# Abide (with other callers) by the contract of only holding this spin lock briefly (and with IRQs disabled - the default via \ref spin_lock_blocking()),
  ##    and not whilst holding other spin locks.
  ##    -# Be OK with any contention caused by the - brief due to the above requirement - contention with other possible users of the spin lock.
  ##   
  ##    \return lock_num a spin lock number the caller may use (non exclusively)
  ##    \see PICO_SPINLOCK_ID_STRIPED_FIRST
  ##    \see PICO_SPINLOCK_ID_STRIPED_LAST

proc spinLockClaim*(lockNum: cuint) {.importc: "spin_lock_claim".}
  ## Mark a spin lock as used
  ##     \ingroup hardware_sync
  ##   
  ##    Method for cooperative claiming of hardware. Will cause a panic if the spin lock
  ##    is already claimed. Use of this method by libraries detects accidental
  ##    configurations that would fail in unpredictable ways.
  ##   
  ##    \param lock_num the spin lock number

proc spinLockClaimMask*(lock_num_mask: uint32) {.importc: "spin_lock_claim_mask".}
  ## Mark multiple spin locks as used
  ##     \ingroup hardware_sync
  ##   
  ##    Method for cooperative claiming of hardware. Will cause a panic if any of the spin locks
  ##    are already claimed. Use of this method by libraries detects accidental
  ##    configurations that would fail in unpredictable ways.
  ##   
  ##    \param lock_num_mask Bitfield of all required spin locks to claim (bit 0 == spin lock 0, bit 1 == spin lock 1 etc)

proc spinLockUnclaim*(lockNum: cuint) {.importc: "spin_lock_unclaim".}
  ## Mark a spin lock as no longer used
  ##     \ingroup hardware_sync
  ##   
  ##    Method for cooperative claiming of hardware.
  ##   
  ##    \param lock_num the spin lock number to release

proc spinLockClaimUnused*(required: bool): cint {.importc: "spin_lock_claim_unused".}
  ## Claim a free spin lock
  ##     \ingroup hardware_sync
  ##   
  ##    \param required if true the function will panic if none are available
  ##    \return the spin lock number or -1 if required was false, and none were free

proc spinLockIsClaimed*(lockNum: cuint): bool {.importc: "spin_lock_is_claimed".}
  ## Determine if a spin lock is claimed
  ##     \ingroup hardware_sync
  ##   
  ##    \param lock_num the spin lock number
  ##    \return true if claimed, false otherwise
  ##    \see spin_lock_claim
  ##    \see spin_lock_claim_mask

{.pop.}
