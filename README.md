# primes
Primes search using trial division - Multiple languages. 

So far: Ruby, Python, C, C++, Objectice-C, Swift, Crystal, BASIC!, Java, Kotlin, Julia, Rust, Go and Assembly (NASM).

I use this simple exercise to get a feel of different languages while benchmarking their performance on different devices. 
Have run them on my MacBook Pro, Mate9, KeyOne, Note8, Essential PH-1, iPhone X (Pythonista), Gemini, Note9, iPhone 12 (using compiled libraries / native code in swift app).
iPhone 12 faster than my Mac...incredible.
On Android I use Termux. On Note 9 also used Linux on Dex, and Debian Linux on Gemini.

-----------------------------------------------

Interesting concurrency side comments:

Impressive results using plain Go & Rust compared to C, but much more so when using concurrency - Goroutines in Go and in Rust using Channels, Mutex-Arc and the Rayon Library.
Update: Impressed with the performance of Crystal both single thread and multithreaded.

Time in millisecs - Multithreaded (Limit 1M - Finding 78,498 primes):
1- Rust		 29 ms
2- Crystal	 55 ms
3- Go 		 74 ms
4- C 		100 ms (As a reference - single threaded)
Hardware: i7 late 2013 Macbook Pro

In the concurrency versions you can input manually the number of threads to use. 
Peak performance is achieved with different number of threads per language in same HW.

I originally created this to figure out if there was a way to predict which was the optimum number of Goroutines for any given problem.

I later replicated this approach in Rust with 3 different approaches:
a) A Goroutines like message passing approach. (“Do not communicate by sharing memory; instead, share memory by communicating.”)
b) Using the Rayon Library which made it very easy to deploy (Cannot determine manually the number of threads. Performance wise is very close to the others).
c) Using Mutex & Arc. (Shared state concurrency - the opposite of Go's approach).

Go has its "green and low cost" Goroutines following the M:N model with M green threads per N operating system threads because it bundles a significant runtime in the binary to handle that.

Rust has a much simpler 1:1 model where each thread equates to an operating system thread as it tries to keep a very minimal runtime, with the Rayon library providing access to a model closer to Go ("It guarantees data-race free executions and takes advantage of parallelism when sensible, based on work-load at runtime.")

Update:
- Crystal model is close to Go's in terms of syntax. Very easy to get going.
But currently Crystal has concurrency support but not parallelism: several tasks can be executed, and a bit of time will be spent on each of these, but two code paths are never executed at the same exact time.
To achieve concurrency, Crystal has fibers. A fiber is in a way similar to an operating system thread except that it's much more lightweight and its execution is managed internally by the process.

- Tried Ruby 3.0's experimental Ractors with poor results. Need to wait for this feature to mature more. There are issues with memory allocation and the GC: "Now, Ractor is not tuned enough, especially on object allocation. When you need to make an object, it locks VM-wide lock and it can be a bottleneck." 


-----------------------------------------------

Assembly using NASM 

Learnt the bare minimum to get this done. It was far more difficult to do than any of the other languages but now I understand how things get done the closest to the metal.
Compared to C in terms of executable size NASM is sligtly smaller but C executable is a tiny tad faster which speaks volumes how efficient compilers are (probaly due to inlining)

Short compare of exec sizes and time it took to search primes until 1M.
C is the king of speed on 1 thread with NASM close behind, but in mutithreaded code Crystal, Go and Rust beats them both. 
NOTE - Surprising size of GO's executable given the added runtime.


| macOS  | Exec size | 1 thread  | 16 threads |
|--------|-----------|-----------|------------|
| NASM   | 14  KB    | 0.125 sec |     -      |
| C      | 18  KB    | 0.100 sec |     -      |
| Rust   | 321 KB    | 0.133 sec | 0.029 sec  |
| Crystal| 409 KB    | 0.192 sec | 0.055 sec  |
| GO     | 2.2 MB    | 0.308 sec | 0.074 sec  |


Bottom line, this is my first and probably last experiment with Assembly. 
Solving a simple problem like this it is not trivial in NASM while very easy to do with anything else.
It is a good excercise to grasp what is being done for you behind the scenes by the compiler and to better understand language design.
Invaluable tool: Compiler Explorer https://gcc.godbolt.org/

-----------------------------------------------

I like Go's simplicity. Crystal is simpler and faster. Swift very nice to work with.

But my language of choice is Rust: its very helpful compiler, awesome tools, very straightforward memory model that helps you avoid many errors, its documentation and helpful community. 
And above all: If its compiles it runs like a charm with no surprises. 
It helps that it is also very fast....;-)

When working on a new problem most of the time I find myself creating a prototype with Python (now perhaps I will use Crystal), sometimes making a Go implementation, but every time I end up writing it in Rust.


