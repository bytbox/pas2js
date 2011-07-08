#include <stdlib.h>
#include <string.h>

#include "tree.h"

#define NODE(x) malloc(sizeof(struct x *))
#define MKNODE(x,n) struct x *n = NODE(x)

struct identifier *
mkIdentifier(char *name) {
	struct identifier *i = NODE(identifier);
	i->name = strdup(name);
	return i;
}

struct program_heading *
mk_program_heading(struct identifier *i) {
	struct program_heading *h = NODE(program_heading);
	h->prog_name = i;
	return h;
}

struct program *
mk_program(struct program_heading *h, struct block *b) {
	MKNODE(program,p);
	p->heading = h;
	p->body = b;
	return p;
}

