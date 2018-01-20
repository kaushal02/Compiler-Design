//a
/*
symbol table all vars together
a=b+c
$t1 = getreg(a);
mov $t1, xx($fp);
$t2=getreg(b);
add $t1, $t2;
$t1 contains a , a in $t1
*/
//#include <bindconfig2.y>

map< string, string> reg;
map< string, string > add;	//which all regs is var contained in
vector< string> freereg;
string s1, s2, s3; 	//in use
int cur;	//current line number
string getreg(string a){
	if(addr.find(a))return addr[a];
	if(freereg.size()){
		string x = freereg[0];
		add[a]=x;
		reg[x]=a;
		freereg.remove(x);
		cout<<"move "<<x<<' '<< to_string(lookup(a).offset)+"($fp)";
		return x;
	}
	/*{
		string tmp="";
		for(auto x:args )if(nextuse(x)<cur and add.count(x))tmp=x;
		for(auto x:vars )if(nextuse(x)<cur and add.count(x))tmp=x;
		if(tmp!=""){
			reg[add[tmp]]=a;
			add[a]=add[tmp];
			add.remove(tmp);
			return add[a];
		}
	{
		for(auto x: reg){
			if((x.Y)!=s1 and (x.Y)!=s2 and (x.Y)!=s3){
				sw x.X, to_string(lookup(a).offset)+"($fp)"
				add.remove(x.Y);
				reg[x.X]=a;
				add[a]=x.X;
				return x.X;
			}
		}
	}*/

	}
}
/*
getreg (str a){
	if a in  reg return register
	else take any free reg if available
	else go over all ti, if no nextuse, return that reg
	else take some variable  (not  ti), store to it's mem location, return it's reg
	else take some ti, move to memory, return that reg
}
*/

int myfunc()){

	freopen("code.s","w",stdout);

	/*
	for(cur=nextquad-1; cur>=0; cur--){
		for(auto x: quadArray[cur]){
			if(lookup(x).X)lastuse[x]=max(lastuse[x], cur);
		}
	}
	*/


	for(cur =0; cur<nextquad; cur++){
		quad x = quadArray[cur];
		if(x.typ==5){	//a = b op c
			string s1 = getreg(a);
			string s2 = getreg(b);
			string s3 = getreg(c);
			cout<< op <<' '<< s1 <<' '<< s2 <<' '<< s3;


		}
	} 
	return 0;
}