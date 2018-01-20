%expect 2

%{
#include <bits/stdc++.h>
#include "structdef.h"
using namespace std;

extern int yylineno;
typedef vector<int> vi;

//#define copy(v1, v2) copy(v2.begin(), v2.end(), back_inserter(v1))
#define err(x) cerr<<#x<<" = "<<x<<'\n'
#define pb push_back
#define X first
#define Y second

ofstream cbug("out/kbug.out");

map<string, int> func; //maps functions and structs to their symbol table ids (in arr)
struct ST;
map<int, int > func_sz;

int type_error=0;
int scope_fl = 0;
struct entry {
	string dt;
	string val;
	int ptr;
	int dimn;
	int sz;
	vector<string> dim;
	string dotstruct;//for a.x
	int offset;
	void assign(string dtt, int ptrr = 0, int dimnn=0, int nestt = 0, vector<string> dimm = vector<string>()) {
		dt=dtt;
		ptr=ptrr;
		dimn=dimnn;//.size();
		dim=dimm;
	}
	string pr() {
		string ret=dt;
		for(int j=0;j<ptr;j++) ret+="*";
		int k=0;
		if(dimn!=dim.size())k=-1;
		for(int j=0;j<dimn;j++) ret+="["+(((j-k)>=0)?dim[j-k]:"")+"]";
		return ret;
	}
	int siz() {
		if(ptr>0) return sz=8;
		int tmp=1;
		for(auto x:dim)tmp=tmp*stoi(x);
		if(dt == "INT") return sz=tmp*sizeof(int);
		if(dt == "CHAR") return sz=tmp*sizeof(char);
		if(dt == "FLOAT") return sz=tmp*sizeof(float);
		return (func_sz[func[dt]])*tmp;
		return sz;
	}
};

struct entry2 {
	string name;
	entry e;
};

typedef struct treeNode {
	char* label;
	int count;
	int id;
	treeNode** children;
} TREE_NODE;

// Type of $
struct entry3 {
	string name;
	entry e;
	string place;
	vector<entry2> v;
	TREE_NODE* tVal;
	vi nextList, trueList, falseList, breakList, continueList;
	void assign(string namee, entry ee = {""}, string placee="", vector<entry2> vv = vector<entry2>()) {
		name=namee;
		e=ee;
		v=vv;
		place=placee;
	}
	void operator=(entry3 y) {
		name=y.name;
		e=y.e;
		v=y.v;
	}
	void prv(string s="") {//print v
		// cerr<<"entry3 vector: "<<s<<"\n";
		// for(auto x:v){cerr<<x.name<<" "<<x.e.pr()<<"\n";}
	}
	string pr(string s="") {
		string ret="";
		ret+="entry3 pr: "+s+"\n";
		ret+=name+" "+e.pr()+"\n";
		ret+="v.size()== "+to_string(v.size())+"\n";
		return ret;
	}
};

struct ST {	//symbol table- kinda generic- args and return value for function.
	int par;
	vector<entry2> arg;
	int def;
	entry ret;
	string name;  //function/node
	int offset; // within parent's scope
	int negoff;
	int sz;
	map<string, entry> var;	//maps variable names to datatype (for structs also), used in global vars, local vars, struct vars, function vars
};

ST arr[1024];
int curST=1, totST=2;	// GST = 1;


pair<bool, entry> lookup(string id, int in=curST) {	//returns yes/no, type of queried identifier
	if(in==0) return {0, {}};
	if(arr[in].var.count(id)) return {1, (arr[in].var)[id]};
	for(auto x: arr[in].arg)if(x.name==id) return{1, x.e};
	return lookup(id, arr[in].par);
}
pair<bool, entry> lookup2(string id, int in=curST) {	//returns yes/no, type of queried identifier
	if(in==0) return {0, {}};
	if(arr[in].var.count(id)) return {1, (arr[in].var)[id]};
	for(auto x: arr[in].arg)if(x.name==id)return{1,x.e};
	return {0, {}};
}
void insert(string id, entry en, int in = curST){	//insert to symbol table
	//cerr<<"inserting "<<id<<' '<<en.dt<<" in "<<in<<endl;
	if(in!=1){while(arr[in].par!=1)in=arr[in].par;}	//todo

	en.offset=arr[in].offset;
	arr[in].offset+=en.siz();
	func_sz[in]+=abs(en.siz());
	//cerr<<"got sz "<<en.siz()<<" "<<en.dt<<" "<<in<<endl;
	(arr[in].var)[id]=en;
	//cerr<<id<<' '<<en.offset<<endl;
	//activation-record;
	// Kaushal

}
////typecheck
map<string, int> prio;
map<int, string> rprio;

bool sametype(entry e1, entry e2) {
	if((e1.ptr==0 and e1.dimn ==0 and e1.dt.find("STRUCT")==0) or( e2.ptr==0 and e2.dimn ==0 and  e2.dt.find("STRUCT")==0))return e1.dt==e2.dt;
	if(e1.ptr + e1.dimn == e2.ptr + e2.dimn) {
		if(prio[e1.dt] < 8 and prio[e2.dt] < 8) return true;
		else if(e1.dt == e2.dt) return true;
		else return false;
	}
	return false;
}

bool exacttype(entry e1, entry e2) {
	return (e1.ptr==e2.ptr and e1.dimn==e2.dimn and e1.dt==e2.dt);
}

// quad and related
set<string> gotos;
struct quad{
	vector<string> v;
	int typ;
};
quad quadArray[10000];
int nextQuad;
entry& eref(string s) {
	return arr[curST].var[s];
}
// void gen(vector<string> v, int type){
// 	int sz=v.size();
// 	entry e, &e0=e, &e1=e, &e2=e, &e3=e;
// 	if(sz>0) e0=eref(v[0]);
// 	if(sz>1) e1=eref(v[1]);
// 	if(sz>2) e2=eref(v[2]);
// 	if(sz>3) e3=eref(v[3]);
// 	switch(type) {
// 		case 1:
// 				e0.val=v[1];
// 				break;
// 		case 2:
// 				if(e1.val!="") {
// 					gen({v[0], e1.val}, 1);
// 					return;
// 				}
// 				break;
// 		case 5:
// 				if(e1.val!="" and e3.val!="") {
// 					string op = e2.val;
// 					if(op == "+") {
// 						gen({v[0], to_string(stoi(e1.val)+stoi(e3.val))}, 1);
// 					}
// 					else if(op == "-") {
// 						gen({v[0], to_string(stoi(e1.val)-stoi(e3.val))}, 1);
// 					}
// 					else if(op == "*") {
// 						gen({v[0], to_string(stoi(e1.val)*stoi(e3.val))}, 1);
// 					}
// 					else if(op == "/") {
// 						gen({v[0], to_string(stoi(e1.val)/stoi(e3.val))}, 1);
// 					}
// 					else break;
// 				}
// 				break;
// 		case 7:
// 				if(e0.val!="" and e2.val!="") {
// 					string op = e1.val;
// 					if(op == "<") {
// 						if(e0.val >= e2.val) gen({""}, 6);
// 						else if(v.size()>3) gen({v[3]}, 6);
// 						else gen({}, 6);
// 					}
// 					else if(op == "<=") {
// 						if(e0.val > e2.val) gen({""}, 6);
// 						else if(v.size()>3) gen({v[3]}, 6);
// 						else gen({}, 6);
// 					}
// 					else if(op == ">") {
// 						if(e0.val <= e2.val) gen({""}, 6);
// 						else if(v.size()>3) gen({v[3]}, 6);
// 						else gen({}, 6);
// 					}
// 					else if(op == ">=") {
// 						if(e0.val < e2.val) gen({""}, 6);
// 						else if(v.size()>3) gen({v[3]}, 6);
// 						else gen({}, 6);
// 					}
// 					else if(op == "==") {
// 						if(e0.val != e2.val) gen({""}, 6);
// 						else if(v.size()>3) gen({v[3]}, 6);
// 						else gen({}, 6);
// 					}
// 					else if(op == "!=") {
// 						if(e0.val == e2.val) gen({""}, 6);
// 						else if(v.size()>3) gen({v[3]}, 6);
// 						else gen({}, 6);
// 					}
// 					else break;
// 				}
// 				break;

// 	}
// 	quadArray[nextQuad++]={v,type};
// }

void gen(vector<string> v, int type){
	quadArray[nextQuad++]={v,type};
}

vi merge(vi v1, vi v2){
	copy(v2.begin(), v2.end(), back_inserter(v1));
	return v1;
}
void backpatch(vi l, int in){
	for(auto x:l){
		quadArray[x].v.pb(to_string(in));
	}
}
// newtmp
int nextvar;
string newtmp(entry e={}) {
	string name = "t" + to_string(nextvar++);
	insert(name, e);
	return name;
}
void quadclean(vi rmv={}) {
	if(rmv.empty()) rmv=vi(nextQuad, 0);
	vi ext(nextQuad), valid(nextQuad);
	for(int i=0; i<nextQuad; i++) {
		ext[i] = (i?ext[i-1]:0);
		if(rmv[i]) valid[i]=0, ext[i]++;
		else if(quadArray[i].typ==6 and quadArray[i].v[0]=="") valid[i]=0, ext[i]++;
		else if(quadArray[i].typ==7 and quadArray[i].v[3]=="") valid[i]=0, ext[i]++;
		else valid[i]=1;
	}
	vector<quad> quadcopy(nextQuad);
	int j=-1; for(int i=0; i<nextQuad; i++) {
		if(valid[i]) {
			j++;
			quadcopy[j]=quadArray[i];
			if(quadArray[i].typ==6 or quadArray[i].typ==7) {
				int k;
				if(quadArray[i].typ==6) k=0;
				if(quadArray[i].typ==7) k=3;
				int x = stoi(quadArray[i].v[k]);
				quadcopy[j].v[k] = to_string(x - ext[x] + !valid[x]);
			}
		}
	}
	nextQuad = j+1;
	for(int i=0; i<nextQuad; i++) quadArray[i] = quadcopy[i];
}
int joj() {
	int diff=0;
	for(int i=0; i<nextQuad; i++) {
		if(quadArray[i].typ==6 or quadArray[i].typ==7) {
			int k;
			if(quadArray[i].typ==6) k=0;
			if(quadArray[i].typ==7) k=3;
			int x = stoi(quadArray[i].v[k]);
			// assert(x>=0 and x<nextQuad and x!=i);
			if(quadArray[x].typ==6) {
				int y = stoi(quadArray[x].v[0]);
				if(stoi(quadArray[i].v[k]) != y) {
					quadArray[i].v[k] = to_string(y);
					diff++;
				}
			}
		}
	}
	return diff;
}
void jojclean() {
	vi ujump(nextQuad+1, 0), ref(nextQuad+1, 0);
	for(int i=0; i<nextQuad; i++) {
		if(quadArray[i].typ==6) ref[stoi(quadArray[i].v[0])] = ujump[i] = 1;
		if(quadArray[i].typ==7) ref[stoi(quadArray[i].v[3])] = 1;
	}
	for(int i=0; i<nextQuad; i++) ujump[i] &= !ref[i];
	for(int i=nextQuad; --i; ) ujump[i] &= ujump[i-1];
	quadclean(ujump);
	
	vi ejump(nextQuad, 0);
	for(int i=0; i<nextQuad; i++) if(quadArray[i].typ==6 and quadArray[i].v[0]==to_string(i+1)) ejump[i] = 1;
	quadclean(ejump);
}
// void print_quad() {
// 	ofstream fout("out/dumpQUAD.out");
// 	for(int i=0; i<nextQuad; i++) quadArray[i].v.pb("");
	
// 	// quadclean();
// 	// while(joj());
// 	// jojclean();

// 	for(int i=0; i<nextQuad; i++) {
// 		auto v=quadArray[i].v;
// 		switch(quadArray[i].typ) {
// 			case 1: // t1 = 3
// 					fout << i << ": " << v[0] << " = " << v[1] << "\n";
// 					break;
// 			case 2: // a = t1
// 					fout << i << ": " << v[0] << " = " << v[1] << "\n";
// 					break;
// 			case 3: // a = (to INT) t1
// 					fout << i << ": " << v[0] << " =" << v[1] << " " << v[2] << "\n";
// 					break;
// 			case 4: // a = op t1
// 					fout << i << ": " << v[0] << " = " << v[1] << v[2] << "\n";
// 					break;
// 			case 5: // a = t1 op t2
// 					fout << i << ": " << v[0] << " = " << v[1] << " " << v[2] << " " << v[3] << "\n";
// 					break;
// 			case 6: // goto a
// 					if(v[0]!=""){
// 						fout << i << ": " << "goto " << v[0] << "\n";
// 						gotos.insert(v[0]);
// 					}
// 					break;
// 			case 7: // if(a relop b) goto c
// 					if(v[3]!=""){
// 						fout << i << ": " << "if (" << v[0] << " " << v[1] << " " << v[2] << ") goto " << v[3] << "\n";
// 						gotos.insert(v[3]);
// 					}
// 					break;
// 			case 8: // param a
// 					fout << i << ": param " << v[0] << "\n";
// 					break;
// 			case 9: // call f 3
// 					fout << i << ": call " << v[0] << " " << v[1] << "\n";
// 					break;
// 			case 10: // *x = y
// 					fout << i << ": * " << v[0] << " = " << v[1] << "\n";
// 					break;
// 			case 11: //a[i] = b
// 					fout << i << ": " << v[0] << "["<<v[1]<<"]"<<" = " << v[2] << "\n";
// 					break;
// 			case 12: //func :
// 					fout<<v[0]<<" :"<<endl;
// 					break;
// 			case 13: //func_endl :
// 					fout<<v[0]<<"_end :"<<endl;
// 					break;
// 			case 14: //func_endl :
// 					fout<< i << ": "<<"return "<<v[0]<<endl;
// 					break;
// 			case 15: //func_endl :
// 					fout<< i << ": "<<"return"<<endl;
// 					break;
// 			case 16: //func_endl :
// 					fout<< i << ": "<<v[0]<< " = "<<v[1]<<endl;
// 					break;
// 			default:
// 					fout << i << ": " << "HANDLE THIS "<<quadArray[i].typ<<endl;
// 		}
// 	}
// }

void print_quad() {
	ofstream fout("out/dumpQUAD.out");
	for(int i=0; i<nextQuad; i++) quadArray[i].v.pb("");
	
	quadclean();
	while(joj());
	jojclean();

	for(int i=0; i<nextQuad; i++) {
		quadArray[i].v.pb("");
		auto v=quadArray[i].v; 
		switch(quadArray[i].typ) {
			case 1: // t1 = 3
					fout << i << ": " << v[0] << " = " << v[1] << "\n";
					break;
			case 2: // a = t1
					fout << i << ": " << v[0] << " = " << v[1] << "\n";
					break;
			case 3: // a = (to INT) t1
					fout << i << ": " << v[0] << " =" << v[1] << " " << v[2] << "\n";
					break;
			case 4: // a = op t1
					fout << i << ": " << v[0] << " = " << v[1] << v[2] << "\n";
					break;
			case 5: // a = t1 op t2
					fout << i << ": " << v[0] << " = " << v[1] << " " << v[2] << " " << v[3] << "\n";
					break;
			case 6: // goto a
					if(v[0]!=""){
						fout << i << ": " << "goto " << v[0] << "\n";
						gotos.insert(v[0]);
					}
					break;
			case 7: // if(a relop b) goto c
					if(v[3]!=""){
						fout << i << ": " << "if (" << v[0] << " " << v[1] << " " << v[2] << ") goto " << v[3] << "\n";
						gotos.insert(v[3]);
					}
					break;
			case 8: // param a
					fout << i << ": param " << v[0] << "\n";
					break;
			case 9: // call f 3
					fout << i << ": call " << v[0] << " " << v[1] << "\n";
					break;
			case 10: // *x = y
					fout << i << ": * " << v[0] << " = " << v[1] << "\n";
					break;
			case 11: //a[i] = b
					fout << i << ": " << v[0] << "["<<v[1]<<"]"<<" = " << v[2] << "\n";
					break;
			case 12: //func :
					fout<<v[0]<<" :"<<endl;
					break;
			case 13: //func_endl :
					fout<<v[0]<<"_end :"<<endl;
					break;
			case 14: //func_endl :
					fout<< i << ": "<<"return "<<v[0]<<endl;
					break;
			case 15: //func_endl :
					fout<< i << ": "<<"return"<<endl;
					break;
			case 16: //func_endl :
					fout<< i << ": "<<v[0]<< " = "<<v[1]<<endl;
					break;
			case 17: //func_endl :
					fout<< i << ": "<<v[0] << " = "<<v[1]<<"["<<v[2]<<"]" << "\n";
					break;
			case 18: //func_endl :
					fout<< i << ": "<<v[0] << "."<<v[1]<<" = "<<v[2]<< "\n";
					break;
			case 19: //func_endl :
					fout<< i << ": "<<v[0] << " = "<<v[1]<<"."<<v[2]<< "\n";
					break;
			default:
					fout << i << ": " << "HANDLE THIS "<<quadArray[i].typ<<endl;
		}
	}
}

set<char*> nonterminals= {"declaration_list", "function_definition", "external_declaration", "translation_unit", "jump_statement", "iteration_statement", "selection_statement", "expression_statement", "block_item", "block_item_list", "compound_statement", "labeled_statement", "statement", "static_assert_declaration", "designator", "designator_list", "designation", "initializer_list", "initializer", "direct_abstract_declarator", "abstract_declarator", "type_name", "identifier_list", "parameter_declaration", "parameter_list", "parameter_type_list", "type_qualifier_list", "pointer", "direct_declarator", "declarator", "alignment_specifier", "function_specifier", "type_qualifier", "atomic_type_specifier", "enumerator", "enumerator_list", "enum_specifier", "struct_declarator", "struct_declarator_list", "specifier_qualifier_list", "struct_declaration", "struct_declaration_list", "struct_or_union", "struct_or_union_specifier", "type_specifier", "storage_class_specifier", "init_declarator", "init_declarator_list", "declaration_specifiers", "declaration", "constant_expression", "expression", "assignment_operator", "assignment_expression", "conditional_expression", "logical_or_expression", "logical_and_expression", "inclusive_or_expression", "exclusive_or_expression", "and_expression", "equality_expression", "relational_expression", "shift_expression", "additive_expression", "multiplicative_expression", "cast_expression", "unary_operator", "unary_expression", "argument_expression_list", "postfix_expression", "generic_association", "generic_assoc_list", "generic_selection", "string", "enumeration_constant", "constant", "primary_expression", "head"};

int id=0; //for dot file label
TREE_NODE* create_node(char* label, TREE_NODE** child, int count) {
	if(strlen(label)==0) {
		assert(count==1);
		return child[0];
	}
	if(count==1 and nonterminals.count(label)) return child[0];
	TREE_NODE* my = (TREE_NODE*)malloc(sizeof(TREE_NODE));
	my->label=(char*)malloc(strlen(label)+1);
	strcpy(my->label, label);
	my->count = count;
	my->id = id++;
	my->children = (TREE_NODE**)malloc(sizeof(TREE_NODE*)*count);
	int i; for(i=0; i<count; i++) (my->children)[i]=child[i];
	return my;
}
TREE_NODE* create_node(string label, TREE_NODE** child, int count) {
	int sz=label.size();
	char *Label=(char*)malloc(label.size()+1);
	strcpy(Label, label.c_str());
	return create_node(Label, child, count);
}

int check_print(char* label) {
	if(label == "IDENTIFIER") return 1;
	if(label == "I_CONSTANT") return 1;
	if(label == "F_CONSTANT") return 1;
	if(label == "STRING_LITERAL") return 1;
	return 0;
}
int check_string(char* label) {
	return (label == "STRING_LITERAL");
}
TREE_NODE* create_leaf(char* label2, char* val) {
	TREE_NODE* ex[] = {};
	int sz=(check_print(label2) ? strlen(val):strlen(label2));
	if(check_string(label2)) sz += 2;
	char* label=(char*)malloc(sz+1);
	if(check_string(label2)) {
		strcpy(label, "\\");
		strcat(label, val);
		label[sz-2]='\\';
		label[sz-1]='\"';
	}
	else if(check_print(label2)) {
		strcpy(label, val);
	}
	else {
		strcpy(label, label2);
	}
	return create_node(label, ex, 0);
}
void dfs(TREE_NODE* t) {
	if(t == NULL) return;
	int i, sz=t->count;
	for(i=0; i<sz; i++) {
		printf("\t%d [label=\"%s\"];\n",(t->children[i])->id,(t->children[i])->label);
		printf("\t%d -> %d [arrowhead=open];\n",t->id,(t->children[i])->id);
	}
	for(i=0; i<sz; i++) dfs((t->children[i]));
	if(sz) printf("\t%d [color=gray30, shape=box];\n", t->id);
	else printf("\t%d [color=crimson];\n", t->id);
}
void print_tree(TREE_NODE* t) {
	printf("digraph myC {\n");
	printf("\t%d [label=\"%s\"];\n",t->id,t->label);
	dfs(t);
	printf("}");
}

string unOp(string op, entry e, bool &valid, entry3* &ret) {
	int x;
	string s=e.dt;
	if(e.ptr>0 or e.dimn>0) x=8;
	else if(s.find("STRUCT") != string::npos) x=10;
	else x=prio[s];

	valid=1;
	ret->e=e;
	s="";
	if(op == "+" or op == "-" or op == "!") {
		if(x>=8) valid=0, s="error: unary operator " + op + " not applicable on " + e.pr();
	}
	else if(op == "~") {
		if(x>1) valid=0, s="error: bitwise unary operator " + op + " not applicable on " + e.pr();
	}
	else if(op == "++" or op == "--") {
		if(x>8) valid=0, s="error: unary operator " + op + " not applicable on " + e.pr();
	}
	else if(op == "*") {
		if(ret->e.dimn>0)ret->e.dimn--;
		else ret->e.ptr--;
		if(ret->e.ptr<0) s="error: unary operator " + op + " not applicable on " + e.pr();
	}
	else if(op == "&") {
		if(ret->e.dimn>0)ret->e.dimn++;
		else ret->e.ptr++;
	}
	else assert(0);
	return s;
}
vector<string> binOp(string op, entry e1, entry e2, bool &valid, entry &ret) { //check type and stuff for e1 op e2
	int x, y;
	string s1=e1.dt, s2=e2.dt;
	if(e1.ptr>0 or e1.dimn>0) x=8;
	else if(s1.find("STRUCT") != string::npos) x=10;
	else x=prio[s1];

	if(e2.ptr>0 or e2.dimn>0) y=8;
	else if(s2.find("STRUCT") != string::npos) y=10;
	else y=prio[s2];

	valid=1;	//lets say default 1; will do valid = 0 whenever needed 	
	if(op=="+" or op=="-" or op=="*" or op=="/") {
		if(x==10 or y==10) {valid = false; return {};}	//no comput ops on struct	
		else if(max(x,y)==8 and min(x,y)<=1) {		//if one is ptr (and variants), other is int
			int tmp=max(x,y);
			ret = (x==8)?e1:e2;
			s1=s2="";
			if(x!=tmp) s1="to "+rprio[tmp];
			if(y!=tmp) s2="to "+rprio[tmp];
			return {rprio[tmp], s1, s2};
		}
		else if(x<8 and x>=0 and y<8 and y>=0) {		//both are int/float/double
			int tmp=max(1,max(x,y));
			ret = {rprio[tmp]};
			s1=s2="";
			if(x!=tmp) s1="to "+rprio[tmp];
			if(y!=tmp) s2="to "+rprio[tmp];
			return {rprio[tmp], s1, s2};
		}
		else {valid=false; return {};}
	}
	else if(op=="%" or op=="|" or op=="&" or op=="^" or op=="<<" or op==">>") {
		if(x>1 or y>1) {valid=false; return{};}
		else {
			int tmp=1;
			ret.assign("INT");
			s1=s2="";
			if(x!=tmp) s1="to "+rprio[tmp];
			if(y!=tmp) s2="to "+rprio[tmp];
			return {rprio[tmp], s1, s2};
		}
	}
	else if(op=="&&" or op=="||") {
		if(x==10 or y==10) {valid = false; return {};}	//no comput ops on struct	
		else {
			int tmp=1;
			ret.assign("INT");
			s1=s2="";
			return {rprio[tmp], s1, s2};
		}
	}
	else if(op=="<" or op==">" or op==">=" or op=="<=" or op=="==" or op=="!=") {
		if(x==10 or y==10) {valid = false; return {};}	//no comput ops on struct
		int tmp=max(x,y);
		ret.assign("INT");
		s1=s2="";
		if(x!=tmp) s1="to "+rprio[tmp];
		if(y!=tmp) s2="to "+rprio[tmp];
		return {rprio[tmp], s1, s2};
	}
	else if(op=="=" or op=="+=" or op=="-=" or op=="*=" or op=="/=" or op=="%=" or op=="|=" or op=="&=" or op=="^=" or op=="<<=" or op==">>=") {
		if(e1.dimn>0) {valid=false; return {};}
		else {
			if(x==10 or y==10) {
				if(e1.dt == e2.dt) {
					if(op == "=") {
						ret=e1;
						s1=s2="";
						return {e1.dt, s1, s2};
					}
					else {valid = false; return {};}
				}
				else {valid = false; return {};}
			}
			else if(op == "=" or op=="+=" or op=="-=" or op=="*=" or op=="/=") {
				int tmp=x;
				ret=e1;
				s1=s2="";
				// if(x!=tmp) s1="to-"+rprio[tmp];
				if(y!=tmp) s2="to "+rprio[tmp];
				//cerr<<"dhawal:: "<<tmp<<' '<<rprio[tmp]<<endl;
				return {rprio[tmp], s1, s2};
			}
			else if(op=="%=" or op=="|=" or op=="&=" or op=="^=" or op=="<<=" or op==">>=") {
				if(x>1 or y>1) {valid=false; return{};}
				else {
					int tmp=1;
					ret=e1;
					s1=s2="";
					// if(x!=tmp) s1="to "+rprio[tmp];
					if(y!=tmp) s2="to "+rprio[tmp];
					return {rprio[tmp], s1, s2};
				}
			}
			else assert(0);
		}
	}
	else assert(0);
	//else invalid op ??
}

string binError(string op) {
	if(op == "+")  return "addition operation";
	else if(op == "-")  return "subtraction operation";
	else if(op == "*")  return "multiplication operation";
	else if(op == "/")  return "division operation";
	else if(op == "%")  return "modulus operation";
	else if(op == "|")  return "or operation";
	else if(op == "&")  return "and operation";
	else if(op == "^")  return "xor operation";
	else if(op == "<<")  return "left shift operation";
	else if(op == ">>")  return "right shift operation";
	
	else if(op == "&&")  return "logical and operation";
	else if(op == "||")  return "logical or operation";
	
	else if(op == "<")  return "less than comparison";
	else if(op == ">")  return "greater than comparison";
	else if(op == "<=")  return "less than or equal to comparison";
	else if(op == ">=")  return "greater than or equal to comparison";
	else if(op == "==")  return "equality comparison";
	else if(op == "!=")  return "inequality comparison";

	else if(op == "=") return "assignment";
	else if(op == "+=") return "addition assignment";
	else if(op == "-=") return "subtraction assignment";
	else if(op == "*=") return "multiplication assignment";
	else if(op == "/=") return "division assignment";
	else if(op == "%=") return "modulus assignment";
	else if(op == "<<=") return "left shift assignment";
	else if(op == ">>=") return "right shift assignment";
	else if(op == "&=") return "and assignment";
	else if(op == "|=") return "or assignment";
	else if(op == "^=") return "xor assignment";
	
	// else if(op == ":") // ternary??
	else assert(0);
	return "";
}

// void binOperation(entry3* a, entry3* b, string op, entry3* &c) {
// 	//cout<<"called\n";
// 	c=new entry3;
// 	bool valid;
// 	vector<string> v = binOp(op, a->e, b->e, valid, c->e);
// 	if(!valid) {type_error=1;cerr << "error at line "<<yylineno<<": type mismatch in "<<binError(op)<<' '<<a->e.pr()<<' '<<b->e.pr()<<endl;}
// 	//cerr<<"\ndebug "<<op<<"#\n"<<valid<<'#'<<v[0]<<'#'<<v[1]<<'#'<<v[2]<<"#\n";
// 	//if c is array
// 	string t1="";
// 	if((a->v).size()!=0){
// 		t1=newtmp();
// 		int t1v=0;
// 		// entry &t1e=arr[curST].var[t1];
// 		int i=0;
// 		auto tm=lookup(a->place).Y.dim;
// 		int fl=0;
// 		for(auto x:a->v){
// 			// to_string(t1v*=stoi(tm[i++]));
// 			if(fl) {
// 				int t1v=t1e.val;
// 				if(t1e.val!="") {
// 					t1v=stoi(t1e.val);
// 					gen({t1, to_string(t1v*=stoi(tm[i++]))}, 1);

// 				}
// 				else {
// 					gen({t1, t1, "*", tm[i++]}, 5);
// 				}
// 			}
// 			if(fl) {
// 				entry ex=arr[curST].var[x.name];
// 				if(ex.val!="") {
// 					gen({t1, to_string(t1v+=stoi(ex.val))}, 1);
// 				}
// 				else {
// 					gen({t1, t1, "+", x.name}, 5);
// 				}
// 			}
// 			else gen({t1, x.name}, 1);
// 			fl=1;
// 		}
// 	}

// 	//
// 	while(v.size()<3) v.pb("");
// 	for(auto &x: v) if(x!="") x = " (" + x + ")";
	
// 	string s[2]={a->place, b->place};
// 	for(int i=1;i<=2;i++){
// 		if(v[i]!=""){
// 			entry tmp=i==1?a->e:b->e;
// 			tmp.dt=v[0];
			
// 			string t1=newtmp(tmp);
// 			s[i-1]=t1;
// 			gen({t1, v[i], i==1?a->place:b->place},3);//a=(toInt)b
// 		}
// 	}

// 	if(op == "=") {
// 		if(t1!="") gen({s[0], t1, s[1]}, 11); //a[i]=b;
// 		else gen({s[0], s[1]}, 2);	//a = b
		
// 	}
// 	else if(op=="+=" or op=="-=" or op=="*=" or op=="/=" or op=="%=" or op=="|=" or op=="&=" or op=="^=" or op=="<<=" or op==">>=") {
// 		gen({s[0], s[0], op, s[1]}, 5); // a = a op b
// 	}
// 	else if(op=="+" or op=="-" or op=="*" or op=="/" or op=="%" or op=="|" or op=="&" or op=="^" or op=="<<" or op==">>") {
// 		string ne=newtmp(c->e);
// 		gen({ne, s[0], op, s[1]}, 5);	//a = b op c
// 		c->place=ne;
// 	}
// 	else { // a relop b
// 		c->trueList.pb(nextQuad);
// 		gen({s[0], op, s[1]}, 7);
// 		c->falseList.pb(nextQuad);
// 		gen({}, 6);
// 	}

// 	TREE_NODE* children1[] = {a->tVal};
// 	TREE_NODE* children2[] = {b->tVal};
// 	TREE_NODE* children[] = {create_node(v[1], children1, 1), create_node(v[2], children2, 1)};
// 	c->tVal = create_node(op + v[0], children, 2);
// }
string opt(string s1, string s2, string op){
	int x=stoi(s1), y=stoi(s2),z;
	cerr<<s1<<' '<<s2<<' '<<op<<endl;
	if(op=="+")z=x+y;
	if(op=="-")z=x-y;
	if(op=="/")z=x/y;
	if(op=="*")z=x*y;
	if(op=="%")z=x%y;
	if(op=="|")z=x|y;
	if(op=="&")z=x&y;
	if(op=="^")z=x^y;
	if(op=="<<")z=x<<y;
	if(op==">>")z=x>>y;
	return to_string(z);
}

void binOperation(entry3* a, entry3* b, string op, entry3* &c) {
	//cout<<"called\n";
	c=new entry3;
	bool valid;
	vector<string> v = binOp(op, a->e, b->e, valid, c->e);
	if(!valid) {type_error=1;cerr << "error at line "<<yylineno<<": type mismatch in "<<binError(op)<<' '<<a->e.pr()<<' '<<b->e.pr()<<endl;}
	//cerr<<"\ndebug "<<op<<"#\n"<<valid<<'#'<<v[0]<<'#'<<v[1]<<'#'<<v[2]<<"#\n";
	//a[i]=b;
	//very simplistic optimisation for x=t1+t2, where t1 and t2 have fixed values
	while(v.size()<3) v.pb("");
	for(auto &x: v) if(x!="") x = " (" + x + ")";
	/*
	if(v[1]=="" and v[2]=="" and a->e.dt=="INT" and b->e.dt=="INT" and a->e.dimn+a->e.ptr==0 and b->e.dimn+b->e.ptr==0){

		string s1=a->place, s2=b->place;
		if(s1.size()>1 and s2.size()>1 and s1[0]=='t' and s2[0]=='t' and s1[1]>='0' and s1[1]<='9' and s2[1]>'0' and s2[1]<='9'){
			if(a->e.val!="" and b->e.val!=""){
				cerr<<a->e.val<<' '<<b->e.val<<endl;
				if(op=="+" or op=="-" or op=="*" or op=="/" or op=="%" or op=="|" or op=="&" or op=="^" or op=="<<" or op==">>"){
					// string ne=newtmp(c->e);
					// string tmp = opt(a->e.val, b->e.val, op);
					// gen({ne, tmp}, 1);	//a = 3
					// c->place=ne;
					// c->e.val=tmp;
					// cerr<<op<<endl;
					return;
				}
			}
		}
		// else if(op=="=" and s2.size()>1 and  s2[0]=='t' and s2[1]>='0' and s2[1]<='9' and b->e.val!=""){
		// 	cerr<<"here\n";
		// 	cerr<<"##"<<b->e.val<<endl;
		// 	gen({a->place, b->e.val},1);
		// 	a->e.val = b->e.val;
		// 	return;
		// }
	}*/

	string t1="";
	if((a->v).size()!=0){
		t1=newtmp({"INT"});
		gen({t1,"0"},1);
		int i=0;
		auto tm = lookup(a->place).Y.dim;
		for(auto x:a->v){
			string tm1 = newtmp({"INT"});
			gen({tm1, tm[i++]}, 1);
			gen({t1, t1, "*", tm1}, 5);
			gen({t1, t1, "+", x.name}, 5);
		}
	}
	//a=b[i]
	string t2="";
	if((b->v).size()!=0){
		t2=newtmp({"INT"});
		gen({t2,"0"},1);
		int i=0;
		auto tm = lookup(b->place).Y.dim;
		for(auto x:b->v){
			string tm1 = newtmp({"INT"});
			gen({tm1, tm[i++]}, 1);
			gen({t2, t2, "*", tm1}, 5);
			gen({t2, t2, "+", x.name}, 5);
		}
	}

	//

	
	string s[2]={a->place, b->place};
	for(int i=1;i<=2;i++){
		if(v[i]!=""){
			entry tmp=i==1?a->e:b->e;
			tmp.dt=v[0];
			
			string t1=newtmp(tmp);
			s[i-1]=t1;
			gen({t1, v[i], i==1?a->place:b->place},3);//a=(toInt)b
		}
	}

	if(op == "=") {
		if(t1!="" and t2!=""){
			string tm = newtmp({"INT"});	//todo
			gen({tm, s[1], t2}, 17);
			gen({s[0], t1, tm}, 11);
		}
		else if(t1!="") gen({s[0], t1, s[1]}, 11); //a[i]=b;
		else if (t2!="")gen({s[0], s[1], t2}, 17);//a=b[i];
		else {
			string s1=a->e.dotstruct,s2=b->e.dotstruct; //if they are structs
			if(s1!="" and s2!=""){
				//do here;
			}
			else if(s1!=""){
				gen({s[0], s1, s[1]},18);
			}
			else if(s2!=""){
				gen({s[0],s[1],s2},19);
			}
			else gen({s[0], s[1]}, 2);	//a = b
		}
		
	}
	else if(op=="+=" or op=="-=" or op=="*=" or op=="/=" or op=="%=" or op=="|=" or op=="&=" or op=="^=" or op=="<<=" or op==">>=") {
		gen({s[0], s[0], op, s[1]}, 5); // a = a op b
	}
	else if(op=="+" or op=="-" or op=="*" or op=="/" or op=="%" or op=="|" or op=="&" or op=="^" or op=="<<" or op==">>") {
		string ne=newtmp(c->e);
		gen({ne, s[0], op, s[1]}, 5);	//a = b op c
		c->place=ne;
	}
	else { // a relop b
		c->trueList.pb(nextQuad);
		gen({s[0], op, s[1]}, 7);
		c->falseList.pb(nextQuad);
		gen({}, 6);
	}

	TREE_NODE* children1[] = {a->tVal};
	TREE_NODE* children2[] = {b->tVal};
	TREE_NODE* children[] = {create_node(v[1], children1, 1), create_node(v[2], children2, 1)};
	c->tVal = create_node(op + v[0], children, 2);
}


void dump_ST() {
	ofstream fout("out/dumpST.out");
	func["GST"]=1;
	for(auto x: func) {
		fout << "Scope/Function/Struct name: " << x.X << "\n";
		fout << "Symbol Table ID: " << x.Y << "\n\n";
	}
	fout << "------------------------------\n\n";
	for(int i=1; i<totST; i++) {
		fout << "Symbol Table ID: " << i << "\n";
		fout << "Parent ID: " << arr[i].par << "\n";
		fout << "Return Type: " << arr[i].ret.pr() << "\n\n";
		fout<<"func_sz: "<<func_sz[i]<<endl;
		int curoff=0;
		for(int j=0;j<(arr[i].arg.size());j++){
			(arr[i].arg)[j].e.offset=(curoff-=(arr[i].arg[j]).e.siz());
		}
		arr[i].negoff=curoff;
		fout << "Arguments: \n"; for(auto x: arr[i].arg){
			fout << x.e.pr() << " " << x.name << ", ";
			fout<<"offset="<<x.e.offset<<", sz="<<x.e.siz()<<", val="<<x.e.val<<endl;
		} fout << "\n";
		fout << "Variables: \n"; for(auto x: arr[i].var){
			fout << x.Y.pr() << " " << x.X << ", ";
			fout<<"offset="<<x.Y.offset<<", sz="<<x.Y.siz()<<", val="<<x.Y.val<<endl;
		} fout << "\n";
		fout << "Size: " << arr[i].offset+arr[i].negoff << "\n\n";
		fout << "------------------------------\n\n";
	}
}

void dfs_AST(TREE_NODE* t, ofstream &fout, string spaces=""){
	fout<<spaces<<t->label<<endl;
	// if(t->count)fout<<spaces<<"Number of children = "<<(t->count)<<endl<<endl;
	// else fout<<spaces<<"Leaf node reached\n\n";
	for(int i=0; i<t->count; i++) dfs_AST(t->children[i], fout, spaces+"    ");
}
void dump_AST(TREE_NODE* t) {
	ofstream fout("out/dumpAST.out");
	fout<<"Pre-Order Traversal of AST\n";
	dfs_AST(t, fout);
}	


extern "C" {

	int yyparse(void);
	int yylex(void);
	void yyerror(const char *s) {
		fflush(stdout);
		fprintf(stderr, "*** %s\n", s);
	}
	int yywrap(void) {
	    return 1;
	}
}
//code-generation
map< string, string> reg;
map< string, string > add;	//which all regs is var contained in
set< string> freereg;
string s1, s2, s3; 	//in use
vector <string> curque;
map<int, map<string, int> > nextuse;
int curl;	//current line number

void _freereg(){
	for(int i=0;i<10;i++){
		string s = "$t"+to_string(i);
		if(!reg.count(s))freereg.insert(s);
	}
	for(int i=2;i<8;i++){
		string s = "$s"+to_string(i);
		if(!reg.count(s))freereg.insert(s);
	}
}

string getreg(string a, int lo=1){	//for a on lhs of assgn, lo=0, else lo=1
	int fl2=0;
	if(lookup2(a).X==0){	//global variable. always $s0 for globals. load, edit, store
		fl2=1;
		// if(lo)cout<<"lw $s0, "<<a<<endl;
		// return "$s0";
	}
	if(!fl2)if(add.count(a))return add[a];
	if(freereg.size()){
		string x = *(freereg.begin());
		if(!fl2){
			add[a]=x;
			reg[x]=a;
			if(lo)cout<<"lw "<<x<<", "<< -lookup(a).Y.offset<<"($fp)"<<endl;
		}
		else {
			if(lo)cout<<"lw "<<x<<", "<<a<<endl;
		}
		freereg.erase(x);
		
		return x;
	}
	//return "noreg-found";

	{
		string tmp="";
		for(auto x: arr[curST].var )if(nextuse[curST][x.X]<curl and add.count(x.X))tmp=x.X;
		for(auto x: arr[curST].arg )if(nextuse[curST][x.name]<curl and add.count(x.name))tmp=x.name;
		if(tmp!=""){
			string regi = add[tmp];
			if(!fl2){
				reg[add[tmp]]=a;
				add[a]=add[tmp];
				if(lo)cout<<"lw "<<add[tmp]<<' '<< -(lookup(a).Y.offset)<<"($fp)"<<endl;
			}
			else{
				if(lo)cout<<"lw "<<add[tmp]<<", "<<a<<endl;
				reg.erase(regi);
			}

			add.erase(tmp);
			
			//cerr<<"in nextuse - returned "<<add[a]<< " for "<<a<<endl;
			return regi;
		}
	}
	
	{
		for(auto x: reg){
			if((x.Y)!=s1 and (x.Y)!=s2 and (x.Y)!=s3){
				cout<<"#move to mem due to lack of space\n";
				cout<<"sw "<<x.X<<", "<< -(lookup(x.Y).Y.offset)<<"($fp)"<<endl;
				if(!fl2){
					if(lo)cout<<"lw "<<x.X<<", "<<-(lookup(a).Y.offset)<<"($fp)"<<endl;
				}
				else{
					if(lo)cout<<"lw "<<x.X<<", "<<a<<endl;
				}

				add.erase(x.Y);
				reg[x.X]=a;
				add[a]=x.X;
				return x.X;
			}
		}
	}

	
}

void clear(string a, string s1, int fl=0){//fl=1 means no write back
	if(!lookup2(a).X){
		if(fl)cout<<"sw "<<s1<<", "<<a<<endl;
		freereg.insert(s1);
	}
}

void nextuses(){
	int cur;
	for(int i=nextQuad-1; i>=0; i--){
		auto v=quadArray[i].v; 
		switch(quadArray[i].typ) {
			case 1: // t1 = 3
					nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
					break;
			case 2: // a = t1
					nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
					nextuse[cur][v[1]] = max(i, nextuse[cur][v[1]]);
					break;
			case 3: // a = (to INT) t1
					nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
					nextuse[cur][v[2]] = max(i, nextuse[cur][v[2]]);
					break;
			case 4: // a = op t1
					nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
					nextuse[cur][v[2]] = max(i, nextuse[cur][v[2]]);
					break;
			case 5: // a = t1 op t2
					nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
					nextuse[cur][v[1]] = max(i, nextuse[cur][v[1]]);
					nextuse[cur][v[3]] = max(i, nextuse[cur][v[3]]);
					break;
			case 6: // goto a
					if(v[0]!=""){
						nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
					}
					break;
			case 7: // if(a relop b) goto c
					if(v[3]!=""){
						nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
						nextuse[cur][v[2]] = max(i, nextuse[cur][v[2]]);
					}
					break;
			case 8: // param a
					nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
					break;
			case 9: // call f 3
					//nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
					break;
			case 10: // *x = y
					nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
					break;
			case 11: //a[i] = b
					nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
					nextuse[cur][v[1]] = max(i, nextuse[cur][v[1]]);
					nextuse[cur][v[2]] = max(i, nextuse[cur][v[2]]);
					break;
			case 12: //func :
					break;
			case 13: //func_endl :
					cur = func[v[0]];
					break;
			case 14: //a[i] = b
					nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
					break;
			case 15: //a[i] = b
					//nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
					break;
			case 16: //
					nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
					break;
			case 17: //
					nextuse[cur][v[0]] = max(i, nextuse[cur][v[0]]);
					nextuse[cur][v[1]] = max(i, nextuse[cur][v[1]]);
					nextuse[cur][v[2]] = max(i, nextuse[cur][v[2]]);
					break;
					break;
			default:
					;// << i << ": " << "HANDLE THIS "<<quadArray[i].typ<<endl;
		}

	}
	// for(auto x:nextuse){
	// 	cerr<<x.X<<endl;
	// 	for(auto y:x.Y)cerr<<y.X<<' '<<y.Y<<endl;
	// }
	return;
}
void scan_print(){
		//int scanint();
		cout<<"\n\
		\n# function scanint starts\
		\nscanint:\
		\nli $v0, 5\
		\nsyscall\
		\nsw $v0, 12($fp)\
		\nj return_scanint\
		\n# function wrap-up begins\
		\nreturn_scanint:\
		\nlw $sp, 8($fp)\
		\nlw $fp, 4($fp)\
		\njr $ra\
		\n# function scanint ends\
		\n\n";

		//void printint(int n);
		cout<<"\n\
		# function printint starts\
		\nprintint:\
		\nlw $a0, 4($fp)\
		\nli $v0, 1\
		\nsyscall\
		\nj return_printint\
		\n# function wrap-up begins\
		\nreturn_printint:\
		\nlw $sp, 12($fp)\
		\nlw $fp, 8($fp)\
		\njr $ra\
		\n# function printint ends\
		\n\n";

		//int println();
		cout<<"\n\
		\n# function println starts\
		\nprintln:\
		\nla $a0, ln\
		\nli $v0, 4\
		\nsyscall\
		\nj return_println\
		\n# function wrap-up begins\
		\nreturn_println:\
		\nlw $sp, 8($fp)\
		\nlw $fp, 4($fp)\
		\njr $ra\
		\n# function println ends\
		\n\n";

}

map<string , string> ops = {{"+", "add"}, {"-", "sub"}, {"*", "mul"}, {"/", "div"}, {"<", "blt"}, {">", "bgt"}, {">=", "bge"}, \
{"==", "beq"}, {"<>", "bne"}, {"<=", "ble"}};
int dump_ASM(){

	freopen("out/code.s", "w", stdout);

	/*
	for(cur=nextquad-1; cur>=0; cur--){
		for(auto x: quadArray[cur]){
			if(lookup(x).X)lastuse[x]=max(lastuse[x], cur);
		}
	}
	*/

	for(int i=0;i<10;i++)freereg.insert("$t"+to_string(i));
	for(int i=2;i<8;i++)freereg.insert("$s"+to_string(i));

	nextuses();
	curST=-1;
	string curfunc;
	//cerr<<"lookup "<<lookup("x").Y.offset<<endl;

	cout<<".data\n";
	for(auto x:arr[1].var){
		cout<<x.X<<":  .space  ";
		int tmp=x.Y.siz();
		//for(auto y:x.Y.dim)tmp=tmp*stoi(y);
		cout<<tmp<<endl;
	}
	cout<<"ln: .asciiz \"\\n\""<<endl;

    cout<<".text\n";
    cout<<"j main\n";
    scan_print();


	for(curl =0; curl<nextQuad; curl++){

		quad x = quadArray[curl];
		if(curST==-1 and x.typ!=12)continue;
		if(gotos.count(to_string(curl)))cout<<"L"<<curl<<":"<<endl;
		cerr<<"#debug "<<curl<<' ';for(auto y:reg)cerr<<y.X<<' '<<y.Y<<" # ";cerr<<endl;
		//cerr<<x.typ<<endl;
		if(x.typ==1){
			string s1 = getreg((x.v)[0], 0);
			cout<<"li "<<s1<<", "<<x.v[1]<<endl;
			clear((x.v)[0], s1, 1);	
		}
		else if(x.typ==5){	//a = b op c
			string s2 = getreg((x.v)[1]);
			string s3 = getreg((x.v)[3]);
			string s1 = getreg((x.v)[0], 0);
			cout<< ops[(x.v)[2]] <<", "<< s1 <<", "<< s2 <<", "<< s3<<endl;
			clear((x.v)[0], s1, 1); clear((x.v)[1], s2); clear((x.v)[3], s3);

		}
		
		else if(x.typ==2){
			int fl2=0;
			string s1 = getreg((x.v)[0], 0);
			int sz=lookup(x.v[0]).Y.siz();
			if(sz>4){

				int sz1=0;
				while(sz1<sz){
					cout<<"lw "<<s1<<", "<<-lookup(x.v[1]).Y.offset-sz1<<"($fp)"<<endl;
					cout<<"sw "<<s1<<", "<< -lookup(x.v[0]).Y.offset-sz1<<"($fp)"<<endl;
					sz1+=4;
				}
				continue;
			}
			string s2;
			int fl=0;
			if(add.count(x.v[1])){s2=add[x.v[1]]; fl=1;}
			else s2=to_string(lookup(x.v[1]).Y.offset)+"($fp)";
			//if(fl2)cerr<<s1<<' '<<s2<<endl;
			if(fl)cout<<"move "<<s1<<", "<<s2<<endl;
			else cout<<"lw "<<s1<<", "<<((lookup2(x.v[1]).X)?s2:x.v[1])<<endl;
			clear((x.v)[0], s1, 1); 
		}

		else if(x.typ==7){
			//for(auto y:x.v)cerr<<"# "<<y<<' ';cerr<<endl;continue;
			if(x.v.size()<4 or x.v[3]=="")continue;


			string s2 = getreg((x.v)[2]);
			string s1 = getreg((x.v)[0]);
			//save all regs t memory on function call
			for(auto x:add){cout<<"sw "<<x.Y<<' '<<-lookup(x.X).Y.offset<<"($fp)"<<endl;cerr<<x.X<<' '<<x.Y<<' '<<-lookup(x.X).Y.offset<<endl;}
			add.clear(), reg.clear();
		    _freereg();
		    cout<<"#caller variable registers saved\n";
			cout<<ops[(x.v)[1]]<<" "<<s1<<", "<<s2<<", "<<"L"<<(x.v)[3]<<endl;

			clear((x.v)[0], s1); clear((x.v)[2], s2);
		}
		//inserting label left above and below - like L20

		else if(x.typ==6){
			//for(auto y:x.v)cerr<<"# "<<y<<' ';cerr<<endl;continue;
			//cerr<<x.v.size()<<' ';for(auto y:x.v)cerr<<"# "<<y<<' ';cerr<<endl;//continue;
			if(x.v.size()<1 or (x.v)[0]=="")continue;

			//save all regs t memory on function call
			for(auto x:add){cout<<"sw "<<x.Y<<' '<<-lookup(x.X).Y.offset<<"($fp)"<<endl;cerr<<x.X<<' '<<x.Y<<' '<<-lookup(x.X).Y.offset<<endl;}
			add.clear(), reg.clear();
		    _freereg();
		    cout<<"#caller variable registers saved\n";

			cout<<"j"<<" "<<"L"<<(x.v)[0]<<endl;
		}

		else if(x.typ==8){	
			curque.pb(x.v[0]);
		}
		//storing floats, structs etc
		else if(x.typ==9){
			//cerr<<"func params: "; for(auto y: curque)cerr<<y<<' ';cerr<<endl;
			reverse(curque.begin(), curque.end());
			int tmp=func[x.v[0]];
			int i=arr[tmp].arg.size();
			//offset floats
			int ret = (arr[func[x.v[0]]].ret.siz()); //return valuse size;
			int off=ret;

			cout<<"sw $sp, "<<-(off)<<"($sp)"<<endl; off+=4;
			cout<<"sw $fp, "<<-(off)<<"($sp)"<<endl; off+=4;
			cout<<"#sp and fp set\n";
			for(auto y: curque){
				string s1 = getreg(y);
				int sz=lookup(y).Y.siz();
				int sz1=0;
				while(sz1<sz){
					cout<<"sw "<<s1<<", "<<-off-sz1<<"($sp)"<<endl;
					sz1+=4;
					if(sz1<sz)cout<<"lw "<<s1<<", "<< -lookup(y).Y.offset-sz1<<"($fp)"<<endl;
				}
				clear(y, s1);
				off+=sz; 	//
			}
			curque.clear();
			cout<<"#arguments set\n";
			//save all regs t memory on function call
			for(auto x:add){cout<<"sw "<<x.Y<<' '<<-lookup(x.X).Y.offset<<"($fp)"<<endl;cerr<<x.X<<' '<<x.Y<<' '<<-lookup(x.X).Y.offset<<endl;}
			add.clear(), reg.clear();
		    _freereg();
		    cout<<"#caller variable registers saved\n";
			cout<<"move $fp, $sp"<<endl;
			cout<<"addi $fp, $fp, "<<-(off)<<endl; //offset(params+return) + $sp + $fp
			cout<<"move $sp, $fp"<<endl;	//
			cout<<"jal "<<x.v[0]<<endl;
		}

		else if(x.typ==12){
			curST=func[(x.v)[0]];//
			curfunc=x.v[0];  //
			cout<<"# function "<<(x.v)[0]<<" starts\n";
			cout<<(x.v)[0]<<":"<<endl;
			if(curfunc=="main"){cout<<"move $fp, $sp\n";}
			//save all regs t memory on function call
			for(auto x:add){cout<<"sw "<<x.Y<<' '<<-lookup(x.X).Y.offset<<"($fp)"<<endl;cerr<<x.X<<' '<<x.Y<<' '<<-lookup(x.X).Y.offset<<endl;}
			add.clear(), reg.clear();
		    _freereg();
		    cout<<"#caller variable registers saved\n";
			//cerr<<"$$ "<<curfunc<<' '<< (arr[curST].offset)<<endl;
			cout<<"addi $sp, $sp, "<<-(arr[curST].offset+4)<<endl;	//params+vars+$ra+previous $fp + previous $sp
			cout<<"sw $ra, 4($sp)"<<endl;
			//
			cout<<"# function initials end\n\n";
		}

		else if(x.typ==13){	//assumes return value is stored
			cout<<"# function wrap-up begins\n";	
			int tmp=-arr[curST].negoff;
			//cerr<<"negoff "<<-tmp<<endl;
			cout<<"return_"<<x.v[0]<<":"<<endl;
			if(x.v[0]=="main"){
				cout<<"li $v0,10\
				\nsyscall\n";
				continue;
			}
			cout<<"lw $ra, 4($sp)"<<endl;
			cout<<"lw $sp, "<<8+tmp<<"($fp)"<<endl;
			cout<<"lw $fp, "<<4+tmp<<"($fp)"<<endl;
			add.clear(), reg.clear(), _freereg();	//cleanup before returning from function
			cout<<"jr $ra"<<endl;
			cout<<"# function "<<(x.v)[0]<<" ends\n\n";
		}

		else if(x.typ==14){

			//save all regs t memory on function call
			string s1 = getreg(x.v[0]);
			int sz=lookup(x.v[0]).Y.siz();
			int sz1=0;
			while(sz1<sz){
				cout<<"sw "<<s1<<", "<<-(arr[curST].negoff- 8 - arr[curST].ret.siz())-sz1<<"($fp)"<<endl;
				sz1+=4;
				if(sz1<sz)cout<<"lw "<<s1<<", "<< -lookup(x.v[0]).Y.offset-sz1<<"($fp)"<<endl;
			}
			//cout<<"sw "<<s1<<", "<<-(arr[curST].negoff- 8 - arr[curST].ret.siz())<<"($fp)"<<endl;	// params, 8 (ra+sp), return value
			//save all regs t memory on function call
			for(auto x:add){cout<<"sw "<<x.Y<<' '<<-lookup(x.X).Y.offset<<"($fp)"<<endl;cerr<<x.X<<' '<<x.Y<<' '<<-lookup(x.X).Y.offset<<endl;}
			add.clear(), reg.clear();
		    _freereg();
		    cout<<"#caller variable registers saved\n";
			clear((x.v)[0], s1);
			cout<<"j return_"<<curfunc<<endl;
		}

		else if(x.typ==15){
			//save all regs t memory on function call
			for(auto x:add){cout<<"sw "<<x.Y<<' '<<-lookup(x.X).Y.offset<<"($fp)"<<endl;cerr<<x.X<<' '<<x.Y<<' '<<-lookup(x.X).Y.offset<<endl;}
			add.clear(), reg.clear();
		    _freereg();
		    cout<<"#caller variable registers saved\n";
			cout<<"j return_"<<curfunc<<endl;
		}

		else if(x.typ==16){
			string s1 = getreg(x.v[0], 0);
			int sz=lookup(x.v[0]).Y.siz();
			int sz1=0;
			while(sz1<sz){
				cout<<"lw "<<s1<<", "<<0-sz1<<"($sp)"<<endl;
				if(sz>4)cout<<"sw "<<s1<<", "<< -lookup(x.v[0]).Y.offset-sz1<<"($fp)"<<endl;
				sz1+=4;
			}
			//cout<<"lw "<<s1<<", "<<0<<"($sp)"<<endl;
			clear((x.v)[0], s1,1);
		}
		else if(x.typ==11){
			string s1 = getreg(x.v[1]);
			string s2 = getreg(x.v[2]);
			string s3 = getreg(x.v[0],0);
			cout<<"la "<<s3<<", "<<x.v[0]<<endl;
			cout<<"li $s0, "<<4<<endl;
			cout<<"mul $s0, $s0, "<<s1<<endl;
			cout<<"add "<<s3<<", "<<s3<<", $s0"<<endl;
			cout<<"sw "<<s2<<", 0("<<s3<<")"<<endl;
			clear(x.v[1],s1); clear(x.v[2],s2); clear(x.v[0],s3); //no write back for quadArray
			cout<<"#array op over\n\n";
		}
		else if(x.typ==17){
			string s3 = getreg(x.v[0],0);
			string s1 = getreg(x.v[1],0);
			string s2 = getreg(x.v[2]);
			cerr<<s3<<' '<<s1<<' '<<s2<<endl;
			cout<<"la "<<s1<<", "<<x.v[1]<<endl;
			cout<<"li $s0, "<<4<<endl;
			cout<<"mul $s0, $s0, "<<s2<<endl;
			cout<<"add "<<s1<<", "<<s1<<", $s0"<<endl;
			cout<<"lw "<<s3<<", 0("<<s1<<")"<<endl;
			clear(x.v[1],s1); clear(x.v[2],s2); clear(x.v[0],s3, 1); //no write back for quadArray
			cout<<"#array op over\n\n";
		}
		else if(x.typ==18){//a.x=b
			string s1 = getreg(x.v[2]);
			entry e=lookup(x.v[0]).Y;
			int _off = (arr[func[e.dt]].var)[x.v[1]].offset;
			cout<<"sw "<<s1<<", "<<-(e.offset+_off)<<"($fp)"<<endl;
			clear(x.v[2], s1);
			cerr<<"struct "<<x.v[0]<<' '<<x.v[1]<<' '<<(e.offset+_off)<<endl;
		}
		else if(x.typ==19){//a=b.x
			string s1 = getreg(x.v[0],0);
			entry e=lookup(x.v[1]).Y;
			int _off = (arr[func[e.dt]].var)[x.v[2]].offset;
			cout<<"lw "<<s1<<", "<<-(e.offset+_off)<<"($fp)"<<endl;
			clear(x.v[0],s1,1);
			cerr<<"struct "<<x.v[0]<<' '<<x.v[1]<<' '<<(e.offset+_off)<<endl;	
		}
	} 
	return 0;
}

set<string> res_func = {"printint", "scanint", "println"};//for reserved functions, need not be declared. eg scan, print

////////////

int main() {
	arr[1].par=0;
	prio["CHAR"]=0, prio["INT"]=1, prio["FLOAT"]=2, prio["DOUBLE"]=3;
	rprio[0]="CHAR", rprio[1]="INT", rprio[2]="FLOAT", rprio[3]="DOUBLE", rprio[8]="POINTER";

    yyparse();
    return 0;
}

%}

