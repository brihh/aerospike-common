/******************************************************************************
 * Copyright 2008-2013 by Aerospike.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy 
 * of this software and associated documentation files (the "Software"), to 
 * deal in the Software without restriction, including without limitation the 
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
 * sell copies of the Software, and to permit persons to whom the Software is 
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in 
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 *****************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <citrusleaf/cf_alloc.h>
#include <aerospike/as_boolean.h>

#include "internal.h"

/******************************************************************************
 * INLINE FUNCTIONS
 ******************************************************************************/
 
extern inline bool as_boolean_tobool(const as_boolean * b);
extern inline uint32_t as_boolean_hash(const as_boolean * b) ;
extern inline as_val * as_boolean_toval(const as_boolean * b);
extern inline as_boolean * as_boolean_fromval(const as_val * v);

/******************************************************************************
 * FUNCTIONS
 ******************************************************************************/

as_boolean * as_boolean_init(as_boolean * v, bool b) {
    as_val_init(&v->_, AS_BOOLEAN, false /*is_rcalloc*/);
    v->value = b;
    return v;
}

as_boolean * as_boolean_new(bool b) {
    as_boolean * v = (as_boolean *) malloc(sizeof(as_boolean));
    as_val_init(&v->_, AS_BOOLEAN, true /*is_rcalloc*/);
    v->value = b;
    return v;
}

// helper function
void as_boolean_destroy(as_boolean * b) {
	as_val_val_destroy( (as_val *) b );
    return;
}

void as_boolean_val_destroy(as_val *v) {
	return;
}

uint32_t as_boolean_val_hash(const as_val * v) {
    return as_boolean_hash((const as_boolean *)v);
}

char * as_boolean_val_tostring(const as_val * v) {
    if ( as_val_type(v) != AS_BOOLEAN ) return NULL;

    as_boolean * b = (as_boolean *) v;
    char * str = (char *) malloc(sizeof(char) * 6);
    bzero(str,6);
    if ( b->value ) {
        strcpy(str,"true");
    }
    else {
        strcpy(str,"false");
    }
    return str;

}