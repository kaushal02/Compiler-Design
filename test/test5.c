// struct node{
//     int x;
//     int y;
// };
// int a;
// int printint(int a);
// struct node f(struct node a){
//     int y,z;
//     y=a.x;
//     z=a.y;
//     printint(y);
//     printint(z);
//     a.x=4;
//     a.y=5;
//     return a;

// }
// int printint(int a);
// int main(){
// 	int i=3;
//     while(1==1){
//         i=i+1;
//         if(i>10)break;
//     }
//     printint(i);
//     return i;
// }
int scanint();
int printint(int a);
int f(int n){
    if(n==1 || n==0 )return 1;
    //if()return 1;
    return f(n-1)+f(n-2);
}
int main(){
    int x;
    x=scanint();
    x=f(x);
    printint(x);
    return 0;
}
