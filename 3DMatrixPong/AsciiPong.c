//
//  AsciiPong.c
//  3D Ascii Pong
//
//  Created by Patrick Cossette on 10/6/13.
//  Copyright (c) 2013 Patrick Cossette. All rights reserved.
//


#include "AsciiPong.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
//#include "APAudio.h"

//Game Variables
int velocityx = 3;
int velocityy = 3;

int ballx = 100;
int bally = 30;

int paddlex = 20;
int paddley = 5;

int backgroundDepth = 0;
int objectDepth = 1;

int ballSpeedx = 2;
int ballSpeedy = 2;

int wallIsAtMax = 0;

int wall = 5;


//Ascii Canvas Functions
void createGameOfSize(int width, int height, int ***game){
    gameSize.width = width;
    gameSize.height = height;
    
    //loadAudio();
    
    int **g =  malloc(height * sizeof(int*));
    
    for(int y = 0; y < height; y++)
        g[y] = (int*) malloc(width*sizeof(int));
    
    *game = g;
}

void fillRect(int originX, int originY, int width, int height, int value, int **game){
    for(int y = originY; y < originY + height; y++){
        for (int x = originX; x < originX + width; x++){
            game[y][x] = value;
        }
    }
}

void clearBoard(int width, int height, int **game){
    for(int y = 0; y < height; y++) //4 && -4 to save time when clearing iPad board, causes bug on iPhone
        memset(game[y], 0, sizeof(int)*width);
}


//Generates depth map as a 2D integar array
void getNextFrame(int width, int height, int **game){
    //ball collision detection
    static int endgameHits = 0;
    static int wallIsRollingBack = 0;
    
    if (ballx <= -1) {
        ballSpeedx = velocityx;
        endgameHits = 0;
        wallIsAtMax = 0;
        if (wall > 5) {
            wallIsRollingBack = 1;
        }
    }
    if (wallIsRollingBack) {
        wall--;
        if (wall == 5) {
            wallIsRollingBack = 0;
        }
    }
    
    //Collision Detection
    if((ballSpeedx < 0) && (ballx <= paddlex + 5) && ballx > paddlex && (bally + 6 > paddley) && (bally < paddley + 25)){
        ballSpeedx = velocityx;
        if (wallIsAtMax) {
            endgameHits++;
            //if (endgameHits > 10) {
                //printf("game is won");
            //}
        }
        else{
            wall+=20;
            if (width-wall <= paddlex + 60) {
                wallIsAtMax = 1;
            }
        }
    }
    if (ballx > width-9-wall) {
        ballSpeedx = -velocityx;
        //playPongAtLocation(ballx);
    }
    if (bally <= 7) {
        ballSpeedy = velocityy;
    }
    if (bally > height-10) {
        ballSpeedy = -velocityy;
    }
    
    bally += ballSpeedy;
    ballx += ballSpeedx;
    
    //Clear board and draw game elements
    clearBoard(width, height, game);
    
    //Draw Paddle
    fillRect(paddlex, paddley, 4, 16, objectDepth, game);
    
    //Draw Ball
    fillRect(ballx, bally, 9, 6, objectDepth, game);
    
    //Draw Moving Wall
    fillRect(width-wall, 0, wall, height, objectDepth, game);
    
    //Draw slanted side walls
    
    fillRect(0, 0, width, 1, objectDepth+2, game);
    fillRect(0, 2, width, 1, objectDepth, game);
    fillRect(0, 1, width, 1, objectDepth+1, game);
    
    fillRect(0, height-3, width, 1, objectDepth, game);
    fillRect(0, height-2, width, 1, objectDepth+1, game);
    fillRect(0, height-1, width, 1, objectDepth+2, game);
}

void freeMap(int **game){
    for (int i = 0; i < gameSize.height; i++ ){
        free(game[i]);
    }
    
    free(game);
}


