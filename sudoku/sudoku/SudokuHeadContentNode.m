//
//  SudokuHeadContentNode.m
//  sudoku
//
//  Created by Peng Wang on 12/26/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import "SudokuHeadContentNode.h"

@interface SudokuHeadContentNode ()

@property (nonatomic, strong) SKSpriteNode *backButton;
@property (nonatomic, strong) SKLabelNode *titleLabel;
@property (nonatomic, strong) SKSpriteNode *restartButton;

@end

@implementation SudokuHeadContentNode

- (void)setSize:(CGSize)size {
    [super setSize:size];
    [self reloadLayout];
}

- (void)reloadLayout {
    
}


@end
