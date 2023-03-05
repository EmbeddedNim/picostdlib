type
  ExceptionNumber* {.pure, size: sizeof(cint).} = enum
    ## Exception number definitions
    ##
    ##    Note for consistency with irq numbers, these numbers are defined to be negative. The VTABLE index is
    ##    the number here plus 16.
    ##
    ##    Name                 | Value | Exception
    ##    ---------------------|-------|----------
    ##    NMI_EXCEPTION        |  -14  | Non Maskable Interrupt
    ##    HARDFAULT_EXCEPTION  |  -13  | HardFault
    ##    SVCALL_EXCEPTION     |   -5  | SV Call
    ##    PENDSV_EXCEPTION     |   -2  | Pend SV
    ##    SYSTICK_EXCEPTION    |   -1  | System Tick
    ##
    Nmi        = -14    # Non Maskable Interrupt
    Hardfault  = -13    # HardFault Interrupt
    SVCall     =  -5    # SV Call Interrupt
    PendSV     =  -2    # Pend SV Interrupt
    SysTick    =  -1    # System Tick Interrupt

{.push header: "hardware/exception.h".}

type
  ExceptionHandler* {.importc: "exception_handler_t".} = proc () {.cdecl.}
    ## Exception handler function type
    ## 
    ## All exception handlers should be of this type, and follow normal ARM EABI register saving conventions

proc exceptionSetExclusiveHandler*(num: ExceptionNumber; handler: ExceptionHandler): ExceptionHandler {.importc: "exception_set_exclusive_handler".}
  ## Set the exception handler for an exception on the executing core.
  ## 
  ## This method will assert if an exception handler has been set for this exception number on this core via
  ## this method, without an intervening restore via exception_restore_handler.
  ## 
  ## \note this method may not be used to override an exception handler that was specified at link time by
  ## providing a strong replacement for the weakly defined stub exception handlers. It will assert in this case too.
  ## 
  ## \param num Exception number
  ## \param handler The handler to set
  ## \see exception_number

proc exceptionRestoreHandler*(num: ExceptionNumber; originalHandler: ExceptionHandler) {.importc: "exception_restore_handler".}
  ## Restore the original exception handler for an exception on this core
  ## 
  ## This method may be used to restore the exception handler for an exception on this core to the state
  ## prior to the call to exception_set_exclusive_handler(), so that exception_set_exclusive_handler()
  ## may be called again in the future.
  ## 
  ## \param num Exception number \ref exception_number
  ## \param original_handler The original handler returned from \ref exception_set_exclusive_handler
  ## \see exception_set_exclusive_handler()

proc exception_get_vtable_handler*(num: ExceptionNumber): ExceptionHandler {.importc: "exception_get_vtable_handler".}
  ## Get the current exception handler for the specified exception from the currently installed vector table
  ## of the execution core
  ## 
  ## \param num Exception number
  ## \return the address stored in the VTABLE for the given exception number

{.pop.}