%union {
	char* str;
	int lineno;
	int nextquad;
	struct pair2 iiVal;
	struct entry3 *nonT;
}

%token <str>	IDENTIFIER I_CONSTANT F_CONSTANT STRING_LITERAL 

%token <str>	PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP FUNC_NAME SIZEOF
%token <str>	AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token <str>	SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN XOR_ASSIGN OR_ASSIGN
%token <str>	TYPEDEF_NAME ENUMERATION_CONSTANT TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
%token <str>	CONST RESTRICT VOLATILE BOOL CHAR SHORT INT LONG SIGNED UNSIGNED
%token <str>	FLOAT DOUBLE VOID COMPLEX IMAGINARY STRUCT UNION ENUM ELLIPSIS
%token <str>	CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN
%token <str>	ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL

%type <iiVal> 	M N
%type <nextquad> P
%type <nonT> Q

%type <nonT>	declaration_list function_definition external_declaration translation_unit jump_statement
%type <nonT>	iteration_statement selection_statement expression_statement block_item block_item_list 
%type <nonT>	compound_statement labeled_statement statement static_assert_declaration designator
%type <nonT>	designator_list designation initializer_list initializer direct_abstract_declarator 
%type <nonT>	abstract_declarator type_name identifier_list parameter_declaration parameter_list 
%type <nonT>	parameter_type_list type_qualifier_list pointer direct_declarator declarator alignment_specifier
%type <nonT>	function_specifier type_qualifier atomic_type_specifier enumerator enumerator_list enum_specifier
%type <nonT>	struct_declarator struct_declarator_list specifier_qualifier_list struct_declaration 
%type <nonT>	struct_declaration_list struct_or_union struct_or_union_specifier type_specifier storage_class_specifier
%type <nonT>	init_declarator init_declarator_list declaration_specifiers declaration constant_expression expression
%type <nonT>	assignment_operator assignment_expression conditional_expression logical_or_expression 
%type <nonT>	logical_and_expression inclusive_or_expression exclusive_or_expression and_expression equality_expression
%type <nonT>	relational_expression shift_expression additive_expression multiplicative_expression cast_expression 
%type <nonT>	unary_operator unary_expression argument_expression_list postfix_expression generic_association 
%type <nonT>	generic_assoc_list generic_selection string enumeration_constant constant primary_expression head

