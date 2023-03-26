// RUSTFLAGS="-C target-cpu=native" cargo build --release

use std::sync::mpsc;
use std::thread;
use std::time::Instant;

pub mod common;
use crate::common::{get_value, prompt};

// this version has a more efficient algorithm eliminating divisible by 2 and 3
// cheating a bit vs other languages as it increments by 6 instead of by 2
// We start by testing 5, which is the first odd number greater than 3. Then, we test 7 (which is 6*1+1), and then
// 11 (which is 6*2-1), and so on. We can see that the difference between consecutive odd numbers of the form 6*k-1
// is always 6, which is why we increment i by 6 inside the loop.
// By incrementing i by 6, we can ensure that we only test odd numbers of the form 6*k-1, without wasting time on
// numbers that we have already eliminated as potential prime numbers (such as even numbers and multiples of 3).
// This can result in a significant speedup for large numbers, since we are only testing a subset of the odd numbers,
// rather than all of them.
#[inline]
fn is_prime(n: u32) -> bool {
    match n {
        0 | 1 => false,
        2 | 3 => true,
        _div_by_2_or_3 if n % 2 == 0 || n % 3 == 0 => false, // we skip divisible by 2 and 3
        _ => !(5..)
            .step_by(6)
            .take_while(|i| i * i <= n)
            .any(|i| n % i == 0 || n % (i + 2) == 0),
    }
}

// Rust provides asynchronous channels for communication between threads.
fn search(vectors: Vec<Vec<u32>>) -> Vec<u32> {
    let mut result: Vec<u32> = Vec::with_capacity(664579); // number of primes in 10M
    result.push(2); // Add 2 as we removed even numbers from list

    let (tx, rx) = mpsc::channel();
    let mut children = Vec::new();

    for segment in vectors {
        // The sender endpoint can be copied
        let thread_tx = tx.clone();
        // Each thread will send its results via the channel
        // The thread takes ownership over `thread_tx`
        let child = thread::spawn(move || {
            let mut temp: Vec<u32> = Vec::new();
            for i in segment {
                if is_prime(i) {
                    temp.push(i);
                }
            }
            // Each thread queues a message in the channel
            // Sending is a non-blocking operation, the thread will continue
            thread_tx.send(temp).unwrap();
        });
        children.push(child);
    }

    // Here, all the messages are collected
    for _ in &children {
        // The `recv` method picks a message from the channel
        // `recv` will block the current thread if there are no messages available
        result.append(&mut rx.recv().unwrap());
    }

    // Wait for the threads to complete any remaining work
    for child in children {
        child.join().expect("oops! the child thread panicked");
    }

    result
}

fn main() {
    println!("Looks for prime numbers from 1 to your input");
        
    loop {
        let mut input: String;
        // get valid number input
        let num: u32;
        loop {
            input = prompt("Seek until what integer number?: ");
            match get_value(&input) {
                Ok(i) => {
                    if i < 5 {
                        println!("Minimum number needs to be 5 or above");
                        continue;
                    }
                    num = i;
                    break;
                }
                Err(e) => {
                    eprintln!("Error: {}", e);
                    continue;
                }
            }
        }

        // get valid threads input
        let threads: usize;
        loop {
            input = prompt("Number of Threads to use?: ");
            match get_value(&input) {
                Ok(i) => {
                    if i < 1 {
                        println!("Minimum number of threads is 1");
                        continue;
                    }
                    threads = i;
                    break;
                }
                Err(e) => {
                    eprintln!("Error: {}", e);
                    continue;
                }
            }
        }

        // prepare the list of numbers to be search
        let odds: Vec<u32> = (3..num).filter(|n| n % 2 != 0).collect();
        let chunk_size: usize = (odds.len() + threads - 1) / threads;
        let vectors: Vec<Vec<u32>> = odds
            .chunks(chunk_size)
            .map(|chunk| chunk.to_vec())
            .collect();

        let now = Instant::now(); // start timer
        let result = search(vectors); // perform the actual work
        let elapsed = now.elapsed(); // check time elapsed

        let sec = (elapsed.as_secs() as f64) + (elapsed.subsec_nanos() as f64 / 1_000_000_000.0);
        println!("Seconds: {:.3}", sec);
        println!("Number of primes: {}", result.len());

        input = prompt("Print results? (y/n) ");
        if input == "y" {
            println!("{:?}", result);
        }

        input = prompt("Another run? (y/n) ");
        if input != "y" {
            break;
        }
        println!();
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::common::vec_compare;

    static FIRST_25_PRIMES: [u32; 25] = [
        2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89,
        97,
    ];

    #[test]
    fn is_prime_works() {
        let mut test_results: Vec<u32> = Vec::new();
        for i in 1..=100 {
            if is_prime(i) {
                test_results.push(i);
            }
        }
        assert!(vec_compare(&test_results, &FIRST_25_PRIMES));
    }
}
