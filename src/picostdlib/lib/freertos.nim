##
## FreeRTOS Kernel <DEVELOPMENT BRANCH>
## Copyright (C) 2021 Amazon.com, Inc. or its affiliates.  All Rights Reserved.
##
## SPDX-License-Identifier: MIT
##
## Permission is hereby granted, free of charge, to any person obtaining a copy of
## this software and associated documentation files (the "Software"), to deal in
## the Software without restriction, including without limitation the rights to
## use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
## the Software, and to permit persons to whom the Software is furnished to do so,
## subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
## FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
## COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
## IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
##
## https://www.FreeRTOS.org
## https://github.com/FreeRTOS
##
{.hint[XDeclaredButNotUsed]: off.}
{.hint[User]: off.}

import ../hardware/timer # for clock_gettime
export timer

import ../helpers

when defined(nimcheck):
  include ../futharkgen/futhark_freertos
else:
  import std/os, std/macros

  import futhark

  const outputPath = when defined(futharkgen): futharkGenDir / "futhark_freertos.nim" else: ""

  importc:
    outputPath outputPath

    compilerArg "--target=arm-none-eabi"
    compilerArg "-mthumb"
    compilerArg "-mcpu=cortex-m0plus"
    compilerArg "-fsigned-char"
    compilerArg "-fshort-enums" # needed to get the right enum size

    sysPath futhark.getClangIncludePath()
    sysPath armSysrootInclude
    sysPath armInstallInclude
    sysPath cmakeBinaryDir / "generated/pico_base"
    sysPath picoSdkPath / "src/common/pico_base/include"
    sysPath picoSdkPath / "src/rp2040/hardware_regs/include"
    sysPath picoSdkPath / "src/rp2_common/hardware_base/include"
    sysPath picoSdkPath / "src/rp2_common/hardware_sync/include"
    sysPath picoSdkPath / "src/rp2_common/pico_platform/include"
    sysPath freertosKernelPath / "portable/ThirdParty/GCC/RP2040/include"
    sysPath freertosKernelPath / "include"
    path piconimCsourceDir
    path getProjectPath()

    renameCallback futharkRenameCallback

    "FreeRTOS.h"
    "task.h"

when freertosKernelHeap != "":
  {.emit: ["// picostdlib import: ", freertosKernelHeap].}

const
  tskIDLE_PRIORITY*: UBaseTypeT = 0
