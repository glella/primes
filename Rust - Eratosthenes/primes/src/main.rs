// Eratosthenes

use std::io;
use std::io::Write; // <--- bring flush() into scope
use std::time::Instant;

fn eratosthenes(n: u32) -> Vec<usize> {
    let arrsize = n as usize;
    if n < 2 {
        Vec::new()
    } else {
        let mut result = vec![true; arrsize + 1 - 2];
        let limit = (n as f64).sqrt() as usize;
        for i in 2..limit + 1 {
            let mut it = result[i - 2..].iter_mut().step_by(i);
            if let Some(true) = it.next() {
                it.for_each(|x| *x = false);
            }
        }
        result
    }
    .into_iter()
    .enumerate()
    .filter_map(|(e, b)| if b { Some(e + 2) } else { None })
    .collect()
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

fn get_int(s: &str) -> u32 {
    let mut n = 0;
    match s.parse::<u32>() {
        Ok(i) => n = i,
        Err(..) => println!("That was not an integer."),
    };
    n
}

fn main() {
    println!("Looks for prime numbers from 1 to your input");
    let mut input = String::new();

    loop {
        input.clear();
        let mut input = prompt("Seek until what integer number? ");
        let num = get_int(&input);

        let now = Instant::now(); // start timer
        let result = eratosthenes(num);
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
        println!("");
    }
}
