#ifndef TREE_H
#define TREE_H

/*
 * tree.h
 *
 * Parse tree representation
 */

struct identifier {
	char *name;
};
struct identifier *mkIdentifier(char *);

struct program_heading {
	struct identifier *prog_name;
};
struct program_heading *mk_program_heading(struct identifier *);

struct block {

};

struct program {
	struct program_heading *heading;
	struct block *body;
};
struct program *mk_program(struct program_heading *, struct block *);

#endif /* !TREE_H */

