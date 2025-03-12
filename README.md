# primes

Primes search using trial division - Multiple languages.

Simple exercise to play with different languages while benchmarking their performance on different devices.

Have run them on my MacBook Pro, Mate9, KeyOne, Note8, Essential PH-1, iPhone X (Pythonista), Gemini, Note9, iPhone 12 (using compiled libraries / native code in iOS app), Fold4.

Update March 2025 - start updating with latest version - Starting with finishing up Zig Threads version

-----------------------------------------------

Results on a Late 2013 15" Macbook Pro (2.3 GHz Quad-Core i7 - 16GB RAM - Catalina):

Time in secs.millisecs searching until 1M - Finding 78,498 primes:

| Language         | secs.millis |       comments        | compile / run command                                         |
| ---------------- | ----------- | --------------------- | ------------------------------------------------------------- |
| Python 3.9.2     |    2.329    | normal - sequential   | python primes.py                                              |
| Python 3.9.2 jit |    0.169    | using numba jit       | python primes_numba.py                                        |
| Python + Rust    |    0.033    | Rust Module & threads | python primes_rust_module.py                                  |
| NASM 2.15.05     |    0.126    | sequential            | run: ./primes 1000000                                         |
| C clang 12.0.0   |    0.125    | sequential            | clang -O2 primes.c -o primes                                  |
| C++ clang 12.0.0 |    0.121    | sequential            | clang++ -O2 primes.cpp -o primes                              |
| Objective-C      |    0.121    | sequential            | clang primes.m -fobjc-arc -fmodules                           |
|                  |             |                       | -mmacosx-version-min=10.6 -o primes                           |
| Ruby 3.0         |    7.011    | normal - sequential   | ruby primes.rb                                                |
| Ruby 3.0 jit     |    6.083    | jit                   | ruby --jit-wait primes.rb                                     |
| Ruby 3.0 Eratos  |    0.445    | Eratosthenes          | ruby primes_erastosthenes.rb                                  |
| Ruby 3.0 Ractors |   12.441    | Experimental Ractors  | Does not work well. Ractors feature needs to mature           |
| Ruby + Rust      |    0.033    | using Rust & threads  | ruby primes.rb                                                |
| Crystal 1.7.3    |    0.241    | sequential            | crystal build --release -Dpreview_mt -o primes primes.cr      |
| Crystal Channels |    0.055    | channels              | set CRYSTAL_WORKERS 16 or CRYSTAL_WORKERS=16                  |
|                  |             |                       | crystal build --release -Dpreview_mt -o primes primes_chan.cr |
| Crystal Eratos   |    0.050    | Eratosthenes          | crystal build --release -o primes primes_eratos.cr            |
| Rust 1.51.0      |    0.131    | sequential            | cargo build --release                                         |
| Rust Rayon       |    0.030    | rayon concurrency     | cargo build --release  (faster with parking_lot::Mutex)       |
| Rust Channels    |    0.029    | channels concurrency  | cargo build --release                                         |
| Rust Arc/Mutex   |    0.030    | threads concurency    | cargo build --release  (faster with parking_lot::Mutex)       |
| Rust Eratos      |    0.006    | Eratosthenes          | cargo build --release                                         |
| Go 1.16.2        |    0.306    | normal - sequential   | go build primes.go                                            |
| Go goroutines    |    0.071    | goroutines            | go build primes.go                                            |
| Swift 5.3.2      |    0.310    | normal - sequential   | (xcode release)                                               |
| Swift threads    |    0.092    | threads               | (xcode release)                                               |
| Java 14.0.1      |    0.121    | sequential            | javac Primes.java & java Primes                               |
| Kotlin 1.4.32    |    0.139    | sequential            | kotlinc primes.kt -include-runtime -d primes.jar              |
|                  |             |                       | java -jar primes.jar                                          |
| Julia 1.6.0      |    0.162    | sequential            | julia primes.jl                                               |
| Zig 0.11         |    0.135    | sequential            | zig build-exe primes.zig -O ReleaseSafe                       |
| V 0.2.2          |    0.131    | sequential            | v -autofree primes.v                                          |
| Nim 1.6.10       |    0.148    | sequential            | nim c -d:release primes.nim                                   |
| Nim threads      |    0.052    | spawn & channels      | nim c -d:release --threads:on primes_threads.nim              |

Comments:

- NASM, C languages, Rust, Java, Kotlin, V and Zig very close in performance single threaded.
- Rust is the fastest when comparing concurrent versions.
- Crystal performed admirably compared to Go, C languages and Swift while being almost as fun to work with as Ruby.
- V was easy and fun to use. Needs to mature more and improve documentation / examples.
- Did not enjoy Zig too much. Felt unnecessarily archaic (ie no strings) but seamless and safe C interoperability is intriguing.
- Nim was nice to work with. Documentation and info is very good.
- Very easy to make Python Module and Ruby Gem in Rust landing these interpreted languages among the top performers. -> Short tutorial included in each folder.
- Surprising size of GO's executable (2.1 MB), and Kotlin's bytecode (1.5 MB) given the significant runtimes.

Time in millisecs - Multithreaded:

| Pos |   Language      |  Time  | Exec size |
| --- | --------------- | ------ | --------- |
|  1  | Rust            |  29 ms |  321 KB   |
|  2  | Ruby & Rust     |  33 ms |           |
|  3  | Crystal         |  58 ms |  436 KB   |
|  4  | Go              |  71 ms |  2.1 MB   |
|  5  | Swift           |  92 ms |  272 KB   |
|  6  | Nim             |  52 ms |  142 KB   |
|     | Reference:      |        |           |
|     |    NASM size    |        |   14 KB   |
|     |    C    size    |        |   18 KB   |
|     |    Kotlin bytec |        |  1.5 MB   |
|     |    V            |        |  309 KB   |
|     |    Zig          |        |  225 KB   |
|     |    Nim          |        |  115 KB   |

