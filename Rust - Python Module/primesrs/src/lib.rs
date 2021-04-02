extern crate pyo3;
extern crate rayon;

use pyo3::prelude::*;
use rayon::prelude::*;
use std::sync::{Arc, Mutex};

/// This module is implemented in Rust.
#[pymodule]
fn primesrs(_py: Python, m: &PyModule) -> PyResult<()> {
    // PyO3 aware function. All of our python interfaces could be declared in a separate module.
    // Note that the `#[pyfn()]` annotation automatically converts the arguments from
    // Python objects to Rust values; and the Rust return value back into a Python object.
    #[pyfn(m, "getlist")]
    fn getlist(_py: Python, n: u32) -> PyResult<Vec<u32>> {
        let list = search(n);
        Ok(list)
    }
    Ok(())
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
    result.lock().unwrap().push(2); // Add 2 as below we start checking odd numbers from 3 onwards
    let num_vector: Vec<u32> = (3..n).step_by(2).collect();
    // iterate through vector of candidates in parallel using rayon
    num_vector.into_par_iter().for_each(|i| {
        if is_prime(i) {
            result.lock().unwrap().push(i); // to be able to write to it concurrently
        }
    });
    // Move vector out of the Arc-Mutex
    let list = Arc::try_unwrap(result).unwrap().into_inner().unwrap();
    list
}
