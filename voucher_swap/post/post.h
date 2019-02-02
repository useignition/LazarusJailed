#ifndef post_h
#define post_h

#include <stdio.h>
#include <Foundation/Foundation.h>
#import "utilities.h"

@interface Post : NSObject

- (bool)go;
- (void)respring;
- (void)disableRevokes;

@end

#endif /* post_h */
