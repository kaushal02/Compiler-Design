int a[100];
int scanint();
int printint(int x);

int main(){

	int n,i,lo,hi,mi,qu,x,an;
	an=-1;
	n=scanint();
	for(i=0;i<n;i=i+1){
		x=i+2;
		a[i]=x;
	}
	qu=4;
	lo=0;
	hi=n-1;
	while(lo<hi){
		mi=(lo+hi)/2;
		x=a[mi];
		if(x==qu){
			an=-1;
			break;
		}
		else if(x>qu)hi=mi-1;
		else lo=mi+1;
	}
	x=a[lo];
	if(x==qu)an=lo;
	printint(an);
}