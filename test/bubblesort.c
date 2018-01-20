int printint(int i);
int println();
int arr[100];
int i, n, ans, j, temp, x, y;
int main() {
	
    
    for(i=0; i<9; i=i+1) arr[i]=9-i;
    n=3;
    for(i=0; i<n-1; i=i+1){  
        printint(i);println();
        // Last i elements are already in place   
        for(j=0; j<n-i-1; j=j+1) {
            x=arr[j]; y=arr[j+1];
            printint(j);    printint(x); printint(y); println();
            if( x > y) {
                temp = arr[j];
                x=arr[j+1];
                arr[j] = x;
                arr[j+1] = temp;
            }
            x=arr[j]; y=arr[j+1];
             printint(j); printint(j);printint(x); printint(y); println();
        }
        printint(i);println();
    }
    ans=0;
    for(i=0; i<n; i=i+1) {
        x=arr[i];
        ans=10*ans+x;
    }
    printint(ans);
    return 0;
}