# primes
Primes search using trial division - Multiple languages. 

So far: Ruby, Python, C, C++, Objectice-C, Swift, Crystal, BASIC!, Java, Kotlin, Julia, Rust and Go.

Impressive results using Go & Rust compared to C languages - Both are way faster than C.
Even much more so when using concurrency - Goroutines in Go and in Rust using Channels, Mutex-Arc and the Rayon Library.

In the concurrency versions you can input manually the number of threads / goroutines to use. 
I had assumed that for this test the optimal amount of Goroutines would be equal to the number of logical cores, but after playing around with this "manually selected" version, it seems that performance peaks out when using roughly 2X the number of logical cores. (No matter how big the search limit - highest limit tried 100,000,000 for practical reasons).

ie: on my Late 2013 i7 MacBookPro: actual cores 4, logical cores detected at runtime 8, optimal performance when using around 16 goroutines. Same in all the Rust concurrency versions. Exactly the same conclusion on my Note9 on Termux (8 logical cores & peak performance when using roughly 16 threads). Need to understand better the reasons why.

I use this simple exercise to learn different languages and to get a taste and feel, while benchmarking their performance on different devices. 
Have run them on my MacBook Pro, Mate9, KeyOne, Note8, Essential PH-1, iPhone X (Pythonista), Gemini, Note9.
On Android I mostly use Termux. On Note 9 also used Linux on Dex, and Debian Linux on Gemini.

Side Note 1 - On Note9 + Termux: Go and Rust are way faster than on MacBook Pro! (same exact source & no other apps running)
That does not happen in any other language. Another thing to investigate further.



