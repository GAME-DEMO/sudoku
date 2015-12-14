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

- (void)setPath:(CGPathRef)path {
    [super setPath:path];
    
    [self reloadLayout];
}

- (void)reloadLayout {
    SKShader *backgroundShader = [SKShader shaderWithFileNamed:@"shader_game_cube_background.fsh"];
    self.fillShader = backgroundShader;
}

@end
