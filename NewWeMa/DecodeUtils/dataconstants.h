//
//  dataconstants.h
//  InvisibleBarcodeIos
//
//  Created by Manish Adhikari on 15/01/2018.
//  Copyright © 2018 W. All rights reserved.
//

#ifndef dataconstants_h
#define dataconstants_h

#include <stdio.h>

#endif /* dataconstants_h */

#define MM 	4
#define NN  ((1 << MM) - 1)
#define TT  1
#define KK  (NN - 2 * TT)
#define RSCODE_CODE_NUM_PER_GROUP 12
#define RSCODE_GROUP_NUM 1
#define BITS_PER_POS 2
#define TYPES_PER_CODE 3
#define GRID_WIDTH 3
#define GRID_HEIGHT 3
#define DATA_ROW 5
#define DATA_COL 5
#define CM_PER_INCH 2.54
#define BLACK_DOT (0xFF000000)
#define WHITE_DOT (0xFFFFFFFF)
#define GRID_SIZE ((GRID_WIDTH) * (GRID_HEIGHT))
#define GRID_PIXEL_WIDTH ((GRID_WIDTH) * (PIXEL_PER_DOT_WIDTH))
#define GRID_PIXEL_HEIGHT ((GRID_HEIGHT) * (PIXEL_PER_DOT_HEIGHT))
#define DATA_LEN ((DATA_ROW) * (DATA_COL))
#define FIELD_ROW (DATA_ROW + 2)
#define FIELD_COL (DATA_COL + 2)
#define CODE_NUM (1 << BITS_PER_POS)
#define PIXEL_PER_DOT_WIDTH 2
#define PIXEL_PER_DOT_HEIGHT 2
#define PIXEL_PER_DOT ((PIXEL_PER_DOT_WIDTH) * (PIXEL_PER_DOT_HEIGHT))
#define BLANK_PIXEL_HEIGHT 3
#define BLANK_PIXEL_WIDTH 3
#define VERT_BLANK_PIXEL_HEIGHT 3
#define FIELD_PIXEL_WIDTH (((FIELD_COL) * (GRID_PIXEL_WIDTH)) + ((FIELD_COL) * (BLANK_PIXEL_WIDTH)))
#define FIELD_PIXEL_HEIGHT (((FIELD_ROW) * (GRID_PIXEL_HEIGHT)) + ((FIELD_ROW) * (VERT_BLANK_PIXEL_HEIGHT)))
#define ACTUAL_FIELD_PIXEL_WIDTH (FIELD_PIXEL_WIDTH - GRID_PIXEL_WIDTH - BLANK_PIXEL_WIDTH)
#define ACTUAL_FIELD_PIXEL_HEIGHT (FIELD_PIXEL_HEIGHT - GRID_PIXEL_HEIGHT - BLANK_PIXEL_HEIGHT)

#define NORM 0
#define HORI_HALF 1
#define VERT_HALF 2

int transfer_bits_per_pos(unsigned char *src, int src_len, int src_bits_per_code, int *data, int to_bits_per_code);
