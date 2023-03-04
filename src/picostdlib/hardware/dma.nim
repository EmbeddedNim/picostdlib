{.push header: "hardware/dma.h".}

type
  DmaChannelTransferSize* {.pure, importc: "enum dma_channel_transfer_size".} = enum
    DmaSize8
    DmaSize16
    DmaSize32

  DmaChannelConfig* {.bycopy, importc: "dma_channel_config".} = object
    ctrl* {.importc.}: uint32

proc dmaChannelClaim*(channel: cuint) {.importc: "dma_channel_claim".}
  ## Mark a dma channel as used
  ## 
  ## Method for cooperative claiming of hardware. Will cause a panic if the channel
  ## is already claimed. Use of this method by libraries detects accidental
  ## configurations that would fail in unpredictable ways.
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    the dma channel
  ## ============  ====== 

proc dmaClaimMask*(channelMask: uint32) {.importc: "dma_claim_mask".}
  ## Mark multiple dma channels as used
  ## 
  ## Method for cooperative claiming of hardware. Will cause a panic if any of the channels
  ## are already claimed. Use of this method by libraries detects accidental
  ## configurations that would fail in unpredictable ways.
  ## 
  ## **Parameters:**
  ## 
  ## ================  ====== 
  ## **channelMask**    Bitfield of all required channels to claim (bit 0 == channel 0, bit 1 == channel 1 etc)
  ## ================  ====== 

proc dmaChannelUnclaim*(channel: cuint) {.importc: "dma_channel_unclaim".}
  ## Mark a dma channel as no longer used
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    the dma channel to release
  ## ============  ====== 

proc dmaUnclaimMask*(channelMask: uint32) {.importc: "dma_unclaim_mask".}
  ## Mark multiple dma channels as no longer used
  ## 
  ## **Parameters:**
  ## 
  ## ================  ====== 
  ## **channelMask**    Bitfield of all channels to unclaim (bit 0 == channel 0, bit 1 == channel 1 etc)
  ## ================  ====== 

proc dmaClaimUnusedChannel*(required: bool): cint {.importc: "dma_claim_unused_channel".}
  ## Claim a free dma channel
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **required**    if true the function will panic if none are available
  ## =============  ====== 
  ## 
  ## **returns** the dma channel number or -1 if required was false, and none were free

proc dmaChannelIsClaimed*(channel: cuint): bool {.importc: "dma_channel_is_claimed".}
  ## Determine if a dma channel is claimed
  ## 
  ## Method for cooperative claiming of hardware. Will cause a panic if the channel
  ## is already claimed. Use of this method by libraries detects accidental
  ## configurations that would fail in unpredictable ways.
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    the dma channel
  ## ============  ====== 
  ## 
  ## **returns** true if the channel is claimed, false otherwise

proc channelConfigSetReadIncrement*(c: ptr DmaChannelConfig, incr: bool) {.importc: "channel_config_set_read_increment".}
  ## Set DMA channel read increment in a channel configuration object
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **c**       Pointer to channel configuration object
  ## **incr**    True to enable read address increments, if false, each read will be from the same address
  ##             Usually disabled for peripheral to memory transfers
  ## =========  ====== 

proc channelConfigSetWriteIncrement*(c: ptr DmaChannelConfig, incr: bool) {.importc: "channel_config_set_write_increment".}
  ## Set DMA channel write increment in a channel configuration object
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **c**       Pointer to channel configuration object
  ## **incr**    True to enable write address increments, if false, each write will be to the same address
  ##             Usually disabled for peripheral to memory transfers
  ## =========  ====== 


proc channelConfigSetDreq*(c: ptr DmaChannelConfig, dreq: cuint) {.importc: "channel_config_set_dreq".}
  ## Select a transfer request signal in a channel configuration object
  ## 
  ## The channel uses the transfer request signal to pace its data transfer rate.
  ## Sources for TREQ signals are internal (TIMERS) or external (DREQ, a Data Request from the system).
  ## 0x0 to 0x3a -> select DREQ n as TREQ
  ## 0x3b -> Select Timer 0 as TREQ
  ## 0x3c -> Select Timer 1 as TREQ
  ## 0x3d -> Select Timer 2 as TREQ (Optional)
  ## 0x3e -> Select Timer 3 as TREQ (Optional)
  ## 0x3f -> Permanent request, for unpaced transfers.
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **c**       Pointer to channel configuration data
  ## **dreq**    Source (see description)
  ## =========  ====== 

