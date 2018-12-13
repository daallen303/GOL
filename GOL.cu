#include <iostream>
#include <fstream>

using namespace std;


__global__
void callCheck(int rows, int cols,char A[], int B[])
{
	int i, k, j, count, iIndex, jIndex;
    i = blockIdx.x * blockDim.x + threadIdx.x; //index of current thread
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
						if(k>=0 && k<=rows && j >=0 && j<= cols && A[k*cols+j] == 'X' && (k*cols+j!= i)) count++;
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
	int rows = 10;
	int cols = 10;
	int i,j, cIndex;
	char temp;
	
	// two sepreate array coalesced reads cuda
	char S[rows*cols];
	int C[rows*cols];
	ifstream fin;
	fin.open("./input.txt");
	
	for(i = 0; i < rows; i++)
	{
		for(j = 0; j<cols; j++)
		{   
			fin >> temp;
			cIndex = i*cols+j;
			S[cIndex]= temp;
			C[cIndex]= -1;
			
			//cout << A[i *cols + j].getStatus();
		}
		cout << endl;
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

				//	A[23].setCount(checkAdjCells(rows,cols,23, A));
				//	cout << "Status " << A[23].getStatus() << " Count" << A[23].getCount();
	}
	int l = 0;
	while(l< 10){
		        //     <<<number of blocks, number of threads per block>>>
	callCheck<<<1,100>>>(rows, cols, A, B);
	cudaDeviceSynchronize();
	for(i = 0; i < rows; i++)
		{
				
				for(j = 0; j<cols; j++)
				{   
					
					cudaMemcpy(&S[i*cols+j], &A[i*cols+j], sizeof(char), cudaMemcpyDeviceToHost);
					cudaMemcpy(&C[i*cols+j], &B[i*cols+j], sizeof(int), cudaMemcpyDeviceToHost);
					//cout << i*cols+j << " index " << S[i*cols+j] << " status " << C[i*cols+j] << " count " << endl;
					cout << S[i*cols+j];
				}
				cout << endl;
					//	A[23].setCount(checkAdjCells(rows,cols,23, A));
					//	cout << "Status " << A[23].getStatus() << " Count" << A[23].getCount();
		}
	cout << endl;
	cout << endl;
	l++;
	}
	cudaFree(A);
	cudaFree(B);
	
	cin.get();
	//cudaMallocManaged(sizeof(char)*rows*cols);
	//cudaMemcpy(hostToDevice)

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
