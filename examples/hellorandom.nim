import picostdlib/[stdio, time, random]

stdioInitAll()
sleep(2000)
randomize()
const 
  slp = 50
  minInt = 0
  maxInt = 99
print("Test Number Generator " & randomGenVer & '\n')
sleep(1000)
for _ in 0..5:
  print("1- Make 15 Random Chars" & '\n')
  for c in 0..15:
    var x = randomChar()
    print($x & ", ")
    sleep(slp)
  print("" & '\n')

  print("2- Make 15 Random Integer Numbers" & '\n')
  for c in 0..15:
    var x = randomInt(minInt, maxInt)
    print($x & ", ")
    sleep(slp)
  print("" & '\n')

  print("3- Make 15 Random Normalized Numbers" & '\n')
  for c in 0..15:
    var x = random()
    print( $x & ", ")
    sleep(slp)
  print("" & '\n')

  print("4- Make 15 Random Bytes uint8" & '\n')
  for c in 0..15:
    var x = randomByte()
    print( $x & ", ")
    sleep(slp)
  print("" & '\n')
  
  print("-------------------------" & '\n')
print("End!" & '\n')
 