%start 			head

%%

head
	: translation_unit {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("head", children, 1);
		if(type_error){cerr<<"\nCompilation Failed\n";	}
		print_tree($$->tVal);
		print_quad();
		dump_ST();
		dump_AST($$->tVal);
		dump_ASM();
		//cerr<<"head "; for(int i=1;i<totST;i++)cerr<<arr[i].par<<" \n"[i==totST-1];
		//string s="main";
		//cerr<<"#debug at head:\n";
		// for(string s: {"STRUCT node"}){
		// 	int tmp=1;
		// 	////cerr<<s<<endl;
		// 	//cerr<<"ret "<<arr[tmp].ret.dt<<"\nargs ";
		// 	for(auto x:arr[tmp].arg);//cerr<<x.e.dt<<' '<<x.name<<", ";//cerr<<"\nvars\n";
		// 	for(auto x:arr[tmp].var);//cerr<<x.Y.dt<<' '<<x.X<<endl;
		// }
	}

primary_expression
	: IDENTIFIER{
	 	TREE_NODE* children[] = {create_leaf("IDENTIFIER", $1)};
	 	$$=new entry3;
	 	$$->name=$1;
	 	$$->place=$1;
	 	if(lookup($1).X) $$->e=lookup($1).Y;
	 	else if(func.count($1))$$->e={"FUNC"};
	 	else {type_error=1; cerr<<"error at line "<<yylineno<<": identifier "<<$1<<" not declared in this scope\n";}
	 	
	 	$$->trueList.pb(nextQuad);
	 	gen({$$->place, "<>", "0"}, 7);
	 	$$->falseList.pb(nextQuad);
	 	gen({}, 6);

	 	$$->pr("primary_expression");
	 	//lookup type;
	 	$$->tVal = create_node("primary_expression", children, 1);
	}
	| constant {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1);

	 	$$->trueList.pb(nextQuad);
	 	gen({$$->place, "<>", "0"}, 7);
	 	$$->falseList.pb(nextQuad);
	 	gen({}, 6);

		$$->tVal = create_node("primary_expression",children,1);
	}
	| string{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("primary_expression",children,1);
	}
	| '(' expression ')'{
		//$$=new entry3; $$->tVal=$2->tVal;
		TREE_NODE* children[] = { $2->tVal};
		$$=new entry3(*$2); $$->tVal = create_node("primary_expression",children,1);
	}
	| generic_selection{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("primary_expression",children,1);
	}
	;

