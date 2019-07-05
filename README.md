# primes
Primes search using trial division - Multiple languages 
Looks for Primes using Trial Division as consistently as possible across languages.
So far: Ruby, Python, C, C++, Objectice-C, Swift, Crystal, BASIC!, Java, Kotlin, Julia, Rust and Go.

Impressive results using Go & Rust compared to C languages - Both are way faster than C.
Even much more so when using concurrency - Goroutines in Go and Rayon Library in Rust.

In the Go Goroutines version you can input manually the number of Goroutines to use. 
I had assumed that for this test the optimal amount of Goroutines would be equal to the number of logical cores, but after playing around with this "manually selected" version, it seems that performance peaks out when using roughly 2X the number of logical cores. (No matter how big the search limit - highest limit tried 100,000,000 for practical reasons).

ie: on my Late 2013 i7 MacBookPro: actual cores 4, logical cores detected at runtime 8, optimal performance when using around 16 goroutines. Exactly the same conclusion on my Note9 running under Termux (8 logical cores & peak performance when using roughly 16 coroutines). Need to understand better the reasons why.

I use this simple exercise to learn different languages hands-on to get a taste and feel of them, and benchmark their performance on different devices. 
Have run them on my MacBook Pro, Mate9, KeyOne, Note8, Essential PH-1, iPhone X (Pythonista), Gemini, Note9.
On Android I mostly use Termux. On Note 9 also used Linux on Dex, and Debian Linux on Gemini.

Side Note 1 - On Note9 + Termux: Go and Rust are way faster than on MacBook Pro! (same exact source & no other apps running)
              That does not happen in any other language.

Side Note 2 - Go and Rust are pretty even on performance with Go a tad faster (regular and using concurrency).


