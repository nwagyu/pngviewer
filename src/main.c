#include <eadk.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <png.h>

const char eadk_app_name[] __attribute__((section(".rodata.eadk_app_name"))) = "Viewer";
const uint32_t eadk_api_level  __attribute__((section(".rodata.eadk_api_level"))) = 0;

// libpng insists on using setjmp, which in turns has dependencies on unwinding the stack
void __exidx_start() { }
void __exidx_end() { }

void rgba8888_rgb565(const uint8_t * src, uint8_t * dst) {
  uint8_t r = src[0];
  uint8_t g = src[1];
  uint8_t b = src[2];

  *(dst+1) = (r&0xF8) | (g>>5);
  *(dst) = ((g&0x7)<<5) | (b>>3);
}

int main(int argc, char * argv[]) {
  eadk_display_push_rect_uniform(eadk_screen_rect, eadk_color_black);

  png_image image;
  image.version = PNG_IMAGE_VERSION;
  image.opaque = NULL;
  if (!png_image_begin_read_from_memory(&image, eadk_external_data, eadk_external_data_size)) {
    printf("Error png_image_begin_read_from_memory\n");
    return -1;
  }
  printf("Image is %dx%d\n", image.width, image.height);
  image.format = PNG_FORMAT_RGBA;
  png_bytep buffer = malloc(PNG_IMAGE_SIZE(image));
  if (!buffer) {
    printf("Error allocating buffer\n");
    return -1;
  }

  if (!png_image_finish_read(&image, NULL, buffer, 0, NULL)) {
    printf("Error png_image_finish_read\n");
    return -1;
  }

  eadk_color_t * pixels = malloc(image.width*image.height*sizeof(eadk_color_t));
  if (!pixels) {
    printf("Error allocating pixels\n");
    return -1;
  }

  for (int i=0; i<image.width*image.height; i++) {
    rgba8888_rgb565(buffer+4*i, ((uint8_t *)pixels)+2*i);
  }

  eadk_display_push_rect((eadk_rect_t){(eadk_screen_rect.width-image.width)/2, (eadk_screen_rect.height-image.height)/2, image.width, image.height}, pixels);

  while (1) {
    eadk_timing_msleep(1000);
  }

  return 0;
}
