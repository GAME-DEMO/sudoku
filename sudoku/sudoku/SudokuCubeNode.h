//
//  SudokuCubeNode.h
//  sudoku
//
//  Created by Peng Wang on 12/13/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SudokuCubeNode : SKSpriteNode

@property (nonatomic, assign) int index;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, copy) NSString *textureName;

@property (nonatomic, copy) NSString *selectedTextureName;

@end
