//
//  SudokuCubeShapeNode.m
//  sudoku
//
//  Created by Peng Wang on 12/13/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import "SudokuCubeNode.h"

@interface SudokuCubeShapeNode ()

@end

@implementation SudokuCubeShapeNode

-(void)setPath:(CGPathRef)path {
    [super setPath:path];
    [self reloadLayout];
}

- (void)reloadLayout {
    
}

@end