constant
	: I_CONSTANT{	/* includes character_constant */	
		TREE_NODE* children[]={create_leaf("I_CONSTANT", $1)};
	 	$$=new entry3;
	 	string tmp=$1;
	 	$$->assign("",{"INT", tmp}); 
	 	$$->place=newtmp({"INT", tmp});
	 	gen({$$->place, tmp}, 1);
	 	$$->tVal = create_node("constant", children, 1);
	}
	| F_CONSTANT{
		TREE_NODE* children[]={create_leaf("F_CONSTANT", $1)};
		$$=new entry3;
		string tmp=$1;
	 	$$->assign("",{"FLOAT", tmp}); 
	 	$$->place=newtmp({"FLOAT", tmp});
	 	gen({$$->place, tmp}, 1);
		$$->tVal = create_node("constant", children, 1);
	}
	| ENUMERATION_CONSTANT{
		TREE_NODE* children[]={create_leaf("ENUMERATION_CONSTANT", $1)};
		$$=new entry3; $$->tVal = create_node("constant", children, 1);
	}	/* after it has been defined as such */
	;

enumeration_constant
	: IDENTIFIER{
		TREE_NODE* children[] = {create_leaf("IDENTIFIER", $1)};
	 	$$=new entry3;
	 	$$->name=$1;
	 	if(!lookup2($1).X) {insert($1,{"INT"});}
	 	else {type_error=1; cerr<<"error at line "<<yylineno<<": redeclaration of symbol "<<$1<<endl;}
	 	$$->tVal = create_node("enumeration_constant", children, 1);
	}
	;

string
	: STRING_LITERAL{
		//$$=new entry3; $$->tVal.assign("",{"STR"});
		TREE_NODE* children[] = {create_leaf("STRING_LITERAL", $1)};
		string tmp=$1;
		tmp="\""+tmp+"\"";
	 	$$=new entry3;
	 	$$->assign("",{"CHAR", tmp, 1});
	 	$$->place=newtmp({"CHAR", tmp, 1});
	 	gen({$$->place, tmp}, 1);
	 	$$->tVal = create_node("string", children, 1);
	}
	| FUNC_NAME{
		//$$=new entry3; $$->tVal.assign("",{"FUNC"});
		TREE_NODE* children[] = {create_leaf("FUNC_NAME", $1)};
	 	$$=new entry3;
	 	$$->assign("",{"FUNC"}); $$->tVal = create_node("string", children, 1);
	}
	;

generic_selection
	: GENERIC '(' assignment_expression ',' generic_assoc_list ')'{
		TREE_NODE* children[] = {create_leaf("GENERIC",$1), $3->tVal, $5->tVal};
		$$=new entry3; $$->tVal = create_node("generic_selection", children, 3);
	}
	;

generic_assoc_list
	: generic_association{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("generic_assoc_list", children, 1);
	}
	| generic_assoc_list ',' generic_association{
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$$=new entry3; $$->tVal = create_node("generic_assoc_list", children, 2);
	}
	;

