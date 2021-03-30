#primesrs

A Ruby Gem written in Rust to see if we can circumvent Global Interpreter Lock (GIL), calculating primes concurrently using the Rayon Rust crate - Success!

Steps:

1- Create the gem

```
bundle gem primesrs -t rspec
cd fib
```


2- Edit primesrs.gemspec

```
require_relative "lib/primesrs/version"

Gem::Specification.new do |spec|
  spec.name          = "primesrs"
  spec.version       = Primesrs::VERSION
  spec.authors       = ["Guillermo Lella"]
  spec.email         = ["arkorott@gmail.com"]
  spec.summary       = "Get list of primes until given integer limit."
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")
  spec.add_dependency "ffi"
  # Specify which files should be added to the gem when it is released.
  spec.files         = Dir['lib/**/*', 'src/**/*.rs', 'Cargo.toml', 'LICENSE', 'README.md']
  spec.require_paths = ["lib"]
end
```

3- Create Cargo.toml & src/lib.rs

```
cargo init --lib
```

4- Setup Cargo.toml (Rust crate information similar to gemspec)
Rayon is a concurrency crate and Libc help us operate with the C FFI intertace and comunicate with Ruby 

```
cargo add rayon
cargo add libc
```

And add these 2 lines

```
[lib]
crate-type = ["cdylib"]
```

Cargo.toml should end up looking like this

```
[package]
name = "primesrs"
version = "0.1.0"
authors = ["Guillermo Lella <arkorott@gmail.com>"]
edition = "2018"

[lib]
crate-type = ["cdylib"]

[dependencies]
rayon = "1.5.0"
libc = "0.2.91"
```


5- Open src/lib.rs remove what is there by default and add the following Rust code that will actually do the work. 
Note the functions marked as 'pub extern' will the be the ones available to Ruby, and the #[no_mangle] compiler directive is for the Rust compiler not to mangle the name as written for optimization sake.
A side complication is to return an array (Vector in Rust) through C FFI to Ruby. 
We create a struct with a pointer and a length of the array on the heap that Ruby will use to create a Ruby array.

```
extern crate rayon;
extern crate libc;

use rayon::prelude::*;
use std::sync::{Arc, Mutex};
use libc::{size_t, c_void};
use std::mem;

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
            len: vec.len() as size_t };
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
        _ => !(3..).step_by(2).take_while(|i| i * i <= n).any(|i| n % i == 0),
    }
}

#[no_mangle]
pub extern fn search(n: u32) -> RubyArray {
    // Surround Vector in Arc-Mutex to be able to write to it concurrently
    let result: Arc<Mutex<Vec<u32>>> = Arc::new(Mutex::new(Vec::new()));
    result.lock().unwrap().push(2); // Add 2 as below we start checking odd numbers from 3 onwards
    let num_vector: Vec<u32> = (3..n).step_by(2).collect();
    // iterate through vector of candidates in parallel using rayon (into_par_iter is the key)
    num_vector.into_par_iter().for_each(|i| {
        if is_prime(i) {
            result.lock().unwrap().push(i); // to be able to write to it concurrently
        }
    });
    // Move vector out of the Arc-Mutex
    let list = Arc::try_unwrap(result).unwrap().into_inner().unwrap();
    // return a struct from which Ruby can construct an array
    RubyArray::from_vec(list)
}
```

6- Add the rust_build and rust_clean tasks to the Rakefile. It should look like this

```
require 'bundler/setup'
require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :rust_build do
  `cargo rustc --release`
  # move dylib to right place
  `mv -f ./target/release/libprimesrs.dylib ./lib/primesrs` 
end

task :build => :rust_build
task :spec => :rust_build

task :rust_clean do
  `cargo clean`
  `rm -f ./lib/primesrs/libprimesrs.dylib` # Change here according to your OS.
end

task :clean => :rust_clean
```

7- Try 'rake rust_build' to see if it works.
Rust compiler will download and compile all dependencies and compile our library code and if all is ok, it should create a file called 'libprimesrs.dylib' at lib/primesrs/

8- Try 'rake clean' to see if it works.
Previous file and Rust compiler target directories should be deleted.

9- Create the FFI module - new file: lib/primesrs/ffi.rb 
Used to interface with the Rust code and create a Ruby array with the returned data

```
require 'ffi'

module Primesrs
  extend FFI::Library
  lib_name = "libprimesrs.#{::FFI::Platform::LIBSUFFIX}"
  ffi_lib File.expand_path(lib_name, __dir__)

  class ArrayFromRust < FFI::Struct
    layout :len, :size_t,
           :ptr, :pointer 

    def to_a
      self[:ptr].get_array_of_uint32(0, self[:len]).compact
    end
  end

  attach_function :search, [:uint], ArrayFromRust.by_value
end
```

10- Create our gem ruby methods. Edit 'lib/primesrs.rb' change it to

```
require "primesrs/ffi"
require "primesrs/version"

module Primesrs
  def self.[](n)
    search(n).to_a
  end
end
```

11- Add a test file. Open spec/primesrs_spec.rb

```
RSpec.describe Primesrs do
  it "has a version number" do
    expect(Primesrs::VERSION).not_to be nil
  end

  it "gets prime numbers" do
    expect((Primesrs[10]).sort!).to match_array([2,3,5,7])
  end
end
```

12- Build, Install and Clean, And then go try it

```
rake rust_build
rake install
rake clean
```
