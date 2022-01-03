from time import timeUs32
from math import round, pow
from sequtils import toSeq
from strutils import Letters

let randomGenVer* = "0.6.5"

var timeSeed: uint32 = 27121975

proc randomize*() = #Randomize the variable with the bootstrap time 
  timeSeed = timeUs32()

proc random*(precision = 9): float = #make a random float number between 0..1 (set precision)
  const 
    a: uint32 = 1664525
    c: uint32 = 1013904223
    m: uint32 = uint32(pow(2.0, 31.0) - 1) 
  timeSeed = uint32((a * timeSeed + c ) mod m) #Lehmer random generator
  result = round(float(timeSeed) / float(m), precision)

proc randomInt*(min = 0, max = 100): int = #make a random integer numer between "min" and "max"
  let
    maxFlt = float(max)
    minFlt = float(min)
  var numbIntRnd = round(((maxFlt - minFlt) * random() + minFlt), 0)
  result = int(numbIntRnd)


proc randomChar*(): char = #make a random char (a..z, A..Z)
  let seqLetters = toSeq(Letters)
  let numbIntRnd = randomInt(0,51)
  result = seqLetters[numbIntRnd]

proc randomByte*(): uint8 =
  result = uint8(randomInt(0, 255))
  
#[ in ...csource/CMakeLists.txt add target_link_libraries(tests pico_stdlib hardware_adc) 
add--> (hardware_timer) ]#
