#include <iostream>
#include <fstream>
#include <vector>

using namespace std;

const int THREADS_PER_BLOCK = 512;

__global__
void callCheck(int rows, int cols,char A[], int B[])
{
	int i, k, j, count, iIndex, jIndex;
    i = blockIdx.x * blockDim.x + threadIdx.x;
    int rowIndex, colIndex;//index of current thread
	//int stride = blockDim.x *gridDim.x; total threads grid striping 
				//checkAdjCells(rows,cols, k, A);
				iIndex = i/cols; //row index
				jIndex = i%cols; // col index
				count = 0;
				for(k = iIndex-1; k <= iIndex+1; k++)
				{
					for (j = jIndex-1; j <= jIndex+1; j++) //Each line ends with newline character \n (Unix formatting)
					{
						// i<0 can't have negative index
						//i>rows j > cols can't have index larger than array Max
						if(k<0) rowIndex = rows;
						else if(k>rows)rowIndex = 0;
						else rowIndex = k;
						if(j<0) colIndex = cols;
						else if(j>cols) colIndex = 0;
						else colIndex = j;
						if (A[rowIndex*cols+colIndex] == 'X' && (rowIndex*cols+colIndex!= i)) count++;
					}
				}
									B[i] = count;
										if(A[i] == 'X') //check if it's alive
										{
										if(B[i] < 2) A[i] = '-';//dead less than 2 living neighbours
										else if(B[i] <= 3) A[i] = 'X'; //do nothing status is already alive
										else A[i] = '-';//dead greater than 3 living neighbours
										}
										else{ //dead cell
											if(B[i] == 3) A[i] = 'X';// dead to alive
										}
}	

int main()
{
	int i,j, rows, cols;
	char temp;
	rows = 1;
	cols = 1;
	// two sepreate array coalesced reads cuda
	vector <char> S;
	vector <int> C;
	ifstream fin;
	ofstream fout;
	fin.open("./input.txt");
	fout.open("output.txt");
	fin >> temp;
	while(!fin.eof())
	{
		if(fin.peek() == '\n')rows++;
		else if(rows == 1)cols++;
		if(temp == 'X' || temp == '-')
		{
			S.push_back(temp); //read in status
			C.push_back(-1); //initialize count of Adjcells
		}else cout << "Invalid input = " << temp << endl;
		fin >> temp;
	}
	
	char *A;
	int *B;
	cudaMalloc(&A, rows*cols*(sizeof(char)));
	cudaMalloc(&B, rows*cols*(sizeof(int)));//allocates bytes from device heap and returns pointer to allocated memory or null
	for(i = 0; i < rows; i++)
	{
			for(j = 0; j<cols; j++)
			{   
				cudaMemcpy(&A[i*cols+j], &S[i*cols+j], sizeof(char), cudaMemcpyHostToDevice);
				cudaMemcpy(&B[i*cols+j], &C[i*cols+j], sizeof(int), cudaMemcpyHostToDevice);
			}
	}
	int l = 0;
	while(l< 5){
 //     <<<number of blocks, number of threads per block>>>
	callCheck<<<cols*rows/THREADS_PER_BLOCK+1,THREADS_PER_BLOCK>>>(rows, cols, A, B); // one block of rows*cols threads
	cudaDeviceSynchronize();
	for(i = 0; i < rows; i++)
		{
				
				for(j = 0; j<cols; j++)
				{   
					
					cudaMemcpy(&S[i*cols+j], &A[i*cols+j], sizeof(char), cudaMemcpyDeviceToHost);
					cudaMemcpy(&C[i*cols+j], &B[i*cols+j], sizeof(int), cudaMemcpyDeviceToHost);
					fout << S[i*cols+j];
				}
				fout << endl;
		}
	fout << endl;
	fout << endl;
	l++;
	}
	cudaFree(A);
	cudaFree(B);
	cout << "All Done";
	cin.get();

}


/*struct Cell{
	char status;
	int count;
};


int checkAdjCells(int rows, int cols, int cIndex, char A[])
	{
		int i, j, iIndex, jIndex, count = 0;
		iIndex = cIndex/cols; //row index
		jIndex = cIndex%cols; // col index
		for(i = iIndex-1; i <= iIndex+1; i++)
		{
			for (j = jIndex-1; j <= jIndex+1; j++) //Each line ends with newline character \n (Unix formatting)
			{
				// i<0 can't have negative index
				//i>rows j > cols can't have index larger than array Max
				if(i>=0 && i<=rows && j >=0 && j<= cols && A[i*cols+j] == 'X' && (i*cols+j!= cIndex)) count++;
			}
		}
		return count;
	}

char setStatus(int num, char status) //Each line ends with newline character \n (Unix formatting)
{
		//cout << num << " ";
		char newStat = status;
		if(status == 'X') //check if it's alive
		{
		if(num < 2) newStat = '-';//dead less than 2 living neighbours
		else if(num <= 3) newStat = 'X'; //do nothing status is already alive
		else newStat = '-';//dead greater than 3 living neighbours
		}
		else{
			if(num == 3) newStat = 'X'; // dead to alive
		}
		return newStat;
}

char getStatus()
{
	return status;
}
int getCount()
{
	return count;
}
void setCount(int num)
{8
		count = num;
}

void initStatus(char c)
{
	status = c;
}

*/
/*
char setStatus(int num, char status) //Each line ends with newline character \n (Unix formatting)
{
		char newStat = status;
		if(status == 'X') //check if it's alive
		{
		if(num < 2) newStat = '-';//dead less than 2 living neighbours
		else if(num <= 3) cout << "ok"; //do nothing status is already alive
		else newStat = '-';//dead greater than 3 living neighbours
		}
		else{
			if(num == 3) newStat = 'X'; // dead to alive
		}
		return newStat;
}


void checkAdjCells(int rows, int cols, int cIndex, Cell A[])
	{
		int i, j, iIndex, jIndex, count = 0;
		iIndex = cIndex/cols; //row index
		jIndex = cIndex%cols; // col index
		for(i = iIndex-1; i <= iIndex+1; i++)
		{
			for (j = jIndex-1; j <= jIndex+1; j++) //Each line ends with newline character \n (Unix formatting)
			{
				// i<0 can't have negative index
				//i>rows j > cols can't have index larger than array Max
				if(i>=0 && i<=rows && j >=0 && j<= cols && A[i*cols+j].status == 'X' && (i*cols+j!= cIndex)) count++;
			}
		}
		A[cIndex].count = count;
	}

for(int m = 0; m < 5; m++){
	for(i = 0; i < rows; i++)
		{
			for(j = 0; j<cols; j++)
			{   
				cIndex = i*cols+j;
				C[cIndex]= checkAdjCells(rows,cols,cIndex, S);
				cout << S[cIndex] << C[cIndex];
				//cout << A[i *cols + j].getStatus();
			}
			cout << endl;
		}
	cout << endl;
	for(i = 0; i < rows; i++)
			{
				for(j = 0; j<cols; j++)
				{   
					cIndex = i*cols+j;
					S[cIndex] = setStatus(C[cIndex], S[cIndex]);
					//cout << A[i *cols + j].getStatus();
					cout << S[cIndex] << C[cIndex];
				}
				cout << endl;
			}
}
	
	cout << endl;
	cout << endl;
	fin.close();
*/
