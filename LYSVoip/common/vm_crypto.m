//#ifdef TEST
#include "vm_crypto.h"
#include <string.h>

#define FULL_UNROLL

/*øÏÀŸº”√‹À„∑®¬Î±Ì£¨«ÎŒ–ﬁ∏ƒ*/
static uint8_t rev[16] = { 0x0b, 0x04, 0x0f, 0x06, 0x01, 0x0a, 0x03, 0x09, 
						   0x0d, 0x07, 0x05, 0x00, 0x0e, 0x08, 0x0c, 0x02 };
static uint8_t sk[16]  = { 0xd7, 0x6a, 0xa4, 0x78, 0xf5, 0x7c, 0x42, 0xab,
						   0xa4, 0x52, 0xf6, 0x76, 0x3b, 0x4d, 0x61, 0xce };

/*≥ı ºªØº”Ω‚√‹µƒKEY*/
int vm_crypto_quick_init_key(vm_crypto_quick_key_t* key, const uint8_t* userkey, int len)
{
	static int __smask[] = {0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01};
	uint8_t ukey[8] = { 0 };
	int i, j;

	/*∞¥8bits’πø™*/
	memset(key->rk, 0, 8);
	memset(key->iv, 0, 8);
	
	for (i=0; *userkey != '\0'; i++) 
		ukey[i&0x7] ^= *userkey++;

	for (i=0; i<8; i++)	for (j=0; j<8; j++)
		key->rk[i] |= ukey[(i+j)&0x07] & __smask[(i+j)&0x07];
	return 0;
}

/*øÏÀŸº”√‹À„∑®£¨ ‰≥ˆŒ™8±∂’˚ ˝*/
/* userkey∞¥64bits’πø™ */
/* src[0] => div(8) => ^iv[0]=> rev(16) => ^key[0] => ^sk[0] => dst[0] (dst[0] -> iv[next]) */
int vm_crypto_quick_enc(vm_crypto_quick_key_t* key, uint8_t* dst, const uint8_t* src, int len)
{
	uint8_t* base = dst;
	uint8_t* iv = key->iv;
	uint8_t* rk = key->rk;

	while (len > 0)
	{
#ifdef FULL_UNROLL
		iv[0] ^= src[7];
		iv[1] ^= src[6];
		iv[2] ^= src[5];
		iv[3] ^= src[4];
		iv[4] ^= src[3];
		iv[5] ^= src[2];
		iv[6] ^= src[1];
		iv[7] ^= src[0];

		dst[0] = (rev[iv[0]>>4] + (rev[iv[0]&0xF]<<4)) ^ rk[0] ^ sk[0];
		dst[1] = (rev[iv[1]>>4] + (rev[iv[1]&0xF]<<4)) ^ rk[1] ^ sk[1];
		dst[2] = (rev[iv[2]>>4] + (rev[iv[2]&0xF]<<4)) ^ rk[2] ^ sk[2];
		dst[3] = (rev[iv[3]>>4] + (rev[iv[3]&0xF]<<4)) ^ rk[3] ^ sk[3];
		dst[4] = (rev[iv[4]>>4] + (rev[iv[4]&0xF]<<4)) ^ rk[4] ^ sk[4];
		dst[5] = (rev[iv[5]>>4] + (rev[iv[5]&0xF]<<4)) ^ rk[5] ^ sk[5];
		dst[6] = (rev[iv[6]>>4] + (rev[iv[6]&0xF]<<4)) ^ rk[6] ^ sk[6];
		dst[7] = (rev[iv[7]>>4] + (rev[iv[7]&0xF]<<4)) ^ rk[7] ^ sk[7];
		
		memcpy(iv, dst, 8);
		
#else //FULL_UNROLL
		int n;
		for (n=0; n<8; n++)
		{
			iv[n] ^= src[7-n];
			iv[n] = (rev[iv[n]>>4] + (rev[iv[n]&0xF]<<4)) ^ rk[n] ^ sk[n];
			dst[n] = iv[n];
		}

#endif //FULL_UNROLL
		
		len -= 8;
		src += 8;
		dst += 8;
	}
	return (dst - base);

}

/*øÏÀŸΩ‚√‹À„∑®£¨ ‰≥ˆŒ™8±∂’˚ ˝*/
/* src[0] => ^sk[0]=> ^key[0] => rev(16) => ^iv[0] => div(8) => dst[0] / (src[0]->iv[next]) */
int vm_crypto_quick_dec(vm_crypto_quick_key_t* key, uint8_t* dst, const uint8_t* src, int len)
{
	uint8_t* base = dst;
	uint8_t* iv = key->iv;
	uint8_t* rk = key->rk;
	uint8_t  r[8];
	
	while (len > 0) 
	{	
#ifdef FULL_UNROLL	
		r[0] = src[0] ^ rk[0] ^ sk[0];
		r[1] = src[1] ^ rk[1] ^ sk[1];
		r[2] = src[2] ^ rk[2] ^ sk[2];
		r[3] = src[3] ^ rk[3] ^ sk[3];
		r[4] = src[4] ^ rk[4] ^ sk[4];
		r[5] = src[5] ^ rk[5] ^ sk[5];
		r[6] = src[6] ^ rk[6] ^ sk[6];
		r[7] = src[7] ^ rk[7] ^ sk[7];
		
		dst[7] = (rev[r[0]>>4] + (rev[r[0]&0xF]<<4)) ^ iv[0];
		dst[6] = (rev[r[1]>>4] + (rev[r[1]&0xF]<<4)) ^ iv[1];
		dst[5] = (rev[r[2]>>4] + (rev[r[2]&0xF]<<4)) ^ iv[2];
		dst[4] = (rev[r[3]>>4] + (rev[r[3]&0xF]<<4)) ^ iv[3];
		dst[3] = (rev[r[4]>>4] + (rev[r[4]&0xF]<<4)) ^ iv[4];
		dst[2] = (rev[r[5]>>4] + (rev[r[5]&0xF]<<4)) ^ iv[5];
		dst[1] = (rev[r[6]>>4] + (rev[r[6]&0xF]<<4)) ^ iv[6];
		dst[0] = (rev[r[7]>>4] + (rev[r[7]&0xF]<<4)) ^ iv[7];

		memcpy(iv, src, 8);
		
#else //FULL_UNROLL
		int n;
		for (n=0; n<8; n++)
		{
			r[n] = src[n] ^ rk[n] ^ sk[n];
			dst[7-n] = (rev[r[n]>>4] + (rev[r[n]&0xF]<<4)) ^ iv[n];
			iv[n] = src[n];
		}

#endif //FULL_UNROLL
		
		len -= 8;
		src += 8;
		dst += 8;
	}
	return (dst - base);
}


int AES_Encrypt_1(const unsigned char *in,int inlen,unsigned char *out,const unsigned char *key)
{
	vm_crypto_quick_key_t ekey;
	vm_crypto_quick_init_key(&ekey, key, 8);
	return vm_crypto_quick_enc(&ekey, out, in, inlen);
}

int AES_Decrypt_1(const unsigned char *in, int inlen, unsigned char *out,const unsigned char *key)
{
	vm_crypto_quick_key_t dkey;
	vm_crypto_quick_init_key(&dkey, key, 8);
	return vm_crypto_quick_dec(&dkey, out, in, inlen);
}

//#endif
