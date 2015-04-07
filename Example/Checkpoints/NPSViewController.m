//
//  NPSViewController.m
//  Checkpoints
//
//  Created by Jordy van Kuijk on 04/07/2015.
//  Copyright (c) 2014 Jordy van Kuijk. All rights reserved.
//

#import "NPSViewController.h"
#import <Checkpoints/NPSCheckpoints.h>

@interface NPSViewController ()

@end

@implementation NPSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)passCheckPoint1:(id)sender {
    [[NPSCheckpoints SDK] checkPoint:@"1"];
}
- (IBAction)logIn:(id)sender {
    [[NPSCheckpoints SDK] checkPoint:@"3"];
}
- (IBAction)fetchData:(id)sender {
    [[NPSCheckpoints SDK] checkPoint:@"2"];
}
- (IBAction)postData:(id)sender {
    [[NPSCheckpoints SDK] checkPoint:@"4"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
