//
//  main.swift
//  swift_and_clang_primes
//
//  Created by Guillermo Lella on 4/4/21.
//

import Foundation

//var result = [Int]()

func report(nanotime: UInt64, count: Int) {
    let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
    print("Found \(count) primes.")
    print("Took: \(String(format: "%.3f", timeInterval)) s")
    print("\n")
}

print("Returns a list of prime numbers from 1 to < n using trial division algorithm\nin Swift, C, C++ and Objective-C.")
print("Seek until what integer number ? ")
var number: Int = 10
if let input = readLine() {
    number = Int(input)!
}

print("C:")
var start = DispatchTime.now()      // <<<<<<<<<< Start time
var count = Int(c_1_Thread(Int32(number)))
var end = DispatchTime.now()        // <<<<<<<<<<   end time
var nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
report(nanotime: nanoTime, count: Int(count))

print("C++:")
start = DispatchTime.now()      // <<<<<<<<<< Start time
count = Int(cpp_1_Thread(Int32(number)))
end = DispatchTime.now()        // <<<<<<<<<<   end time
nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
report(nanotime: nanoTime, count: Int(count))

print("Objective-C:")
start = DispatchTime.now()      // <<<<<<<<<< Start time
count = Int(objC_1_Thread(Int32(number)))
end = DispatchTime.now()        // <<<<<<<<<<   end time
nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
report(nanotime: nanoTime, count: Int(count))

print("Swift 1 thread:")
start = DispatchTime.now()      // <<<<<<<<<< Start time
count = swift_1_Thread(limit: number)
end = DispatchTime.now()        // <<<<<<<<<<   end time
nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
report(nanotime: nanoTime, count: count)

print("Swift 16 threads:")
start = DispatchTime.now()      // <<<<<<<<<< Start time
count = swift_n_threads(limit: number)
end = DispatchTime.now()        // <<<<<<<<<<   end time
nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
report(nanotime: nanoTime, count: count)
