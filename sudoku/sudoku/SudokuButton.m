//
//  SudokuButton.m
//  sudoku
//
//  Created by Peng Wang on 12/26/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import "SudokuButton.h"

@interface SudokuButton ()

@property (nonatomic, strong) SKLabelNode *buttonLabel;

@property (nonatomic, assign) BOOL buttonPressedDown;

// ButtonEvent -> SELArray
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
        [_buttonEventDictionary setObject:[NSMutableDictionary dictionary] forKey:@(i)];
    }
}

- (void)addTarget:(nullable id)target action:(_Nonnull SEL)action forButtonEvent:(SudokuButtonEvent)buttonEvent {
    NSMutableArray *SELArray = [_buttonEventDictionary objectForKey:@(buttonEvent)];
    if (!SELArray) {
        SELArray = [NSMutableArray array];
        [_buttonEventDictionary setObject:SELArray forKey:target];
    }
    
    NSInvocation *invocation = [[NSInvocation alloc] init];
    invocation.target = target;
    invocation.selector = action;
    [SELArray addObject:invocation];
}

- (void)removeTarget:(nullable id)target action:(nullable SEL)action forButtonEvent:(SudokuButtonEvent)buttonEvent {
    NSMutableArray *SELArray = [_buttonEventDictionary objectForKey:@(buttonEvent)];
    for (NSInteger i = SELArray.count - 1; i >= 0; --i) {
        NSInvocation *invocation = [SELArray objectAtIndex:i];
        if (invocation.target == target && (invocation.selector == action || action == nil)) {
            [SELArray removeObjectAtIndex:i];
        }
    }
}

- (void)invokeForButtonEvent:(SudokuButtonEvent)buttonEvent {
    NSArray *SELArray = [_buttonEventDictionary objectForKey:@(buttonEvent)];
    for (int i = 0; i < SELArray.count; ++i) {
        NSInvocation *invocation = [SELArray objectAtIndex:i];
        [invocation setArgument:(__bridge void * _Nonnull)(self) atIndex:3];
        [invocation invoke];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.buttonPressedDown = YES;
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

@end
