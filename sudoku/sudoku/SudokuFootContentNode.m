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

@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong) NSMutableArray<SKSpriteNode *> *numberBackgroundArray;
@property (nonatomic, strong) NSMutableArray<SudokuButton *> *numberButtonArray;
@property (nonatomic, strong) SudokuButton *switchButton;
@property (nonatomic, assign) int buttonCountForCol;
@property (nonatomic, assign) int buttonCountForRow;
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
    
    if ([Presenter sharedInstance].dimension == DIMENSION_LEVEL_NINE) {
        self.buttonCountForCol = 2;
        self.buttonCountForRow = 5;
    }
    
    int allCubes = self.buttonCountForCol * self.buttonCountForRow;
    _numberBackgroundArray = [NSMutableArray arrayWithCapacity:allCubes];
    for (int i = 0; i < allCubes; ++i) {
        SKSpriteNode *numberBackgroundNode = [SKSpriteNode node];
        [_numberBackgroundArray addObject:numberBackgroundNode];
        [self addChild:numberBackgroundNode];
    }
    
    _numberButtonArray = [NSMutableArray arrayWithCapacity:[Presenter sharedInstance].dimension];
    for (int i = 0; i < [Presenter sharedInstance].dimension; ++i) {
        SudokuButton *button = [[SudokuButton alloc] init];
        [button addTarget:self action:@selector(sudokuNumberButtonDidTouchUpInside:) withObject:button forButtonEvent:ButtonEventTouchUpInside];
        [_numberButtonArray addObject:button];
    }
    
    _switchButton = [[SudokuButton alloc] init];

    _initialized = YES;
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    [self reloadLayout];
}

- (void)reloadLayout {
    if (!self.initialized) {
        return;
    }
    
    if ([Presenter sharedInstance].dimension == DIMENSION_LEVEL_NINE) {
        CGFloat height = self.size.height * 2.0 / 3.0;
        CGFloat baseHeight = self.size.height - height;
        CGFloat width = self.size.width;
        
        CGFloat perHeight = height / self.buttonCountForCol;
        CGFloat perWidth = width / self.buttonCountForRow;
        
        for (int i = 0; i < self.numberBackgroundArray.count; ++i) {
            SKSpriteNode *numberBackgroundNode = [self.numberBackgroundArray objectAtIndex:i];
            CGFloat col = i % self.buttonCountForRow;
            CGFloat row = self.buttonCountForCol - 1 - i / self.buttonCountForRow;
            numberBackgroundNode.anchorPoint = CGPointMake(0, 0);
            numberBackgroundNode.position = CGPointMake(col * perWidth, row * perHeight + baseHeight);
            numberBackgroundNode.size = CGSizeMake(perWidth, perHeight);
        }
        
        CGFloat sideLength = MIN(perWidth, perHeight);
        self.buttonSideLength = sideLength * 5.0 / 6.0;
        for (int i = 0; i < self.numberButtonArray.count + 1; ++i) {
            SKSpriteNode *numberBackgroundNode = [self.numberBackgroundArray objectAtIndex:i];
            SudokuButton *button = nil;
            if (i < self.numberButtonArray.count) {
                button = [self.numberButtonArray objectAtIndex:i];
                button.buttonImage.texture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:[NSString stringWithFormat:@"b%d.png", i + 1]];
            } else {
                button = _switchButton;
                button.buttonImage.texture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:@"pencil.png"];
            }
            [numberBackgroundNode addChild:button];
            button.anchorPoint = CGPointMake(0.5, 0);
            button.position = CGPointMake(numberBackgroundNode.size.width / 2.0, 0);
            button.size = CGSizeMake(self.buttonSideLength, self.buttonSideLength);
            button.buttonNormalTexture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:@"button_number.png"];
            button.buttonHighlightTexture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:@"button_number_highlight.png"];
        }
    }
}

- (void)sudokuNumberButtonDidTouchUpInside:(SudokuButton *)button {
    button.buttonSelected = !button.buttonSelected;
}

@end
