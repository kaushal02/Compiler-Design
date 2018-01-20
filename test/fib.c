int scanint();
int printint(int x);
int println();

int main(){
	int x,y,tmp,i;
	int n;
	x=1;
	y=1;
	tmp=1;
	n=8;
	for(i=2;i<=n;i=i+1){
		tmp=x+y;
		y=x;
		x=tmp;
	}
	printint(tmp);
	return 0;
}