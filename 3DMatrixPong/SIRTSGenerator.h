//
//  SIRTSGenerator.h
//  3D Ascii Pong
//
//  Created by Patrick Cossette on 10/6/13.
//  Copyright (c) 2013 Patrick Cossette. All rights reserved.
//

#ifndef Straight_C_3DAsciiPong_SIRTSGenerator_h
#define Straight_C_3DAsciiPong_SIRTSGenerator_h

struct n{
    char character;
    struct n *next;
};

typedef struct n node;

//SIRTS Generator (Generates a random text stereogram corresponding to a single line of a depth map - must be called for each line of text!)
char *generateStereogram(int *line, int width, int depth, char hiddenMessage[4]);
void getRandomString(int length, char *s);

//Linked List Functions
char charAtIndex(int charIndex, node *list);
void insertChar(node **list, char c, int charIndex);
void popChar(int charIndex, node *sourceList, node **destList);
void popOffTop(node **sourceList, node **destList);
void appendList(node **list, char c);
void printList(node *root);

#endif
