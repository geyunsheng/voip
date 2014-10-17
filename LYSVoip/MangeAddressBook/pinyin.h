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

#ifndef pinyin_H_wrw4y56e5yhtg34wef
#define pinyin_H_wrw4y56e5yhtg34wef
//

#include "xm_type.h"
#ifdef __cplusplus
extern "C"{
#endif
//
    xmt_uint16 xm_get_unicode_sort_index(xmt_uint16 wUnicode);
    const char* xm_get_hanzi_pinyin(xmt_uint16 wUnicode, xmt_bool* pbMultiPinyin);
    
    int xm_string_to_pinyin(NSString * pws, int len, NSMutableArray * pRetPinyin);
//    NSMutableArray * xm_string_to_pinyin(const xmt_uint16 * pws, int len, NSMutableArray * pRetPinyin);
    void xm_string_to_pinyin_hanzi(const xmt_uint16 * pws, int len, NSMutableArray * pRetPinyin);
    void xm_string_to_raw_hanzi(const xmt_uint16 * pws, int len, NSMutableArray * pRetHanzi);    
    void xm_string_to_pinyin2(const xmt_uint16 * pws, int len, NSMutableString * pRetWstring);
    
    int xm_compare_pinyin(const xmt_uint16 * ps1, const xmt_uint16 * ps2);
    
    char kcl_wstring_exist_in_vector(NSArray * pVec, NSString * pws);
    
//    NSArray * splitString(const xmt_uint16 *strUS,int length);
    NSArray * splitString(NSString *str,int length);

//
#ifdef __cplusplus
}
#endif
#endif
