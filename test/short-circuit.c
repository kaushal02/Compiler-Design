int printint(int a);
int scanint();

int main(){
	int x,y;
	x=scanint();
	y=scanint();
	if(x==1 || y==2){
		x=x+1;
		y=y+1;
	}
	int a=1*2/3;
	printint(x);
	printint(y);
	return 0;
}