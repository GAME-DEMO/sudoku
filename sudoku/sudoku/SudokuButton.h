//
//  SudokuButton.h
//  sudoku
//
//  Created by Peng Wang on 12/26/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class SudokuButton;

typedef NS_OPTIONS(NSUInteger, SudokuButtonControlEvent)
{
    SudokuButtonControlEventTouchDown = 1,
    SudokuButtonControlEventTouchUpInside,
    SudokuButtonControlEventTouchCancel,
};

typedef void(^ButtonTouchEventBlock)(SudokuButton *button, SudokuButtonControlEvent event);

@interface SudokuButton : SKSpriteNode

@property (nonatomic, strong) SKTexture *buttonNormalTexture;
@property (nonatomic, strong) SKTexture *buttonHighlightedTexture;
@property (nonatomic, readonly) SKLabelNode *buttonLabel;



@end
