#nim c -d:release primes.nim
#optionally: nim c -d:danger --gc:orc primes.nim
import times, strutils

proc prime(n: int): bool =
    #if n < 2: return false
    #if n == 2: return true
    #if n mod 2 == 0: return false
    var i = 3
    while i*i <= n:
        if n mod i == 0: return false
        inc i, 2
    true

proc search(n: int): seq[int] =
    var res = @[2]
    for i in countup(3, n, 2):
        if i.prime(): res.add(i)
    echo "Found ", res.len(), " prime numbers."
    return res

template benchmark(benchmarkName: string, code: untyped) =
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "Seconds [", benchmarkName, "] ", elapsedStr, "."

echo "\nLooks for prime numbers from 1 to your input"
while true:
    write(stdout, "\nSeek until what integer number ? ")
    var number = stdin.readLine().parseInt()
    var list: seq[int] = @[]

    benchmark "Search":
        list = search(number)
    
    write(stdout, "Print prime numbers? (y/n) ")
    var input = stdin.readline()
    if input == "y": echo(list)

    write(stdout, "Another run? (y/n) ")
    input = stdin.readline()
    if input != "y": break


     
