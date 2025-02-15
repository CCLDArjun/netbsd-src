/*	$NetBSD: atomic.S,v 1.28 2022/04/09 23:32:52 riastradh Exp $	*/

/*-
 * Copyright (c) 2007 The NetBSD Foundation, Inc.
 * All rights reserved.
 *
 * This code is derived from software contributed to The NetBSD Foundation
 * by Jason R. Thorpe, and by Andrew Doran.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <sys/param.h>
#include <machine/asm.h>

#ifdef _KERNEL
#define	ALIAS(f, t)	STRONG_ALIAS(f,t)
#else
#define	ALIAS(f, t)	WEAK_ALIAS(f,t)
#endif

#ifdef _HARDKERNEL
#include <machine/frameasm.h>
#define LOCK			HOTPATCH(HP_NAME_NOLOCK, 1); lock
#define HOTPATCH_SSE2_MFENCE	HOTPATCH(HP_NAME_SSE2_MFENCE, 8);
#else
#define LOCK			lock
#define HOTPATCH_SSE2_MFENCE	/* nothing */
#endif

	.text

/* 32-bit */

ENTRY(_atomic_add_32)
	LOCK
	addl	%esi, (%rdi)
	ret
END(_atomic_add_32)

ENTRY(_atomic_add_32_nv)
	movl	%esi, %eax
	LOCK
	xaddl	%eax, (%rdi)
	addl	%esi, %eax
	ret
END(_atomic_add_32_nv)

ENTRY(_atomic_and_32)
	LOCK
	andl	%esi, (%rdi)
	ret
END(_atomic_and_32)

ENTRY(_atomic_and_32_nv)
	movl	(%rdi), %eax
1:
	movl	%eax, %ecx
	andl	%esi, %ecx
	LOCK
	cmpxchgl %ecx, (%rdi)
	jnz	1b
	movl	%ecx, %eax
	ret
END(_atomic_and_32_nv)

ENTRY(_atomic_dec_32)
	LOCK
	decl	(%rdi)
	ret
END(_atomic_dec_32)

ENTRY(_atomic_dec_32_nv)
	movl	$-1, %eax
	LOCK
	xaddl	%eax, (%rdi)
	decl	%eax
	ret
END(_atomic_dec_32_nv)

ENTRY(_atomic_inc_32)
	LOCK
	incl	(%rdi)
	ret
END(_atomic_inc_32)

ENTRY(_atomic_inc_32_nv)
	movl	$1, %eax
	LOCK
	xaddl	%eax, (%rdi)
	incl	%eax
	ret
END(_atomic_inc_32_nv)

ENTRY(_atomic_or_32)
	LOCK
	orl	%esi, (%rdi)
	ret
END(_atomic_or_32)

ENTRY(_atomic_or_32_nv)
	movl	(%rdi), %eax
1:
	movl	%eax, %ecx
	orl	%esi, %ecx
	LOCK
	cmpxchgl %ecx, (%rdi)
	jnz	1b
	movl	%ecx, %eax
	ret
END(_atomic_or_32_nv)

ENTRY(_atomic_swap_32)
	movl	%esi, %eax
	xchgl	%eax, (%rdi)
	ret
END(_atomic_swap_32)

ENTRY(_atomic_cas_32)
	movl	%esi, %eax
	LOCK
	cmpxchgl %edx, (%rdi)
	/* %eax now contains the old value */
	ret
END(_atomic_cas_32)

ENTRY(_atomic_cas_32_ni)
	movl	%esi, %eax
	cmpxchgl %edx, (%rdi)
	/* %eax now contains the old value */
	ret
END(_atomic_cas_32_ni)

/* 64-bit */

ENTRY(_atomic_add_64)
	LOCK
	addq	%rsi, (%rdi)
	ret
END(_atomic_add_64)

ENTRY(_atomic_add_64_nv)
	movq	%rsi, %rax
	LOCK
	xaddq	%rax, (%rdi)
	addq	%rsi, %rax
	ret
END(_atomic_add_64_nv)

