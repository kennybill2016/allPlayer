//
//  sha1.h
//  360CloudIPhone
//
//  Created by aizhongyuan on 12-2-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef _60CloudIPhone_sha1_h
#define _60CloudIPhone_sha1_h


/* POINTER defines a generic pointer type */
typedef unsigned char *POINTER;

/* UINT4 defines a four byte word */
typedef unsigned long int UINT4;

/* BYTE defines a unsigned character */
typedef unsigned char BYTE;

#ifndef TRUE
#define FALSE	0
#define TRUE	( !FALSE )
#endif /* TRUE */


/* #include "global.h" */

/* The structure for storing SHS info */

typedef struct 
{
	UINT4 digest[ 5 ];            /* Message digest */
	UINT4 countLo, countHi;       /* 64-bit bit count */
	UINT4 data[ 16 ];             /* SHS data buffer */
	int Endianness;
} SHA_CTX;

/* Message digest functions */

void SHAInit(SHA_CTX *);
void SHAUpdate(SHA_CTX *, BYTE *buffer, int count);
void SHAFinal(BYTE *output, SHA_CTX *);

#endif
