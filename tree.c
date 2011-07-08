#include <stdlib.h>
#include <string.h>

#include "tree.h"

stringmap *mk_stringmap(int size) {
	stringmap *m = malloc(sizeof(stringmap *));
	m->size = size;
	m->len = 0;
	m->data = calloc(size*2, sizeof(void *));
	return m;
}

void sm_add(stringmap *m, char *key, void *data) {
	m->data[2*m->len] = key;
	m->data[1+2*m->len++] = data;
}

void *sm_get(stringmap *m, char *key) {
	int i;
	for (i=0; i<m->len; i+=2)
		if (strcmp(m->data[i], key) == 0) {
			return m->data[i+1];
		}
	return NULL;
}

void free_stringmap(stringmap *m) {
	free(m->data);
	free(m);
}

