//
//  SudokuButton.h
//  sudoku
//
//  Created by Peng Wang on 12/26/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_OPTIONS(int, SudokuButtonControlEvent)
{
    SudokuButtonControlEventTouchDown = 1,
    SudokuButtonControlEventTouchUp,
    SudokuButtonControlEventTouchUpInside,
    SudokuButtonControlEventAll
};

@interface SudokuButton : SKSpriteNode

@property (nonatomic, strong) SKTexture *buttonNormalTexture;
@property (nonatomic, strong) SKTexture *buttonHighlightedTexture;
@property (nonatomic, readonly) SKLabelNode *buttonLabel;

@end
