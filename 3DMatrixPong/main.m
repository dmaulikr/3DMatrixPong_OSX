//
//  main.c
//  3D Ascii Pong
//
//  Created by Patrick Cossette on 10/6/13.
//  Copyright (c) 2013 Patrick Cossette. All rights reserved.
//

#include <stdlib.h>
#include <time.h>

#include <SDL2/SDL.h>
#include <SDL2_ttf/SDL_ttf.h>

#include "AsciiPong.h"
#include "SIRTSGenerator.h"

//#include "APAudio.h"
#import "Utility.h"
#import "patch.h"

#define SCREEN_WIDTH  1920
#define SCREEN_HEIGHT 1200


const int MAX_FPS = 22;
const int TICKS_PER_FRAME = 1000 / MAX_FPS;


float sWidth = 0;
float sHeight = 0;
float sScale = 0;

bool fullscreen = true;

bool stereogram = true; //false will show depth map

SDL_Texture *line;
SDL_Window *mainWindow;
SDL_Renderer *renderer;

enum{
    initSuccess,
    videoError,
    vsyncError,
    windowError,
    rendererError,
    fontError,
};

int init();
void cleanup();

char depthdigits[] = {"0123456789"};

/*    MAIN    */

int main(int argc, const char * argv[]){
    screenResolution();
    
    sWidth   = screenWidth();
    sHeight  = screenHeight();
    sScale   = screenScale();
    
    sWidth = SCREEN_WIDTH;
    sHeight = SCREEN_HEIGHT;
    sScale = 1;
    
    printf("Scale: %.2f\nWidth: %.2f\nHeight:%.2f\n", sScale, sWidth, sHeight);
    
    int running = true;
    int onc = 0;
    char buffer[512] = {'\0'};
    int *intBuffer = NULL;
    int charsWide = 0;
    int charsHigh = 0;
    
    char *renderedLine = NULL;
    
    int **gamespace = NULL;
    
    srand((unsigned int)time(NULL));
    
    int sdl = init();
    if (sdl) {
        printf("Failed to initiate SDL, error code: %d", sdl);
    }
    
    SDL_Point windowSize;
    SDL_GetWindowSize(mainWindow, &windowSize.x, &windowSize.y);


    charsWide = windowSize.x / 9;
    charsHigh = windowSize.y / 18;
    
    intBuffer = (int*)malloc(sizeof(int)*charsWide+1);
    
    createGameOfSize(charsWide+1, charsHigh, &gamespace);
    getNextFrame(charsWide, charsHigh, gamespace);
    
    /* Load Font File */
    SDL_Color textColor;
    textColor.r = 0;
    textColor.g = 255;
    textColor.b = 0;
    
    TTF_Font *fonts[2];
    int selectedFont = 1;
    
    fonts[0] = TTF_OpenFont("tarzeau_ocr_a.ttf", 12);
    fonts[1] = TTF_OpenFont("DroidSansMono.ttf", 15);
    if (!fonts[1] || !fonts[0]) {
        printf("error loading font\n");
    }
    
    SDL_Surface* textSurface; // = TTF_RenderText_Solid(font, buffer, textColor);
    SDL_Texture *tex;         // = SDL_CreateTextureFromSurface(renderer, textSurface);
    
    SDL_Event Event;
    
    SDL_Color white = {255, 255, 255, 1};
    //int numberOfAgents = 0;
    //int agents[16] = {0}; //white lines when the ball gets close
    int offset = 0;
    //int time = 0;
    //int ticks = 9;
    int frameCount = 0;
    //float avgFPS = 0;
    float ticksSinceFrameStart = 0;
    bool isAgent = false;
    char msg[5];
    char msgs[4][4];
    strcpy(msgs[0], "free\0");
    strcpy(msgs[1], "your\0");
    strcpy(msgs[2], "mind\0");
    int onmsg = 100;
    
    bool backgroundIsBlack = true;
    while (running){
        ticksSinceFrameStart = SDL_GetTicks();
        while(SDL_PollEvent(&Event) != 0){
            //User requests quit
            if(Event.type == SDL_QUIT){
                running = false;
            }
            
            else if(Event.type == SDL_KEYDOWN) {
                //Select surfaces based on key press
                switch(Event.key.keysym.sym){
                    case SDLK_q:
                        running = false;
                        break;
                        
                    case SDLK_ESCAPE:
                        running = false;
                        break;
                        
                    case SDLK_e:
                        stereogram = !stereogram;
                        break;
                        
                    case SDLK_w:
                        objectDepth--;
                        break;
                        
                    case SDLK_r:
                        objectDepth++;
                        break;
                        
                    case SDLK_f:
                        selectedFont = !selectedFont;
                        if (selectedFont) {
                            charsWide++;
                        }
                        else{
                            charsWide--;
                        }
                        //gameSize.width = charsWide;
                        break;
                        
                    case SDLK_1:
                        textColor.r = 0;
                        textColor.g = 255;
                        textColor.b = 0;
                        break;
                        
                    case SDLK_2:
                        textColor.r = 255;
                        textColor.g = 0;
                        textColor.b = 0;
                        break;
                        
                    case SDLK_3:
                        textColor.r = 0;
                        textColor.g = 0;
                        textColor.b = 255;
                        break;
                        
                    case SDLK_4:
                        textColor.r = 255;
                        textColor.g = 255;
                        textColor.b = 0;
                        break;
                        
                    case SDLK_5:
                        textColor.r = 0;
                        textColor.g = 255;
                        textColor.b = 255;
                        break;
                        
                    case SDLK_6:
                        textColor.r = 255;
                        textColor.g = 0;
                        textColor.b = 255;
                        break;
                        
                    case SDLK_0:
                        backgroundIsBlack = !backgroundIsBlack;
                        break;
                        
                    default:
                        break;
                }
            }
        } //End of event loop
        
        const Uint8* currentKeyStates = SDL_GetKeyboardState(NULL);
        if(currentKeyStates[SDL_SCANCODE_UP])
            paddley-=3;
        
        if (currentKeyStates[SDL_SCANCODE_DOWN])
            paddley+=3;
        
        if (paddley < 3)
            paddley = 3;
        
        if (paddley > charsHigh - 15 - 3)
            paddley = charsHigh - 15 - 3;
        
        //End of event handling
        
        if (!stereogram && objectDepth > 9) {
                objectDepth = 9;
        }
        
        if (objectDepth < 0) {
            objectDepth = 0;
        }
        
        if (backgroundIsBlack) SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0xFF);
        else SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);
        
        SDL_RenderClear(renderer);

        
        SDL_Rect renderQuad;
        onc = offset;
        
        //wallIsAtMax = 1;
        
        /*
        if (wallIsAtMax) {
            numberOfAgents = rand() % 25;
            for (int i = 0; i < numberOfAgents; i++) {
                agents[i] = rand() % charsHigh-1;
            }
        }
        */
        
        getNextFrame(charsWide, charsHigh, gamespace);
        for(int y = 0;y < charsHigh; y++){
            isAgent = false;
            for(int x = 0; x < charsWide; x++){
                buffer[x] = depthdigits[(gamespace[y][x] > 9) ? 9 : gamespace[y][x]];
                intBuffer[x] = gamespace[y][x];
            }
            
            if (!(rand() % 70)) {
                onmsg = 0;
            }
            
            if (onmsg < 4) {
                switch (onmsg) {
                    case 0:
                        strcpy(msg, "free");
                        break;
                        
                    case 1:
                        strcpy(msg, "your");
                        break;
                        
                    case 2:
                        strcpy(msg, "mind");
                        break;
                        
                    default:
                        memset(&msg, 0, sizeof(msg));
                        break;
                }
                
                onmsg++;
            }
            
            if (stereogram)
                renderedLine = generateStereogram(intBuffer, charsWide, 20, msg);
            
            /*
            if (wallIsAtMax) {
                for (int i = 0; i < numberOfAgents; i++) {
                    if(agents[i] == y){
                        isAgent = true;
                        break;
                    }
                }
            }
            */
            
            white.r = 0 + rand() % 255;
            white.b = 0 + rand() % 255;
            white.g = 0 + rand() % 255;
            
            textSurface = TTF_RenderText_Blended(fonts[selectedFont], stereogram ? renderedLine : buffer, wallIsAtMax ? white : textColor);
            tex = SDL_CreateTextureFromSurface(renderer, textSurface);
            
            renderQuad.x = 0;
            renderQuad.y = y*18;
            renderQuad.w = textSurface->w;
            renderQuad.h = textSurface->h;
            SDL_RenderCopy(renderer, tex, NULL, &renderQuad);
            SDL_FreeSurface(textSurface);
            SDL_DestroyTexture(tex);
            if (stereogram) free(renderedLine);
        }
    

        SDL_RenderPresent(renderer);
        
        frameCount++;
        ticksSinceFrameStart = SDL_GetTicks() - ticksSinceFrameStart;
        
        //avgFPS = frameCount / ( SDL_GetTicks() / 1000.f );
        //printf("avg fps: %.2f\nticks per frame: %d\nTicks THIS frame: %.2f\n", avgFPS, TICKS_PER_FRAME, ticksSinceFrameStart);
        
        //Cap framerate
        if (!(TICKS_PER_FRAME - ticksSinceFrameStart <= 0)) {
            SDL_Delay(TICKS_PER_FRAME - ticksSinceFrameStart);
        }
    }
    
    //cleanup
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(mainWindow);
    TTF_CloseFont(fonts[0]);
    TTF_CloseFont(fonts[1]);
    
    free(intBuffer);
    freeMap(gamespace);
    return 0;
}



int init(){
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0){
        return videoError;
    }
    else{
        if( !SDL_SetHint( SDL_HINT_RENDER_VSYNC, "1" ) ){
            return vsyncError;
        }
        
        printf("Creating window of size: %.2f x %.2f\nBased on native size (%.2f %.2f) x scale: %.2f\n", sWidth*sScale, sHeight*sScale, screenWidth(), screenHeight(), screenScale());
        
        mainWindow = SDL_CreateWindow("3D Matrix Pong", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, fullscreen ? SDL_WINDOW_SHOWN | SDL_WINDOW_FULLSCREEN : SDL_WINDOW_SHOWN);
        
        if(mainWindow == NULL){
            return windowError;
        }
        else{
            renderer = SDL_CreateRenderer(mainWindow, -1, SDL_RENDERER_ACCELERATED);
            if(renderer == NULL){
                return rendererError;
            }
            else{
                SDL_SetRenderDrawColor(renderer, 0xFF, 0xFF, 0xFF, 0xFF);
    

                if( TTF_Init() == -1 ){
					return fontError;
				}
            }
        }
    }
    return initSuccess; //success
}
