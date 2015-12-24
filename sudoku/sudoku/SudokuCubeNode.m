//
//  SudokuCubeNode.m
//  sudoku
//
//  Created by Peng Wang on 12/13/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

/*
 |-----------------------------|
 |         |         |         |
 |        11        12         |
 |         |         |         |
 |----4----|----5----|----6----|
 |         |         |         |
 |         9        10         |
 |         |         |         |
 |----1----|----2----|----3----|
 |         |         |         |
 |         7         8         |
 |         |         |         |
 |-----------------------------|
 */


#import "SudokuCubeNode.h"
#import "Presenter.h"
#import "SudokuCubeValueNode.h"
#import "SudokuCubeGuessNode.h"

@interface SudokuCubeNode ()

@property (nonatomic, strong) SudokuCubeValueNode *valueNode;
@property (nonatomic, strong) SKSpriteNode *guessSpriteNode;
@property (nonatomic, strong) NSMutableArray<SKSpriteNode *> *guessSpriteNodeArray;

@end

@implementation SudokuCubeNode

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
    self.userInteractionEnabled = NO;
    
    self.valueNode = [SudokuCubeValueNode node];
    self.valueNode.anchorPoint = CGPointMake(0, 0);
    self.valueNode.position = CGPointMake(0, 0);
    self.valueNode.size = self.size;
    [self addChild:self.valueNode];
    
    self.guessSpriteNode = [SKSpriteNode node];
    self.guessSpriteNode.anchorPoint = CGPointMake(0, 0);
    self.guessSpriteNode.position = CGPointMake(0, 0);
    self.guessSpriteNode.size = self.size;
    [self addChild:self.guessSpriteNode];
    
    self.guessArray = [NSMutableArray arrayWithCapacity:[Presenter sharedInstance].dimension];
    for (int i = 0; i < [Presenter sharedInstance].dimension; ++i) {
        [self.guessArray addObject:@(0)];
    }
    self.guessSpriteNodeArray = [NSMutableArray arrayWithCapacity:[Presenter sharedInstance].dimension];
    for (int i = 0; i < [Presenter sharedInstance].dimension; ++i) {
        SudokuCubeGuessNode *guessNode = [SudokuCubeGuessNode node];
        guessNode.anchorPoint = CGPointMake(0, 0);
        guessNode.position = [self positionForGuess:i];
        guessNode.size = [self sizeForGuess];
        [self.guessSpriteNode addChild:guessNode];
        [self.guessSpriteNodeArray addObject:guessNode];
    }
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    
    self.valueNode.size = size;
    self.guessSpriteNode.size = size;
    
}

- (void)setBackgroundTextureName:(NSString *)textureName {
    _backgroundTextureName = [textureName copy];
    [self updateCubeNodeTexture];
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self updateCubeNodeTexture];
    [[Presenter sharedInstance] cubeDidSelect:self];
}

- (void)updateCubeNodeTexture {
    if (self.selected) {
        self.texture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:self.selectedTextureName];
    } else {
        self.texture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:self.backgroundTextureName];
    }
}

- (void)setValue:(int)value {
    if (_value != value) {
        _value = value;
        [self updateValueSpriteNode];
    }
}

- (void)updateValueSpriteNode {
    
}

- (void)updateGuessSpriteNode {
    
}

- (CGFloat)sideLengthForGuess {
    return MIN(self.guessSpriteNode.size.width, self.guessSpriteNode.size.height) / (CGFloat)[Presenter sharedInstance].eachCount;
}

- (CGPoint)positionForGuess:(int)guessIndex {
    CGFloat guessSideLength = [self sideLengthForGuess];
    int row = guessIndex % [Presenter sharedInstance].eachCount;
    int col = guessIndex / [Presenter sharedInstance].eachCount;
    return CGPointMake(row * guessSideLength, col * guessSideLength);
}

- (CGSize)sizeForGuess {
    return CGSizeMake([self sideLengthForGuess], [self sideLengthForGuess]);
}

- (CGRect)frameForGuess:(int)guessIndex {
    CGFloat guessSideLength = [self sideLengthForGuess];
    CGPoint position = [self positionForGuess:guessIndex];
    return CGRectMake(position.x, position.y, guessSideLength, guessSideLength);
}

@end
