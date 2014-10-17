/*
 All rights reserved.
 
 Permission to use, copy, modify, and distribute this software
 for any purpose with or without fee is hereby granted, provided
 that the above copyright notice and this permission notice
 appear in all copies.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT OF THIRD PARTY RIGHTS. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 Except as contained in this notice, the name of a copyright
 holder shall not be used in advertising or otherwise to promote
 the sale, use or other dealings in this Software without prior
 written authorization of the copyright holder.
 */

#ifndef libcex_type_h
#define libcex_type_h
//
#ifdef __cplusplus
extern "C"{
#endif
//

typedef char	xmt_bool;
typedef unsigned char	xmt_byte;

typedef signed short		xmt_int16;

typedef unsigned char		xmt_uint8;
typedef unsigned short		xmt_uint16;

typedef int					xmt_int32;
typedef unsigned int		xmt_uint32;

typedef   signed long long              xmt_int64;
typedef unsigned long long              xmt_uint64;

typedef xmt_int32		xmt_int;
typedef xmt_uint32		xmt_uint;

typedef wchar_t			xmt_wchar;

typedef char	xmt_char;

typedef float	xmt_float;
typedef double	xmt_double;
	
#define KCNull	NULL
#define XMTrue (xmt_bool)1
#define XMFalse (xmt_bool)0
#define FCBool(b) ((b)?KCTrue:KCFalse)
    
#define ContactNameFirstCharA 'a'
#define ContactNameFirstCharB 'b'
#define ContactNameFirstCharC 'c'
#define ContactNameFirstCharD 'd'
#define ContactNameFirstCharE 'e'
#define ContactNameFirstCharF 'f'
#define ContactNameFirstCharG 'g'
#define ContactNameFirstCharH 'h'
#define ContactNameFirstCharI 'i'
#define ContactNameFirstCharJ 'j'
#define ContactNameFirstCharK 'k'
#define ContactNameFirstCharL 'l'
#define ContactNameFirstCharM 'm'
#define ContactNameFirstCharN 'n'
#define ContactNameFirstCharO 'o'
#define ContactNameFirstCharP 'p'
#define ContactNameFirstCharQ 'q'
#define ContactNameFirstCharR 'r'
#define ContactNameFirstCharS 's'
#define ContactNameFirstCharT 't'
#define ContactNameFirstCharU 'u'
#define ContactNameFirstCharV 'v'
#define ContactNameFirstCharW 'w'
#define ContactNameFirstCharX 'x'
#define ContactNameFirstCharY 'y'
#define ContactNameFirstCharZ 'z'
#define ContactNamefirstCharSpecial '#'

#pragma mark -
#pragma mark keyboard type
#define OriginalKeyboard 0
#define T9Keyboard 1
#define NumberKeyboard 2

    
#define MaxSearchLength 11
    
#pragma mark -
#pragma mark voip
#define voipCount 30
    
    
#define EMAIL 0
    
#define HANZI_START 19968
#define HANZI_COUNT 20902
    
#define UNICODE_LOW 	0x4E00
#define UNICODE_HIGH 	0x9FA5
    
#define MULTI_PINYIN_BASE 1000

#define xm_IsSpecial(wchar) (((wchar) == (xmt_wchar)0x40) || ((wchar) == (xmt_wchar)0x2E)) ? XMTrue : XMFalse
#define xm_IsSpecial2(wchar) (((wchar) == (xmt_wchar)0x21) || ((wchar) == (xmt_wchar)0x23) || ((wchar) == (xmt_wchar)0x24) || ((wchar) == (xmt_wchar)0x25) || ((wchar) == (xmt_wchar)0x26) || ((wchar) == (xmt_wchar)0x7E) || ((xmt_wchar)0x2A <= (wchar)) && ((wchar) <= (xmt_wchar)0x2F) || ((xmt_wchar)0x3C <= (wchar)) && ((wchar) <= (xmt_wchar)0x3F)) ? XMTrue : XMFalse
#define xm_IsUnicode(wchar) (((xmt_uint16)wchar) >= (xmt_uint16)0x7f) ? XMTrue : XMFalse
#define xm_IsAlpha(wchar) ((((wchar) >= (xmt_wchar)0x41) && ((wchar) <= (xmt_wchar)0x5A)) || (((wchar) >= (xmt_wchar)0x61) && ((wchar) <= (xmt_wchar)0x7A))) ? XMTrue : XMFalse
#define xm_IsNum(wchar) (((wchar) >= (xmt_wchar)0x30) && ((wchar) <= (xmt_wchar)0x39)) ? XMTrue : XMFalse
#define xm_IsAlphaOrNum(wchar) ((xm_IsAlpha(wchar)) || (xm_IsNum(wchar))) ? XMTrue : XMFalse

#define xm_IsCJK(wchar) ((((xmt_uint16)wchar) >= ((xmt_uint16)UNICODE_LOW)) && (((xmt_uint16)wchar) <= ((xmt_uint16)UNICODE_HIGH))) ? XMTrue : XMFalse
#define xm_ToLower(wchar) ((xmt_uint16)wchar <= (xmt_uint16)0x5A) ? (xmt_uint16)(wchar+0x20) : wchar

    
    
//
#ifdef __cplusplus
}
#endif
#endif
