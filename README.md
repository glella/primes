# primes
Primes search using trial division - Multiple languages. 

Simple exercise to play with different languages while benchmarking their performance on different devices. 

Have run them on my MacBook Pro, Mate9, KeyOne, Note8, Essential PH-1, iPhone X (Pythonista), Gemini, Note9, iPhone 12 (using compiled libraries / native code in iOS app).
Termux on Android. On Note 9 also used Linux on Dex, and Debian Linux on Gemini.

-----------------------------------------------

Results on a Late 2013 15" Macbook Pro (2.3 GHz Quad-Core i7 - 16GB RAM - Catalina):

Time in secs.millisecs searching until 1M - Finding 78,498 primes: 


| Language         | secs.millis |       comments        | compile / run command                                         |
| ---------------- | ----------- | --------------------- | ------------------------------------------------------------- |
| Python 3.9.2     |    2.329    | normal - sequential   | python primes.py                                              |
| Python 3.9.2 jit |    0.169    | using numba jit       | python primes_numba.py                                        |
| Python + Rust    |    0.042    | Rust Module & threads | python primes_rust_module.py                                  |
| NASM 2.15.05     |    0.126    | sequential            | run: ./primes 1000000                                         |
| C clang 12.0.0   |    0.125    | sequential            | clang -O2 primes.c -o primes                                  |
| C++ clang 12.0.0 |    0.121    | sequential            | clang++ -O2 primes.cpp -o primes                              |
| Objective-C      |    0.121    | sequential            | clang primes.m -fobjc-arc -fmodules                           |
|                  |             |                       | -mmacosx-version-min=10.6 -o primes                           |
| Ruby 3.0         |    7.011    | normal - sequential   | ruby primes.rb                                                |
| Ruby 3.0 jit     |    6.083    | jit                   | ruby --jit-wait primes.rb                                     |
| Ruby 3.0 Eratos  |    0.445    | Eratosthenes          | ruby primes_erastosthenes.rb                                  |
| Ruby 3.0 Ractors |   12.441    | Experimental Ractors  | Does not work well. Ractors feature needs to mature           |
| Ruby + Rust      |    0.042    | using Rust & threads  | ruby primes.rb                                                |
| Crystal 0.36.1   |    0.200    | sequential            | crystal build --release -Dpreview_mt -o primes primes.cr      |
| Crystal Channels |    0.055    | channels              | set CRYSTAL_WORKERS 16 or CRYSTAL_WORKERS=16                  |
|                  |             |                       | crystal build --release -Dpreview_mt -o primes primes_chan.cr |
| Crystal Eratos   |    0.050    | Eratosthenes          | crystal build --release -o primes primes_eratos.cr            |
| Rust 1.51.0      |    0.131    | sequential            | cargo build --release                                         |
| Rust Rayon       |    0.041    | rayon concurrency     | cargo build --release                                         |
| Rust Channels    |    0.029    | channels concurrency  | cargo build --release                                         |
| Rust Arc/Mutex   |    0.039    | threads concurency    | cargo build --release                                         |
| Rust Eratos      |    0.006    | Eratosthenes          | cargo build --release                                         |
| Go 1.16.2        |    0.306    | normal - sequential   | go build primes.go                                            |
| Go goroutines    |    0.071    | goroutines            | go build primes.go                                            |
| Swift 5.3.2      |    0.310    | normal - sequential   | (xcode release)                                               |
| Swift threads    |    0.092    | threads               |                                                               |
| Java 14.0.1      |    0.121    | sequential            | javac Primes.java & java Primes                               |
| Kotlin 1.4.32    |    0.139    | sequential            | kotlinc primes.kt -include-runtime -d primes.jar              |
|                  |             |                       | java -jar primes.jar                                          |
| Julia            |             |                       |                                                               |
| Zig 0.8.0        |             |                       | zig build-exe fib.zig -O ReleaseSafe                          |
| V 0.2.2          |             |                       | v -autofree fib.v                                             |


Comments:

- NASM, C languages, Rust, Java & Kotlin very close in performance single threaded.
- Rust is the fastest when comparing concurrent versions. 
- Crystal performed admirably compared to Go, C languages and Swift while being almost as fun to work with as Ruby.
- Very easy to make Python Module and Ruby Gem in Rust landing these interpreted languages among the top performers.
-> Short tutorial included in each folder
- Surprising size of GO's executable (2.1 MB), and Kotlin's bytecode (1.5 MB) given the significant runtimes.

Time in millisecs - Multithreaded:

| Pos |   Language      |  Time  | Exec size |
| --- | --------------- | ------ | --------- |
|  1  | Rust            |  29 ms |  321 KB   |
|  2  | Ruby & Python   |  42 ms |           |
|  3  | Crystal         |  55 ms |  409 KB   |
|  4  | Go              |  71 ms |  2.1 MB   |
|  5  | Swift           |  92 ms |  272 KB   |
|     | Reference:      |        |           |
|     |    NASM size    |        |   14 KB   |
|     |    C    size    |        |   18 KB   |
|     |    Kotlin byte  |        |  1.5 MB   |


- In Rust tried 3 approaches for concurrency:
a) A Goroutines like message passing approach using channels. (“Do not communicate by sharing memory; instead, share memory by communicating.”) -> Seems the fastest.
b) Using the Rayon Library which made it the easiest to deploy with almost no changes to code.
c) Using Mutex & Arc. (Shared state concurrency - the opposite of Go's approach).

- Go has its "green and low cost" Goroutines following the M:N model with M green threads per N operating system threads because it bundles a significant runtime in the binary to handle that. Very easy to deploy.

- Rust has a much simpler 1:1 model where each thread equates to an operating system thread as it tries to keep a very minimal runtime, with the Rayon library providing access to a model closer to Go ("It guarantees data-race free executions and takes advantage of parallelism when sensible, based on work-load at runtime.")

- Crystal's model is based on Go's in terms of syntax. Very easy to get going. Experimental multithreading now.
Before it had concurrency support but not parallelism: several tasks can be executed, and a bit of time will be spent on each of these, but two code paths are never executed at the same exact time.
To achieve concurrency, Crystal has fibers. A fiber is in a way similar to an operating system thread except that it's much more lightweight and its execution is managed internally by the process.

- Tried Ruby 3.0's experimental Ractors with poor results. Need to wait for this feature to mature more. There are issues with memory allocation and the GC: "Now, Ractor is not tuned enough, especially on object allocation. When you need to make an object, it locks VM-wide lock and it can be a bottleneck." 

- Assembly using NASM. Learnt the bare minimum to get this done. It was far more difficult than expected.
It is a good excercise to grasp what is being done for you behind the scenes by the compiler. 
Invaluable tool: Compiler Explorer https://gcc.godbolt.org/

-----------------------------------------------

I like Go's simplicity. Crystal is simpler and faster. Swift very nice to work with.

Language of choice: Rust -> gives you control and clarity of what you are doing, it has a very helpful compiler, awesome tools, great libraries, very straightforward memory model that helps you to avoid many errors, no significant runtime, good documentation and helpful community. If its compiles it runs with no runtime surprises, while being fast and efficient.

When working on a new problem most of the time I find myself creating a prototype with Python or Ruby (now perhaps I will try using Crystal), but every time I end up writing it in Rust for optimal performance.