generic_association
	: type_name ':' assignment_expression{
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$$=new entry3; $$->tVal = create_node(":", children, 2);
	}
	| DEFAULT ':' assignment_expression{
		TREE_NODE* children[] = {create_leaf("DEFAULT",$1), $3->tVal};
		$$=new entry3; $$->tVal = create_node(":", children, 2);
	}
	;

postfix_expression
	: primary_expression{
		//$$=new entry3; $$->tVal=$2->tVal;
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); //$$->pr("postfix_expression->primary_expression");
		$$->tVal = create_node("postfix_expression", children, 1);
	}
	| postfix_expression '[' expression ']' {
		//$$=new entry3; $$->tVal=$2->tVal;
		//$$=new entry3; $$->tVal.e.dimn++;
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$$=new entry3(*$1); 
		$$->v.pb({$3->place, {}});
		//cerr<<"at postfix_expression "<<$1->e.pr()<<endl;
		if($$->e.dimn>0)$$->e.dimn--;
		else $$->e.ptr--;
		if($$->e.ptr<0){type_error=1; cerr<<"error at line "<<yylineno<<": array indexed with more indices than its dimension " << '\n';}
		$$->tVal = create_node("[]", children, 2);
	}
	| postfix_expression '(' ')' {
		TREE_NODE* children[] = {$1->tVal, create_leaf("()","")};
		$$=new entry3;
		if((!func.count($1->name) or !arr[func[$1->name]].def)and !res_func.count($1->name) ) {
			type_error=1; cerr<<"error at line "<<yylineno<<": function " << $1->name << " not defined\n";}
		else {
			int temp=func[$1->name];
			int sz=arr[temp].arg.size();
			if(0!=sz) {type_error=1; cerr<<"error at line "<<yylineno<<": Number of arguments does not match the function " << $1->name << '\n';}
		}
		$$->e=arr[func[$1->name]].ret;

		gen({$1->name, "0"}, 9);
		//
		string s1=newtmp(arr[func[$1->place]].ret);
		gen({s1, $1->name}, 16);
		$$->place=s1;
		//
		$$->tVal = create_node("postfix_expression", children, 2);
	}
	| postfix_expression '(' argument_expression_list ')'{
		TREE_NODE* children[] = {$1->tVal,$3->tVal};
		$$=new entry3;
		if((!func.count($1->name) or !arr[func[$1->name]].def) and !res_func.count($1->name)) {type_error=1;  cerr<<"error at line "<<yylineno<<": function " << $1->name << " not defined\n";}
		else {
			int temp=func[$1->name];
			int sz=arr[temp].arg.size();
			if(($3->v).size()!=sz) {type_error=1; cerr<<"error at line "<<yylineno<<": Number of arguments does not match the function " << $1->name << '\n';
				//cerr<<sz<<' '<<($3->v).size()<<endl;
			}
			else {
				string params[sz];
				for(int i=0;i<sz;i++) {
					// string s="";
					params[i]=($3->v)[i].name;
					if(!sametype(($3->v)[i].e, (arr[temp].arg)[i].e)) {
						type_error=1; cerr<<"error at line "<<yylineno<<": Cannot convert argument " << i+1 << " from " << ($3->v)[i].e.dt << " to " << (arr[temp].arg)[i].e.dt << '\n';
					}
					else if(!exacttype(($3->v)[i].e, (arr[temp].arg)[i].e)) {
						entry3 *x1, *y1, *z1;
						string x = newtmp((arr[temp].arg)[i].e);
						x1 = new entry3({"", (arr[temp].arg)[i].e, x});
						y1 = new entry3({"", ($3->v)[i].e, ($3->v)[i].name});
						binOperation(x1, y1, "=", z1);
						params[i] = x;
					}
					// else if(!exacttype(($3->v)[i].e, (arr[temp].arg)[i].e)) {
					// 	s="(to "+(arr[temp].arg)[i].e.pr()+")";
					// }
				}
				for(int i=0;i<sz;i++){
					gen({params[i]}, 8);
				}
				gen({$1->name, to_string(sz)}, 9);
				//
				string s1=newtmp(arr[func[$1->place]].ret);
				gen({s1, $1->name}, 16);
				$$->place=s1;
				//
			}
		}
		$$->e=arr[func[$1->name]].ret;
		$$->tVal = create_node("postfix_expression",children,2);
	}
	| postfix_expression '.' IDENTIFIER{
		TREE_NODE* children[] = {$1->tVal,  create_leaf("IDENTIFIER",$3)};

		$$=new entry3; 
		
		string typ = $1->e.dt;
		if(typ.find("STRUCT") == 0){
			if(!func.count(typ)){type_error=1; cerr<<"error at line "<<yylineno<<": "<<typ<<" not declared\n";}
		}
		else {type_error=1; cerr<<"error at line "<<yylineno<<": "<<$1->name<<" is not a STRUCT\n";}
		if(!(arr[func[typ]].var).count($3)){type_error=1; cerr<<"error at line "<<yylineno<<": "<<$3<<" is not a member of "<<typ<<endl;}
		else $$->e=(arr[func[typ]].var)[$3];
		//cerr<<"assigned $$ "<<($$->e.dt)<<" # "<<$3<<	" " <<typ<<endl;
		$$->place=$1->place;
		$$->e.dotstruct=$3;
		cerr<<($$->place)<<endl;
		$$->tVal = create_node(".", children, 2);
	}
	| postfix_expression PTR_OP IDENTIFIER{
		TREE_NODE* children[] = {$1->tVal,  create_leaf("IDENTIFIER",$3)};
		$$=new entry3; 
		if($1->e.dimn>0)$1->e.dimn--;
		else $1->e.ptr--;
		if($1->e.ptr<0){type_error=1; cerr<<"error at line "<<yylineno<<": invalid unary operator "<<'*'<<$1->e.dt<<endl;}
		string typ = $1->e.dt;
		if(typ.find("STRUCT") == 0){
			if(!func.count(typ)){type_error=1; cerr<<"error at line "<<yylineno<<": "<<typ<<" not declared\n";}
		}
		else {type_error=1; cerr<<"error at line "<<yylineno<<": "<<$1->name<<" is not a STRUCT\n";}
		if(!(arr[func[typ]].var).count($3)){type_error=1; cerr<<"error at line "<<yylineno<<": "<<$3<<" is not a member of "<<typ<<endl;}
		else $$->e=(arr[func[typ]].var)[$3];
		$$->tVal = create_node("->", children, 2);
	}

	| postfix_expression INC_OP{
		$$=new entry3;
		bool valid;
		string s=unOp("++", $1->e, valid, $$);
		if(!valid) {type_error=1;cerr<<s<<'\n';}
		TREE_NODE* children1[] = {$1->tVal};
		TREE_NODE* children[] = {create_node("++", children1, 1)};
		$$->tVal = create_node("postfix_expression", children, 1);
	}
	| postfix_expression DEC_OP{
		$$=new entry3;
		bool valid;
		string s=unOp("--", $1->e, valid, $$);
		if(!valid) {type_error=1;cerr<<s<<'\n';}
		TREE_NODE* children1[] = {$1->tVal};
		TREE_NODE* children[] = {create_node("--", children1, 1)};
		$$->tVal = create_node("postfix_expression", children, 1);
	}
	| '(' type_name ')' '{' initializer_list '}' {
		TREE_NODE* children[] = {create_leaf("(",""), $2->tVal, create_leaf(")",""),create_leaf("{",""), $5->tVal, create_leaf("}","")};
		$$=new entry3; $$->tVal = create_node("postfix_expression", children, 6);
	}
	| '(' type_name ')' '{' initializer_list ',' '}'{
		TREE_NODE* children[] = {create_leaf("(",""), $2->tVal, create_leaf(")",""), create_leaf("{",""), $5->tVal, create_leaf(",",""), create_leaf("}","")};
		$$=new entry3; $$->tVal = create_node("postfix_expression", children, 7);
	}
	;

argument_expression_list
	: assignment_expression{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3;
		$$->v.pb({$1->place, $1->e});
		$$->tVal = create_node("argument_expression_list", children, 1);
	}
	| argument_expression_list ',' assignment_expression{
		TREE_NODE* children[] = {$1->tVal,  $3->tVal};
		$$=new entry3(*$1); 
		$$->v.pb({$3->place, $3->e});
		$$->tVal = create_node("argument_expression_list", children, 2);
	}
	;

unary_expression
	: postfix_expression{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("unary_expression", children, 1);
	}
	| INC_OP unary_expression{
		$$=new entry3;
		bool valid;
		string s=unOp("++", $2->e, valid, $$);
		if(!valid) {type_error=1;cerr<<s<<'\n';}
		TREE_NODE* children1[] = {$2->tVal};
		TREE_NODE* children[] = {create_node("++", children1, 1)};
		$$->tVal = create_node("unary_expression", children, 1);
	}
	| DEC_OP unary_expression{
		$$=new entry3;
		bool valid;
		string s=unOp("--", $2->e, valid, $$);
		if(!valid) {type_error=1;cerr<<s<<'\n';}
		TREE_NODE* children1[] = {$2->tVal};
		TREE_NODE* children[] = {create_node("--", children1, 1)};
		$$->tVal = create_node("unary_expression", children, 1);
	}
	| unary_operator cast_expression{
		$$=new entry3;
		bool valid;
		string s=unOp($1->name, $2->e, valid, $$);
		if(!valid) {type_error=1;cerr<<s<<'\n';}

		if($1->name=="-") {
			entry tempe = $2->e; tempe.val = "0";
			string temp=newtmp(tempe);
			gen({temp, "0"}, 1);
			entry3 *var1=new entry3({"", $2->e, temp});
			binOperation(var1, $2, "-", $$);
		}

		TREE_NODE* children1[] = {$2->tVal};
		TREE_NODE* children[] = {create_node($1->name, children1, 1)};
		$$->tVal = create_node("unary_expression", children, 1);
	}
	| SIZEOF unary_expression{
		TREE_NODE* children[] = {$2->tVal};
	 	$$=new entry3({"", {"INT"}}); $$->tVal = create_node("SIZEOF", children, 1);
	}
	| SIZEOF '(' type_name ')'{
		TREE_NODE* children[] = {$3->tVal};
		$$=new entry3({"", {"INT"}}); $$->tVal = create_node("SIZEOF", children, 1);
	}
	| ALIGNOF '(' type_name ')'{
		TREE_NODE* children[] = {$3->tVal};
		$$=new entry3({"", {"INT"}}); $$->tVal = create_node("ALIGNOF", children, 1);
	}
	;

unary_operator
	: '&' {
		TREE_NODE* children[] = {create_leaf("&", "")};
	 	$$=new entry3({"&"}); $$->tVal = create_node("unary_operator", children, 1);
	}
	| '*' {
		TREE_NODE* children[] = {create_leaf("*", "")};
	 	$$=new entry3({"*"}); $$->tVal = create_node("unary_operator", children, 1);
	}
	| '+' {
		TREE_NODE* children[] = {create_leaf("+", "")};
	 	$$=new entry3({"+"}); $$->tVal = create_node("unary_operator", children, 1);
	}
	| '-' {
		TREE_NODE* children[] = {create_leaf("-", "")};
	 	$$=new entry3({"-"}); $$->tVal = create_node("unary_operator", children, 1);
	}
	| '~' {
		TREE_NODE* children[] = {create_leaf("~", "")};
	 	$$=new entry3({"~"}); $$->tVal = create_node("unary_operator", children, 1);
	}
	| '!' {
		TREE_NODE* children[] = {create_leaf("!", "")};
	 	$$=new entry3({"!"}); $$->tVal = create_node("unary_operator", children, 1);
	}
	;

cast_expression
	: unary_expression {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1);	$$->tVal = create_node("cast_expression", children, 1);
	}
	| '(' type_name ')' cast_expression{
		$$=new entry3;
		bool valid;
		//cerr<<"Kaushal::"<<$2->e.pr()<<"#"<<$4->e.pr()<<"#\n";
		vector<string> v = binOp("=", $2->e, $4->e, valid, $$->e);
		while(v.size()<3) v.pb(""); for(auto &x: v) if(x!="") x = " (" + x + ")";
		//cerr<<"\ndebug typecast#\n"<<valid<<'#'<<v[0]<<'#'<<v[1]<<'#'<<v[2]<<"#\n";
		if(!valid) {type_error=1;cerr << "error at line "<<yylineno<<": type mismatch in typecasting "<<$2->e.pr()<<' '<<$4->e.pr()<<endl;}
		
		TREE_NODE* children[] = {$4->tVal};
		$$->tVal = create_node("("+$2->e.pr()+")", children, 1);
	}
	;

multiplicative_expression
	: cast_expression {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("multiplicative_expression", children, 1);
	}
	| multiplicative_expression '*' cast_expression {
		binOperation($1, $3, "*", $$);
	}
	| multiplicative_expression '/' cast_expression {
		binOperation($1, $3, "/", $$);
	}
	| multiplicative_expression '%' cast_expression{
		binOperation($1, $3, "%", $$);
	}
	;

additive_expression
	: multiplicative_expression{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1);	$$->tVal = create_node("additive_expression", children, 1);
	}
	| additive_expression '+' multiplicative_expression{
		binOperation($1, $3, "+", $$);
	}
	| additive_expression '-' multiplicative_expression{
		binOperation($1, $3, "-", $$);
	}
	;

shift_expression
	: additive_expression{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("shift_expression", children, 1);
	}
	| shift_expression LEFT_OP additive_expression{
		binOperation($1, $3, "<<", $$);
	}
	| shift_expression RIGHT_OP additive_expression{
		binOperation($1, $3, ">>", $$);
	}
	;

relational_expression
	: shift_expression {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("relational_expression", children, 1);
	}
	| relational_expression '<' shift_expression{
		binOperation($1, $3, "<", $$);
	}
	| relational_expression '>' shift_expression{
		binOperation($1, $3, ">", $$);
	}
	| relational_expression LE_OP shift_expression{
		binOperation($1, $3, "<=", $$);
	}
	| relational_expression GE_OP shift_expression{
		binOperation($1, $3, ">=", $$);
	}
	;

equality_expression
	: relational_expression{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("equality_expression", children, 1);
	}
	| equality_expression EQ_OP relational_expression{
		binOperation($1, $3, "==", $$);
	}
	| equality_expression NE_OP relational_expression{
		binOperation($1, $3, "!=", $$);
	}
	;

and_expression
	: equality_expression{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("and_expression", children, 1);
	}
	| and_expression '&' equality_expression{
		binOperation($1, $3, "&", $$);
	}
	;

exclusive_or_expression
	: and_expression{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("exclusive_or_expression", children, 1);
	}
	| exclusive_or_expression '^' and_expression {
		binOperation($1, $3, "^", $$);
	}
	;

inclusive_or_expression
	: exclusive_or_expression{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("inclusive_or_expression", children, 1);
	}
	| inclusive_or_expression '|' exclusive_or_expression{
		binOperation($1, $3, "|", $$);
	}
	;

logical_and_expression
	: inclusive_or_expression{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("logical_and_expression", children, 1);
	}
	| logical_and_expression AND_OP P inclusive_or_expression{
		binOperation($1, $4, "&&", $$);
		backpatch($1->trueList, $3);
		$$->falseList=merge($1->falseList, $4->falseList);
		$$->trueList=$4->trueList;
	}
	;

P 	: {$$ = nextQuad; 
	// cerr<<"P got "<<$$<<endl;
}
	;

logical_or_expression
	: logical_and_expression{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("logical_or_expression", children, 1);
	}
	| logical_or_expression OR_OP P logical_and_expression{
		binOperation($1, $4, "||", $$);
		backpatch($1->falseList, $3);
		$$->falseList=$4->falseList;
		$$->trueList=merge($1->trueList, $4->trueList);
	}
	;

conditional_expression
	: logical_or_expression{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("conditional_expression", children, 1);
	}
	| logical_or_expression '?' expression ':' conditional_expression{
		TREE_NODE* children1[] = {$3->tVal, $5->tVal};
		TREE_NODE* children[] = {$1->tVal, create_node(":", children1, 2)};
		if(!sametype($3->e, $5->e)) {type_error=1; cerr<<"error at line "<<yylineno<<": types not same in ternary assignment "<<$3->e.pr()<<" "<<$5->e.pr()<<"\n";}
		$$=new entry3(*$3); $$->tVal = create_node("?", children, 2);
	}
	;

assignment_expression
	: conditional_expression{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("assignment_expression", children, 1);
	}
	| unary_expression assignment_operator assignment_expression{	////need to check for type convertibility, mod case separate
		//cerr<<"h1\n";
		$$=new entry3(*$1);
		cerr<<"ass-exp ";for(auto x:$1->v)cerr<<x.name<<' ';cerr<<endl;
		// cerr<<"assgn-exp ";	for(auto x:$$->nextList)cerr<<x<<endl;cerr<<"\n";
		binOperation($1, $3, $2->name, $$);
		//cerr<<"h1\n";
	}
	;