proc channelConfigSetChainTo*(c: ptr DmaChannelConfig, chainTo: cuint) {.importc: "channel_config_set_chain_to".}
  ## Set DMA channel chain_to channel in a channel configuration object
  ## 
  ## When this channel completes, it will trigger the channel indicated by chain_to. Disable by
  ## setting chain_to to itself (the same channel)
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **c**          Pointer to channel configuration object
  ## **chainTo**    Channel to trigger when this channel completes.
  ## ============  ====== 

proc channelConfigSetTransferDataSize*(c: ptr DmaChannelConfig, size: DmaChannelTransferSize) {.importc: "channel_config_set_transfer_data_size".}
  ## Set the size of each DMA bus transfer in a channel configuration object
  ## 
  ## Set the size of each bus transfer (byte/halfword/word). The read and write addresses
  ## advance by the specific amount (1/2/4 bytes) with each transfer.
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **c**       Pointer to channel configuration object
  ## **size**    See enum for possible values.
  ## =========  ====== 

proc channelConfigSetRing*(c: ptr DmaChannelConfig, write: bool, sizeBits: cuint) {.importc: "channel_config_set_ring".}
  ## Set address wrapping parameters in a channel configuration object
  ## 
  ## Size of address wrap region. If 0, don’t wrap. For values n > 0, only the lower n bits of the address
  ## will change. This wraps the address on a (1 << n) byte boundary, facilitating access to naturally-aligned
  ## ring buffers.
  ## Ring sizes between 2 and 32768 bytes are possible (size_bits from 1 - 15)
  ##
  ## 0x0 -> No wrapping.
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **c**           Pointer to channel configuration object
  ## **write**       True to apply to write addresses, false to apply to read addresses
  ## **sizeBits**    0 to disable wrapping. Otherwise the size in bits of the changing part of the address.
  ##                 Effectively wraps the address on a (1 << sizeBits) byte boundary.
  ## =============  ====== 

proc channelConfigSetBswap*(c: ptr DmaChannelConfig, bswap: bool) {.importc: "channel_config_set_bswap".}
  ## Set DMA byte swapping config in a channel configuration object
  ## 
  ## No effect for byte data, for halfword data, the two bytes of each halfword are
  ## swapped. For word data, the four bytes of each word are swapped to reverse their order.
  ## 
  ## **Parameters:**
  ## 
  ## ==========  ====== 
  ## **c**        Pointer to channel configuration object
  ## **bswap**    True to enable byte swapping
  ## ==========  ====== 

proc channelConfigSetIrqQuiet*(c: ptr DmaChannelConfig; irqQuiet: bool) {.importc: "channel_config_set_irq_quiet".}
  ## Set IRQ quiet mode in a channel configuration object
  ## 
  ## In QUIET mode, the channel does not generate IRQs at the end of every transfer block. Instead,
  ## an IRQ is raised when NULL is written to a trigger register, indicating the end of a control
  ## block chain.
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **c**           Pointer to channel configuration object
  ## **irqQuiet**    True to enable quiet mode, false to disable.
  ## =============  ====== 

proc channelConfigSetHighPriority*(c: ptr DmaChannelConfig; highPriority: bool) {.importc: "channel_config_set_high_priority".}
  ## Set the channel priority in a channel configuration object
  ## 
  ## When true, gives a channel preferential treatment in issue scheduling: in each scheduling round,
  ## all high priority channels are considered first, and then only a single low
  ## priority channel, before returning to the high priority channels.
  ## 
  ## This only affects the order in which the DMA schedules channels. The DMA's bus priority is not changed.
  ## If the DMA is not saturated then a low priority channel will see no loss of throughput.
  ## 
  ## **Parameters:**
  ## 
  ## =================  ====== 
  ## **c**               Pointer to channel configuration object
  ## **highPriority**    True to enable high priority
  ## =================  ====== 

