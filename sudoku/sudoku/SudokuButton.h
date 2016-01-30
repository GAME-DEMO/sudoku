//
//  SudokuButton.h
//  sudoku
//
//  Created by Peng Wang on 12/26/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSUInteger, SudokuButtonEvent) {
    ButtonEventTouchDown,
    ButtonEventTouchUpInside,
    ButtonEventTouchUpOutside,
    ButtonEventTouchCancel,
    ButtonEventAll,
};

//@class SudokuButton;
//typedef void(^SudokuButtonEventBlock)(SudokuButton * _Nonnull button);

@interface SudokuButton : SKSpriteNode

// UIControl
@property (nonatomic, strong, nullable) SKTexture *buttonNormalTexture;
@property (nonatomic, strong, nullable) SKTexture *buttonHighlightTexture;
@property (nonatomic, readonly, nullable) SKLabelNode *buttonLabel;
@property (nonatomic, readonly, nullable) SKSpriteNode *buttonImage;
@property (nonatomic, assign) BOOL buttonSelected;

- (void)addTarget:(nullable id)target action:(_Nonnull SEL)action withObject:(nullable id)object forButtonEvent:(SudokuButtonEvent)buttonEvent;
- (void)removeTarget:(nullable id)target action:(nullable SEL)action forButtonEvent:(SudokuButtonEvent)buttonEvent;

@end
