import ../base

{.push header: "hardware/structs/i2c.h".}

type
  I2cHw* {.importc: "i2c_hw_t".} = object
    con* {.importc.}: IoRw32
    tar* {.importc.}: IoRw32
    sar* {.importc.}: IoRw32
    pad0 {.importc: "_pad0".}: uint32
    dataCmd* {.importc: "data_cmd".}: IoRw32
    ssSclHcnt* {.importc: "ss_scl_hcnt".}: IoRw32
    ssSclLcnt* {.importc: "ss_scl_lcnt".}: IoRw32
    fsSclHcnt* {.importc: "fs_scl_hcnt".}: IoRw32
    fsSclLcnt* {.importc: "fs_scl_lcnt".}: IoRw32
    pad1 {.importc: "_pad1".}: array[2, uint32]
    intrStat* {.importc: "intr_stat".}: IoRo32
    intrMask* {.importc: "intr_mask".}: IoRw32
    rawIntrStat* {.importc: "raw_intr_stat".}: IoRo32
    rxTl* {.importc: "rx_tl".}: IoRw32
    txTl* {.importc: "tx_tl".}: IoRw32
    clrIntr* {.importc: "clr_intr".}: IoRo32
    clrRxUnder* {.importc: "clr_rx_under".}: IoRo32
    clrRxOver* {.importc: "clr_rx_over".}: IoRo32
    clTxOver* {.importc: "clr_tx_over".}: IoRo32
    clRdReq* {.importc: "clr_rd_req".}: IoRo32
    clrTxAbrt* {.importc: "clr_tx_abrt".}: IoRo32
    clrRxDone* {.importc: "clr_rx_done".}: IoRo32
    clrActivity* {.importc: "clr_activity".}: IoRo32
    clrStopDet* {.importc: "clr_stop_det".}: IoRo32
    clrStartDet* {.importc: "clr_start_det".}: IoRo32
    clrGenCall* {.importc: "clr_gen_call".}: IoRo32
    enable* {.importc.}: IoRw32
    status* {.importc.}: IoRo32
    txFlr* {.importc: "txflr".}: IoRo32
    rxFlr* {.importc: "rxflr".}: IoRo32
    sdaHold* {.importc: "sda_hold".}: IoRw32
    txAbortSource* {.importc: "tx_abrt_source".}: IoRo32
    slvDataNackOnly* {.importc: "slv_data_nack_only".}: IoRw32
    dmaCr* {.importc: "dma_cr".}: IoRw32
    dmaTdlr* {.importc: "dma_tdlr".}: IoRw32
    dmaRdlr* {.importc: "dma_rdlr".}: IoRw32
    sdaSetup* {.importc: "sda_setup".}: IoRw32
    ackGeneralCall* {.importc: "ack_general_call".}: IoRw32
    enableStatus* {.importc: "enable_status".}: IoRo32
    fkSpkLen* {.importc: "fs_spklen".}: IoRw32
    pad2 {.importc: "_pad2".}: uint32
    clrRestartDet* {.importc: "clr_restart_det".}: IoRo32
    pad3 {.importc: "_pad3".}: array[18, uint32]
    compParam1* {.importc: "comp_param_1".}: IoRo32
    compVersion* {.importc: "comp_version".}: IoRo32
    compType* {.importc: "comp_type".}: IoRo32

{.pop.}