proc channelConfigSetEnable*(c: ptr DmaChannelConfig; enable: bool) {.importc: "channel_config_set_enable".}
  ## Enable/Disable the DMA channel in a channel configuration object
  ## 
  ## When false, the channel will ignore triggers, stop issuing transfers, and pause the current transfer sequence (i.e. BUSY will
  ## remain high if already high)
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **c**         Pointer to channel configuration object
  ## **enable**    True to enable the DMA channel. When enabled, the channel will respond to triggering events, and start transferring data.
  ## ============  ====== 

proc channelConfigSetSniffEnable*(c: ptr DmaChannelConfig; sniffEnable: bool) {.importc: "channel_config_set_sniff_enable".}
  ## Enable access to channel by sniff hardware in a channel configuration object
  ## 
  ## Sniff HW must be enabled and have this channel selected.
  ## 
  ## **Parameters:**
  ## 
  ## ================  ====== 
  ## **c**              Pointer to channel configuration object
  ## **sniffEnable**    True to enable the Sniff HW access to this DMA channel.
  ## ================  ====== 

proc dmaChannelGetDefaultConfig*(channel: cuint): DmaChannelConfig {.importc: "dma_channel_get_default_config".}
  ## Get the default channel configuration for a given channel
  ## 
  ## Setting | Default
  ## --------|--------
  ## Read Increment | true
  ## Write Increment | false
  ## DReq | DREQ_FORCE
  ## Chain to | self
  ## Data size | DMA_SIZE_32
  ## Ring | write=false, size=0 (i.e. off)
  ## Byte Swap | false
  ## Quiet IRQs | false
  ## High Priority | false
  ## Channel Enable | true
  ## Sniff Enable | false
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    DMA channel
  ## ============  ====== 
  ## 
  ## **returns** the default configuration which can then be modified.

proc dmaGetChannelConfig*(channel: cuint): DmaChannelConfig {.importc: "dma_get_channel_config".}
  ## Get the current configuration for the specified channel.
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    DMA channel
  ## ============  ====== 
  ## 
  ## **returns** The current configuration as read from the HW register (not cached)

proc channelConfigGetCtrlValue*(config: ptr DmaChannelConfig): uint32 {.importc: "channel_config_get_ctrl_value".}
  ## Get the raw configuration register from a channel configuration
  ## 
  ## **Parameters:**
  ## 
  ## ===========  ====== 
  ## **config**    Pointer to a config structure.
  ## ===========  ====== 
  ## 
  ## **returns** Register content

proc dmaChannelSetConfig*(channel: cuint; config: ptr DmaChannelConfig; trigger: bool) {.importc: "dma_channel_set_config".}
  ## Set a channel configuration
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    DMA channel
  ## **config**     Pointer to a config structure with required configuration
  ## **trigger**    True to trigger the transfer immediately
  ## ============  ====== 

proc dmaChannelSetReadAddr*(channel: cuint; readAddr: pointer; trigger: bool) {.importc: "dma_channel_set_read_addr".}
  ## Set the DMA initial read address.
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **channel**     DMA channel
  ## **readAddr**    Initial read address of transfer.
  ## **trigger**     True to start the transfer immediately
  ## =============  ====== 

proc dmaChannelSetWriteAddr*(channel: cuint; writeAddr: pointer; trigger: bool) {.importc: "dma_channel_set_write_addr".}
  ## Set the DMA initial write address
  ## 
  ## **Parameters:**
  ## 
  ## ==============  ====== 
  ## **channel**      DMA channel
  ## **writeAddr**    Initial write address of transfer.
  ## **trigger**      True to start the transfer immediately
  ## ==============  ====== 

