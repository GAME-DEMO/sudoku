//
//  SudokuCubeShapeNode.m
//  sudoku
//
//  Created by Peng Wang on 12/13/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import "SudokuCubeShapeNode.h"

@interface SudokuCubeShapeNode ()

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

@property (nonatomic, strong) NSArray<SKShapeNode *>* lines;


@end

@implementation SudokuCubeShapeNode

-(void)setPath:(CGPathRef)path {
    [super setPath:path];
    [self reloadLayout];
}

- (void)reloadLayout {
    
}

@end