ENTRY(_atomic_and_64)
	LOCK
	andq	%rsi, (%rdi)
	ret
END(_atomic_and_64)

ENTRY(_atomic_and_64_nv)
	movq	(%rdi), %rax
1:
	movq	%rax, %rcx
	andq	%rsi, %rcx
	LOCK
	cmpxchgq %rcx, (%rdi)
	jnz	1b
	movq	%rcx, %rax
	ret
END(_atomic_and_64_nv)

ENTRY(_atomic_dec_64)
	LOCK
	decq	(%rdi)
	ret
END(_atomic_dec_64)

ENTRY(_atomic_dec_64_nv)
	movq	$-1, %rax
	LOCK
	xaddq	%rax, (%rdi)
	decq	%rax
	ret
END(_atomic_dec_64_nv)

ENTRY(_atomic_inc_64)
	LOCK
	incq	(%rdi)
	ret
END(_atomic_inc_64)

ENTRY(_atomic_inc_64_nv)
	movq	$1, %rax
	LOCK
	xaddq	%rax, (%rdi)
	incq	%rax
	ret
END(_atomic_inc_64_nv)

ENTRY(_atomic_or_64)
	LOCK
	orq	%rsi, (%rdi)
	ret
END(_atomic_or_64)

ENTRY(_atomic_or_64_nv)
	movq	(%rdi), %rax
1:
	movq	%rax, %rcx
	orq	%rsi, %rcx
	LOCK
	cmpxchgq %rcx, (%rdi)
	jnz	1b
	movq	%rcx, %rax
	ret
END(_atomic_or_64_nv)

ENTRY(_atomic_swap_64)
	movq	%rsi, %rax
	xchgq	%rax, (%rdi)
	ret
END(_atomic_swap_64)

ENTRY(_atomic_cas_64)
	movq	%rsi, %rax
	LOCK
	cmpxchgq %rdx, (%rdi)
	/* %eax now contains the old value */
	ret
END(_atomic_cas_64)

ENTRY(_atomic_cas_64_ni)
	movq	%rsi, %rax
	cmpxchgq %rdx, (%rdi)
	/* %eax now contains the old value */
	ret
END(_atomic_cas_64_ni)

/* memory barriers */

ENTRY(_membar_acquire)
	/*
	 * Every load from normal memory is a load-acquire on x86, so
	 * there is never any need for explicit barriers to order
	 * load-before-anything.
	 */
	ret
END(_membar_acquire)

ENTRY(_membar_release)
	/*
	 * Every store to normal memory is a store-release on x86, so
	 * there is never any need for explicit barriers to order
	 * anything-before-store.
	 */
	ret
END(_membar_release)

ENTRY(_membar_sync)
	/*
	 * MFENCE, or a serializing instruction like a locked addq,
	 * is necessary to order store-before-load.  Every other
	 * ordering -- load-before-anything, anything-before-store --
	 * is already guaranteed without explicit barriers.
	 */
	HOTPATCH_SSE2_MFENCE
	/* 8 bytes of instructions */
	LOCK
	addq	$0, -8(%rsp)
	ret
END(_membar_sync)

ALIAS(atomic_add_32,_atomic_add_32)
ALIAS(atomic_add_64,_atomic_add_64)
ALIAS(atomic_add_int,_atomic_add_32)
ALIAS(atomic_add_long,_atomic_add_64)
ALIAS(atomic_add_ptr,_atomic_add_64)

ALIAS(atomic_add_32_nv,_atomic_add_32_nv)
ALIAS(atomic_add_64_nv,_atomic_add_64_nv)
ALIAS(atomic_add_int_nv,_atomic_add_32_nv)
ALIAS(atomic_add_long_nv,_atomic_add_64_nv)
ALIAS(atomic_add_ptr_nv,_atomic_add_64_nv)

ALIAS(atomic_and_32,_atomic_and_32)
ALIAS(atomic_and_64,_atomic_and_64)
ALIAS(atomic_and_uint,_atomic_and_32)
ALIAS(atomic_and_ulong,_atomic_and_64)
ALIAS(atomic_and_ptr,_atomic_and_64)

