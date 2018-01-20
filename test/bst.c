int a[100],n;
int printint(int x);
int dfs(int in){
	printint(in);
	int x=2*in;
	int y=x+1;
	if(x<n)dfs(x);
	if(y<n)dfs(y);
	return 1;
}
int main(){
	n=10;
	dfs(1);
}