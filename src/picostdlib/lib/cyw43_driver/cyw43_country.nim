##
##  This file is part of the cyw43-driver
##
##  Copyright (C) 2019-2022 George Robotics Pty Ltd
##
##  Redistribution and use in source and binary forms, with or without
##  modification, are permitted provided that the following conditions are met:
##
##  1. Redistributions of source code must retain the above copyright notice,
##     this list of conditions and the following disclaimer.
##  2. Redistributions in binary form must reproduce the above copyright notice,
##     this list of conditions and the following disclaimer in the documentation
##     and/or other materials provided with the distribution.
##  3. Any redistribution, use, or modification in source or binary form is done
##     solely for personal benefit and not for any commercial purpose or for
##     monetary gain.
##
##  THIS SOFTWARE IS PROVIDED BY THE LICENSOR AND COPYRIGHT OWNER "AS IS" AND ANY
##  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
##  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
##  DISCLAIMED. IN NO EVENT SHALL THE LICENSOR OR COPYRIGHT OWNER BE LIABLE FOR
##  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
##  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
##  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
##  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
##  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
##  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
##  This software is also available for use with certain devices under different
##  terms, as set out in the top level LICENSE file.  For commercial licensing
##  options please email contact@georgerobotics.com.au.
##

## * \addtogroup cyw43_driver
##

## *
##   \file cyw43_country.h
##   \brief CYW43 country codes
##

type
  Cyw43Country* = distinct uint32


template cyw43Country*(a, b: char; rev: int): Cyw43Country =
  ##  create a country code from the two character country and revision number
  (a.uint8 or (b.uint8 shl 8) or (rev shl 16)).Cyw43Country


{.push header: "cyw43_country.h".}

## !
##  \name Country codes
##  \anchor CYW43_COUNTRY_
##
## !\{


let
  CYW43_COUNTRY_WORLDWIDE* {.importc.}: Cyw43Country
  ##  Worldwide Locale (passive Ch12-14)

  CYW43_COUNTRY_AUSTRALIA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_AUSTRIA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_BELGIUM* {.importc.}: Cyw43Country
  CYW43_COUNTRY_BRAZIL* {.importc.}: Cyw43Country
  CYW43_COUNTRY_CANADA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_CHILE* {.importc.}: Cyw43Country
  CYW43_COUNTRY_CHINA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_COLOMBIA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_CZECH_REPUBLIC* {.importc.}: Cyw43Country
  CYW43_COUNTRY_DENMARK* {.importc.}: Cyw43Country
  CYW43_COUNTRY_ESTONIA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_FINLAND* {.importc.}: Cyw43Country
  CYW43_COUNTRY_FRANCE* {.importc.}: Cyw43Country
  CYW43_COUNTRY_GERMANY* {.importc.}: Cyw43Country
  CYW43_COUNTRY_GREECE* {.importc.}: Cyw43Country
  CYW43_COUNTRY_HONG_KONG* {.importc.}: Cyw43Country
  CYW43_COUNTRY_HUNGARY* {.importc.}: Cyw43Country
  CYW43_COUNTRY_ICELAND* {.importc.}: Cyw43Country
  CYW43_COUNTRY_INDIA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_ISRAEL* {.importc.}: Cyw43Country
  CYW43_COUNTRY_ITALY* {.importc.}: Cyw43Country
  CYW43_COUNTRY_JAPAN* {.importc.}: Cyw43Country
  CYW43_COUNTRY_KENYA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_LATVIA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_LIECHTENSTEIN* {.importc.}: Cyw43Country
  CYW43_COUNTRY_LITHUANIA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_LUXEMBOURG* {.importc.}: Cyw43Country
  CYW43_COUNTRY_MALAYSIA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_MALTA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_MEXICO* {.importc.}: Cyw43Country
  CYW43_COUNTRY_NETHERLANDS* {.importc.}: Cyw43Country
  CYW43_COUNTRY_NEW_ZEALAND* {.importc.}: Cyw43Country
  CYW43_COUNTRY_NIGERIA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_NORWAY* {.importc.}: Cyw43Country
  CYW43_COUNTRY_PERU* {.importc.}: Cyw43Country
  CYW43_COUNTRY_PHILIPPINES* {.importc.}: Cyw43Country
  CYW43_COUNTRY_POLAND* {.importc.}: Cyw43Country
  CYW43_COUNTRY_PORTUGAL* {.importc.}: Cyw43Country
  CYW43_COUNTRY_SINGAPORE* {.importc.}: Cyw43Country
  CYW43_COUNTRY_SLOVAKIA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_SLOVENIA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_SOUTH_AFRICA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_SOUTH_KOREA* {.importc.}: Cyw43Country
  CYW43_COUNTRY_SPAIN* {.importc.}: Cyw43Country
  CYW43_COUNTRY_SWEDEN* {.importc.}: Cyw43Country
  CYW43_COUNTRY_SWITZERLAND* {.importc.}: Cyw43Country
  CYW43_COUNTRY_TAIWAN* {.importc.}: Cyw43Country
  CYW43_COUNTRY_THAILAND* {.importc.}: Cyw43Country
  CYW43_COUNTRY_TURKEY* {.importc.}: Cyw43Country
  CYW43_COUNTRY_UK* {.importc.}: Cyw43Country
  CYW43_COUNTRY_USA* {.importc.}: Cyw43Country

{.pop.}
