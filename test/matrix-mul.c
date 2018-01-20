
int main() {
  	
 int i, j, k, temp, ans, x, y;
int printint(int i);
int println();
int arr[100];

	int num=7;
	for(i=0; i<7; i=i+1) {
		int x=7-i;
		arr[i]=x;
	    printint(x);println();
	}
	
	for(i=0; i<3; i=i+1) {
		//printint(i);printint(i);println();
	    for(j=0; j<3; j=j+1) {
	        if(i==j) {
	            b[i][j] = 2;
	        }
	        else {
	            b[i][j] = 0;
	        }
	        x=b[i][j];
	        printint(x);println();
	    }
	    printint(i);printint(i);println();
	}
	for(i=0; i<3; i=i+1) {
	    for(j=0; j<3; j=j+1) {
		    temp=0;
		    for(k=0; k<3; k=k+1) {
		        x=a[i][k];
	            y=b[k][j];
	            temp = temp+ x*y;
		    }
		    c[i][j]=temp;
		    printint(temp);println();
	    }
	    printint(i); printint(i); println();
    }


	  ans=0; for(i=0; i<3; i=i+1) {temp=c[0][i]; ans=100*ans+temp;} printint(ans); println();
	  ans=0; for(i=0; i<3; i=i+1) {temp=c[1][i]; ans=100*ans+temp;} printint(ans); println();
	  ans=0; for(i=0; i<3; i=i+1) {temp=c[2][i]; ans=100*ans+temp;} printint(ans); println();
  return 0;
}
