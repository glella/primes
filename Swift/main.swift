//
//  main.swift
//  primesswift
//


import Foundation

var result = [Int]()


func populatePrimeList(max: Int) {
    
    result.append(2)
    
    var isPrime:Bool = true
    
    for x in stride(from: 3, through: max, by: 2) {
        let sq: Int = Int(sqrt(Double(x)))
        isPrime = true
        
        for i in stride(from: 3, through: sq, by: 2) where x % i == 0 {
                isPrime = false
                break
        }
        
        if isPrime {
            result.append(x)
        }
    }
    
}


print("Returns a list of prime numbers from 1 to < n using trial division algorithm.")
print("Seek until what integer number ? ")

var number: Int = 10

if let input = readLine() {
    number = Int(input)!
}


let start = DispatchTime.now() // <<<<<<<<<< Start time
populatePrimeList(max: number)
let end = DispatchTime.now()   // <<<<<<<<<<   end time

let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests

print("Found \(result.count) primes.")
print("Took: \(String(format: "%.3f", timeInterval)) s")