- In Rust tried 3 approaches for concurrency:
a) A Goroutines like message passing approach using channels. (“Do not communicate by sharing memory; instead, share memory by communicating.”) -> Seems the fastest.
b) Using the Rayon Library which made it the easiest to deploy with almost no changes to code.
c) Using Mutex & Arc. (Shared state concurrency - the opposite of Go's approach). Faster with parking_lot::Mutex than with std Lib Mutex

- Go has its "green and low cost" Goroutines following the M:N model with M green threads per N operating system threads because it bundles a significant runtime in the binary to handle that. Very easy to deploy.

- Rust has a much simpler 1:1 model where each thread equates to an operating system thread as it tries to keep a very minimal runtime, with the Rayon library providing access to a model closer to Go ("It guarantees data-race free executions and takes advantage of parallelism when sensible, based on work-load at runtime.")

- Crystal's model is based on Go's in terms of syntax. Very easy to get going. Experimental multithreading now.
Before it had concurrency support but not parallelism: several tasks can be executed, and a bit of time will be spent on each of these, but two code paths are never executed at the same exact time.
To achieve concurrency, Crystal has fibers. A fiber is in a way similar to an operating system thread except that it's much more lightweight and its execution is managed internally by the process.

- Tried Ruby 3.0's experimental Ractors with poor results. Need to wait for this feature to mature more. There are issues with memory allocation and the GC: "Now, Ractor is not tuned enough, especially on object allocation. When you need to make an object, it locks VM-wide lock and it can be a bottleneck."

- Assembly using NASM. Learnt the bare minimum to get this done. It was far more difficult than expected.
It is a good excercise to grasp what is being done for you behind the scenes by the compiler.
Invaluable tool: Compiler Explorer <https://gcc.godbolt.org/>

-----------------------------------------------

I like Go's simplicity. Crystal is simpler and faster. Swift very nice to work with. V is not there yet but fun to use.
Rust, Crystal and Zig are my top languaages and in that order. Rust overall, Crystal for simplicity and Zig for a better C but yet immature.
Nim is in the middle between Crystal and Zig - not as easy to use as Crystal, not as bare metal as Zig and also immature in terms of books / code examples and still evolving.

Language of choice: Rust -> gives you control and clarity of what you are doing, it has a very helpful compiler, awesome tools, great libraries, very straightforward memory model that helps you to avoid many errors, no significant runtime, good documentation and helpful community. When programs compile they run with no runtime surprises. It is fast and efficient and keeps on improving at a fast pace.

When working on a new problem most of the time I find myself creating a prototype with Python or Ruby/Crystal, but every time I end up writing it in Rust for optimal performance and robustness.

-----------------------------------------------

Prime benchmarking done for the 6502 8-bit family of processors.

It all started when doing Ben Eater's 6502 computer project (check it out).

After finishing I decided to run the benchmark on it but then though of running them on real old time HW.
Got an Apple2e enhanced back to working condition, also an Atari 800XL and will get when available a modern Commander X16 - for now using an emulator.

BASIC - Did not bother to use basic as it is very slow.

ASM - It was difficult to use the exact same algorithm used above in 8 bit assembly as these processors can only add and substract.

- Had to create routines that use bitshifting and addition and substraction to do division and finding square root.
- Had to create routines to print decimal numbers converting them from hex.

C - Used CC65 afterwards and created the same solution for all the platforms - much easier and faster.

- Had to reuse part of the ASM code to calculate  square roots. It creates also the exact same division algorithm in assembly.

Reduced the bechmark to seek until number 50,000 so it does not overflow beyond 16-bits and also due to time (does not make any sense to measure hours).

Seek until 50,000. 5133 primes.

Time in minutes and seconds:

| Computer            |   Processor      |  Executable created with  |  Time Emulator  |  Time real HW   |
| ------------------- | ---------------- | ------------------------- | --------------- | --------------- |
|  Apple 2e enhanced  | 65C02 - 1 Mhz    |  CC65 - C + ASM           |      6:20       |     6:15        |
|  Apple 2e enhanced  | 65C02 - 1 Mhz    |  ASM                      |      9:42       |     8:40        |
|  cx16               | 65C02 - 8 Mhz    |  CC65 - C + ASM           |      0:48       |      -          |
|  cx16               | 65C02 - 8 Mhz    |  ASM                      |      1:07       |      -          |
|  Atari 800XL        | 6502  - 1.8 Mhz  |  CC65 - C + ASM           |      5:27       |     5:51        |
|  Atari 800XL        | 6502  - 1.8 Mhz  |  ASM                      |    too lazy     |    too lazy     |

C does more efficient looping that what I manually created for looping using 16bit numbers - other than that, it uses exact same division and sqroot assembly. Could investigate more. Just spent too much time on this already.

Not super easy to print in assembly for the Atari using a similar approach as with the Apple, or cx16. Would need to recreate a completely different routine for the Atari and I am too lazy. You are welcome to add.

Bottom line:

- After doing this appreciate more the speed, power and capabilities of modern processors that even in assembly are much easier to work with.
- Also how awesome and efficient compiled languages are, and how they abstract you from needing to understand every single bit of the platform you are coding for.
- And how much more limited, but simpler these platforms were. How awesome it was that 1 single person could know everything of his particular machine.
- On the other hand porting Assembly was a lot of work despite using same processor due to differences in the kernel.
