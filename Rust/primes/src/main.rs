// compile with cargo build --release
use std::io::Write;
use std::time::Instant;
use std::{io, u32}; // <--- bring flush() into scope

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

fn my_is_prime(n: u32) -> bool {
    match n {
        0 | 1 => false,
        2 => true,
        //_even if n % 2 == 0 => false, // we skip even numbers
        _ => !(3..)
            .step_by(2)
            .take_while(|i| i * i <= n)
            .any(|i| n % i == 0),
    }
}

fn main() {
    println!("Looks for prime numbers from 1 to your input");
    let mut input = String::new();
    let mut result: Vec<u32> = Vec::with_capacity(80000); // 78498 primes in 1M

    loop {
        input.clear();
        result.clear();

        let mut input = prompt("Seek until what integer number? ");
        let num = get_int(&input);

        let now = Instant::now(); // start timer
        result.push(2); // Add 2 as we start checking at 3 onwards
        for i in (3..num).step_by(2) {
            if my_is_prime(i) {
                result.push(i);
            }
        }
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
