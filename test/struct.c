struct node{
	int x;
	int y;
}
int printint(int a);
int println();
struct node f(struct node a){
	int x,y;
	x=a.x;
	y=a.y;
	printint(x);printint(y);println();
	a.x=3;
	a.y=4;
	return a;
}

int main(){
	struct node a;
	int x,y;
	a.x=1;
	a.y=2;
	a=f(a);
	x=a.x;
	y=a.y;
	printint(x);printint(y);println();

	return 0;
}