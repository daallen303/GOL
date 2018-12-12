#include <iostream>
#include <fstream>

using namespace std;


class Cell{
	private:
	char status;
	int count;

	public:

	void setCount(int num)
	{
		count = num;
	}
	void initStatus(char c)
	{
		status = c;
	}
	void setStatus(int num) //Each line ends with newline character \n (Unix formatting)
	{
		if(status == 'X') //check if it's alive
		{
		if(num < 2) status = '-';//dead less than 2 living neighbours
		else if(num <= 3) cout << "ok"; //do nothing status is already alive
		else status = '-';//dead greater than 3 living neighbours
		}
		else{
			if(num == 3) status = 'X'; // dead to alive
		}
	}
	char getStatus()
	{
	   return status;
	}
	int getCount()
	{
		return count;
	}


};

int checkAdjCells(int rows, int cols, int cIndex, Cell A[])
	{
	cout <<cIndex << endl;
		int i, j, iIndex, jIndex, count = 0;git@git.aetheris.co:daniel.allen/Cuda_GOL.git
		iIndex = cIndex/cols; //row index
		jIndex = cIndex%cols; // col index
		for(i = iIndex-1; i <= iIndex+1; i++)
		{
			cout << "i = " << i << endl;
			for (j = jIndex-1; j <= jIndex+1; j++)
			{
				cout << "j = " << j << endl;
				// i<0 can't have negative index
				//i>rows j > cols can't have index larger than array Max
				if(i>=0 && i<=rows && j >=0 && j<= cols && A[i*cols+j].getStatus() == 'X' && (i*cols+j!= cIndex)) count++;
			}
		}
		return count;
	}


int main()
{
	int rows = 10;
	int cols = 10;
	int i,j, cIndex;
	char temp;
	Cell A[cols*rows];

	ifstream fin;
	fin.open("./input.txt");
	for(i = 0; i < rows; i++)
		for(j = 0; j<cols; j++)
		{
			fin >> temp;
			cIndex = i*cols+j;
			A[cIndex].initStatus(temp);
			A[cIndex].setCount(0);
			cout << A[i *cols + j].getStatus();
		}
					A[23].setCount(checkAdjCells(rows,cols,23, A));
					cout << "Status " << A[23].getStatus() << " Count" << A[23].getCount();
	fin.close();
cin.get();
	//cudaMallocManaged(sizeof(char)*rows*cols);
	//cudaMemcpy(hostToDevice)

}