proc dmaChannelSetTransCount*(channel: cuint; transCount: uint32; trigger: bool) {.importc: "dma_channel_set_trans_count".}
  ## Set the number of bus transfers the channel will do
  ## 
  ## **Parameters:**
  ## 
  ## ===============  ====== 
  ## **channel**       DMA channel
  ## **transCount**    The number of transfers (not NOT bytes, see channelConfigSetTransferDataSize)
  ## **trigger**       True to start the transfer immediately
  ## ===============  ====== 
proc dmaChannelConfigure*(channel: cuint; config: ptr DmaChannelConfig; writeAddr: pointer; readAddr: pointer; transferCount: cuint; trigger: bool) {.importc: "dma_channel_configure".}
  ## Configure all DMA parameters and optionally start transfer
  ## 
  ## **Parameters:**
  ## 
  ## ==================  ====== 
  ## **channel**          DMA channel
  ## **config**           Pointer to DMA config structure
  ## **writeAddr**        Initial write address
  ## **readAddr**         Initial read address
  ## **transferCount**    Number of transfers to perform
  ## **trigger**          True to start the transfer immediately
  ## ==================  ====== 

proc dmaChannelTransferFromBufferNow*(channel: cuint; readAddr: pointer; transferCount: uint32) {.importc: "dma_channel_transfer_from_buffer_now".}
  ## Start a DMA transfer from a buffer immediately
  ## 
  ## **Parameters:**
  ## 
  ## ==================  ====== 
  ## **channel**          DMA channel
  ## **readAddr**         Sets the initial read address
  ## **transferCount**    Number of transfers to make. Not bytes, but the number of transfers of channelConfigSetTransferDataSize() to be sent.
  ## ==================  ====== 

proc dmaChannelTransferToBufferNow*(channel: cuint; writeAddr: pointer; transferCount: uint32) {.importc: "dma_channel_transfer_to_buffer_now".}
  ## Start a DMA transfer to a buffer immediately
  ## 
  ## **Parameters:**
  ## 
  ## ==================  ====== 
  ## **channel**          DMA channel
  ## **writeAddr**        Sets the initial write address
  ## **transferCount**    Number of transfers to make. Not bytes, but the number of transfers of channelConfigSetTransferDataSize() to be sent.
  ## ==================  ====== 

proc dmaStartChannelMask*(chanMask: uint32) {.importc: "dma_start_channel_mask".}
  ## Start one or more channels simultaneously
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **chanMask**    Bitmask of all the channels requiring starting. Channel 0 = bit 0, channel 1 = bit 1 etc.
  ## =============  ====== 

proc dmaChannelStart*(channel: cuint) {.importc: "dma_channel_start".}
  ## Start a single DMA channel
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    DMA channel
  ## ============  ====== 

proc dmaChannelAbort*(channel: cuint) {.importc: "dma_channel_abort".}
  ## Stop a DMA transfer
  ## 
  ## Function will only return once the DMA has stopped.
  ## 
  ## Note that due to errata RP2040-E13, aborting a channel which has transfers
  ## in-flight (i.e. an individual read has taken place but the corresponding write has not), the ABORT
  ## status bit will clear prematurely, and subsequently the in-flight
  ## transfers will trigger a completion interrupt once they complete.
  ##   
  ## The effect of this is that you *may* see a spurious completion interrupt
  ## on the channel as a result of calling this method.
  ##   
  ## The calling code should be sure to ignore a completion IRQ as a result of this method. This may
  ## not require any additional work, as aborting a channel which may be about to complete, when you have a completion
  ## IRQ handler registered, is inherently race-prone, and so code is likely needed to disambiguate the two occurrences.
  ##   
  ## If that is not the case, but you do have a channel completion IRQ handler registered, you can simply
  ## disable/re-enable the IRQ around the call to this method as shown by this code fragment (using DMA IRQ0).
  ## 
  ## ```
  ##  # disable the channel on IRQ0
  ##  dma_channel_set_irq0_enabled(channel, false);
  ##  # abort the channel
  ##  dma_channel_abort(channel);
  ##  # clear the spurious IRQ (if there was one)
  ##  dma_channel_acknowledge_irq0(channel);
  ##  # re-enable the channel on IRQ0
  ##  dma_channel_set_irq0_enabled(channel, true);
  ## ```
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    DMA channel
  ## ============  ====== 

