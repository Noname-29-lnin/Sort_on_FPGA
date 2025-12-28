// random_float32_to_txt.c
// Build: gcc -O3 -std=c11 -Wall -Wextra -pedantic random_float32_to_txt.c -o gen
// Run:   ./gen
// (Optional test run fewer lines): ./gen 1000000

#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdlib.h>
#include <errno.h>

#define FILE_RANDOM "./tools/unsorted.txt"

// --- 32-bit Feistel PRP (format-preserving over 2^32 values) ---
// Not cryptographically strong, but good for "random-looking" + guaranteed no-duplicate mapping.

static inline uint16_t rotl16(uint16_t x, unsigned r) {
    return (uint16_t)((x << (r & 15)) | (x >> ((16 - r) & 15)));
}

static inline uint16_t F(uint16_t r, uint32_t key, uint16_t round) {
    // Simple mixing function on 16-bit
    uint16_t k16 = (uint16_t)((key >> ((round & 1) ? 16 : 0)) & 0xFFFFu);
    uint16_t x = (uint16_t)(r ^ k16 ^ (uint16_t)(0x9E37u + 0xB7u * round));
    x = (uint16_t)(x * 0x5BD1u);
    x = (uint16_t)(x + rotl16(x, 7));
    x = (uint16_t)(x ^ rotl16(x, 3));
    return x;
}

static inline uint32_t feistel32(uint32_t x, uint32_t key) {
    uint16_t L = (uint16_t)(x >> 16);
    uint16_t R = (uint16_t)(x & 0xFFFFu);

    // 8 rounds is usually enough for "random-looking" for testing/data-gen
    for (uint16_t round = 0; round < 8; ++round) {
        uint16_t newL = R;
        uint16_t newR = (uint16_t)(L ^ F(R, key, round));
        L = newL;
        R = newR;
    }
    return ((uint32_t)L << 16) | (uint32_t)R;
}

static inline float u32_to_f32(uint32_t u) {
    // Bit-cast without UB
    float f;
    // Using memcpy is the strict-aliasing safe way
    unsigned char *pf = (unsigned char*)&f;
    unsigned char *pu = (unsigned char*)&u;
    pf[0] = pu[0]; pf[1] = pu[1]; pf[2] = pu[2]; pf[3] = pu[3];
    return f;
}

static uint64_t parse_u64(const char *s) {
    errno = 0;
    char *end = NULL;
    unsigned long long v = strtoull(s, &end, 10);
    if (errno != 0 || end == s || *end != '\0') {
        fprintf(stderr, "Invalid limit: %s\n", s);
        exit(1);
    }
    return (uint64_t)v;
}

int main(int argc, char **argv) {
    // Default: generate exactly 2^32 values
    uint64_t limit = (1ULL << 32);
    if (argc >= 2) {
        limit = parse_u64(argv[1]); // optional for testing
    }

    FILE *fp = fopen(FILE_RANDOM, "wb");
    if (!fp) {
        perror("fopen");
        return 1;
    }

    // Big buffer for fast IO (8MB)
    static unsigned char outbuf[8 * 1024 * 1024];
    setvbuf(fp, (char*)outbuf, _IOFBF, sizeof(outbuf));

    // Header (optional)
    // Each line: 8-hex-digits + tab + hexfloat + newline
    fprintf(fp, "u32_hex\tfloat_hex\n");

    const uint32_t key = 0xA5B35705u;

    if (limit >= (1ULL << 32)) {
        // Exactly 2^32 iterations without overflow using uint32_t wrap-safe loop
        for (uint32_t i = 0;; ++i) {
            uint32_t u = feistel32(i, key);
            float f = u32_to_f32(u);

            // Print both: exact bits + hex-float (portable-ish)
            // Note: %a prints "nan" for NaN without payload on some libc,
            // so the first column preserves uniqueness.
            fprintf(fp, "%08" PRIX32 "\t%a\n", u, (double)f);

            if (i == UINT32_MAX) break;
        }
    } else {
        // For testing smaller output
        for (uint64_t i64 = 0; i64 < limit; ++i64) {
            uint32_t i = (uint32_t)i64;
            uint32_t u = feistel32(i, key);
            float f = u32_to_f32(u);
            fprintf(fp, "%08" PRIX32 "\t%a\n", u, (double)f);
        }
    }

    if (fclose(fp) != 0) {
        perror("fclose");
        return 1;
    }

    return 0;
}
