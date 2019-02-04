#ifndef post_h
#define post_h

#include <stdio.h>
#include <Foundation/Foundation.h>
#import "utilities.h"

@interface Post : NSObject

- (bool)go:(id)sender;
- (bool)isRoot;
- (bool)isSandboxed;
- (void)setUID:(uid_t)uid;
- (void)setGID:(gid_t)gid;
- (void)root;
- (void)mobile;
- (void)unsandbox;
- (void)sandbox;
- (uint64_t)selfproc;
- (uint64_t)kernproc;
- (int)name_to_pid:(NSString *)name;
- (void)respring;
- (void)disableRevokes;

@end

#endif /* post_h */
