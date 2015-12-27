//
//  SudokuButton.h
//  sudoku
//
//  Created by Peng Wang on 12/26/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_OPTIONS(NSUInteger, SudokuButtonEvent)
{
    SudokuButtonEventTouchDown,
    SudokuButtonEventTouchUpInside,
    SudokuButtonEventClick,
    SudokuButtonEventTouchCancel,
    SudokuButtonEventAll,
};


@class SudokuButton;

@interface SudokuButton : SKSpriteNode

// UIControl
@property (nonatomic, strong, nullable) SKTexture *buttonNormalTexture;
@property (nonatomic, strong, nullable) SKTexture *buttonHighlightedTexture;
@property (nonatomic, readonly, nullable) SKLabelNode *buttonLabel;

- (void)addTarget:(nullable id)target action:(_Nonnull SEL)action forButtonEvent:(SudokuButtonEvent)buttonEvent;

- (void)removeTarget:(nullable id)target action:(nullable SEL)action forButtonEvent:(SudokuButtonEvent)buttonEvent;

@end
