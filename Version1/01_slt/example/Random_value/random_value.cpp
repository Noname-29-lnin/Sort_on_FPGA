// random_float32_to_txt_optimized.cpp
// Build: g++ -O3 -std=c++17 -Wall -Wextra -pedantic random_float32_to_txt_optimized.cpp -o gen
// Run (args): ./gen float 32 1000000
// Run (interactive): ./gen
// Output: FILE_RANDOM (space-separated, one line)

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cerrno>
#include <ctime>
#include <string>
#include <filesystem>
#include <charconv>
#include <limits>

#define FILE_RANDOM "./tools/unsorted.txt"

// ---------------- PCG32 RNG ----------------
struct pcg32_random_t {
    std::uint64_t state = 0;
    std::uint64_t inc   = 0;
};

static inline std::uint32_t pcg32_random_r(pcg32_random_t* rng) {
    std::uint64_t oldstate = rng->state;
    rng->state = oldstate * 6364136223846793005ULL + (rng->inc | 1ULL);
    std::uint32_t xorshifted = (std::uint32_t)(((oldstate >> 18u) ^ oldstate) >> 27u);
    std::uint32_t rot = (std::uint32_t)(oldstate >> 59u);
    return (xorshifted >> rot) | (xorshifted << ((-(int)rot) & 31));
}

static inline void pcg32_srandom_r(pcg32_random_t* rng, std::uint64_t initstate, std::uint64_t initseq) {
    rng->state = 0U;
    rng->inc = (initseq << 1u) | 1u;
    (void)pcg32_random_r(rng);
    rng->state += initstate;
    (void)pcg32_random_r(rng);
}

// uniform uint32 in [0, bound) without modulo bias (rejection sampling)
static inline std::uint32_t pcg32_boundedrand_r(pcg32_random_t* rng, std::uint32_t bound) {
    if (bound == 0) return pcg32_random_r(rng);
    std::uint32_t threshold = (std::uint32_t)(-bound % bound);
    for (;;) {
        std::uint32_t r = pcg32_random_r(rng);
        if (r >= threshold) return r % bound;
    }
}

// uniform double in [0,1)
static inline double rng_double01(pcg32_random_t* rng) {
    // 53 random bits -> double
    std::uint64_t hi = (std::uint64_t)pcg32_random_r(rng);
    std::uint64_t lo = (std::uint64_t)pcg32_random_r(rng);
    std::uint64_t x  = (hi << 21) ^ lo;
    x &= ((1ULL << 53) - 1ULL);
    return (double)x / (double)(1ULL << 53);
}

// ---------------- Parsing ----------------
static std::uint64_t parse_u64(const char* s, const char* name) {
    errno = 0;
    char* end = nullptr;
    unsigned long long v = std::strtoull(s, &end, 10);
    if (errno != 0 || end == s || *end != '\0') {
        std::fprintf(stderr, "Invalid %s: %s\n", name, s);
        std::exit(1);
    }
    return (std::uint64_t)v;
}

// ---------------- Fast buffered writer ----------------
struct FastWriter {
    std::FILE* fp;
    char* buf;
    std::size_t cap;
    std::size_t len;

    explicit FastWriter(std::FILE* f, std::size_t capacity)
        : fp(f), buf((char*)std::malloc(capacity)), cap(capacity), len(0) {
        if (!buf) {
            std::fprintf(stderr, "malloc failed\n");
            std::exit(1);
        }
    }

    ~FastWriter() {
        flush();
        std::free(buf);
    }

    inline void flush() {
        if (len) {
            std::fwrite(buf, 1, len, fp);
            len = 0;
        }
    }

    inline void ensure(std::size_t need) {
        if (cap - len < need) flush();
    }

    inline void putc(char c) {
        ensure(1);
        buf[len++] = c;
    }

    inline void write_str(const char* s, std::size_t n) {
        // if very large, flush then write directly
        if (n >= cap) {
            flush();
            std::fwrite(s, 1, n, fp);
            return;
        }
        ensure(n);
        std::memcpy(buf + len, s, n);
        len += n;
    }

    template <typename IntT>
    inline void write_int(IntT v) {
        ensure(32);
        auto res = std::to_chars(buf + len, buf + cap, v);
        if (res.ec != std::errc()) {
            std::fprintf(stderr, "to_chars(int) failed\n");
            std::exit(1);
        }
        len += (std::size_t)(res.ptr - (buf + len));
    }

