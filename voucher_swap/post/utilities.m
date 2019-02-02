//
//  utilities.m
//  voucher_swap
//
//  Created by Ignition on 3/2/19.
//  Copyright © 2019 Brandon Azad. All rights reserved.
//

#import "utilities.h"
#import <mach/error.h>
#import <sys/sysctl.h>
#import <CommonCrypto/CommonDigest.h>
#import <spawn.h>
#include <copyfile.h>
#include <sys/utsname.h>
#include <sys/socket.h>
#include <netinet/in.h>

bool ensure_symlink(const char *to, const char *from) {
    ssize_t wantedLength = strlen(to);
    ssize_t maxLen = wantedLength + 1;
    char link[maxLen];
    ssize_t linkLength = readlink(from, link, sizeof(link));
    if (linkLength != wantedLength ||
        strncmp(link, to, maxLen) != ERR_SUCCESS
        ) {
        if (!clean_file(from)) {
            return false;
        }
        if (symlink(to, from) != ERR_SUCCESS) {
            return false;
        }
    }
    return true;
}
