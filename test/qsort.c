int scanint();
int printint(int i);
int println();
int arr[100];
int partition(int low, int high) {
   int left = low, right, temp1;
   for(right = low + 1; right <= high; right=right+1) {
      if(arr[right] < arr[low]) {
         left=left+1; // Every element smaller than pivot comes before 'left'
         // Swap arr[left] and arr[right]
         temp1 = arr[left];
         arr[left] = arr[right];
         arr[right] = temp1;
        }
    }
    // Swap arr[low] and arr[left]
   temp1 = arr[left];
   arr[left] = arr[low];
   arr[low] = temp1;
   return left;
}

int quick_sort(int low, int high) {
   int pivot;
   if(low < high) { // Base case: when range length is 1, i.e. low == high, do nothing
      pivot = partition(low, high);
      quick_sort(low, pivot-1); // Recursively call for the left sub-arr
      quick_sort(pivot+1, high); // Recursively call for the right sub-arr
   }
   return 1;
}

int main() {
    int num, i, x;
    num=8;
    for(i=0; i<num; i=i+1) {
        x=8-i;
        arr[i] = x;
        printint(x);println();
    }
   quick_sort(0, num-1);
    for(i=0; i<num; i=i+1) {
        x = arr[i];
        
        println();
    }
    return 0;
}