//
//  AsciiPong.h
//  3D Ascii Pong
//
//  Created by Patrick Cossette on 10/6/13.
//  Copyright (c) 2013 Patrick Cossette. All rights reserved.
//

#ifndef Straight_C_3DAsciiPong_AsciiPong_h
#define Straight_C_3DAsciiPong_AsciiPong_h

int paddlex;
int paddley;

int ballSpeedx;
int ballSpeedy;

int wallIsAtMax;

typedef struct s{
    int width;
    int height;
} csize;


void createGameOfSize(int width, int height, int ***game);
void getNextFrame(int width, int height, int **game);
void freeMap(int **game);

int objectDepth;
csize gameSize;


#endif
