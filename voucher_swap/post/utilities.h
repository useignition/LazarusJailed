//
//  utilities.h
//  voucher_swap
//
//  Created by Ignition on 3/2/19.
//  Copyright © 2019 Brandon Azad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/types.h>
#import <sys/stat.h>

static inline bool clean_file(const char *file) {
    NSString *path = @(file);
    if ([[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil]) {
        return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    return YES;
}

bool ensure_symlink(const char *to, const char *from);
