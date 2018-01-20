int printint(int i);
int println();

int bigsum(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j) {
    int sum;
    sum = a+b+c+d+e+f+g+h+i+j;
    return sum;
}

int main() {
    int x;
    x=bigsum(1,2,3,4,5,6,7,8,9,10);
    printint(x);
    return 0;
}