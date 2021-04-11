// cargo build --release
//extern crate rayon;

use std::io;
use std::io::Write;
use std::time::Instant; // <--- bring flush() into scope

use rayon::prelude::*;
// use std::sync::{Arc, Mutex};
use parking_lot::Mutex;
use std::sync::Arc;

fn prompt(s: &str) -> String {
    print!("{}", s);
    io::stdout().flush().unwrap(); // flush it to the screen

    let mut text = String::new();
    io::stdin()
        .read_line(&mut text)
        .expect("failed to read from stdin");
    text.trim().to_string()
}

fn get_int(s: &str) -> u32 {
    let mut n = 0;
    match s.parse::<u32>() {
        Ok(i) => n = i,
        Err(..) => println!("That was not an integer."),
    };
    n
}

fn is_prime(n: u32) -> bool {
    match n {
        0 | 1 => false,
        2 => true,
        //_even if n % 2 == 0 => false,
        _ => !(3..)
            .step_by(2)
            .take_while(|i| i * i <= n)
            .any(|i| n % i == 0),
    }
}

fn search(n: u32) -> Vec<u32> {
    // Surround Vector in Arc-Mutex to be able to write to it concurrently / 78498 primes in 1M
    let result: Arc<Mutex<Vec<u32>>> = Arc::new(Mutex::new(Vec::with_capacity(80000)));
    result.lock().push(2); // Add 2 as below we start checking odd numbers from 3 onwards
    let num_vector: Vec<u32> = (3..n).step_by(2).collect();
    // iterate through vector of candidates in parallel using rayon
    num_vector.into_par_iter().for_each(|i| {
        if is_prime(i) {
            result.lock().push(i); // to be able to write to it concurrently
        }
    });
    // Move vector out of the Arc-Mutex
    let list = Arc::try_unwrap(result).unwrap().into_inner();
    list
}

fn main() {
    println!("Looks for prime numbers from 1 to your input");

    loop {
        let mut input = prompt("Seek until what integer number? ");
        let num = get_int(&input);

        let now = Instant::now(); // start timer
        let result = search(num);
        let elapsed = now.elapsed(); // check time elapsed
        let sec = (elapsed.as_secs() as f64) + (elapsed.subsec_nanos() as f64 / 1000_000_000.0);
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
