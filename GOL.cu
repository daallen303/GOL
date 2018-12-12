#include <iostream>
#include <fstream>

using namespace std;


struct Cell{
	char status;
	int count;
};


/*
char getStatus()
{
	return status;
}
int getCount()
{
	return count;
}
void setCount(int num)
{
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
*/
__global__
void callCheck(int rows, int cols,Cell A[])
{
	int i, k, j, count, iIndex, jIndex;
	char newStat;
    int index = blockIdx.x * blockDim.x + threadIdx.x; //index of current thread
	//int stride = blockDim.x *gridDim.x; total threads grid striping
	for(i = index; i < cols*rows; i++) 
			{
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
						if(k>=0 && k<=rows && j >=0 && j<= cols && A[i*cols+j].status == 'X' && (k*cols+j!= i)) count++;
					}
				}
				A[i].count = count;
				newStat = A[i].status;
						if(newStat == 'X') //check if it's alive
						{
						if(count < 2) newStat = '-';//dead less than 2 living neighbours
						else if(count <= 3) newStat = 'X'; //do nothing status is already alive
						else newStat = '-';//dead greater than 3 living neighbours
						}
						else{
							if(count == 3) newStat = 'X'; // dead to alive
						}
				A[i].status = newStat;
			}
}	


int main()
{
	int rows = 10;
	int cols = 10;
	int i,j, cIndex;
	char temp;
	
	Cell *A;
	cudaMallocManaged(&A, rows*cols*(8)); //allocates bytes from device heap and returns pointer to allocated memory or null
	ifstream fin;
	fin.open("./input.txt");
	
	for(i = 0; i < rows; i++)
		for(j = 0; j<cols; j++)
		{   
			fin >> temp;
			cIndex = i*cols+j;
			A[cIndex].status = temp;
			A[cIndex].count = 0;
			//cout << A[i *cols + j].getStatus();
		}
	
	callCheck<<<1,1>>>(rows, cols, A);
	cudaDeviceSynchronize();
	cudaFree(A);
				//	A[23].setCount(checkAdjCells(rows,cols,23, A));
				//	cout << "Status " << A[23].getStatus() << " Count" << A[23].getCount();
	fin.close();
cin.get();
	//cudaMallocManaged(sizeof(char)*rows*cols);
	//cudaMemcpy(hostToDevice)

}
