// Eratosthenes

use std::thread;
use std::sync::mpsc;
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


// avoid using sqrt - test now fails because we start at 3 and we miss 2
fn is_prime(n: u32) -> bool {
    match n {
        0 | 1 => false,
        2 => true,
        //_even if n % 2 == 0 => false,
        _ => {
            !(3..).step_by(2).take_while(|i| i*i <= n).any(|i| n % i == 0)

        }
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

fn get_int(s: &str) -> u32 {
    let mut n = 0;
    match s.parse::<u32>() {
        Ok(i) => n = i,
        Err(..) => println!("That was not an integer."),
    };
    n
}

// test now fails because we add only odd numbers to range
fn make_range(min: u32, max: u32) -> Vec<u32> {
	let mut range = Vec::new();
	for i in (min..max).filter(|x| x % 2 == 1) { // Add only odd numbers
		range.push(i);
	}
	range
}

fn prep_search(n: u32, num_threads: u32) -> Vec<Vec<u32>> {	
	let range_size = n / num_threads;		    // range sized divided evenly
	let mut reminder = n % num_threads;			// reminder to be spread out

	let mut range_sizes_vec = Vec::new();	// vector to hold each range size
	for _i in 0..num_threads {
		range_sizes_vec.push(range_size);	        // initial size without reminder
	}

	// Spread the reminder
	for i in &mut range_sizes_vec {
		if reminder > 0 {
			*i += 1;
			reminder -= 1;
		}
	}

	let mut vec_of_vec = Vec::new();	// vector of vectors to be returned
	let mut min = 1;
	let mut max;

	for i in range_sizes_vec {
		max = min + i; 
		let temp = make_range(min, max);
		//println!("{:?}", temp);
		vec_of_vec.push(temp);
		min = max; 
	}
	vec_of_vec
}

fn search(vectors: Vec<Vec<u32>>) -> Vec<u32> {
	let mut result: Vec<u32> = Vec::with_capacity(80000);	// 78498 primes in 1M
    result.push(2);            // Add 2 as we removed even numbers from list

	// Channels - send and receive
	let (tx, rx) = mpsc::channel();
	let mut children = Vec::new();

	let nthreads = vectors.len();

	for segment in vectors {
    	// The sender endpoint can be copied
        let thread_tx = tx.clone();

        // Each thread will send its results via the channel
        let child = thread::spawn(move || {
        	let mut temp: Vec<u32> = Vec::new();
        	for i in segment {
        		if is_prime(i) {
        			temp.push(i);
        		}
        	}
        	//println!("temp {:?}", temp);
        	thread_tx.send(temp).unwrap();
        });
        	
        children.push(child);
    }
        
    // Here, all the messages are collected
    for _ in 0..nthreads {
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
	let mut input = String::new();	
	
	loop {
		input.clear();
    	let mut input = prompt("Seek until what integer number? ");
    	let num = get_int(&input); 

    	input = prompt("Number of Threads to use? ");
		let threads = get_int(&input);

    	let search_vectors = prep_search(num, threads);
    	
    	let now = Instant::now(); // start timer
    	
    	//let result = search(search_vectors); // perform the actual work
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

#[cfg(test)]
mod tests {
	use super::*;

	static FIRST_25_PRIMES: [u32; 25] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97];
	static TEST_RANGE: [u32; 14] = [11, 12, 13, 14, 15 , 16, 17, 18, 19, 20, 21, 22, 23, 24];

	fn vec_compare(va: &[u32], vb: &[u32]) -> bool {
    (va.len() == vb.len()) &&  	// zip stops at the shortest
     va.iter()					// creates iterator of first vec
       .zip(vb)					// zips up two iterators into a single iterator of pairs tuple
       .all(|(a,b)| a == b)		// tests if every element of the iterator matches a predicate
	}
	
    #[test]
    fn is_prime_works() {
    	//let first_25_primes: Vec<u64> = FIRST_25_PRIMES.to_vec();
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
    	assert_eq!(get_int(&"42"), 42);
    }

    #[test]
    fn make_range_works() {
    	let range = make_range(11, 25);
    	assert!(vec_compare(&range, &TEST_RANGE), "Got {:?}", range);
    }

    #[test]
    fn prep_search_works() {
    	// create vector of vector to compare to
    	let mut vectors = Vec::new();
    	vectors.push(make_range(1,35));			// 1 - 34
    	vectors.push(make_range(35,68));		// 35 - 67
    	vectors.push(make_range(68,101));		// 68 - 100
    	
    	// try the function up to 100 to compae to hardcoded values using 3 threads
    	// so we can compare vs the hardcoded split above (used 3 so we made it short and simple)
    	let test_vectors = prep_search(100, 3);

    	for (i, vector) in test_vectors.iter().enumerate() {
    		assert!(vec_compare(&vector, &vectors[i]), "Got {:?}", vector);
    	}
    }

    #[test]
    fn run_using_threads_works() {
    	// so we can compare to our hardcoded values we search to 100 using 6 threads just because
    	let search_vectors = prep_search(100, 6);

		let mut test_result = search(search_vectors);
    	test_result.sort();		// sort numbers for the compare - that why it was stored in a mutable vec

    	assert!(vec_compare(&test_result, &FIRST_25_PRIMES), "Got {:?}", test_result);
    }
}

