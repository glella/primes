// RUSTFLAGS="-C target-cpu=native" cargo build --release
use std::io::{self, Error, ErrorKind};
use std::io::Write; // <--- bring flush() into scope
use std::sync::mpsc;
use std::thread;
use std::time::Instant;
use std::str::FromStr;

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

fn prompt(s: &str) -> String {
    print!("{}", s);
    io::stdout().flush().unwrap(); // flush it to the screen

    let mut text = String::new();
    io::stdin()
        .read_line(&mut text)
        .expect("failed to read from stdin");
    text.trim().to_string()
}

// Propagates the error if it can't parse a u32 from the string
// Uses the map_err method to convert the ParseIntError returned by the parse method into an Error with the 
// InvalidInput kind. The Result<u32, Error> type means that the function returns an integer on success (Ok) and 
// an Error on failure (Err).
// 
// fn get_int(s: &str) -> Result<u32, Error> {
//     s.parse::<u32>()
//         .map_err(|e| Error::new(ErrorKind::InvalidInput, e))
// }

// Generic version
// This version of the function uses a type parameter T that implements the FromStr trait, which allows us to parse 
// the input string into a value of type T. The map_err method is used to convert the ParseError returned by the 
// parse method into an Error with the InvalidInput kind.

// The T::Err type parameter is used to specify the associated error type for the FromStr trait. This allows us to 
// convert the ParseError into an Error that can be returned from the function.

// When calling this function, you need to specify the type parameter T explicitly, since Rust cannot infer the type 
// from the input string alone. For example:
// let value: Result<u32, Error> = get_value("42");
// let value: Result<f64, Error> = get_value("3.14");

fn get_value<T>(s: &str) -> Result<T, Error>
where
    T: FromStr,
    T::Err: std::error::Error + Send + Sync + 'static,
{
    s.parse::<T>()
        .map_err(|e| Error::new(ErrorKind::InvalidInput, e))
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
        let num: u32;
        
        // get valid number input
        loop {
            input = prompt("Seek until what integer number?: ");
            // match get_int(&input) {
            match get_value(&input) {
                Ok(i) => {
                    if i < 2 {
                        println!("Minimum number needs to be 2 or above");
                        continue;
                    }
                    num = i;
                    break;
                },
                Err(e) => {
                    eprintln!("Error: {}", e);
                    continue;
                },
            }
        }

        // get valid threads input
        let threads: usize;
        loop {
            input = prompt("Number of Threads to use?: ");
            // match get_int(&input) {
            match get_value(&input) {
                Ok(i) => {
                    if i < 1 {
                        println!("Minimum number of threads is 1");
                        continue;
                    }
                    threads = i;
                    break;
                },
                Err(e) => {
                    eprintln!("Error: {}", e);
                    continue;
                },
            }
        }

        // prepare the list of numbers to be searched 
        let odds: Vec<u32> = (3..num)
                                    .filter(|n| n % 2 != 0)
                                    .collect();
        let chunk_size: usize = (odds.len() + threads - 1) / threads;
        let vectors: Vec<Vec<u32>> = odds.chunks(chunk_size)
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

    static FIRST_25_PRIMES: [u32; 25] = [
        2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89,
        97,
    ];

    fn vec_compare(va: &[u32], vb: &[u32]) -> bool {
        (va.len() == vb.len()) &&  	              // zip stops at the shortest
        va.iter()					     // creates iterator of first vec
       .zip(vb)		   // zips up two iterators into a single iterator of pairs tuple
       .all(|(a,b)| a == b) // tests if every element of the iterator matches a predicate
    }

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

    #[test]
    fn get_int_works() {
        let value: Result<u32, Error> = get_value("42");
        assert_eq!(value.unwrap(), 42);
    }

}