    inline void write_float32(float v) {
        // 9 digits is enough for float32 round-trip (max_digits10 for float is 9)
        ensure(64);
        auto res = std::to_chars(buf + len, buf + cap, (double)v,
                                 std::chars_format::general, 9);
        if (res.ec != std::errc()) {
            // fallback: (rare) if library doesn't support float to_chars well
            // use a minimal slow path
            char tmp[64];
            int n = std::snprintf(tmp, sizeof(tmp), "%.9g", (double)v);
            write_str(tmp, (std::size_t)n);
            return;
        }
        len += (std::size_t)(res.ptr - (buf + len));
    }
};

int main(int argc, char** argv) {
    std::string data_type;
    std::uint64_t bit = 0;
    std::uint64_t number = 0;

    if (argc >= 4) {
        data_type = argv[1];
        bit = parse_u64(argv[2], "bit");
        number = parse_u64(argv[3], "number");
    } else {
        std::printf("Type of data (int/float): ");
        char tbuf[16];
        if (std::scanf("%15s", tbuf) != 1) return 1;
        data_type = tbuf;

        std::printf("Input Size data (bit): ");
        unsigned long long tmp;
        if (std::scanf("%llu", &tmp) != 1) return 1;
        bit = (std::uint64_t)tmp;

        std::printf("Input Number of Elements: ");
        if (std::scanf("%llu", &tmp) != 1) return 1;
        number = (std::uint64_t)tmp;
    }

    for (auto& c : data_type) if (c >= 'A' && c <= 'Z') c = (char)(c - 'A' + 'a');

    if (!(data_type == "int" || data_type == "float")) {
        std::fprintf(stderr, "Invalid type! Choose 'int' or 'float'\n");
        return 1;
    }
    if (bit == 0 || bit >= 63) {
        std::fprintf(stderr, "bit must be in range [1..62]\n");
        return 1;
    }

    // size_bit = 2^bit
    std::uint64_t size_bit = 1ULL << bit;

    // low/high like python:
    // low = -(size_bit-1)/2, high = (size_bit-1)/2  (these are .5 for odd)
    // For int mode python does int(low)/int(high) => trunc toward zero.
    // Since (size_bit-1) is odd, low=-x.5 => int(low) = -floor(x) (NOT -ceil).
    std::uint64_t half = (size_bit - 1ULL) / 2ULL; // floor
    std::int64_t low_i  = -(std::int64_t)half;
    std::int64_t high_i =  (std::int64_t)half;

    double low_f  = -((double)(size_bit - 1ULL)) / 2.0;
    double high_f =  ((double)(size_bit - 1ULL)) / 2.0;
    double range_f = high_f - low_f;

    // seed RNG
    pcg32_random_t rng;
    std::uint64_t seed1 = (std::uint64_t)std::time(nullptr);
    std::uint64_t seed2 = (std::uint64_t)(uintptr_t)&rng;
    pcg32_srandom_r(&rng,
                    seed1 ^ (seed2 * 0x9E3779B97F4A7C15ULL),
                    seed2 ^ 0xDA3E39CB94B95BDBULL);

    // ensure ./tools exists
    try { std::filesystem::create_directories("./tools"); } catch (...) {}

    std::FILE* fp = std::fopen(FILE_RANDOM, "wb");
    if (!fp) {
        std::perror("fopen");
        return 1;
    }

    // writer buffer (16MB) - tune if needed
    FastWriter w(fp, 16u * 1024u * 1024u);

    if (data_type == "int") {
        // inclusive range [low_i, high_i]
        std::uint64_t span = (std::uint64_t)(high_i - low_i + 1);

        // Fast path if span fits 32-bit bound
        if (span <= UINT32_MAX) {
            std::uint32_t bound = (std::uint32_t)span;
            for (std::uint64_t i = 0; i < number; ++i) {
                if (i) w.putc('\n');
                std::uint32_t r = pcg32_boundedrand_r(&rng, bound);
                std::int64_t v = low_i + (std::int64_t)r;
                w.write_int<long long>((long long)v);
            }
        } else {
            // Rare for bit close to 62, still works
            for (std::uint64_t i = 0; i < number; ++i) {
                if (i) w.putc('\n');
                std::uint64_t r = ((std::uint64_t)pcg32_random_r(&rng) << 32) | (std::uint64_t)pcg32_random_r(&rng);
                std::int64_t v = low_i + (std::int64_t)(r % span);
                w.write_int<long long>((long long)v);
            }
        }
    } else {
        // float: uniform in [low, high) then cast to float32
        for (std::uint64_t i = 0; i < number; ++i) {
            if (i) w.putc('\n');
            double u = rng_double01(&rng);              // [0,1)
            double xd = low_f + range_f * u;            // [low, high)
            float xf = (float)xd;                       // float32
            w.write_float32(xf);
        }
    }

    w.putc('\n');
    w.flush();
    std::fclose(fp);

    std::printf("Data saved to: %s\n", FILE_RANDOM);
    return 0;
}
