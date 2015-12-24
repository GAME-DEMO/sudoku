//
//  SudokuBodyContentNode.h
//  sudoku
//
//  Created by Peng Wang on 12/20/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class SudokuCubeNode;

@interface SudokuBodyContentNode : SKSpriteNode

@property (nonatomic, readonly) NSArray<SudokuCubeNode *> *cubeArray;

@end
