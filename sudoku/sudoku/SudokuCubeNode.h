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

@property (nonatomic, copy) NSString *backgroundTextureName;

@property (nonatomic, copy) NSString *selectedTextureName;

#pragma mark - data

@property (nonatomic, assign) int value;

- (void)setGuess:(int)guess;

- (void)removeGuess:(int)guess;



@end
