#include "types.h"


typedef struct CResultBytes {
  char *error;
  uint32_t len;
  const uint8_t *value;
} CResultBytes;

struct CResultBytes transcribe_file(char *audio_filename);
