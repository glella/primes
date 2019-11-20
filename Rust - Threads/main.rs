// Using messages

use std::thread;
use std::sync::mpsc;
//use std::time::Duration;
use std::io;
use std::io::Write; // <--- bring flush() into scope
use std::time::Instant;


fn is_prime(n: u64) -> bool {
    match n {
        0 | 1 => false,
        2 => true,
        _even if n % 2 == 0 => false,
        _ => {
            let sqrt_limit = (n as f64).sqrt() as u64;
            !(3..=sqrt_limit).step_by(2).any(|i| n % i == 0) 			
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

fn get_int(s: &str) -> u64 {
    let mut n = 0;
    match s.parse::<u64>() {
        Ok(i) => n = i,
        Err(..) => println!("That was not an integer."),
    };
    n
}

fn make_range(min: u64, max: u64) -> Vec<u64> {
	let mut range = Vec::new();
	for i in min..max {
		range.push(i);
	}
	range
}

fn prep_search(n: u64) -> Vec<Vec<u64>> {
	let text = prompt("Number of Threads to use? ");
	let num_threads = get_int(&text);
	//println!("Creating {} threads.", num_threads);

	let range_size = n / num_threads;		// range sized divided evenly
	let mut reminder = n % num_threads;			// reminder to be spread out

	let mut range_sizes_vec = Vec::new();	// vector to hold each range size
	for _i in 0..num_threads {
		range_sizes_vec.push(range_size);	// initial size without reminder
	}

	// Spread the reminder
	for i in &mut range_sizes_vec {
		if reminder > 0 {
			*i += 1;
			reminder -= 1;
		}
	}

	let mut vec_of_vec = Vec::new();		// vector of vectors to be returned
	let mut min = 1;
	let mut max;

	for i in range_sizes_vec {
		max = min + i; // - 1;
		let temp = make_range(min, max);
		//println!("{:?}", temp);
		vec_of_vec.push(temp);
		min = max; // +1
	}
	vec_of_vec
}


fn main() {

	println!("Looks for prime numbers from 1 to your input");
	let mut input = String::new();	
	let mut result: Vec<u64> = Vec::new();
	
	loop {
		input.clear();
		result.clear();

		// Channels - send and receive
		let (tx, rx) = mpsc::channel();
		let mut children = Vec::new();
		
    	input = prompt("Seek until what integer number? ");
    	let num = get_int(&input); //as u64;

    	let search_vectors = prep_search(num);
    	//println!("{:?}", search_vectors);
    	let nthreads = search_vectors.len();

    	let now = Instant::now(); // start timer
    	
    	for segment in search_vectors {
    		// The sender endpoint can be copied
        	let thread_tx = tx.clone();

        	// Each thread will send its results via the channel
        	let child = thread::spawn(move || {
        		let mut temp: Vec<u64> = Vec::new();
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
            
            //Can do it too by creating another temporary vector but not needed:
            //println!("Got: {:?}", rx.recv().unwrap());
            //let mut temp = Vec::new();
            //temp.push(rx.recv().unwrap());
            //result.extend(temp);
            //for mut v in temp {
                //result.append(&mut v);
    	    //}
        }
        
        
    	// Wait for the threads to complete any remaining work
    	for child in children {
        	child.join().expect("oops! the child thread panicked");
    	}


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
