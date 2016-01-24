//
//  SudokuButton.m
//  sudoku
//
//  Created by Peng Wang on 12/26/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import "SudokuButton.h"

static NSString * const SudokuSELTarget = @"SudokuSELTarget";
static NSString * const SudokuSELSelector = @"SudokuSELSelector";
static NSString * const SudokuSELObject = @"SudokuSELObject";

@interface SudokuButton ()

@property (nonatomic, strong) SKLabelNode *buttonLabel;
@property (nonatomic, strong) SKSpriteNode *buttonImage;

@property (nonatomic, strong) NSMutableDictionary *buttonEventDictionary;

@end

@implementation SudokuButton

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.userInteractionEnabled = YES;
    
    _buttonEventDictionary = [NSMutableDictionary dictionary];
    for (NSUInteger i = SudokuButtonEventTouchDown; i < SudokuButtonEventAll; ++i) {
        [_buttonEventDictionary setObject:[NSMutableArray array] forKey:@(i)];
    }
}

- (void)addTarget:(nullable id)target action:(_Nonnull SEL)action withObject:(nullable id)object forButtonEvent:(SudokuButtonEvent)buttonEvent {
    NSMutableArray *SELArray = [self.buttonEventDictionary objectForKey:@(buttonEvent)];
    NSMutableDictionary *SELDict = [NSMutableDictionary dictionary];
    [SELDict setObject:target forKey:SudokuSELTarget];
    [SELDict setObject:[NSValue valueWithPointer:action] forKey:SudokuSELSelector];
    if (object) {
        [SELDict setObject:object forKey:SudokuSELObject];
    }
    [SELArray addObject:SELDict];
}

- (void)removeTarget:(nullable id)target action:(nullable SEL)action forButtonEvent:(SudokuButtonEvent)buttonEvent {
    if (buttonEvent == SudokuButtonEventAll) {
        for (NSUInteger i = SudokuButtonEventTouchDown; i < SudokuButtonEventAll; ++i) {
            [self removeTarget:target action:action forButtonEvent:i];
        }
        return;
    }
    
    NSMutableArray *SELArray = [self.buttonEventDictionary objectForKey:@(buttonEvent)];
    if (action != nil) {
        for (NSInteger i = SELArray.count - 1; i >= 0; --i) {
            NSDictionary *SELDict = [SELArray objectAtIndex:i];
            if ([SELDict objectForKey:SudokuSELTarget] == target &&
                [[SELDict objectForKey:SudokuSELSelector] pointerValue] == action) {
                [SELArray removeObjectAtIndex:i];
                return;
            }
        }
    } else {
        for (NSInteger i = SELArray.count - 1; i >= 0; --i) {
            NSDictionary *SELDict = [SELArray objectAtIndex:i];
            if ([SELDict objectForKey:SudokuSELTarget] == target) {
                [SELArray removeObjectAtIndex:i];
            }
        }
    }
}

- (void)invokeForButtonEvent:(SudokuButtonEvent)buttonEvent {
    NSMutableArray *SELArray = [self.buttonEventDictionary objectForKey:@(buttonEvent)];
    for (int i = 0; i < SELArray.count; ++i) {
        NSDictionary *SELDict = [SELArray objectAtIndex:i];
        id target = [SELDict objectForKey:SudokuSELTarget];
        SEL selector = [[SELDict objectForKey:SudokuSELSelector] pointerValue];
        id object = [SELDict objectForKey:SudokuSELObject];
        IMP implementation = [target methodForSelector:selector];
        if (object) {
            void (*func)(id, SEL, id) = (void *)implementation;
            func(target, selector, object);
        } else {
            void (*func)(id, SEL) = (void *)implementation;
            func(target, selector);
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.texture = self.buttonHighlightTexture;
    [self invokeForButtonEvent:SudokuButtonEventTouchDown];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    self.texture = self.buttonNormalTexture;
    for (UITouch *touch in touches) {
        if (CGRectContainsPoint(CGRectMake(0, 0, self.size.width, self.size.height), [touch locationInNode:self])) {
            [self invokeForButtonEvent:SudokuButtonEventTouchUpInside];
            return;
        }
    }
    [self invokeForButtonEvent:SudokuButtonEventTouchUpOutside];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.texture = self.buttonNormalTexture;
    [self invokeForButtonEvent:SudokuButtonEventTouchCancel];
}

- (void)setButtonNormalTexture:(SKTexture *)buttonNormalTexture {
    _buttonNormalTexture = buttonNormalTexture;
    if (self.texture == nil) {
        self.texture = buttonNormalTexture;
    }
}

- (void)setButtonHighlightTexture:(SKTexture *)buttonHighlightTexture {
    _buttonHighlightTexture = buttonHighlightTexture;
}

@end