ALIAS(atomic_and_32_nv,_atomic_and_32_nv)
ALIAS(atomic_and_64_nv,_atomic_and_64_nv)
ALIAS(atomic_and_uint_nv,_atomic_and_32_nv)
ALIAS(atomic_and_ulong_nv,_atomic_and_64_nv)
ALIAS(atomic_and_ptr_nv,_atomic_and_64_nv)

ALIAS(atomic_dec_32,_atomic_dec_32)
ALIAS(atomic_dec_64,_atomic_dec_64)
ALIAS(atomic_dec_uint,_atomic_dec_32)
ALIAS(atomic_dec_ulong,_atomic_dec_64)
ALIAS(atomic_dec_ptr,_atomic_dec_64)

ALIAS(atomic_dec_32_nv,_atomic_dec_32_nv)
ALIAS(atomic_dec_64_nv,_atomic_dec_64_nv)
ALIAS(atomic_dec_uint_nv,_atomic_dec_32_nv)
ALIAS(atomic_dec_ulong_nv,_atomic_dec_64_nv)
ALIAS(atomic_dec_ptr_nv,_atomic_dec_64_nv)

ALIAS(atomic_inc_32,_atomic_inc_32)
ALIAS(atomic_inc_64,_atomic_inc_64)
ALIAS(atomic_inc_uint,_atomic_inc_32)
ALIAS(atomic_inc_ulong,_atomic_inc_64)
ALIAS(atomic_inc_ptr,_atomic_inc_64)

ALIAS(atomic_inc_32_nv,_atomic_inc_32_nv)
ALIAS(atomic_inc_64_nv,_atomic_inc_64_nv)
ALIAS(atomic_inc_uint_nv,_atomic_inc_32_nv)
ALIAS(atomic_inc_ulong_nv,_atomic_inc_64_nv)
ALIAS(atomic_inc_ptr_nv,_atomic_inc_64_nv)

ALIAS(atomic_or_32,_atomic_or_32)
ALIAS(atomic_or_64,_atomic_or_64)
ALIAS(atomic_or_uint,_atomic_or_32)
ALIAS(atomic_or_ulong,_atomic_or_64)
ALIAS(atomic_or_ptr,_atomic_or_64)

ALIAS(atomic_or_32_nv,_atomic_or_32_nv)
ALIAS(atomic_or_64_nv,_atomic_or_64_nv)
ALIAS(atomic_or_uint_nv,_atomic_or_32_nv)
ALIAS(atomic_or_ulong_nv,_atomic_or_64_nv)
ALIAS(atomic_or_ptr_nv,_atomic_or_64_nv)

ALIAS(atomic_swap_32,_atomic_swap_32)
ALIAS(atomic_swap_64,_atomic_swap_64)
ALIAS(atomic_swap_uint,_atomic_swap_32)
ALIAS(atomic_swap_ulong,_atomic_swap_64)
ALIAS(atomic_swap_ptr,_atomic_swap_64)

ALIAS(atomic_cas_32,_atomic_cas_32)
ALIAS(atomic_cas_64,_atomic_cas_64)
ALIAS(atomic_cas_uint,_atomic_cas_32)
ALIAS(atomic_cas_ulong,_atomic_cas_64)
ALIAS(atomic_cas_ptr,_atomic_cas_64)

ALIAS(atomic_cas_32_ni,_atomic_cas_32_ni)
ALIAS(atomic_cas_64_ni,_atomic_cas_64_ni)
ALIAS(atomic_cas_uint_ni,_atomic_cas_32_ni)
ALIAS(atomic_cas_ulong_ni,_atomic_cas_64_ni)
ALIAS(atomic_cas_ptr_ni,_atomic_cas_64_ni)

ALIAS(membar_acquire,_membar_acquire)
ALIAS(membar_release,_membar_release)
ALIAS(membar_sync,_membar_sync)

ALIAS(membar_consumer,_membar_acquire)
ALIAS(membar_producer,_membar_release)
ALIAS(membar_enter,_membar_sync)
ALIAS(membar_exit,_membar_release)
ALIAS(membar_sync,_membar_sync)

