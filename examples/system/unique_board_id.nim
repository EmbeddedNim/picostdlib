import std/strutils
import picostdlib/[pico/stdio, pico/unique_id]

# RP2040 does not have a unique on-board ID, but this is a standard feature
# on the NOR flash it boots from. There is a 1:1 association between RP2040
# and the flash, so this can be used to get a 64 bit globally unique board ID
# for an RP2040-based board, including Pico.
#
# The pico_unique_id library retrieves this unique identifier during boot and
# stores it in memory, where it can be accessed at any time without
# disturbing the flash XIP hardware.

stdioInitAll()

var boardId: PicoUniqueBoardId
picoGetUniqueBoardId(boardId.addr)

echo "Unique identifier:"
for i in 0..<PicoUniqueBoardIdSizeBytes:
  stdout.write(" " & boardId.id[i].toHex(2))

echo ""

echo picoGetUniqueBoardIdString()
