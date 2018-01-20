int printint(int i);
int println();

int main() {
    int i, j, k, x, y, z;
    i=1, j=2, k=3;
    x=(i+j+k)*(j+k/i)+i; // x = (1+2+3)*(2+3/1)+1 = 6*5+1 = 31
    y=(x/2)*2+i; // y = (31/2)*2+1 = 15*2+1 = 31
    
    if(x==y) z=1;
    else z=2;
    printint(z);
    return 0;
}