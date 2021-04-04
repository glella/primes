// compile to bytecode with:
// javac Primes.java
// execute in terminal:
// java Primes
import java.util.*;

public class Primes
{
	public static void main(String[] args)
	{
		System.out.println("Returns a list of prime numbers from 1 to < n using trial division algorithm");

		Scanner input = new Scanner(System.in);

		System.out.print("Enter number limit: ");
		double num = input.nextInt();
		
		int i=0;
		int n=0;
		ArrayList<Integer> result = new ArrayList<Integer>();
		result.add(2);
		boolean isPrime;
		int sq;
		
		long startTime = System.nanoTime();
		
		for(i = 3; i <= num; i=i+2) {
			isPrime = true;
			sq = (int)Math.sqrt(i);
			
			for(n = 3; n <= sq && isPrime; n=n+2) {
				if (i % n == 0) {
					isPrime = false;
                    break;
               }
			}
			
			if (isPrime) 
				result.add(i);
			
		}
		
		double elapsedTime = (System.nanoTime() - startTime) / 1E9;
		
		System.out.printf("Found %d primes.%n", result.size());
		System.out.printf("Took %.3f seconds.%n", elapsedTime);
		//System.out.println(result);
	}
}
