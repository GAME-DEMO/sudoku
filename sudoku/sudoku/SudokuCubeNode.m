//
//  SudokuCubeNode.m
//  sudoku
//
//  Created by Peng Wang on 12/13/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

/*
 |-----------------------------|
 |         |         |         |
 |        11        12         |
 |         |         |         |
 |----4----|----5----|----6----|
 |         |         |         |
 |         9        10         |
 |         |         |         |
 |----1----|----2----|----3----|
 |         |         |         |
 |         7         8         |
 |         |         |         |
 |-----------------------------|
 */


#import "SudokuCubeNode.h"

@interface SudokuCubeNode ()

@end

@implementation SudokuCubeNode

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.userInteractionEnabled = NO;
}

@end
