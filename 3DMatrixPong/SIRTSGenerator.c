//
//  SIRTSGenerator.c
//  3D Ascii Pong
//
//  Created by Patrick Cossette on 10/6/13.
//  Copyright (c) 2013 Patrick Cossette. All rights reserved.
//
//  Generates a SIRTS (Single Image Random Text Stereogram) based on a line from a depth map (int array)

#include "SIRTSGenerator.h"
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include "stdio.h"

char alpha[] = "abcdefghijklmnopqrstuvwxyz`1234567890-=~!@#$%^&*()_+[]\\;',./<>?:\"{}|ABCDEFGHIKLMNOPQRSTUVWXYZ ";

char *generateStereogram(int *line, int width, int depth, char hiddenMessage[4]){
    
    int onChar = 0;
    int offset = 0;
    int prevOffset = 0;
    
    int charsInPattern = depth-3;
    
    char *pattern = (char*)malloc(depth*sizeof(char));
    getRandomString(depth, pattern);
    
    //Testing - hide messages in the pattern (currently limited to strings of 4 characters each per line!)
    if (hiddenMessage) {
        int oc = 0;
        while (hiddenMessage[3-oc] != '\0') {
            pattern[oc+4] = hiddenMessage[3-oc];
            oc++;
        }
    }
    
    char *sirts = (char*)malloc(width*(sizeof(char)));
    memset(&sirts[0], 0, sizeof(sirts));
    
    //Linked list bidneh
    node *patternRoot;
    node *pointer;
    node *charsRemoved;
    
    patternRoot = NULL;
    charsRemoved = NULL;
    
    //Put random chars in a linked list
    for (int i = 0; i < depth; i++) {
        appendList(&patternRoot, pattern[i]);
    }
    pointer = patternRoot;

    //sirtsgen
    int count = 0;
    node *tmp;
    
    for (int i = 0; i < width; i++) {
        offset = line[i];
        onChar++;
        
        if (onChar >= charsInPattern)
            onChar = 0;
        
        if (offset > prevOffset) {
            count = 0;
            while (count < (offset-prevOffset)){
                charsInPattern--;
                
                if (onChar) {
                    popChar(onChar, patternRoot, &charsRemoved);
                }
                else
                    popOffTop(&patternRoot, &charsRemoved);
                
                if (onChar >= charsInPattern) onChar = 0;
                count++;
            }
        }
        else if(offset < prevOffset){
            count = 0;
            while (count < (prevOffset-offset)){
                insertChar(&patternRoot, charsRemoved->character, onChar+1);

                tmp = charsRemoved;
                charsRemoved = charsRemoved->next;
                free(tmp);
                charsInPattern++;
                count++;
            }
        }
        
        prevOffset = offset;
        if (onChar >= charsInPattern)
            onChar = 0;
        
        sirts[i] = charAtIndex(onChar, patternRoot);
    }
    
    //Make *sure* our string is null-terminated
    sirts[width-1] = '\0';
    
    //cleanup
    pointer = patternRoot;
    while (pointer) {
        tmp = pointer;
        pointer = pointer->next;
        free(tmp);
    }
    
    pointer = charsRemoved;
    while (pointer) {
        tmp = pointer;
        pointer = pointer->next;
        free(tmp);
    }
    
    free(pointer);
    free(pattern);
    return sirts;
}

char charAtIndex(int charIndex, node *list){
    node *n;
    int i = 0;
    
    n = list;
    while(n != NULL){
        if (charIndex == i) {
            return n->character;
        }
        n = n->next;
        i++;
    }
    
    return '\0';
}

void printList(node *root){
    while (root != NULL) {
        printf("%c", root->character);
        root = root->next;
    }
    printf("\n");
}

void popOffTop(node **sourceList, node **destList){
    node *tmp;
    appendList(destList, (char)(*sourceList)->character);
    
    tmp = *sourceList;
    *sourceList = (node*)(*sourceList)->next;
    free(tmp);
}

void insertChar(node **list, char c, int charIndex){
    int i = 0;
    node *insert = (node*)malloc(sizeof(node));
    insert->character = c;
    
    node *pointer = *list;
    while (pointer != NULL) {
        if (charIndex == i+1) {
            insert->next = pointer->next;
            pointer->next = insert;
            break;
        }
        pointer = pointer->next;
        i++;
    }
}

void popChar(int charIndex, node *sourceList, node **destList){
    node *pointer = NULL;
    node *destPointer = NULL;
    int i = 0;
    char popped = '\0';
    
    pointer = sourceList;
    while (pointer != NULL) {
        if (charIndex == i+1) {
            popped = pointer->next->character;
            destPointer = pointer->next;
            pointer->next = pointer->next->next;
            free(destPointer);
            break;
        }
        pointer = pointer->next;
        i++;
    }
    
   appendList(destList, popped);
}

void appendList(node **list, char c){
    node *tmp = (node*)malloc(sizeof(node));
    tmp->character = c;
    tmp->next = *list;
    *list = tmp;
}

void getRandomString(int length, char *s){
    char tmp;
    int t;
    int onc = 0;
    memset(s, '\0', length);
    
    for (int i = 0; i < length; i++) {
        tmp = alpha[rand() % strlen(alpha)];
        t = 0;
        while (s[t]) { //Using a linked list to pop characters from the alpha array may be more efficient in some scenarios - but since the target string is so short in this application I believe a manual check to exclude repeating characters is better
            if (s[t] == tmp) {
                t = 0;
                tmp = alpha[rand() % strlen(alpha)];
                continue;
            }
            t++;
        }
        s[i] = tmp;
        onc++;
    }
}


