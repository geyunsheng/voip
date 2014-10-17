#ifndef __VM_CRYPTO_H__
#define __VM_CRYPTO_H__

typedef unsigned char uint8_t;

typedef struct {
	uint8_t iv[8];
	uint8_t rk[8];
} vm_crypto_quick_key_t;

/*初始化加解密的KEY*/
int vm_crypto_quick_init_key(vm_crypto_quick_key_t* key, const uint8_t* userkey, int len);

/*加密处理*/
int vm_crypto_quick_enc(vm_crypto_quick_key_t* key, uint8_t* dst, const uint8_t* src, int len);

/*解密处理*/
int vm_crypto_quick_dec(vm_crypto_quick_key_t* key, uint8_t* dst, const uint8_t* src, int len);


//
int AES_Encrypt_1(const unsigned char *in,int inlen,unsigned char *out,const unsigned char *key);
int AES_Decrypt_1(const unsigned char *in, int inlen, unsigned char *out,const unsigned char *key);


#endif	//__VM_CRYPTO_H__