STRONG_ALIAS(_atomic_add_int,_atomic_add_32)
STRONG_ALIAS(_atomic_add_long,_atomic_add_64)
STRONG_ALIAS(_atomic_add_ptr,_atomic_add_64)

STRONG_ALIAS(_atomic_add_int_nv,_atomic_add_32_nv)
STRONG_ALIAS(_atomic_add_long_nv,_atomic_add_64_nv)
STRONG_ALIAS(_atomic_add_ptr_nv,_atomic_add_64_nv)

STRONG_ALIAS(_atomic_and_uint,_atomic_and_32)
STRONG_ALIAS(_atomic_and_ulong,_atomic_and_64)
STRONG_ALIAS(_atomic_and_ptr,_atomic_and_64)

STRONG_ALIAS(_atomic_and_uint_nv,_atomic_and_32_nv)
STRONG_ALIAS(_atomic_and_ulong_nv,_atomic_and_64_nv)
STRONG_ALIAS(_atomic_and_ptr_nv,_atomic_and_64_nv)

STRONG_ALIAS(_atomic_dec_uint,_atomic_dec_32)
STRONG_ALIAS(_atomic_dec_ulong,_atomic_dec_64)
STRONG_ALIAS(_atomic_dec_ptr,_atomic_dec_64)

STRONG_ALIAS(_atomic_dec_uint_nv,_atomic_dec_32_nv)
STRONG_ALIAS(_atomic_dec_ulong_nv,_atomic_dec_64_nv)
STRONG_ALIAS(_atomic_dec_ptr_nv,_atomic_dec_64_nv)

STRONG_ALIAS(_atomic_inc_uint,_atomic_inc_32)
STRONG_ALIAS(_atomic_inc_ulong,_atomic_inc_64)
STRONG_ALIAS(_atomic_inc_ptr,_atomic_inc_64)

STRONG_ALIAS(_atomic_inc_uint_nv,_atomic_inc_32_nv)
STRONG_ALIAS(_atomic_inc_ulong_nv,_atomic_inc_64_nv)
STRONG_ALIAS(_atomic_inc_ptr_nv,_atomic_inc_64_nv)

STRONG_ALIAS(_atomic_or_uint,_atomic_or_32)
STRONG_ALIAS(_atomic_or_ulong,_atomic_or_64)
STRONG_ALIAS(_atomic_or_ptr,_atomic_or_64)

STRONG_ALIAS(_atomic_or_uint_nv,_atomic_or_32_nv)
STRONG_ALIAS(_atomic_or_ulong_nv,_atomic_or_64_nv)
STRONG_ALIAS(_atomic_or_ptr_nv,_atomic_or_64_nv)

STRONG_ALIAS(_atomic_swap_uint,_atomic_swap_32)
STRONG_ALIAS(_atomic_swap_ulong,_atomic_swap_64)
STRONG_ALIAS(_atomic_swap_ptr,_atomic_swap_64)

STRONG_ALIAS(_atomic_cas_uint,_atomic_cas_32)
STRONG_ALIAS(_atomic_cas_ulong,_atomic_cas_64)
STRONG_ALIAS(_atomic_cas_ptr,_atomic_cas_64)

STRONG_ALIAS(_atomic_cas_uint_ni,_atomic_cas_32_ni)
STRONG_ALIAS(_atomic_cas_ulong_ni,_atomic_cas_64_ni)
STRONG_ALIAS(_atomic_cas_ptr_ni,_atomic_cas_64_ni)

STRONG_ALIAS(_membar_consumer,_membar_acquire)
STRONG_ALIAS(_membar_producer,_membar_release)
STRONG_ALIAS(_membar_enter,_membar_sync)
STRONG_ALIAS(_membar_exit,_membar_release)

#ifdef _HARDKERNEL
	.section .rodata

LABEL(sse2_mfence)
	mfence
	ret
	nop; nop; nop; nop;
LABEL(sse2_mfence_end)
#endif	/* _HARDKERNEL */
