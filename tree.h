#ifndef TREE_H
#define TREE_H

/*
 * tree.h
 *
 * Parse tree representation
 */

typedef struct stringmap {
	void **data;
	int size;
	int len;
} stringmap;

stringmap *mk_stringmap(int);
void sm_add(stringmap *m, char *key, void *data);
void *sm_get(stringmap *m, char *key);
void free_stringmap(stringmap *);

#define MKSM(x, y) stringmap *sm = mk_stringmap(x + 1); sm_add(sm, "_", y);
#define ADD(x,y) sm_add(sm, x, y)

#endif /* !TREE_H */

