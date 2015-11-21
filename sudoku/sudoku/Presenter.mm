//
//  Presenter.m
//  sudoku
//
//  Created by Peng Wang on 11/21/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import "Presenter.h"
#import "Algorithm.h"

@implementation Presenter

+ (instancetype)sharedInstance {
    static Presenter *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Presenter alloc] init];
    });
    return instance;
}

- (void)mainTest {
    MainTest();
}

@end