proc dmaChannelSetIrq0Enabled*(channel: cuint; enabled: bool) {.importc: "dma_channel_set_irq0_enabled".}
  ## Enable single DMA channel's interrupt via DMA_IRQ_0
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    DMA channel
  ## **enabled**    true to enable interrupt 0 on specified channel, false to disable.
  ## ============  ====== 

proc dmaSetIrq0ChannelMaskEnabled*(channelMask: uint32; enabled: bool) {.importc: "dma_set_irq0_channel_mask_enabled".}
  ## Enable multiple DMA channels' interrupts via DMA_IRQ_0
  ## 
  ## **Parameters:**
  ## 
  ## ================  ====== 
  ## **channelMask**    Bitmask of all the channels to enable/disable. Channel 0 = bit 0, channel 1 = bit 1 etc.
  ## **enabled**        true to enable all the interrupts specified in the mask, false to disable all the interrupts specified in the mask.
  ## ================  ====== 

proc dmaChannelSetIrq1Enabled*(channel: cuint; enabled: bool) {.importc: "dma_channel_set_irq1_enabled".}
  ## Enable single DMA channel's interrupt via DMA_IRQ_1
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    DMA channel
  ## **enabled**    true to enable interrupt 1 on specified channel, false to disable.
  ## ============  ====== 

proc dmaSetIrq1ChannelMaskEnabled*(channelMask: uint32; enabled: bool) {.importc: "dma_set_irq1_channel_mask_enabled".}
  ## Enable multiple DMA channels' interrupts via DMA_IRQ_1
  ## 
  ## **Parameters:**
  ## 
  ## ================  ====== 
  ## **channelMask**    Bitmask of all the channels to enable/disable. Channel 0 = bit 0, channel 1 = bit 1 etc.
  ## **enabled**        true to enable all the interrupts specified in the mask, false to disable all the interrupts specified in the mask.
  ## ================  ====== 

proc dmaIrqnSetChannelEnabled*(irqIndex: cuint; channel: cuint; enabled: bool) {.importc: "dma_irqn_set_channel_enabled".}
  ## Enable single DMA channel interrupt on either DMA_IRQ_0 or DMA_IRQ_1
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **irqIndex**    the IRQ index; either 0 or 1 for DMA_IRQ_0 or DMA_IRQ_1
  ## **channel**     DMA channel
  ## **enabled**     true to enable interrupt via irqIndex for specified channel, false to disable.
  ## =============  ====== 

proc dmaIrqnSetChannelMaskEnabled*(irqIndex: cuint; channelMask: uint32; enabled: bool) {.importc: "dma_irqn_set_channel_mask_enabled".}
  ## Enable multiple DMA channels' interrupt via either DMA_IRQ_0 or DMA_IRQ_1
  ## 
  ## **Parameters:**
  ## 
  ## ================  ====== 
  ## **irqIndex**       the IRQ index; either 0 or 1 for DMA_IRQ_0 or DMA_IRQ_1
  ## **channelMask**    Bitmask of all the channels to enable/disable. Channel 0 = bit 0, channel 1 = bit 1 etc.
  ## **enabled**        true to enable all the interrupts specified in the mask, false to disable all the interrupts specified in the mask.
  ## ================  ====== 

proc dmaChannelGetIrq0Status*(channel: cuint): bool {.importc: "dma_channel_get_irq0_status".}
  ## Determine if a particular channel is a cause of DMA_IRQ_0
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    DMA channel
  ## ============  ====== 
  ## 
  ## **returns** true if the channel is a cause of DMA_IRQ_0, false otherwise

proc dmaChannelGetIrq1Status*(channel: cuint): bool {.importc: "dma_channel_get_irq1_status".}
  ## Determine if a particular channel is a cause of DMA_IRQ_1
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    DMA channel
  ## ============  ====== 
  ## 
  ## **returns** true if the channel is a cause of DMA_IRQ_1, false otherwise

