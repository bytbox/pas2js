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

struct constant_definition_part {

};

struct type_definition_part {

};

struct variable_definition_part {

};

struct procedure_and_function_definition_part {

};

struct statement_part {

};

struct block {
	struct constant_definition_part *consts;
	struct type_definition_part *types;
	struct variable_definition_part *vars;
	struct procedure_and_function_definition_part *funcs;
	struct statement_part *statements;
};
struct block *mk_block(
	struct constant_definition_part *,
	struct type_definition_part *,
	struct variable_definition_part *,
	struct procedure_and_function_definition_part *,
	struct statement_part *);

struct program {
	struct program_heading *heading;
	struct block *body;
};
struct program *mk_program(struct program_heading *, struct block *);

#endif /* !TREE_H */

