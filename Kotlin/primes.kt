// compile with:
// kotlinc primes.kt -include-runtime -d primes.jar
// run in terminal with:
// java -jar primes.jar

@file:JvmName("Primes")

fun checkPrime(n: Int): Boolean {
    val limit = Math.sqrt(n.toDouble()).toInt()
    return (3..limit step 2).none { n % it == 0 }
}

fun main() {
    
    println("Looks for prime numbers from 1 to your input ")
    print("Seek until what integer number ? ")
    val num: Int = readLine()!!.toInt()
    //val num = 1000000

    val results = arrayListOf<Int>()
    results.add(2)
    // start time
    val startTime = System.nanoTime()

    for (i in 3..num step 2) {
        val sq = Math.sqrt(i.toDouble()).toInt()
        var isPrime = true
        for (n in 3..sq step 2) if (i % n == 0) {
            isPrime = false
            break
        }
        if (isPrime) {
            results.add(i)
        }
    }

    // stop time
    val elapsedTime: Double = (System.nanoTime() - startTime) / 1E9
    val formattedElapsedTime = "Took %.3f seconds".format(elapsedTime)
    val count: Int = results.size
    println("Found $count primes.")
    println(formattedElapsedTime)

}