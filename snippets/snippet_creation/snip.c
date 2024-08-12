#include <stdio.h>
#include <stdlib.h>

void arg_print(int argc, char** argv)
{
  for(int i = 1; i < argc; i++)
    {
	  printf("arg[%d]: %s", i, argv[i]);
    }
  if(argc > 1)
    {
	  printf("\n");
    }
}


int main(int argc, char **argv)
{
  arg_print(argc, argv);
  printf("Hello, world!\n");
  return EXIT_SUCCESS;
}
