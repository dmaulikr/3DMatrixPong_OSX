//
//  APAudio.h
//  Straight_C_3DAsciiPong
//
//  Created by Patrick on 11/16/13.
//  Copyright (c) 2013 Patrick. All rights reserved.
//

#ifndef Straight_C_3DAsciiPong_APAudio_h
#define Straight_C_3DAsciiPong_APAudio_h

//#include <SDL2_mixer/SDL_mixer.h>
#include <OpenAL/al.h>
#include <OpenAL/alc.h>
#include <AudioToolbox/AudioToolbox.h>

unsigned int impactID;
unsigned int  hitID;
unsigned int  missID;

ALCcontext* mContext;
ALCdevice* mDevice;

void loadAudio();
UInt32 audioFileSize(AudioFileID fileDescriptor);

void playMissAtLocation(float x);

void playHitAtLocation(float x);
void playPongAtLocation(float x);
void loadFile(char *filename, unsigned int ID);


#endif
