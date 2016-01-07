//
//  SudokuFootContentNode.m
//  sudoku
//
//  Created by Peng Wang on 12/29/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import "SudokuFootContentNode.h"
#import "SudokuButton.h"
#import "Presenter.h"

@interface SudokuFootContentNode ()

@property (nonatomic, strong) NSMutableArray<SudokuButton *> *numberButtonArray;

@end

@implementation SudokuFootContentNode

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _numberButtonArray = [NSMutableArray arrayWithCapacity:[Presenter sharedInstance].dimension];
    for (int i = 0; i < [Presenter sharedInstance].dimension; ++i) {
        SudokuButton *button = [[SudokuButton alloc] init];
        [_numberButtonArray addObject:button];
    }
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    [self reloadLayout];
}

- (void)reloadLayout {
    CGFloat buttonsPerCol = sqrtf(((CGFloat)[Presenter sharedInstance].dimension) * (self.size.height * 0.8) / self.size.width);
    
}

@end
