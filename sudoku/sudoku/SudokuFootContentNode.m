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
@property (nonatomic, strong) SudokuButton *switchButton;
@property (nonatomic, assign) CGFloat buttonCountForCol;
@property (nonatomic, assign) CGFloat buttonCountForRow;
@property (nonatomic, assign) CGFloat buttonSideLength;

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
    self.texture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:@"background_below.png"];
    
    _numberButtonArray = [NSMutableArray arrayWithCapacity:[Presenter sharedInstance].dimension];
    for (int i = 0; i < [Presenter sharedInstance].dimension; ++i) {
        SudokuButton *button = [[SudokuButton alloc] init];
        [_numberButtonArray addObject:button];
    }
    
    if ([Presenter sharedInstance].dimension == DIMENSION_LEVEL_NINE) {
        self.buttonCountForCol = 2.0;
        self.buttonCountForRow = 5.0;
    }
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    [self reloadLayout];
}

- (void)reloadLayout {
    if ([Presenter sharedInstance].dimension == DIMENSION_LEVEL_NINE) {
        CGFloat height = self.size.height * 2.0 / 3.0;
        CGFloat width = self.size.width;
        CGFloat sideLength = MIN(width / self.buttonCountForRow, height / self.buttonCountForCol);
        self.buttonSideLength = sideLength - 4.0;
    }
}

@end
