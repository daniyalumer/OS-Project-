#include"kernel/types.h"
#include"kernel/stat.h"
#include"user.h"

int main(){
    printf("return val of system call is %d\n", munmap());
    printf("Congrats !! You have successfully added new system  call in xv6 OS :) \n");
    return 0; 
}

