/*
Write a new main.c that prints the elements of argv to the standard output, without using stdlib. 
This part is important, as here is where you make sure that you have the compiler set up correctly to work using the CDECL C calling convention, as described in class.*/




#include "util.h"
#define SYS_WRITE 4
#define STDOUT 1
#define SYS_OPEN 5
#define O_RDWR 2
#define SYS_SEEK 19
#define SEEK_SET 0
#define SHIRA_OFFSET 0x291
/*FILE* Infile = stdin;*/
/*FILE* Outfile = stdout;*/

extern int system_call();

int get_string_length(char* str){
  int length = 0;
  while (str[length] != '\0')
  {
    length++;
  }
  return length;
}

void print_string(char* str, int length){
  system_call(SYS_WRITE, STDOUT, str, length);

}

int main (int argc , char* argv[], char* envp[])
{
  int i =0 ;
    /*like debuger from Lab A*/
    while (i < argc)
    {
        system_call(SYS_WRITE, STDOUT, argv[i], get_string_length(argv[i]));
        system_call(SYS_WRITE, STDOUT, "\n", 1);
         i++;
  }



    /*exit after printing argc*/
    system_call(STDOUT);
   
  return 0;
}