#include <libpressio.h>
#include <stddef.h>
#include <stdlib.h>
#include <limits.h>
#include <stdio.h>

int main() {
    size_t r1 = 500, r2=500, r3=100;
    int8_t* ptr = (int8_t*) malloc(sizeof(int8_t) * r1*r2*r3);
    for (size_t i = 0; i < r1; ++i) {
        for (int j = 0; j < r2; ++j) {
            for (int k = 0; k < r3; ++k) {
                ptr[i*r3*r2+j*r3+k] = rand() % CHAR_MAX;
            }
        }
    }

    // configure compressor
    struct pressio* library = pressio_instance();
    struct pressio_compressor* compressor = pressio_get_compressor(library, "manifest");
    struct pressio_options* opts = pressio_options_new();
    pressio_options_set_double(opts, "pressio:abs", 1e-4);
    pressio_options_set_string(opts, "manifest:compressor", "sz");
    pressio_compressor_set_options(compressor, opts);
    pressio_options_free(opts);

    //compress
    size_t dims[] ={r1,r2,r3};
    struct pressio_data* input = pressio_data_new_nonowning(pressio_int8_dtype, ptr, sizeof(dims)/sizeof(dims[0]), dims);
    struct pressio_data* compressed = pressio_data_new_empty(pressio_byte_dtype, 0, NULL);
    struct pressio_data* decompressed = pressio_data_new_empty(pressio_byte_dtype, 0, NULL);
    if(pressio_compressor_compress(compressor, input, compressed)) {
        printf("compression error: %s\n", pressio_compressor_error_msg(compressor));
        exit(1);
    }

    //decompress
    if(pressio_compressor_decompress(compressor, compressed, decompressed)) {
        printf("decompression error: %s\n", pressio_compressor_error_msg(compressor));
        exit(1);
    }

    //get a pointer to the data, and it's size in bytes;
    size_t size;
    int8_t* data = pressio_data_ptr(decompressed, &size);
    printf("size of decompressed %zd\n", size);

    pressio_data_free(input);
    pressio_data_free(decompressed);
    pressio_data_free(compressed);
    pressio_compressor_release(compressor);
    pressio_release(library);

}