assignment_operator
	: '='{
		TREE_NODE* children[] = {create_leaf("=", "")};
	 	$$=new entry3({"="}); $$->tVal = create_node("assignment_operator", children, 1);
	}
	| MUL_ASSIGN{
		TREE_NODE* children[] = {create_leaf("*=", $1)};
	 	$$=new entry3({"*="}); $$->tVal = create_node("assignment_operator", children, 1);
	}
	| DIV_ASSIGN{
		TREE_NODE* children[] = {create_leaf("/=", $1)};
	 	$$=new entry3({"/="}); $$->tVal = create_node("assignment_operator", children, 1);
	}
	| MOD_ASSIGN{
		TREE_NODE* children[] = {create_leaf("%=", $1)};
	 	$$=new entry3({"%="}); $$->tVal = create_node("assignment_operator", children, 1);
	}
	| ADD_ASSIGN{
		TREE_NODE* children[] = {create_leaf("+=", $1)};
	 	$$=new entry3({"+="}); $$->tVal = create_node("assignment_operator", children, 1);
	}
	| SUB_ASSIGN{
		TREE_NODE* children[] = {create_leaf("-=", $1)};
	 	$$=new entry3({"-="}); $$->tVal = create_node("assignment_operator", children, 1);
	}
	| LEFT_ASSIGN{
		TREE_NODE* children[] = {create_leaf("<<=", $1)};
	 	$$=new entry3({"<<="}); $$->tVal = create_node("assignment_operator", children, 1);
	}
	| RIGHT_ASSIGN{
		TREE_NODE* children[] = {create_leaf(">>=", $1)};
	 	$$=new entry3({">>="}); $$->tVal = create_node("assignment_operator", children, 1);
	}
	| AND_ASSIGN{
		TREE_NODE* children[] = {create_leaf("&=", $1)};
	 	$$=new entry3({"&="}); $$->tVal = create_node("assignment_operator", children, 1);
	}
	| XOR_ASSIGN{
		TREE_NODE* children[] = {create_leaf("^=", $1)};
	 	$$=new entry3({"^="}); $$->tVal = create_node("assignment_operator", children, 1);
	}
	| OR_ASSIGN{
		TREE_NODE* children[] = {create_leaf("|=", $1)};
	 	$$=new entry3({"|="}); $$->tVal = create_node("assignment_operator", children, 1);
	}
	;

expression
	: assignment_expression{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); 
		// cerr<<"exp ";for(auto x:$$->nextList)cerr<<x<<endl;cerr<<"\n";
		$$->tVal = create_node("expression", children, 1);
	}
	| expression ',' assignment_expression{
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$$=new entry3; $$->tVal = create_node("expression", children, 2);
	}
	;

constant_expression
	: conditional_expression	/* with constraints */
	{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("constant_expression", children, 1);
	}
	;

declaration
	: declaration_specifiers ';'{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("declaration", children, 1);
	}
	| declaration_specifiers init_declarator_list ';'{
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3;
		string typ = $1->e.dt;
		if(typ.find("STRUCT") == 0){
			if(!func.count(typ)){type_error=1; cerr<<"error at line "<<yylineno<<": "<<typ<<" not declared\n";}
		}
		//cerr<<"at type "<<typ<<endl;
		for(auto x:($2->v)){
			int fl=0;
			for(auto y:arr[curST].arg)if(y.name==x.name)fl=1;

			if(func.count(x.name) and arr[func[x.name]].ret.dt!="") {

				//cerr<<"## "<<x.name<<endl;
				if(x.e.dt=="FUNC") {
					if(!exacttype($1->e, (arr[func[x.name]].ret))) {type_error=1; cerr<<"error at line "<<yylineno<<": redeclaration of function "<<x.name<<" with different \
return type"<<endl;}
				}
				else if(curST==1) {
					type_error=1; cerr<<"error at line "<<yylineno<<": function/struct with name "<<x.name<<" exists, cannnot declare global variable\n";
				}
				else if(arr[curST].var.count(x.name) or fl) {type_error=1; cerr<<"error at line "<<yylineno<<": redeclaration of symbol "<<x.name<<endl;}
				else if(x.e.dt=="" or sametype( {x.e.dt}, {typ})){
					if(typ=="VOID"){type_error=1; cerr<<"error at line "<<yylineno<<": variable with type VOID can not be declared\n";}
					x.e.dt=typ;		//to-float handle
					insert(x.name,x.e);	
				}
				else {type_error=1; cerr<<"error at line "<<yylineno<<": type mismatch "<<typ<<' '<<x.name<<' '<<x.e.dt<<endl;}	
			}

			else if(arr[curST].var.count(x.name) or fl) {type_error=1; cerr<<"error at line "<<yylineno<<": redeclaration of symbol "<<x.name<<endl;}
			else if(x.e.dt=="FUNC") {
				//cerr<<"#setting return type to "<<' '<<$1->e.dt<<endl;
				arr[func[x.name]].ret=$1->e;
				//x.e.dt=typ;
				//insert(x.name,x.e);
			}
			else if(x.e.dt=="" or sametype( {x.e.dt}, {typ})){	//for three cases- int x | int x="xyz"
				if(typ=="VOID"){type_error=1; cerr<<"error at line "<<yylineno<<": variable with type VOID can not be declared\n";}
				x.e.dt=typ;		//to-float handle
				insert(x.name,x.e);
			}
			else {type_error=1; cerr<<"error at line "<<yylineno<<": type mismatch "<<typ<<' '<<x.name<<' '<<x.e.dt<<endl;}
		}
		$$->e.dt="VOID";
		$$->tVal = create_node("declaration", children, 2);
	}
	| static_assert_declaration{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("declaration", children, 1);
	}
	;

declaration_specifiers
	: storage_class_specifier declaration_specifiers{
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3; $$->tVal = create_node("declaration_specifiers", children, 2);
	}
	| storage_class_specifier{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("declaration_specifiers", children, 1);
	}
	| type_specifier declaration_specifiers{
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3; $$->tVal = create_node("declaration_specifiers", children, 2);
	}
	| type_specifier{
		TREE_NODE* children[] = {$1->tVal};
		//cerr<<"at type_specifier "<<$1->e.dt<<endl;
		$$=new entry3(*$1); $$->tVal = create_node("declaration_specifiers", children, 1);
	}
	| type_qualifier declaration_specifiers{
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3; $$->tVal = create_node("declaration_specifiers", children, 2);
	}
	| type_qualifier{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("declaration_specifiers", children, 1);
	}
	| function_specifier declaration_specifiers{
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3; $$->tVal = create_node("declaration_specifiers", children, 2);
	}
	| function_specifier{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("declaration_specifiers", children, 1);
	}
	| alignment_specifier declaration_specifiers{
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3; $$->tVal = create_node("declaration_specifiers", children, 2);
	}
	| alignment_specifier{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("declaration_specifiers", children, 1);
	}
	;

init_declarator_list
	: init_declarator{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); 
		$$->v.pb({$1->place,$1->e});
		$$->prv("init_declarator_list->init_declarator");
		$$->tVal = create_node("init_declarator_list", children, 1);
	}
	| init_declarator_list ',' init_declarator{
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$$=new entry3(*$1); 
		$$->v.pb({$3->place,$3->e});
		$$->prv("init_declarator_list->initializer_list, init_declarator");
		$$->tVal = create_node("init_declarator_list", children, 2);
	}
	;

init_declarator
	: declarator '=' initializer{
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$1->e.dt=$3->e.dt;

		$$=new entry3(*$3); //make basic types equal, then check if type is same
		//$$->v.clear();
		$$->place=$1->place;
		gen({$1->place, $3->place}, 2);
		if(!sametype($1->e,$3->e)){type_error=1; cerr<<"error at line "<<yylineno<<": invalid initialization "<<$1->e.pr()<<" "<<$3->e.pr()<<"\n";
		}
		$$->tVal = create_node("=", children, 2);
	}
	| declarator{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); 
		//$$->v.clear();
		$$->tVal = create_node("init_declarator", children, 1);
	}
	;

storage_class_specifier
	: TYPEDEF	/* identifiers must be flagged as TYPEDEF_NAME */
	{
		TREE_NODE* children[] = {create_leaf("TYPEDEF", $1)};
		$$=new entry3; $$->tVal = create_node("storage_class_specifier", children, 1);
	}
	| EXTERN{
		TREE_NODE* children[] = {create_leaf("EXTERN", $1)};
		$$=new entry3; $$->tVal = create_node("storage_class_specifier", children, 1);
	}
	| STATIC{
		TREE_NODE* children[] = {create_leaf("STATIC", $1)};
		$$=new entry3; $$->tVal = create_node("storage_class_specifier", children, 1);
	}
	| THREAD_LOCAL{
		TREE_NODE* children[] = {create_leaf("THREAD_LOCAL", $1)};
		$$=new entry3; $$->tVal = create_node("storage_class_specifier", children, 1);
	}
	| AUTO{
		TREE_NODE* children[] = {create_leaf("AUTO", $1)};
		$$=new entry3; $$->tVal = create_node("storage_class_specifier", children, 1);
	}
	| REGISTER{
		TREE_NODE* children[] = {create_leaf("REGISTER", $1)};
		$$=new entry3; $$->tVal = create_node("storage_class_specifier", children, 1);
	}
	;

type_specifier
	: VOID{
		TREE_NODE* children[] = {create_leaf("VOID", $1)};
		$$=new entry3; 
		$$->e={"VOID"};
		$$->tVal = create_node("type_specifier", children, 1);
	}
	| CHAR{
		TREE_NODE* children[] = {create_leaf("CHAR", $1)};
		$$=new entry3; 
		$$->e={"CHAR"};
		$$->tVal = create_node("type_specifier", children, 1);
	}
	| SHORT{
		TREE_NODE* children[] = {create_leaf("SHORT", $1)};
		$$=new entry3; 
		$$->e={"SHORT"};
		$$->tVal = create_node("type_specifier", children, 1);
	}
	| INT{
		TREE_NODE* children[] = {create_leaf("INT", $1)};
		$$=new entry3; 
		$$->e={"INT"};
		$$->tVal = create_node("type_specifier", children, 1);
	}
	| LONG{
		TREE_NODE* children[] = {create_leaf("LONG", $1)};
		$$=new entry3; 
		$$->e={"LONG"};
		$$->tVal = create_node("type_specifier", children, 1);
	}
	| FLOAT{
		TREE_NODE* children[] = {create_leaf("FLOAT", $1)};
		$$=new entry3; 
		$$->e={"FLOAT"};
		$$->tVal = create_node("type_specifier", children, 1);
	}
	| DOUBLE{
		TREE_NODE* children[] = {create_leaf("DOUBLE", $1)};
		$$=new entry3; 
		$$->e={"DOUBLE"};
		$$->tVal = create_node("type_specifier", children, 1);
	}
	| SIGNED{
		TREE_NODE* children[] = {create_leaf("SIGNED", $1)};
		$$=new entry3; 
		$$->e={"SIGNED"};
		$$->tVal = create_node("type_specifier", children, 1);
	}
	| UNSIGNED{
		TREE_NODE* children[] = {create_leaf("UNSIGNED", $1)};
		$$=new entry3; 
		$$->e={"UNSIGNED"};
		$$->tVal = create_node("type_specifier", children, 1);
	}
	| BOOL{
		TREE_NODE* children[] = {create_leaf("BOOL", $1)};
		$$=new entry3; 
		$$->e={"BOOL"};
		$$->tVal = create_node("type_specifier", children, 1);
	}
	| COMPLEX{
		TREE_NODE* children[] = {create_leaf("COMPLEX", $1)};
		$$=new entry3; 
		$$->e={"COMPLEX"};
		$$->tVal = create_node("type_specifier", children, 1);
	}
	| IMAGINARY	  	/* non-mandated extension */
	{
		TREE_NODE* children[] = {create_leaf("IMAGINARY", $1)};
		$$=new entry3; 
		$$->e={"IMAGINARY"};
		$$->tVal = create_node("type_specifier", children, 1);
	}
	| atomic_type_specifier{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("type_specifier", children, 1);
	}
	| struct_or_union_specifier{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); 
		$$->tVal = create_node("type_specifier", children, 1);	
	}
	| enum_specifier{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("type_specifier", children, 1);
	}
	| TYPEDEF_NAME		/* after it has been defined as such */
	{
		TREE_NODE* children[] = {create_leaf("TYPEDEF_NAME", $1)};
		$$=new entry3; $$->tVal = create_node("type_specifier", children, 1);
	}
	;

struct_or_union_specifier
	: struct_or_union '{' struct_declaration_list '}'{
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$$=new entry3; $$->tVal = create_node("struct_or_union_specifier", children, 2);
	}
	| struct_or_union IDENTIFIER '{' M struct_declaration_list '}'{
		TREE_NODE* children[] = {$1->tVal, create_leaf("IDENTIFIER",$2), $5->tVal};
		
		if(func.count($1->e.dt + " " + $2)){type_error=1; cerr<<"error at line "<<yylineno<<": redeclaration of symbol "<<$1->e.dt + " " + $2<<endl;}
		else func[$1->e.dt + " " + $2] = $4.Y;
		curST=$4.X;

		$$=new entry3;
		$$->assign("", {"VOID"});
		$$->tVal = create_node("struct_or_union_specifier", children, 3);
	}
	| struct_or_union IDENTIFIER{
		TREE_NODE* children[] = {$1->tVal, create_leaf("IDENTIFIER",$2)};
		$$=new entry3; 
		$$->e.dt={$1->e.dt+" "+$2};
		if(!func.count($$->e.dt)){type_error=1; cerr<<"error at line "<<yylineno<<": "<<$$->e.dt + " not declared"<<endl;}
		//cerr<<"#debug in struct "<<$$->e.dt<<' '<<$1->e.dt<<' '<<$2<<endl;
		$$->tVal = create_node("struct_or_union_specifier", children, 2);
	}
	;

struct_or_union
	: STRUCT{
		TREE_NODE* children[] = {create_leaf("STRUCT", $1)};
	 	$$=new entry3;
	 	$$->assign("", {"STRUCT"});
	 	$$->tVal = create_node("struct_or_union", children, 1);
	}
	| UNION{
		TREE_NODE* children[] = {create_leaf("UNION", $1)};
	 	$$=new entry3;
	 	$$->assign("", {"UNION"});
	 	$$->tVal = create_node("struct_or_union", children, 1);
	}
	;

struct_declaration_list
	: struct_declaration{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("struct_declaration_list", children, 1);
	}
	| struct_declaration_list struct_declaration{
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3; $$->tVal = create_node("struct_declaration_list", children, 2);
	}
	;

struct_declaration
	: specifier_qualifier_list ';'	/* for anonymous struct/union */
	{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("struct_declaration", children, 1);
	}
	| specifier_qualifier_list struct_declarator_list ';'{
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3; 
		string typ=$1->e.dt;
		for(auto x:$2->v){
			if((arr[curST].var).count(x.name)){type_error=1; cerr<<"error at line "<<yylineno<<": redeclaration of symbol "<<x.name<<endl;}
			else if(x.e.dt=="" or sametype({x.e.dt},{typ})){x.e.dt=typ; insert(x.name, x.e);}
			else {type_error=1; cerr<<"error at line "<<yylineno<<": type mismatch in declaration "<<typ<<' '<<x.e.dt<<endl;}
		}
		$$->e.dt="VOID";
		$$->tVal = create_node("struct_declaration", children, 2);
	}
	| static_assert_declaration{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("struct_declaration", children, 1);
	}
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list{
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3; $$->tVal = create_node("specifier_qualifier_list", children, 2);
	}
	| type_specifier{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("specifier_qualifier_list", children, 1);
	}
	| type_qualifier specifier_qualifier_list{
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3; $$->tVal = create_node("specifier_qualifier_list", children, 2);
	}
	| type_qualifier{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("specifier_qualifier_list", children, 1);
	}
	;

struct_declarator_list
	: struct_declarator{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); 
		$$->v.pb({$1->name,$1->e});
		$$->tVal = create_node("struct_declarator_list", children, 1);
	}
	| struct_declarator_list ',' struct_declarator{
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$$=new entry3(*$1); 
		$$->v.pb({$3->name,$3->e});
		$$->tVal = create_node("struct_declarator_list", children, 2);
	}
	;

struct_declarator
	: ':' constant_expression{
		TREE_NODE* children[] = {create_leaf(":",""), $2->tVal};
		$$=new entry3; $$->tVal = create_node("struct_declarator", children, 2);
	}
	| declarator ':' constant_expression{
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$$=new entry3(*$1); 
		$1->e.dt=$3->e.dt;
		if(!sametype($1->e,$3->e)){type_error=1; cerr<<"error at line "<<yylineno<<": invalid initialisation"<<$1->e.pr()<<" "<<$3->e.pr()<<"\n";
		}
		$$->e=$1->e;
		$$->tVal = create_node(":", children, 2);
	}
	| declarator{
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("struct_declarator", children, 1);
	}
	;

/* half */

