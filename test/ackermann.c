int scanint();
int printint(int i); 
int println();
int ackermann(int m, int n)
{      
        if (m==0) return n + 1;
        if (n==0) return ackermann(m - 1, 1);
       // printint(m);printint(n);println();
        int x=ackermann(m, n - 1);
        return ackermann(m - 1, x);
}


int main()
{
        int m, n;
        int x;
        m=1;
        n=2;
        x=ackermann(m,n);
        printint(x);
 
        return 0;
}