proc dmaIrqnGetChannelStatus*(irqIndex: cuint; channel: cuint): bool {.importc: "dma_irqn_get_channel_status".}
  ## Determine if a particular channel is a cause of DMA_IRQ_N
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **irqIndex**    the IRQ index; either 0 or 1 for DMA_IRQ_0 or DMA_IRQ_1
  ## **channel**     DMA channel
  ## =============  ====== 
  ## 
  ## **returns** true if the channel is a cause of the DMA_IRQ_N, false otherwise

proc dmaChannelAcknowledgeIrq0*(channel: cuint) {.importc: "dma_channel_acknowledge_irq0".}
  ## Acknowledge a channel IRQ, resetting it as the cause of DMA_IRQ_0
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    DMA channel
  ## ============  ====== 

proc dmaChannelAcknowledgeIrq1*(channel: cuint) {.importc: "dma_channel_acknowledge_irq1".}
  ## Acknowledge a channel IRQ, resetting it as the cause of DMA_IRQ_1
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    DMA channel
  ## ============  ====== 

proc dmaIrqnAcknowledgeChannel*(irqIndex: cuint; channel: cuint) {.importc: "dma_irqn_acknowledge_channel".}
  ## Acknowledge a channel IRQ, resetting it as the cause of DMA_IRQ_N
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **irqIndex**    the IRQ index; either 0 or 1 for DMA_IRQ_0 or DMA_IRQ_1
  ## **channel**     DMA channel
  ## =============  ====== 

proc dmaChannelIsBusy*(channel: cuint): bool {.importc: "dma_channel_is_busy".}
  ## Check if DMA channel is busy
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    DMA channel
  ## ============  ====== 
  ## 
  ## **returns** true if the channel is currently busy

proc dmaChannelWaitForFinishBlocking*(channel: cuint) {.importc: "dma_channel_wait_for_finish_blocking".}
  ## Wait for a DMA channel transfer to complete
  ## 
  ## **Parameters:**
  ## 
  ## ============  ====== 
  ## **channel**    DMA channel
  ## ============  ====== 

proc dmaSnifferEnable*(channel: cuint; mode: cuint; forceChannelEnable: bool) {.importc: "dma_sniffer_enable".}
  ## Enable the DMA sniffing targeting the specified channel
  ## 
  ## The mode can be one of the following:
  ## 
  ## Mode | Function
  ## -----|---------
  ## 0x0 | Calculate a CRC-32 (IEEE802.3 polynomial)
  ## 0x1 | Calculate a CRC-32 (IEEE802.3 polynomial) with bit reversed data
  ## 0x2 | Calculate a CRC-16-CCITT
  ## 0x3 | Calculate a CRC-16-CCITT with bit reversed data
  ## 0xe | XOR reduction over all data. == 1 if the total 1 population count is odd.
  ## 0xf | Calculate a simple 32-bit checksum (addition with a 32 bit accumulator)
  ## 
  ## **Parameters:**
  ## 
  ## =======================  ====== 
  ## **channel**               DMA channel
  ## **mode**                  See description
  ## **forceChannelEnable**    Set true to also turn on sniffing in the channel configuration (this
  ##                           is usually what you want, but sometimes you might have a chain DMA with only certain segments
  ##                           of the chain sniffed, in which case you might pass false).
  ## =======================  ====== 

proc dmaSnifferSetByteSwapEnabled*(swap: bool) {.importc: "dma_sniffer_set_byte_swap_enabled".}
  ## Enable the Sniffer byte swap function
  ## 
  ## Locally perform a byte reverse on the sniffed data, before feeding into checksum.
  ## 
  ## Note that the sniff hardware is downstream of the DMA channel byteswap performed in the
  ## read master: if channel_config_set_bswap() and dma_sniffer_set_byte_swap_enabled() are both enabled,
  ## their effects cancel from the sniffer’s point of view.
  ## 
  ## **Parameters:**
  ## 
  ## =========  ====== 
  ## **swap**    Set true to enable byte swapping
  ## =========  ====== 

