#include <iostream>
#include <fstream>
#include <vector>
#include <stdlib.h>
#include <string>

using namespace std;

const int THREADS_PER_BLOCK = 512;

__global__
void callCheck(int rows, int cols,char A[])
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
			// k<0 j >0 can't have negative index
			//k>rows j > cols can't have index larger than array Max
			if(k<0) rowIndex = rows-1;
			else if(k>=rows)rowIndex = 0;
			else rowIndex = k;
			if(j<0) colIndex = cols-1;
			else if(j>=cols) colIndex = 0;
			else colIndex = j;
			if (A[rowIndex*cols+colIndex] == 'X' && (rowIndex*cols+colIndex!= i)) count++;
		}
	}
	if(A[i] == 'X') //check if it's alive
	{
	if(count < 2) A[i] = '-';//dead less than 2 living neighbours
	else if(count <= 3) A[i] = 'X'; //do nothing status is already alive
	else A[i] = '-';//dead greater than 3 living neighbours
	}else{ //dead cell
			if(count == 3) A[i] = 'X';// dead to alive
	}
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
		if(string(argv[opts]) == "-i") iterations = strtol(argv[opts+1], NULL, 10);
		if(string(argv[opts]) == "-v") printAll = true;
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
	if(fin){
	fout.open("output.txt");
	i=0;
	fin >> temp;
	int totalcount = 0; //total number of elements
	while(!fin.eof())
	{
		totalcount++;
		if(temp == 'X' || temp == '-')
		{
			if(fin.peek() == '\n')
				{
				   rows++;
				}else if(rows == 1)cols++;
		tempS.push_back(temp); //read in status 
		}else cout << "Invalid input = " << temp << endl;
		fin >> temp;
		i++;
	}
	fin.close();
	
	int Array_size = cols*rows;
	if(Array_size >8){
	if(totalcount== rows*cols){
	char S[rows*cols];
	for(j=0; j<rows*cols; j++)
	{
		S[j]= tempS[j];
	}
	
	tempS.clear();
	
	fout << "Initial step" << endl;
	for(i = 0; i < rows; i++)
		{
					
			for(j = 0; j<cols; j++)
			{   
				fout << S[i*cols+j];
			}
			fout << endl;
		}
	fout << endl;
	fout << endl;
	
	char *A;
	int GD;
	i=1;
	while(i <= THREADS_PER_BLOCK)
		{
		   if (Array_size%i == 0) GD = i;//find greatest denominator of Array_size < THREADS_PER_BLOCK
		   i++;
		}
	cudaMalloc((void** ) &A, rows*cols*(sizeof(char)));	//allocates bytes from device heap and returns pointer to allocated memory or null
	cudaMemcpy(A, S, rows*cols*sizeof(char), cudaMemcpyHostToDevice);
	//cout << Array_size%(Array_size/(THREADS_PER_BLOCK-(Array_size%THREADS_PER_BLOCK))) << endl;
	//cout << THREADS_PER_BLOCK%(Array_size/(THREADS_PER_BLOCK-(Array_size%THREADS_PER_BLOCK))) << endl;
	int l = 0;
	while(l < iterations){
    //     <<<number of blocks, number of threads per block>>>
	callCheck<<<Array_size/GD,GD>>>(rows,cols,A);
	//callCheck<<<(Array_size+THREADS_PER_BLOCK-1)/THREADS_PER_BLOCK, THREADS_PER_BLOCK>>>(rows,cols,A); I get memcheck errors using this
	cudaDeviceSynchronize();
	
	if(printAll == true || l == iterations-1)
	{
		cudaMemcpy(S, A, rows*cols*sizeof(char), cudaMemcpyDeviceToHost);
		fout << "Step " << l+1 << endl;
	for(i = 0; i < rows; i++)
		{
				
			for(j = 0; j<cols; j++)
			{   
				fout << S[i*cols+j];
			}
			fout << endl;
		}
	    fout << endl;
	    fout << endl;
	}
	l++;
	}
	cudaFree(A);
	fout.close();
	cout << "All Done";
		}else cout << "Matrix is not even";
	}else cout <<"Matrix must be at least 9 elements";
	}else cout<< "Could not find the input file please try running again with valid file";
	cin.get();

}

