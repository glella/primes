# primes
Primes search using trial division - Multiple languages. 

So far: Ruby, Python, C, C++, Objectice-C, Swift, Crystal, BASIC!, Java, Kotlin, Julia, Rust, Go and Assembly (NASM).

I use this simple exercise to learn different languages and to get a feel of them, while benchmarking their performance on different devices. 
Have run them on my MacBook Pro, Mate9, KeyOne, Note8, Essential PH-1, iPhone X (Pythonista), Gemini, Note9.
On Android I mostly use Termux. On Note 9 also used Linux on Dex, and Debian Linux on Gemini.

-----------------------------------------------

Interesting concurrency side comments:

Impressive results using plain Go & Rust compared to C, but much more so when using concurrency - Goroutines in Go and in Rust using Channels, Mutex-Arc and the Rayon Library.

In the concurrency versions you can input manually the number of threads to use. 
I originally created this to figure out if there was a way to predict which was the optimum number of Goroutines for any given problem.

I later replicated this approach in Rust with 3 different approaches:
a) A Goroutines like message passing approach. (“Do not communicate by sharing memory; instead, share memory by communicating.”)
b) Using the Rayon Library which made it very easy to deploy (Cannot determine manually the number of threads. Performance wise is very close to the others)
c) Using Mutex & Arc. (Shared state concurrency - the opposite of Go's approach).

These approaches deliver extremely consistent results in terms of that the performance peaks out when using threads roughly 2X the number of logical cores. 
ie: on my Late 2013 i7 MacBookPro: actual cores 4, logical cores detected at runtime 8, optimal performance when using around 16 threads.
Exactly the same conclusion on my Note9 on Termux (8 logical cores & peak performance when using roughly 16 threads). 

No matter the underlying differences in the approach of threads creation between languages.
Go has its "green and low cost" Goroutines following the M:N model with M green threads per N operating system threads because it bundles a significant runtime in the binary to handle that.
Rust has a much simpler 1:1 model where each thread equates to an operating system thread as it tries to keep a very minimal runtime, with the Rayon library providing access to a model closer to Go ("It guarantees data-race free executions and takes advantage of parallelism when sensible, based on work-load at runtime.")

-----------------------------------------------

Assembly using NASM 

Learnt the bare minimum to get this done. It was far more difficult to do but now I understand how things get done the closest to the metal.
Compared to C in terms of executable size NASM is sligtly smaller but C executable is a tiny tad faster which speaks volumes how efficient compilers are.

Short compare of exec sizes and time it took to search primes until 1M.
C is the king of speed on 1 thread with NASM close behind, but in mutithreaded code Go and Rust beats them both easily. (BTW, it is surprising the size of GO's executable given the added runtime).


macOS     Exec size     1 thread      16 threads

NASM      14  KB        0.125 sec     -

C         18  KB        0.100 sec     -

Rust      321 KB        0.334 sec     0.061 sec

GO        2.2 MB        0.308 sec     0.074 sec


Bottom line, this is my first and probably last experiment with Assembly. If you are not working on firmware or on hardware there are no othe compilers for, it is needed, but in any other language a problem like this is trivial but doing it on NASM it is not. In any case, it is great to better grasp what is being done for you behind the scenes and to better understand language design and needs.

So far I like Go's simplicity but I am in love with Rust, its very helpful compiler, and its very straightforward model that helps you avoid many errors. If its compiles it runs like a charm with no surprises. 
It helps that it is also very fast....;-)

When working on a new problem most of the time I find myself creating a prototype with Python, sometimes making a Go implementation, but every time I end up writing it in Rust.


