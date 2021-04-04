// go build primes.go
// prime search trail division - no concurrency

package main

import (
	"bufio"
	"fmt"
	"os"
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
	//case n < 2 || n%2 == 0: // we skip testing even numbers
	//return false
	default:
		for i := 3; i*i <= n; i += 2 {
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

		start := time.Now()        // Start timer
		result = append(result, 2) // append 2 manually as we start searching from 3
		for i := 3; i < num; i += 2 {
			if IsPrime(i) {
				result = append(result, i)
			}
		}
		duration := time.Since(start) // End timer & duration
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
