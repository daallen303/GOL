#include <iostream>
#include <fstream>
#include <vector>
#include <stdlib.h>
#include <string>
#include <unistd.h>

using namespace std;

const int THREADS_PER_BLOCK = 512;

__global__ 
void setStatus(char A[], int B[])
{
	int i;
	i = blockIdx.x * blockDim.x + threadIdx.x;
	if(A[i] == 'X') //check if it's alive
	{
		if(B[i] < 2)
		{
			A[i] = '-';//dead less than 2 living neighbours
		}
		else if(B[i] <= 3)
		{
			A[i] = 'X'; //do nothing status is already alive
		}
		else 
		{
			A[i] = '-';//dead greater than 3 living neighbours
		}
	}
	else
	{ //dead cell
		if(B[i] == 3)
		{
			A[i] = 'X';// dead to alive
		}
	}
}

__global__
void callCheck(int rows, int cols,char A[], int B[])
{
	int i, k, j, count, iIndex, jIndex;
	i = blockIdx.x * blockDim.x + threadIdx.x;
	int rowIndex, colIndex;//index of current thread
	iIndex = i/cols; //row index
	jIndex = i%cols; // col index
	count = 0;
	
	for(k = iIndex-1; k <= iIndex+1; k++)
	{
	    for (j = jIndex-1; j <= jIndex+1; j++) //Each line ends with newline character \n (Unix formatting)
		{
			// k < 0 j >0 can't have negative index
			//k > rows j > cols can't have index larger than array Max
	    	
			if(k<0)
			{
				rowIndex = rows-1;
			}
			else if(k>=rows)
			{
				rowIndex = 0;
			}
			else
			{
				rowIndex = k;
			}
			if(j<0)
			{
				colIndex = cols-1;
			}
			else if(j>=cols)
			{
				colIndex = 0;
			}
			else
			{
				colIndex = j;
			}
			if (A[rowIndex*cols+colIndex] == 'X' && (rowIndex*cols+colIndex!= i))
			{
				count++;
			}
		}
	}
	B[i] = count;
	
}


	

int main(int argc, char *argv[])
{
	int i,j, rows, cols;
	char temp = '=';
	rows = 1;
	cols = 1;
	vector<char> tempS;
	ifstream fin;
	ofstream fout;
	bool printAll = false;
	int opts = 0;
	string input;
	int iterations = 1;
	
	while(opts < argc)
	{
		if(string(argv[opts]) == "-i")
		{
			iterations = strtol(argv[opts+1], NULL, 10);
		}
		if(string(argv[opts]) == "-v")
		{
			printAll = true;
		}
		if(opts == argc-1)
		{
			string ext;
			string temp = argv[opts];
			for(i = temp.length()-4; i < temp.length(); i++) ext += temp[i];
			if(ext == ".txt") input = temp;
		}
		opts++;
	}
	
	fin.open(input.c_str());
	if(!fin)
	{
		cout<< "Could not find the input file please try running again with valid file";
		exit(1);
	}
	fout.open("output.txt");
	i=0;
	fin >> temp;
	int totalcount = 0;   //total number of elements
	
	while(!fin.eof())
	{
		totalcount++;
		if(temp == 'X' || temp == '-')
		{
			if(fin.peek() == '\n')
			{
				rows++;
			}else if(rows == 1)
			{
				cols++;
			}
		tempS.push_back(temp); //read in status 
		}
		else
		{
			cout << "Invalid input = " << temp << endl;
		}
		fin >> temp;
		i++;
	}
	fin.close();
	
	int Array_size = cols*rows;
	
	if(Array_size <= 8)
	{
		cout <<"Matrix must be at least 9 elements";
		exit(1);
	}
	if(totalcount != Array_size)
	{
		cout << "Matrix is not even";
		exit(1);
	}
	char S[Array_size];
	
	for(j=0; j<Array_size; j++)
	{
		S[j]= tempS[j];
	}
	
	tempS.clear();

	char *A;
	int *B;
	int GD;
	i=1;
	
	while(i <= THREADS_PER_BLOCK)
	{
		if (Array_size%i == 0)
			{
			GD = i;	//find greatest denominator of Array_size < THREADS_PER_BLOCK
			}
		   i++;
	}
	
	cudaMalloc((void** ) &A, Array_size*(sizeof(char)));
	cudaMalloc((void** ) &B, Array_size*(sizeof(int)));	//allocates bytes from device heap and returns pointer to allocated memory or null
	cudaMemcpy(A, S, Array_size*sizeof(char), cudaMemcpyHostToDevice);
	
	int l = 0;
	while(l < iterations)
	{

		callCheck<<<Array_size/GD,GD>>>(rows,cols,A, B);
		setStatus<<<Array_size/GD,GD>>>(A, B);
	
	
		if(printAll == true || l == iterations-1)
		{
			cudaDeviceSynchronize();
			cudaMemcpy(S, A, Array_size*sizeof(char), cudaMemcpyDeviceToHost);
			printf("\033[2J\033[H");
			for(i = 0; i < rows; i++)
			{
				
				for(j = 0; j<cols; j++)
				{   
					cout << S[i*cols+j];
				}
				cout << endl;
			}
		}
		l++;
	}
	cudaFree(A);
	cudaFree(B);
	
	return 0;

}

