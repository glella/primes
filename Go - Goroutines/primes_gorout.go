// prime search - trial division
// understand optimal number of goroutines to use
// for this case seems performance peaks at 2X number of logical cores
// ie: cores 4, logical cores 8 ==> performance peaks when using 16 goroutines

package main

import (
	"bufio"
	"fmt"
	"os"
	"runtime"
	"strconv"
	"strings"
	"time"
)

func IsPrime(n int) bool {
	if n < 0 {
		n = -n
	}
	switch {
	case n == 2:
		return true
	case n < 2 || n%2 == 0:
		return false

	default:
		var i int
		for i = 3; i*i <= n; i += 2 {
			if n%i == 0 {
				return false
			}
		}
	}
	return true
}

func prompt(s string) string {
	fmt.Print(s + " ")
	reader := bufio.NewReader(os.Stdin)
	text, _ := reader.ReadString('\n')
	// convert CRLF to LF
	text = strings.Replace(text, "\n", "", -1)
	return text
}

func getInt(s string) int {
	temp, err := strconv.Atoi(s)
	if err == nil {
		return temp
	}
	return 0
}

func doSearch(s []int, c chan []int) {
	var res []int
	for _, val := range s {
		if IsPrime(val) {
			res = append(res, val)
		}
	}
	c <- res
}

func makeRange(min, max int) []int {
	a := make([]int, max-min+1)
	for i := range a {
		a[i] = min + i
	}
	return a
}

func prepSearch(n int) [][]int {

	text := prompt("Number of Goroutines to use?")
	numOfRout := getInt(text)
	//numCPUs := runtime.NumCPU() // changed to determine number of goroutines manually
	numCPUs := numOfRout
	fmt.Printf("Logical CPUs: %d. Creating %d Goroutines.\n", runtime.NumCPU(), numCPUs)

	rangesToSearchSlice := make([][]int, numCPUs)

	rangeSize := n / numCPUs // divide the search evenly between CPUs
	reminder := n % numCPUs  // calculate de reminder to be spread out

	// Number of ranges to search evenly = number of CPUs
	range_sizes := make([]int, numCPUs)
	// Even numbers per range
	for i := 0; i < numCPUs; i++ {
		range_sizes[i] = rangeSize
	}
	// Spread the reminder
	for i := 0; reminder > 0; i = (i + 1) % numCPUs {
		range_sizes[i] += 1
		reminder -= 1
	}
	// Make ranges & store them
	min := 1
	max := n
	for i := 0; i < numCPUs && max <= n; i++ {
		max = min + range_sizes[i] - 1
		rangeToSearch := makeRange(min, max)
		rangesToSearchSlice[i] = rangeToSearch
		min = max + 1
	}

	//fmt.Println(rangesToSearchSlice) // To test it worked properly
	return rangesToSearchSlice
}

func main() {
	var result []int
	var num = 0
	var text = ""

	fmt.Println("Looks for prime numbers from 1 to your input")

	for {
		result = nil
		num = 0
		text = prompt("Seek until what integer number?")
		num = getInt(text)

		rangesToSearch := prepSearch(num)
		l := len(rangesToSearch)
		c := make(chan []int)
		start := time.Now() // Start timer

		for i := range rangesToSearch {
			go doSearch(rangesToSearch[i], c)
		}

		for i := 0; i < l; i++ {
			temp := <-c
			result = append(result, temp...)
		}

		duration := time.Since(start) // End timer & duration
		close(c)                      // close channel
		elapsed := float64(duration) / float64(time.Millisecond)
		elapsed = elapsed / 1000.0
		fmt.Printf("Found %d primes.\n", len(result))
		fmt.Printf("Seconds: %.3f\n", elapsed)

		text = prompt("Print primes? (y/n)")
		if strings.Compare("y", text) == 0 {
			fmt.Printf("%v\n", result)
		}

		text = prompt("Another run? (y/n)")
		if strings.Compare("y", text) != 0 {
			break
		}
		fmt.Println("---------------------")
		fmt.Println("")
	}

}
