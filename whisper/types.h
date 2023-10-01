#if !defined(__APPLE__) || !defined(TARGET_OS_IPHONE)
typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef unsigned short int uint16_t;
typedef long long int int64_t;
typedef unsigned long long int uint64_t;
typedef unsigned long int uintptr_t;
typedef int int32_t;
typedef unsigned int uint32_t;
#ifndef __cplusplus
typedef char bool;
#endif
#endif
typedef void *DartPostCObjectFnType;

typedef struct {
  char *error;
} CResult;