enum_specifier
	: ENUM '{' enumerator_list '}' {
		TREE_NODE* children[] = {$3->tVal};
		$$=new entry3; $$->tVal = create_node("ENUM", children, 1);
	}
	| ENUM '{' enumerator_list ',' '}' {
		TREE_NODE* children[] = {$3->tVal};
		$$=new entry3; $$->tVal = create_node("ENUM", children, 1);
	}
	| ENUM IDENTIFIER '{' enumerator_list '}' {
		TREE_NODE* children[] = {create_leaf("IDENTIFIER", $2), $4->tVal};
		$$=new entry3; $$->tVal = create_node("ENUM", children, 2);
	}
	| ENUM IDENTIFIER '{' enumerator_list ',' '}' {
		TREE_NODE* children[] = {create_leaf("IDENTIFIER", $2), $4->tVal};
		$$=new entry3; $$->tVal = create_node("ENUM", children, 2);
	}
	| ENUM IDENTIFIER {
		TREE_NODE* children[] = {create_leaf("ENUM", $1), create_leaf("IDENTIFIER", $2)};
		$$=new entry3; $$->tVal = create_node("enum_specifier", children, 2);
	}
	;

enumerator_list
	: enumerator {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("enumerator_list", children, 1);
	}
	| enumerator_list ',' enumerator {
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$$=new entry3; $$->tVal = create_node("enumerator_list", children, 2);
	}
	;

enumerator
	: enumeration_constant '=' constant_expression {
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		if(!exacttype($3->e, {"INT"}) and !exacttype($3->e, {"CHAR"})) { 
			type_error=1; cerr<<"error at line "<<yylineno<<": Integer constant not provided to enumerator " << $1->name << ' ' << $3->e.dt << '\n';
		} 
		$$=new entry3; $$->tVal = create_node("=", children, 2);
	}
	| enumeration_constant {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("enumerator", children, 1);
	}
	;

atomic_type_specifier
	: ATOMIC '(' type_name ')' {
		TREE_NODE* children[] = {$3->tVal};
		$$=new entry3; $$->tVal = create_node("ATOMIC", children, 1);
	}
	;

type_qualifier
	: CONST {
		TREE_NODE* children[] = {create_leaf("CONST", $1)};
		$$=new entry3; $$->tVal = create_node("type_qualifier", children, 1);
	}
	| RESTRICT {
		TREE_NODE* children[] = {create_leaf("RESTRICT", $1)};
		$$=new entry3; $$->tVal = create_node("type_qualifier", children, 1);
	}
	| VOLATILE {
		TREE_NODE* children[] = {create_leaf("VOLATILE", $1)};
		$$=new entry3; $$->tVal = create_node("type_qualifier", children, 1);
	}
	| ATOMIC {
		TREE_NODE* children[] = {create_leaf("ATOMIC", $1)};
		$$=new entry3; $$->tVal = create_node("type_qualifier", children, 1);
	}
	;

function_specifier
	: INLINE {
		TREE_NODE* children[] = {create_leaf("INLINE", $1)};
		$$=new entry3; $$->tVal = create_node("function_specifier", children, 1);
	}
	| NORETURN {
		TREE_NODE* children[] = {create_leaf("NORETURN", $1)};
		$$=new entry3; $$->tVal = create_node("function_specifier", children, 1);
	}
	;

alignment_specifier
	: ALIGNAS '(' type_name ')' {
		TREE_NODE* children[] = {$3->tVal};
		$$=new entry3; $$->tVal = create_node("ALIGNAS", children, 1);
	}
	| ALIGNAS '(' constant_expression ')' {
		TREE_NODE* children[] = {$3->tVal};
		$$=new entry3; $$->tVal = create_node("ALIGNAS", children, 1);
	}
	;

declarator
	: pointer direct_declarator {
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3(*$2); 
		$$->e.ptr+=$1->e.ptr;
		//cerr<<"# "<<$$->e.pr()<<endl;
		$$->tVal = create_node("declarator", children, 2);
	}
	| direct_declarator {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); 
		int fl=0;
		for(int i=1;i<($1->v.size());i++)if(($1->v)[i].name=="zero")fl=1;
		if(fl){type_error=1; cerr<<"error at line "<<yylineno<<": only first dimension of array can be uninitialized\n";}
		for(auto x:$$->v){($$->e).dim.pb(lookup(x.name).Y.val);}
		if(($$->e).dim.size()){cerr<<$$->place; for(auto x:($$->e).dim)cerr<<x<<endl;cerr<<endl;}
		$$->v.clear();
		//cerr<<"at top "<<$1->name<<endl;
		$$->tVal = create_node("declarator", children, 1);
	}
	;

direct_declarator
	: IDENTIFIER {
		TREE_NODE* children[] = {create_leaf("IDENTIFIER", $1)};
		$$=new entry3;
		$$->assign($1);
		$$->place=$1;
		$$->tVal = create_node("direct_declarator", children, 1);
	}
	| '(' declarator ')' {
		TREE_NODE* children[] = {$2->tVal};
		$$=new entry3; $$->tVal = create_node("direct_declarator", children, 1);
	}
	| direct_declarator '[' ']' {
		TREE_NODE* children[] = {$1->tVal, create_leaf("[]", "")};
		$$=new entry3(*$1); 
		($$->e).dimn++;
		$$->v.pb({"zero",{}});
		$$->pr("direct_declarator->direct_declarator[]");
		$$->tVal = create_node("direct_declarator", children, 2);
	}
	| direct_declarator '[' '*' ']' {
		TREE_NODE* children[] = {$1->tVal, create_leaf("[*]", "")};
		$$=new entry3; 
		$$->tVal = create_node("direct_declarator", children, 2);
	}
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']' {
		TREE_NODE* children[] = {$1->tVal, create_leaf("STATIC", $3), $4->tVal, $5->tVal};
		$$=new entry3; $$->tVal = create_node("[]", children, 4);
	}
	| direct_declarator '[' STATIC assignment_expression ']' {
		TREE_NODE* children[] = {$1->tVal, create_leaf("STATIC", $3), $4->tVal};
		$$=new entry3; $$->tVal = create_node("[]", children, 3);
	}
	| direct_declarator '[' type_qualifier_list '*' ']' {
		TREE_NODE* children[] = {$1->tVal, $3->tVal, create_leaf("*", "")};
		$$=new entry3; $$->tVal = create_node("[]", children, 3);
	}
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']' {
		TREE_NODE* children[] = {$1->tVal, $3->tVal, create_leaf("STATIC", $4), $5->tVal};
		$$=new entry3; $$->tVal = create_node("direct_declarator", children, 4);
	}
	| direct_declarator '[' type_qualifier_list assignment_expression ']' {
		TREE_NODE* children[] = {$1->tVal, $3->tVal, $4->tVal};
		$$=new entry3; $$->tVal = create_node("[]", children, 3);
	}
	| direct_declarator '[' type_qualifier_list ']' {
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$$=new entry3; $$->tVal = create_node("[]", children, 2);
	}
	| direct_declarator '[' assignment_expression ']' {
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$$=new entry3(*$1); 
		$$->v.pb({$3->place,{}});
		($$->e).dimn++;	//not pushing assignment expression
		//cerr<<"direct_declarator "<<$3->e.dt<<endl;

		if(!exacttype($3->e,{"INT"}) and !exacttype($3->e,{"CHAR"})) {type_error=1; cerr<<"error at line "<<yylineno<<": array index not an integer, it is "<<$3->e.pr()<<"\n";}
		$$->tVal = create_node("[]", children, 2);
	}
	| direct_declarator '(' parameter_type_list ')' {
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$$=new entry3(*$1);
		$$->e.dt="FUNC";
		if(func.count($1->name)) {
			// cerr<<"dodo\n";
			int temp=func[$1->name];
			int sz=arr[temp].arg.size();
			if(($3->v).size() != sz) {type_error=1; cerr<<"error at line "<<yylineno<<": redeclaration of function " << $1->name << " with different argument list\n";}
			else {
				for(int i=0;i<sz;i++) if(!exacttype(($3->v)[i].e, (arr[temp].arg)[i].e)) {
					type_error=1; cerr<<"error at line "<<yylineno<<": redefinition of argument " << i+1 << " to " << ($3->v)[i].e.pr() << ", previously defined as " << (arr[temp].arg)[i].e.pr() \
					<< " in function " << $1->name << "\n";
				}
			}
			for(auto x:$3->v)if(exacttype(x.e, {"VOID"})){cerr<<"error at line "<<yylineno<<": arguments cannot be of type VOID "<<x.name<<endl;}
			if(!arr[temp].def){
				arr[temp].arg.clear();
				for(auto x:$3->v){
					if(!lookup2(x.name).X)arr[temp].arg.pb(x);
					else {type_error=1;cerr<<"error at line "<<yylineno<<": variable "<<x.name<<" already declared\n";}
					//cerr<<"inserting something args in "<<curST<<endl;
				}
				arr[temp].arg = $3->v; 
				//cerr<<"insert args"<<" into "<<$1->name<<' '<<temp<<endl;
			}
			for(auto x: arr[temp].arg);//cerr<<x.name<<' '<<x.e.dt<<" ,";cerr<<endl;

		}
		else if(lookup2($1->name).X) {type_error=1; cerr<<"error at line "<<yylineno<<": redeclaration of variable " << $1->name << " to a function\n";}
		///check previous declarations
		else {
			int temp=curST;
			curST=totST++;
			arr[curST].par=temp;
			arr[curST].name=$1->name;
			for(auto x:$3->v)if(exacttype(x.e, {"VOID"})){cerr<<"error at line "<<yylineno<<": arguments cannot be of type VOID "<<x.name<<endl;}
			if(!arr[curST].def){
				arr[curST].arg.clear();
				for(auto x:$3->v){
					if(!lookup2(x.name).X)arr[curST].arg.pb(x);
					else {type_error=1;cerr<<"error at line "<<yylineno<<": variable "<<x.name<<" already declared\n";}
					//cerr<<"inserting something args in "<<curST<<endl;
				}
				arr[curST].arg = $3->v; 
				//cerr<<"insert args"<<" into "<<$1->name<<' '<<curST<<endl;
			}	
			func[$1->name]=curST;
			arr[curST].def=1;
			curST=temp;
		}
		$$->tVal = create_node("direct_declarator", children, 2);
	}
	| direct_declarator '(' ')' {
		TREE_NODE* children[] = {$1->tVal, create_leaf("()","")};
		$$=new entry3(*$1);
		$$->e.dt="FUNC";
		if(func.count($1->name)) {
			if(!arr[func[$1->name]].arg.empty()) {type_error=1; cerr<<"error at line "<<yylineno<<": redeclaration of function " << $1->name << " with empty argument list\n";}
		}
		else if(lookup2($1->name).X) {type_error=1; cerr<<"error at line "<<yylineno<<": redeclaration of symbol " << $1->name << "\n";}
		///check previous declarations
		else {
			int temp=curST;
			curST=totST++;
			arr[curST].par=temp;
			arr[curST].name=$1->name;
			//for(auto x:($3->v)){arr[curST].arg.pb(x); cerr<<"insert "<<x.name<<' '<< x.e.dt<<" into "<<$1->name<<' '<<curST<<endl;}
			func[$1->name]=curST;
			curST=temp;
		}
		$$->tVal = create_node("direct_declarator", children, 2);
	}
	| direct_declarator '(' identifier_list ')' {
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$$=new entry3;
		*$$=*$1;$$->v=$3->v;
		$$->tVal = create_node("direct_declarator", children, 2);
	}
	;

pointer
	: '*' type_qualifier_list pointer {
		TREE_NODE* children[] = {create_leaf("*", ""), $2->tVal, $3->tVal};
		$$=new entry3; $$->tVal = create_node("pointer", children, 3);
	}
	| '*' type_qualifier_list {
		TREE_NODE* children[] = {create_leaf("*", ""), $2->tVal};
		$$=new entry3; $$->tVal = create_node("pointer", children, 2);
	}
	| '*' pointer {
		TREE_NODE* children[] = {create_leaf("*", ""), $2->tVal};
		$$=new entry3(*$2); 
		$$->e.ptr++;
		$$->tVal = create_node("pointer", children, 2);
	}
	| '*' {
		TREE_NODE* children[] = {create_leaf("*", "")};
		$$=new entry3; 
		$$->e.ptr=1;
		$$->tVal = create_node("pointer", children, 1);
	}
	;

type_qualifier_list
	: type_qualifier {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("type_qualifier_list", children, 1);
	}
	| type_qualifier_list type_qualifier {
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3; $$->tVal = create_node("type_qualifier_list", children, 2);
	}
	;


parameter_type_list
	: parameter_list ',' ELLIPSIS {
		TREE_NODE* children[] = {$1->tVal, create_leaf("ELLIPSIS", $3)};
		$$=new entry3; $$->tVal = create_node("parameter_type_list", children, 2);
	}
	| parameter_list {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("parameter_type_list", children, 1);
	}
	;

parameter_list
	: parameter_declaration {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; 
		$$->v.pb({$1->name,$1->e});
		$$->tVal = create_node("parameter_list", children, 1);
	}
	| parameter_list ',' parameter_declaration {
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
		$$=new entry3(*$1); 
		$$->v.pb({$3->name,$3->e});
		$$->tVal = create_node("parameter_list", children, 2);
	}
	;

parameter_declaration
	: declaration_specifiers declarator {
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3(*$1);
		$$->e.ptr+=$2->e.ptr, $$->e.dimn+=$2->e.dimn;
		$$->name=$2->name;
		$$->tVal = create_node("parameter_declaration", children, 2);
	}
	| declaration_specifiers abstract_declarator {
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3; $$->tVal = create_node("parameter_declaration", children, 2);
	}
	| declaration_specifiers {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("parameter_declaration", children, 1);
	}
	;

identifier_list
	: IDENTIFIER {
		TREE_NODE* children[] = {create_leaf("IDENTIFIER", $1)};
		$$=new entry3; $$->tVal = create_node("identifier_list", children, 1);
	}
	| identifier_list ',' IDENTIFIER {
		TREE_NODE* children[] = {$1->tVal, create_leaf("IDENTIFIER", $3)};
		$$=new entry3; $$->tVal = create_node("identifier_list", children, 2);
	}
	;

type_name
	: specifier_qualifier_list abstract_declarator {
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3(*$1); 
		$$->e.ptr += $2->e.ptr;
		$$->tVal = create_node("type_name", children, 2);
	}
	| specifier_qualifier_list {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("type_name", children, 1);
	}
	;

abstract_declarator
	: pointer direct_abstract_declarator {
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3; $$->tVal = create_node("abstract_declarator", children, 2);
	}
	| pointer {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("abstract_declarator", children, 1);
	}
	| direct_abstract_declarator {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("abstract_declarator", children, 1);
	}
	;

