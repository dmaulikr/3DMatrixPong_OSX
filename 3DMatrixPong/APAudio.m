//
//  APAudio.c
//  Straight_C_3DAsciiPong
//
//  Created by Patrick on 11/16/13.
//  Copyright (c) 2013 Patrick. All rights reserved.
//


/*  NOT YET IN USE
 
    The iPad version of this game has 3D audio using OpenAL (only available when using headphones)
    TODO: Add 3D audio to this desktop version
 
 */

#include <stdio.h>
#include "APAudio.h"

#import "Utility.h"


void loadAudio(){
    
    
    //bufferStorageArray = [[NSMutableArray alloc] init];
    //soundDictionary = [[NSMutableDictionary alloc] init];
    mDevice = alcOpenDevice(NULL); // select the "preferred device"
    if (mDevice) {
        // use the device to make a context
        mContext=alcCreateContext(mDevice,NULL);
        // set my context to the currently active one
        alcMakeContextCurrent(mContext);
    }
    else{
        printf("Could not create context\n");
    }
    
    char hit1Path[256] = {'\0'};
    char hit2Path[256] = {'\0'};

    
    sprintf(hit1Path, "%s/hit3.caf", currentWorkingDirectory());
    sprintf(hit2Path, "%s/hit1.caf", currentWorkingDirectory());

    loadFile(hit1Path, impactID);
    loadFile(hit2Path, hitID);
    loadFile(hit2Path, missID);
    
}

UInt32 audioFileSize(AudioFileID fileDescriptor){
    UInt64 outDataSize = 0;
    UInt32 thePropSize = sizeof(UInt64);
    OSStatus result = AudioFileGetProperty(fileDescriptor, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
    if(result != 0) printf("cannot find file size\n");
    return (UInt32)outDataSize;
}

void playMissAtLocation(float x){
    float pan = (2.0 * x) - 1.0f;
    alSource3f(missID, AL_POSITION, pan, 1.0f, 1.0f);
    
    alSourcePlay(impactID);
}

void playHitAtLocation(float x){
    float pan = (2.0 * x) - 1.0f;
    alSource3f(missID, AL_POSITION, pan, 1.0f, 1.0f);
    
    alSourcePlay(hitID);
}

void playPongAtLocation(float x){
    //int preresents percentage
    printf("Play pong at %.2f called\n", x);
    
    float pan = (2.0 * x) - 1.0f;
    alSource3f(impactID, AL_POSITION, 1.0f, 1.0f, 1.0f);
    
    alSourcePlay(impactID);
}

void loadFile(char *filename, unsigned int ID){
    
    AudioFileID fileID;
    
    CFStringRef filenameStr = CFStringCreateWithCString( NULL, filename, kCFStringEncodingUTF8 );
    CFURLRef url = CFURLCreateWithFileSystemPath( NULL, filenameStr, kCFURLPOSIXPathStyle, false );
    CFRelease( filenameStr );
    
    OSStatus openResult = AudioFileOpenURL(url, kAudioFileReadPermission, 0, &fileID);
    
    
    
    // get the full path of the file
    // first, open the file
    // AudioFileID fileID = [self openAudioFile:@"hit3.caf"];
    UInt32 fileSize = audioFileSize(fileID);
    
    // this is where the audio data will live for the moment
    unsigned char * outData = malloc(fileSize);
    
    // this where we actually get the bytes from the file and put them
    // into the data buffer
    OSStatus result = noErr;
    result = AudioFileReadBytes(fileID, false, 0, &fileSize, outData);
    // AudioFileClose(fileID); //close the file
    
    if (openResult != 0) printf("cannot load effect: %s\n",filename);
    
    unsigned int bufferID;
    // grab a buffer ID from openAL
    alGenBuffers(1, &bufferID);
    
    // jam the audio data into the new buffer
    alBufferData(bufferID, AL_FORMAT_MONO16,outData,fileSize,44100);
    
    // save the buffer so I can release it later
    //[bufferStorageArray addObject:[NSNumber numberWithUnsignedInteger:bufferID]];
    
    
    // grab a source ID from openAL
    alGenSources(1, &ID);
    
    // attach the buffer to the source
    alSourcei(ID, AL_BUFFER, bufferID);
    
    // set some basic source prefs
    alSourcef(ID, AL_PITCH, 1.0f);
    alSourcef(ID, AL_GAIN, 1.0f);
    
    // if (loops) alSourcei(*ID, AL_LOOPING, AL_TRUE);
    
    // store this for future use
    //[soundDictionary setObject:[NSNumber numberWithUnsignedInt:*ID] forKey:@"pong"];
    
    // clean up the buffer
    if (outData){
        free(outData);
        outData = NULL;
    }
}


