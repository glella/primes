use std::io::{self, Error, ErrorKind, Write};
use std::str::FromStr;

// print a prompt and get user input - gets a &str and returns a String
pub fn prompt(s: &str) -> String {
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

pub fn get_value<T>(s: &str) -> Result<T, Error>
where
    T: FromStr,
    T::Err: std::error::Error + Send + Sync + 'static,
{
    s.parse::<T>()
        .map_err(|e| Error::new(ErrorKind::InvalidInput, e))
}

// compare 2 vectors
pub fn vec_compare(va: &[u32], vb: &[u32]) -> bool {
    (va.len() == vb.len()) &&  	              // zip stops at the shortest
        va.iter()					     // creates iterator of first vec
    .zip(vb)		   // zips up two iterators into a single iterator of pairs tuple
    .all(|(a,b)| a == b) // tests if every element of the iterator matches a predicate
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn get_value_works() {
        let value: Result<u32, Error> = get_value("42");
        assert_eq!(value.unwrap(), 42);
    }
}
