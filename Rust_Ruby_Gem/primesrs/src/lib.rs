use libc::{c_void, size_t};
use parking_lot::Mutex;
use rayon::prelude::*;
use std::mem;
use std::sync::Arc;

// to be able to return struct compatible with a Ruby array
#[repr(C)]
pub struct RubyArray {
    len: size_t,
    ptr: *const c_void,
}

impl RubyArray {
    fn from_vec<T>(vec: Vec<T>) -> RubyArray {
        let array = RubyArray {
            ptr: vec.as_ptr() as *const c_void,
            len: vec.len() as size_t,
        };
        // forget it so that it is not destructed at the end of the scope.
        mem::forget(vec); // Leaks if not freed from Ruby.
        array
    }
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

#[no_mangle]
pub extern "C" fn search(n: u32) -> RubyArray {
    // Surround Vector in Arc-Mutex to be able to write to it concurrently / 78498 primes in 1M
    let result: Arc<Mutex<Vec<u32>>> = Arc::new(Mutex::new(Vec::with_capacity(80000)));
    result.lock().push(2); // Add 2 as below we start checking odd numbers from 3 onwards
    let num_vector: Vec<u32> = (3..n).step_by(2).collect();
    // iterate through vector of candidates in parallel using rayon (into_par_iter is the key)
    num_vector.into_par_iter().for_each(|i| {
        if is_prime(i) {
            result.lock().push(i); // to be able to write to it concurrently
        }
    });
    // Move vector out of the Arc-Mutex
    let mut list = Arc::try_unwrap(result).unwrap().into_inner();
    // make vector capacity equal length / optional
    list.shrink_to_fit();
    // return a struct from which Ruby can construct an array
    RubyArray::from_vec(list)
}
