int printint(int i);
int println();

int main() {
    int i, j, k;
    i=1, j=2, k=3;
    while(i<5) {
        if(j>2) {
            if(k<2) continue;
            else if(k<4) break;
            else {
                for(k=5; k<10; k=k+1) {
                    if(i==5) break;
                    j=j+10;
                }
            }
        }
        else {
            j=j+1;
        }
        i=i+2;
    }
    return 0;
}
