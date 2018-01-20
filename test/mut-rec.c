int scanint();
int printint(int i);

int b(int n);
int a(int n) {
	if(n<=1) return n;
	else return b(n-1)+1;
}
int b(int n) {
	if(n<=2) return n;
	else return a(n-1)+1;
}

int main() {
	int n, ans;
	n=scanint();
	ans=a(n);
	printint(ans);
	return 0;
}