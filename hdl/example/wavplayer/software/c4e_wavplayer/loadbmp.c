/* BMPファイルロードライブラリ                             */
/*                                                         */
/*   The MIT License (MIT)                                 */
/*   Copyright (c) 2023 J-7SYSTEM WORKS LTD.               */
/*   http://opensource.org/licenses/mit-license.php        */

#include "system.h"
#include <peridot_sdif_pff.h>

#include "xprintf.h"
#define printf(...) xprintf(__VA_ARGS__)

#include <stdlib.h>


// 画面情報 

#define na_VRAM_linesize	VGA_VRAM_LINEBYTES
#define window_xsize		VGA_VRAM_VIEWWIDTH
#define window_ysize		VGA_VRAM_VIEWHEIGHT

#define get_red(_x)			(((_x) & 0xf100)>> 8)
#define get_green(_x)		(((_x) & 0x07e0)>> 3)
#define get_blue(_x)		(((_x) & 0x001f)<< 3)
#define set_pixel(_r,_g,_b)	( (((_r) & 0xf8)<<8)|(((_g) & 0xfc)<<3)|(((_b) & 0xf8)>>3) )


// 指定のBMPファイルをフレームバッファに読み込む 

int loadbmp(const char *bmpname, alt_u16 *pFrameBuffer)
{
	FRESULT res;
	UINT readsize;

	unsigned char bmp_h[54];
	int xsize,ysize,bpp,line,progdiv,progcount;
	int x,y,width,height;
	unsigned char *pbmp, *bmp_pixel;
	alt_u16 *ppix,*pline;


	// BMPファイルを開く 

	do {
		if ((res = pf_open(bmpname)) != FR_OK) break;
		res = pf_read(bmp_h, 54, &readsize);		// ヘッダ読み出し 
	} while(0);

	if (res == FR_OK && readsize == 54) {
		if ((bmp_h[0x00] == 'B') && (bmp_h[0x01] == 'M')) {

			bpp = bmp_h[0x1c];
			if ( !(bpp==32 || bpp==24) ) {
				printf("[!] This color type cannot display.\n");
				return -2;
			}

			xsize = (bmp_h[0x13] << 8) | bmp_h[0x12];
			ysize = (bmp_h[0x17] << 8) | bmp_h[0x16];

			line = (xsize * bpp) / 8;
			if ((line % 4) != 0) line = ((line / 4) + 1) * 4;

		} else {
			printf("[!] '%s' is not supported.\n", bmpname);
			return -3;
		}

	} else {
		printf("[!] file open failure. (code:%d)\n", res);
		return -1;
	}


	// BMP画像データをロード 

	printf("bmpfile : %s\n   %d x %d pix, %dbpp, %dbyte/line\n",bmpname,xsize,ysize,bpp,line);
	printf("   [....................]\r   [");

	const int x_offs = 0;
	const int y_offs = 0;
	if (xsize+x_offs > window_xsize) width  = window_xsize-x_offs; else width  = xsize;
	if (ysize+y_offs > window_ysize) height = window_ysize-y_offs; else height = ysize;

	pline = pFrameBuffer + (y_offs + height - 1) * (na_VRAM_linesize/2);
	bmp_pixel = (unsigned char *)malloc(line);
	progdiv = height/20;
	progcount = 0;

	for(y=0 ; y<height ; y++) {
		ppix = pline;								// ピクセルポインタをラインの先頭へ移動 
		pbmp = bmp_pixel;

		res = pf_read(bmp_pixel, line, &readsize);
		if (res != FR_OK) break;

		if (bpp == 32) {
			for(x=0 ; x<width ; x++,pbmp+=4) *ppix++ = set_pixel(*(pbmp+2), *(pbmp+1), *(pbmp+0));
		} else {
			for(x=0 ; x<width ; x++,pbmp+=3) *ppix++ = set_pixel(*(pbmp+2), *(pbmp+1), *(pbmp+0));
		}

		pline -= (na_VRAM_linesize/2);

		progcount++;
		if (progcount == progdiv) {
			progcount = 0;
			printf("#");
		}
	}
	printf("\n");


	free(bmp_pixel);
	return 0;
}

