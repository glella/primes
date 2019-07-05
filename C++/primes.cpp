#include <iostream>
#include <iomanip>
#include <math.h>
#include <time.h>

using namespace std;

int main()
{
	int 		cant, num, i, n, sq;
	double 		elapsedTime;
	int 		result[350000];
	bool 		isPrime;
	clock_t 	start, end;
	char 		response;
	
	do {
	
		cout << "Look for primes until n < 1 using trial division" << endl;
		cout << "Seek until: ";
		cin >> num;
		cout << endl;
	
		result[0] = 2;
		cant = 1;
	
		// start time
		start = clock();
	
		for(i = 3; i <= num; i=i+2) {
			isPrime = true;
			sq = (int)sqrt(i);
		
			for(n = 3; n <= sq; n=n+2)
				if (i % n == 0)
					isPrime = false;
		
			if (isPrime) {
				result[cant] = i;
				cant++;
			}
		
		}
	
		// stop time
		end = clock();
		// calculate elapsed time
		elapsedTime = double(end - start) / CLOCKS_PER_SEC;
	
		cout << "Found " << cant << " primes." << endl;
		cout << fixed;
		cout << setprecision(3);
		cout << "Took " << elapsedTime << " seconds." << endl;
		cout << "Print them ? (y/n) ";
		cin >> response;
		//cout << endl;
		if ((response == 'y') || (response == 'Y')) {
			for(i = 0; i <= cant-1; i++)
				cout << result[i] << ", ";
			cout << endl;
		}
		response = 'n';
		cout << "Another run ? (y/n) ";
		cin >> response;
		cout << endl;
	} while ((response == 'y') || (response == 'Y'));
}
