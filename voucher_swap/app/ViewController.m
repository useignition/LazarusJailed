//
//  ViewController.m
//  voucher_swap
//
//  Created by Brandon Azad on 12/7/18.
//  Copyright © 2018 Brandon Azad. All rights reserved.
//

#import "ViewController.h"
#import "kernel_slide.h"
#import "voucher_swap.h"
#import "kernel_memory.h"
#import <mach/mach.h>
#include "post.h"
#include <sys/utsname.h>

@interface ViewController ()

@end

@implementation ViewController

- (bool)voucher_swap {
    vm_size_t size = 0;
    host_page_size(mach_host_self(), &size);
    if (size < 16000) {
        printf("non-16K devices are not currently supported.\n");
        return false;
    }
    voucher_swap();
    if (!MACH_PORT_VALID(kernel_task_port)) {
        printf("tfp0 is invalid?\n");
        return false;
    }
    return true;
}

- (void)failure {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"failed" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)go:(id)sender {
    Post *post = [[Post alloc] init];
    static int progress = 0;
    if (progress == 2) {
        [post respring];
        return;
    }
    if (progress == 1) {
	return;
    }
    progress++;
    bool success = [self voucher_swap];
    if (success) {
	sleep(1);
        [post go];
        [sender setTitle:@"respring" forState:UIControlStateNormal];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"success" message:[NSString stringWithFormat:@"tfp0: %i\nkernel base: 0x%llx\nuid: %i\nunsandboxed: true", kernel_task_port, kernel_slide + 0xFFFFFFF007004000, getuid()] preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"done" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self failure];
    }
    progress++;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

@end