proc dmaSnifferSetOutputInvertEnabled*(invert: bool) {.importc: "dma_sniffer_set_output_invert_enabled".}
  ## Enable the Sniffer output invert function
  ##
  ## If enabled, the sniff data result appears bit-inverted when read.
  ## This does not affect the way the checksum is calculated.
  ##
  ## \param invert Set true to enable output bit inversion

proc dmaSnifferSetOutputReverseEnabled*(reverse: bool) {.importc: "dma_sniffer_set_output_reverse_enabled".}
  ## Enable the Sniffer output bit reversal function
  ##
  ## If enabled, the sniff data result appears bit-reversed when read.
  ## This does not affect the way the checksum is calculated.
  ##
  ## \param reverse Set true to enable output bit reversal

proc dmaSnifferDisable*() {.importc: "dma_sniffer_disable".}
  ## Disable the DMA sniffer

proc dmaSnifferSetDataAccumulator*(seedValue: uint32) {.importc: "dma_sniffer_set_data_accumulator".}
  ## Set the sniffer's data accumulator with initial value
  ##
  ## Generally, CRC algorithms are used with the data accumulator initially
  ## seeded with 0xFFFF or 0xFFFFFFFF (for crc16 and crc32 algorithms)
  ##
  ## \param seed_value value to set data accumulator

proc dmaSnifferGetDataAccumulator*(): uint32 {.importc: "dma_sniffer_get_data_accumulator".}
  ## Get the sniffer's data accumulator value
  ##
  ## Read value calculated by the hardware from sniffing the DMA stream

proc dmaTimerClaim*(timer: cuint) {.importc: "dma_timer_claim".}
  ## Mark a dma timer as used
  ## 
  ## Method for cooperative claiming of hardware. Will cause a panic if the timer
  ## is already claimed. Use of this method by libraries detects accidental
  ## configurations that would fail in unpredictable ways.
  ## 
  ## **Parameters:**
  ## 
  ## ==========  ====== 
  ## **timer**    the dma timer
  ## ==========  ====== 

proc dmaTimerUnclaim*(timer: cuint) {.importc: "dma_timer_unclaim".}
  ## Mark a dma timer as no longer used
  ## 
  ## Method for cooperative claiming of hardware.
  ## 
  ## **Parameters:**
  ## 
  ## ==========  ====== 
  ## **timer**    the dma timer to release
  ## ==========  ====== 

proc dmaClaimUnusedTimer*(required: bool): cint {.importc: "dma_claim_unused_timer".}
  ## Claim a free dma timer
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **required**    if true the function will panic if none are available
  ## =============  ====== 
  ## 
  ## **returns** the dma timer number or -1 if required was false, and none were free

proc dmaTimerIsClaimed*(timer: cuint): bool {.importc: "dma_timer_is_claimed".}
  ## Determine if a dma timer is claimed
  ## 
  ## **Parameters:**
  ## 
  ## ==========  ====== 
  ## **timer**    the dma timer
  ## ==========  ====== 
  ## 
  ## **returns** if the timer is claimed, false otherwise
  ## 
  ## **note** see dmaTimerClaim

proc dmaTimerSetFraction*(timer: cuint; numerator: uint16; denominator: uint16) {.importc: "dma_timer_set_fraction".}
  ## Set the divider for the given DMA timer
  ## 
  ## The timer will run at the system_clock_freq numerator / denominator, so this is the speed
  ## that data elements will be transferred at via a DMA channel using this timer as a DREQ
  ## 
  ## **Parameters:**
  ## 
  ## ================  ====== 
  ## **timer**          the dma timer
  ## **numerator**      the fraction's numerator
  ## **denominator**    the fraction's denominator
  ## ================  ====== 

proc dmaGetTimerDreq*(timerNum: cuint): cuint {.importc: "dma_get_timer_dreq".}
  ## Return the DREQ number for a given DMA timer
  ## 
  ## **Parameters:**
  ## 
  ## =============  ====== 
  ## **timerNum**    DMA timer number 0-3
  ## =============  ====== 
  ## 
  ## **returns** DREQ number for a given DMA timer

{.pop.}
