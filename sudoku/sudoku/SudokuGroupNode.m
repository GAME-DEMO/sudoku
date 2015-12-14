//
//  SudokuGroupNode.m
//  sudoku
//
//  Created by Peng Wang on 12/14/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

/*
 |-----------------------------|
 |         |         |         |
 |    6    |    7    |    8    |
 |         |         |         |
 |---------|---------|---------|
 |         |         |         |
 |    3    |    4    |    5    |
 |         |         |         |
 |---------|---------|---------|
 |         |         |         |
 |    0    |    1    |    2    |
 |         |         |         |
 |-----------------------------|
 */



#import "SudokuGroupNode.h"
#import "SudokuCubeNode.h"

@interface SudokuGroupNode ()

@property (nonatomic, strong) NSArray<SudokuCubeNode *> *cubeNodeArray;

@end


@implementation SudokuGroupNode

- (void)setPath:(CGPathRef)path {
    [super setPath:path];
    
    if (!self.cubeNodeArray) {
        NSMutableArray *groups = [NSMutableArray array];
        
        self.cubeNodeArray = [NSArray arrayWithArray:groups];
    }
}

@end
