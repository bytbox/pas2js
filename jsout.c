#include <stdio.h>

#include "tree.h"

void output_js_program(struct program *p) {
	printf("PROGRAM NAME: %s\n", p->heading->prog_name->name);
}

