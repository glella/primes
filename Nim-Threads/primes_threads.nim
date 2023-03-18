# debug: nim c -r --threads:on primes_threads.nim
# release: nim c -d:release --threads:on primes_threads.nim
# optionally: nim c -d:danger --gc:orc primes.nim
import times, strutils, std/sequtils, threadpool

# creating a global channel and open it to pass seq[int] from spawned threads
var ch = Channel[seq[int]]()
ch.open()

proc prime(n: int): bool =
    var i = 3
    while i*i <= n:
        if n mod i == 0: return false
        inc i, 2
    true

proc checkPrimes(numbers: seq[int]): seq[int] =
    var res: seq[int] = @[]
    for number in numbers:
        if prime(number):
            res.add(number)
    ch.send(res)    # sends the result through the channel
    return res      # need to keep it so data sending through channel is not ambiguous

proc search(ranges: seq[seq[int]]): seq[int] =
    var res: seq[int] = @[]
    for segment in ranges:
        # spawn one proc per range of numbers to check
        # uses the ^ operator to get the return value of a spawned proc
        # add method modifies the first sequence by appending the elements of the second sequence
        # res.add(^spawn checkPrimes(segment))
        # The above has a problem as it waits for each thread to wait sequentially negating the advantage of using threads
        # better to use channels:
        discard spawn checkPrimes(segment)
    for segment in ranges:
        res.add(ch.recv())
    return res

template benchmark(benchmarkName: string, code: untyped) =
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "Seconds [", benchmarkName, "] ", elapsedStr, "."

echo "\nLooks for prime numbers from 1 to your input"
while true:
    write(stdout, "\nSeek until what integer number?: ")
    var num = stdin.readLine().parseInt()

    # create list of all odd numbers to be checked
    var list: seq[int] = @[]
    for i in countup(3, num, 2):
        list.add(i)
    
    # get number of desired threads to use
    write(stdout, "\nNumber of threads to use?: ")
    num = stdin.readLine().parseInt()
    
    # create a sequence of sequences to distribute the work between threads
    let seq_of_seq = list.distribute(num, true)

    # result will accumulate primes from all threads
    var result: seq[int] = @[]
     
    benchmark "Search":
        result = search(seq_of_seq)
        result.add(2) # add 2 to result as we start checking at 3 
    
    echo "Found ", result.len(), " prime numbers."

    write(stdout, "Print prime numbers? (y/n): ")
    var input = stdin.readline()
    if input == "y": echo(result)

    write(stdout, "Another run? (y/n): ")
    input = stdin.readline()
    if input != "y": break

ch.close() #close the channel