direct_abstract_declarator
	: '(' abstract_declarator ')' {
		TREE_NODE* children[] = {$2->tVal};
	 	$$=new entry3; $$->tVal = create_node("direct_abstract_declarator", children, 1);
	}
	| '[' ']' {
		TREE_NODE* children[] = {create_leaf("[]", "")};
	 	$$=new entry3; $$->tVal = create_node("direct_abstract_declarator", children, 1);
	}
	| '[' '*' ']' {
		TREE_NODE* children[] = {create_leaf("[*]", "")};
	 	$$=new entry3; $$->tVal = create_node("direct_abstract_declarator", children, 1);
	}
	| '[' STATIC type_qualifier_list assignment_expression ']' {
		TREE_NODE* children[] = {create_leaf("STATIC", $2), $3->tVal, $4->tVal};
	 	$$=new entry3; $$->tVal = create_node("[]", children, 3);
	}
	| '[' STATIC assignment_expression ']' {
		TREE_NODE* children[] = {create_leaf("STATIC", $2), $3->tVal};
	 	$$=new entry3; $$->tVal = create_node("[]", children, 2);
	}
	| '[' type_qualifier_list STATIC assignment_expression ']' {
		TREE_NODE* children[] = {$2->tVal, create_leaf("STATIC", $3), $4->tVal};
	 	$$=new entry3; $$->tVal = create_node("[]", children, 3);
	}
	| '[' type_qualifier_list assignment_expression ']' {
		TREE_NODE* children[] = {$2->tVal, $3->tVal};
	 	$$=new entry3; $$->tVal = create_node("[]", children, 2);
	}
	| '[' type_qualifier_list ']' {
		TREE_NODE* children[] = {$2->tVal};
	 	$$=new entry3; $$->tVal = create_node("[]", children, 1);
	}
	| '[' assignment_expression ']' {
		TREE_NODE* children[] = {$2->tVal};
	 	$$=new entry3; $$->tVal = create_node("[]", children, 1);
	}
	| direct_abstract_declarator '[' ']' {
		TREE_NODE* children[] = {$1->tVal, create_leaf("[]", "")};
	 	$$=new entry3; $$->tVal = create_node("direct_abstract_declarator", children, 2);
	}
	| direct_abstract_declarator '[' '*' ']' {
		TREE_NODE* children[] = {$1->tVal, create_leaf("*", "")};
	 	$$=new entry3; $$->tVal = create_node("[]", children, 2);
	}
	| direct_abstract_declarator '[' STATIC type_qualifier_list assignment_expression ']' {
		TREE_NODE* children[] = {$1->tVal, create_leaf("STATIC", $3), $4->tVal, $5->tVal};
	 	$$=new entry3; $$->tVal = create_node("[]", children, 4);
	}
	| direct_abstract_declarator '[' STATIC assignment_expression ']' {
		TREE_NODE* children[] = {$1->tVal, create_leaf("STATIC", $3), $4->tVal};
	 	$$=new entry3; $$->tVal = create_node("[]", children, 3);
	}
	| direct_abstract_declarator '[' type_qualifier_list assignment_expression ']' {
		TREE_NODE* children[] = {$1->tVal, $3->tVal, $4->tVal};
	 	$$=new entry3; $$->tVal = create_node("[]", children, 3);
	}
	| direct_abstract_declarator '[' type_qualifier_list STATIC assignment_expression ']' {
		TREE_NODE* children[] = {$1->tVal, $3->tVal, create_leaf("STATIC", $4), $5->tVal};
	 	$$=new entry3; $$->tVal = create_node("[]", children, 4);
	}
	| direct_abstract_declarator '[' type_qualifier_list ']' {
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
	 	$$=new entry3; $$->tVal = create_node("[]", children, 2);
	}
	| direct_abstract_declarator '[' assignment_expression ']' {
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
	 	$$=new entry3; $$->tVal = create_node("[]", children, 2);
	}
	| '(' ')' {
		TREE_NODE* children[] = {};
	 	$$=new entry3; $$->tVal = create_node("()", children, 0);
	}
	| '(' parameter_type_list ')' {
		TREE_NODE* children[] = {$2->tVal};
	 	$$=new entry3; $$->tVal = create_node("direct_abstract_declarator", children, 1);
	}
	| direct_abstract_declarator '(' ')' {
		TREE_NODE* children[] = {$1->tVal};
	 	$$=new entry3; $$->tVal = create_node("direct_abstract_declarator", children, 1);
	}
	| direct_abstract_declarator '(' parameter_type_list ')' {
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
	 	$$=new entry3; $$->tVal = create_node("direct_abstract_declarator", children, 2);
	}
	;

initializer
	: '{' initializer_list '}'  {
		TREE_NODE* children[] = {$2->tVal};
	 	$$=new entry3(*$2); 
	 	$$->e.dimn++;
	 	$$->tVal = create_node("initializer", children, 1);
	}
	| '{' initializer_list ',' '}'  {
		TREE_NODE* children[] = {$2->tVal};
	 	$$=new entry3(*$2); 
	 	$$->e.dimn++;
	 	$$->tVal = create_node("initializer", children, 1);
	}
	| assignment_expression  {
		TREE_NODE* children[] = {$1->tVal};
	 	$$=new entry3(*$1); 
	 	$$->tVal = create_node("initializer", children, 1);
	}
	;

initializer_list
	: designation initializer  {
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
	 	$$=new entry3; $$->tVal = create_node("initializer_list", children, 2);
	}
	| initializer  {
		TREE_NODE* children[] = {$1->tVal};
	 	$$=new entry3(*$1); 
	 	//$$->v.pb({$1->name,$1->e});
	 	$$->tVal = create_node("initializer_list", children, 1);
	}
	| initializer_list ',' designation initializer  {
		TREE_NODE* children[] = {$1->tVal, $3->tVal, $4->tVal};
	 	$$=new entry3; $$->tVal = create_node("initializer_list", children, 3);
	}
	| initializer_list ',' initializer  {
		$$=new entry3(*$1); 
	 	if(!sametype($1->e, $3->e)) {type_error=1; cerr<<"error at line "<<yylineno<<": mismatching types in brace initialisation: "<<$1->e.dt<<" , "<< $3->e.dt<<endl;
	 		cerr<<"Note: brace initialization of structs not supported"<<endl;
	 	}
	 	string s="";
	 	if(!exacttype($1->e, $3->e)) s="(to "+$1->e.pr()+")";
	 	TREE_NODE* children1[] = {$3->tVal};
	 	TREE_NODE* children[] = {$1->tVal, create_node(s, children1, 1)};
	 	$$->tVal = create_node("initializer_list", children, 2);
	}
	;

designation
	: designator_list '='  {
		TREE_NODE* children[] = {$1->tVal, create_leaf("=", "")};
	 	$$=new entry3; $$->tVal = create_node("designation", children, 2);
	}
	;

designator_list
	: designator  {
		TREE_NODE* children[] = {$1->tVal};
	 	$$=new entry3; $$->tVal = create_node("designator_list", children, 1);
	}
	| designator_list designator  {
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
	 	$$=new entry3; $$->tVal = create_node("designator_list", children, 2);
	}
	;

designator
	: '[' constant_expression ']'  {
		TREE_NODE* children[] = {create_leaf("[", ""), $2->tVal, create_leaf("]", "")};
	 	$$=new entry3; $$->tVal = create_node("designator", children, 3);
	}
	| '.' IDENTIFIER  {
		TREE_NODE* children[] = {create_leaf(".", ""), create_leaf("IDENTIFIER", $2)};
	 	$$=new entry3; $$->tVal = create_node("designator", children, 2);
	}
	;

static_assert_declaration
	: STATIC_ASSERT '(' constant_expression ',' STRING_LITERAL ')' ';'  {
		TREE_NODE* children[] = {$3->tVal, create_leaf("STRING_LITERAL", $5)};
	 	$$=new entry3; $$->tVal = create_node("STATIC_ASSERT", children, 2);
	}
	;

statement
	: labeled_statement {
		TREE_NODE* children[] = {$1->tVal};
	 	$$=new entry3(*$1); $$->tVal = create_node("statement", children, 1);
	}
	| compound_statement {
		TREE_NODE* children[] = {$1->tVal};
	 	$$=new entry3(*$1); 
		// cerr<<"stmt - comp-st ";for(auto x:$$->nextList)cerr<<x<<endl;cerr<<"\n";
	 	$$->tVal = create_node("statement", children, 1);
	}
	| expression_statement {
		TREE_NODE* children[] = {$1->tVal};
		// cerr<<"stmt - exp-st ";for(auto x:$$->nextList)cerr<<x<<endl;cerr<<"\n";
	 	$$=new entry3(*$1); $$->tVal = create_node("statement", children, 1);
	}
	| selection_statement {
		TREE_NODE* children[] = {$1->tVal};
		// cerr<<"stmt - sel-st ";for(auto x:$$->nextList)cerr<<x<<endl;cerr<<"\n";
	 	$$=new entry3(*$1); $$->tVal = create_node("statement", children, 1);
	}
	| iteration_statement {
		TREE_NODE* children[] = {$1->tVal};
	 	$$=new entry3(*$1); $$->tVal = create_node("statement", children, 1);
	}
	| jump_statement {
		TREE_NODE* children[] = {$1->tVal};
	 	$$=new entry3(*$1); $$->tVal = create_node("statement", children, 1);
	}
	;

labeled_statement
	: IDENTIFIER ':' statement {
		TREE_NODE* children[] = {create_leaf("IDENTIFIER", $1), $3->tVal};
	 	$$=new entry3; $$->tVal = create_node(":", children, 2);
	}
	| CASE constant_expression ':' statement {
		TREE_NODE* children[] = {$2->tVal, $4->tVal};
	 	$$=new entry3; $$->tVal = create_node("CASE", children, 2);
	}
	| DEFAULT ':' statement {
		TREE_NODE* children[] = {create_leaf("DEFAULT", $1), $3->tVal};
	 	$$=new entry3; $$->tVal = create_node(":", children, 2);
	}
	;

compound_statement
	: '{' '}' {
		TREE_NODE* children[] = {};
	 	$$=new entry3; $$->tVal = create_node("{}", children, 0);
	}	
	|  '{' M block_item_list '}' {
		//cerr<<"axe "<<$2<<endl;
		curST=$2.X;
		//cerr<<"in compound_statement "<<curST<<endl;
		TREE_NODE* children[] = { $3->tVal };
	 	$$=new entry3(*$3); 
	 	$$->e.assign($3->e.dt);
		// cerr<<"comp-st ";for(auto x:$$->nextList)cerr<<x<<endl;cerr<<"\n";
	 	$$->tVal = create_node("compound_statement", children, 1);
	}
	;

M
	: {
		int temp=curST;
		if(scope_fl==0){curST=totST++; arr[curST].par=temp;}
		scope_fl=0;
		$$={temp,curST};
	}
	;

block_item_list
	: block_item {
		TREE_NODE* children[] = {$1->tVal};
	 	$$=new entry3(*$1); $$->tVal = create_node("block_item_list", children, 1);
	}
	| block_item_list P block_item {
		TREE_NODE* children[] = {$1->tVal, $3->tVal};
	 	$$=new entry3;
	 	backpatch($1->nextList, $2);
	 	$$->nextList = $3->nextList;
	 	$$->breakList = merge($1->breakList, $3->breakList);
	 	$$->continueList = merge($1->continueList, $3->continueList);
	 	$$->tVal = create_node("block_item_list", children, 2);
	}
	;

block_item
	: declaration {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("block_item", children, 1);
	}
	| statement {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); 
		// cerr<<"block-it ";for(auto x:$$->nextList)cerr<<x<<endl;cerr<<"\n";
		$$->tVal = create_node("block_item", children, 1);
	}
	;

expression_statement
	: ';' {
		TREE_NODE* children[] = {create_leaf(";", "")};
		$$=new entry3; $$->tVal = create_node("expression_statement", children, 1);
	}
	| expression ';' {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3(*$1); $$->tVal = create_node("expression_statement", children, 1);
	}
	;

selection_statement
	: IF '(' expression ')' P statement Q ELSE P statement Q {
		TREE_NODE* children[] = {$3->tVal,  $6->tVal, $10->tVal};
		$$=new entry3;
		backpatch($3->trueList, $5);
		backpatch($3->falseList, $9);
		// cerr << "$3->FL "; for(auto x: $3->falseList) cerr << x << ' '; cerr << endl;
		// cerr << "$6->NL "; for(auto x: $6->nextList) cerr << x << ' '; cerr << endl;	
		// cerr << "$7->NL "; for(auto x: $7->nextList) cerr << x << ' '; cerr << endl;
		$$->nextList = merge(merge($3->falseList, $7->nextList), merge($6->nextList, $10->nextList));
		$$->breakList = merge($6->breakList, $10->breakList);
		$$->continueList = merge($6->continueList, $10->continueList);
		// cerr << "$$->nextlist "; for(auto x: $$->nextList) cerr << x << ' '; cerr << endl;
		
		$$->tVal = create_node("IF-THEN-ELSE", children, 3);
	}
	| IF '(' expression ')' P statement Q {
		TREE_NODE* children[] = {$3->tVal, $6->tVal};
		$$=new entry3;
		backpatch($3->trueList, $5);
		$$->nextList = merge($3->falseList, $6->nextList);
		$$->breakList = $6->breakList;
		$$->continueList = $6->continueList;
		$$->tVal = create_node("IF-THEN", children, 2);
	}
	| SWITCH '(' expression ')' statement {
		TREE_NODE* children[] = {$3->tVal,  $5->tVal};
		$$=new entry3; $$->tVal = create_node("SWITCH", children, 2);
	}
	;

Q 	: {
		$$ = new entry3;
		$$->nextList.pb(nextQuad);
		gen({}, 6);
	}
	;

iteration_statement
	: WHILE '(' P expression ')' P statement Q {
		TREE_NODE* children[] = {$4->tVal, $7->tVal};
		$$=new entry3; 
		backpatch($4->trueList, $6);
		backpatch($7->nextList, $3);
		backpatch($7->continueList, $3);
		$$->nextList = merge($4->falseList, $7->breakList);
		//for(auto x:$4->falseList)cerr<<x<<endl;
		backpatch($8->nextList, $3);
		$$->tVal = create_node("WHILE", children, 2);
	}
	| DO statement WHILE '(' expression ')' ';' {
		TREE_NODE* children[] = {$2->tVal, $5->tVal};
		$$=new entry3; $$->tVal = create_node("DO-WHILE", children, 2);
	}
	| FOR '(' expression_statement P expression_statement ')' P statement Q {
		TREE_NODE* children[] = {$3->tVal, $5->tVal, $8->tVal};
		$$=new entry3;

		backpatch($5->trueList, $7);
		backpatch($9->nextList, $4);
		$$->nextList = merge($5->falseList, $8->breakList);
		backpatch($8->continueList, $4);
		
		$$->tVal = create_node("FOR", children, 3);
	}
	| FOR '(' expression_statement P expression_statement P expression ')' Q P statement Q {
		TREE_NODE* children[] = {$3->tVal, $5->tVal, $7->tVal, $11->tVal};
		$$=new entry3; 

		backpatch($5->trueList, $10);
		backpatch($12->nextList, $6);
		backpatch($9->nextList, $4);
		$$->nextList=merge($5->falseList, $11->breakList);
		backpatch($11->continueList, $6);
		// cerr<<"KKK:";for(auto x:$12->nextList)cerr<<x<<endl;

		$$->tVal = create_node("FOR", children, 4);
	}
	// | FOR '(' declaration expression_statement ')' statement {
	// 	TREE_NODE* children[] = {create_leaf("FOR", $1), create_leaf("(", ""), $3->tVal, $4->tVal, create_leaf(")", ""), $6->tVal};
	// 	$$=new entry3; $$->tVal = create_node("iteration_statement", children, 6);
	// }
	// | FOR '(' declaration expression_statement expression ')' statement {
	// 	TREE_NODE* children[] = {create_leaf("FOR", $1), create_leaf("(", ""), $3->tVal, $4->tVal, $5->tVal, create_leaf(")", ""), $7->tVal};
	// 	$$=new entry3; $$->tVal = create_node("iteration_statement", children, 7);
	// }
	;

jump_statement
	: GOTO IDENTIFIER ';' {
		TREE_NODE* children[] = {create_leaf("GOTO", $1), create_leaf("IDENTIFIER", $2)};
		$$=new entry3; $$->tVal = create_node("jump_statement", children, 2);
	}
	| CONTINUE ';' {
		TREE_NODE* children[] = {create_leaf("CONTINUE", $1)};
		$$=new entry3;
		$$->continueList.pb(nextQuad);
		gen({}, 6);
		$$->tVal = create_node("jump_statement", children, 1);
	}
	| BREAK ';' {
		TREE_NODE* children[] = {create_leaf("BREAK", $1)};
		$$=new entry3;
		$$->breakList.pb(nextQuad);
		gen({}, 6);
		$$->tVal = create_node("jump_statement", children, 1);
	}
	| RETURN ';' {
		TREE_NODE* children[] = {create_leaf("RETURN", $1)};
		$$=new entry3; 
		gen({}, 15);
		$$->tVal = create_node("jump_statement", children, 1);
	}
	| RETURN expression ';' {
		TREE_NODE* children[] = {create_leaf("RETURN", $1), $2->tVal};
		$$=new entry3;
		gen({$2->place}, 14);
		$$->tVal = create_node("jump_statement", children, 2);
	}
	;

translation_unit
	: external_declaration {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("translation_unit", children, 1);
	}
	| translation_unit external_declaration {
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3; $$->tVal = create_node("translation_unit", children, 2);	
	}
	;

external_declaration
	: function_definition {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("external_declaration", children, 1);
	}
	| declaration {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("external_declaration", children, 1);
	}
	;

function_definition
	: declaration_specifiers declarator declaration_list N compound_statement {
		TREE_NODE* children[] = {$1->tVal, $2->tVal, $3->tVal, $5->tVal};
	 	$$=new entry3; 
	 	$$->tVal = create_node("function_definition", children, 4);
	}
	| declaration_specifiers declarator N {curST = func[$2->name]; 
		// if(arr[curST].def) {type_error=1; cerr<<"error at line "<<yylineno<<": function redefinition of "<<$2->name<<endl;}
		arr[func[$2->name]].ret=$1->e;
		//cerr<<"at ret "<<($1->e.pr())<<endl;
	 	arr[func[$2->name]].def=1;
		gen({$2->place}, 12);
	} compound_statement {
		TREE_NODE* children[] = {$1->tVal, $2->tVal, $5->tVal};
	 	$$=new entry3; 
	 	curST=$3.X;
	 	gen({$2->place}, 13);
	 	$$->tVal = create_node("function_definition", children, 3);
	}
	;

N
	: {
		scope_fl=1;
		$$={curST, curST};
	}
	; 

declaration_list
	: declaration {
		TREE_NODE* children[] = {$1->tVal};
		$$=new entry3; $$->tVal = create_node("declaration_list", children, 1);
	}
	| declaration_list declaration {
		TREE_NODE* children[] = {$1->tVal, $2->tVal};
		$$=new entry3; $$->tVal = create_node("declaration_list", children, 2);
	}
	;

%%

