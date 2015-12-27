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
 |    6    |    7    |    8    |
 |         |         |         |
 |---------|---------|---------|
 |         |         |         |
 |    3    |    4    |    5    |
 |         |         |         |
 |---------|---------|---------|
 |         |         |         |
 |    0    |    1    |    2    |
 |         |         |         |
 |-----------------------------|
 */


#import "SudokuCubeNode.h"
#import "Presenter.h"

@interface SudokuCubeNode ()

@property (nonatomic, strong) SKSpriteNode *valueSpriteNode;
@property (nonatomic, strong) SKSpriteNode *guessUnionInSpriteNode;
@property (nonatomic, strong) NSMutableArray<SKSpriteNode *> *guessSpriteNodeArray;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *guessArray;

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
    
    self.valueSpriteNode = [SKSpriteNode node];
    self.valueSpriteNode.anchorPoint = CGPointMake(0, 0);
    self.valueSpriteNode.position = CGPointMake(0, 0);
    self.valueSpriteNode.size = self.size;
    [self addChild:self.valueSpriteNode];
    
    self.guessUnionInSpriteNode = [SKSpriteNode node];
    self.guessUnionInSpriteNode.anchorPoint = CGPointMake(0, 0);
    self.guessUnionInSpriteNode.position = CGPointMake(0, 0);
    self.guessUnionInSpriteNode.size = self.size;
    [self addChild:self.guessUnionInSpriteNode];
    
    self.guessArray = [NSMutableArray arrayWithCapacity:[Presenter sharedInstance].dimension];
    for (int i = 0; i < [Presenter sharedInstance].dimension; ++i) {
        [self.guessArray addObject:@(0)];
    }
    self.guessSpriteNodeArray = [NSMutableArray arrayWithCapacity:[Presenter sharedInstance].dimension];
    for (int i = 0; i < [Presenter sharedInstance].dimension; ++i) {
        SKSpriteNode *guessSpriteNode = [SKSpriteNode node];
        guessSpriteNode.anchorPoint = CGPointMake(0, 0);
        guessSpriteNode.position = [self positionForGuess:i];
        guessSpriteNode.size = [self sizeForGuess];
        [self.guessUnionInSpriteNode addChild:guessSpriteNode];
        [self.guessSpriteNodeArray addObject:guessSpriteNode];
    }
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    
    self.valueSpriteNode.size = size;
    self.guessUnionInSpriteNode.size = size;
    for (int i = 0; i < [Presenter sharedInstance].dimension; ++i) {
        SKSpriteNode *guessSpriteNode = [self.guessSpriteNodeArray objectAtIndex:i];
        guessSpriteNode.position = [self positionForGuess:i];
        guessSpriteNode.size = [self sizeForGuess];
    }
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
        
        if (self.value != 0) {
            SKTexture *valueTexture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:[NSString stringWithFormat:@"s%d@2x.png", self.value]];
            [self.valueSpriteNode setTexture:valueTexture];
        }
    }
}

- (void)setGuess:(int)guess {
    if (guess <= 0) {
        return;
    }
    int index = guess - 1;
    [self.guessArray setObject:@(guess) atIndexedSubscript:index];
    
    SKTexture *guessTexture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:[NSString stringWithFormat:@"s%d@2x.png", [[self.guessArray objectAtIndex:index] intValue]]];
    SKSpriteNode *guessSpriteNode = [self.guessSpriteNodeArray objectAtIndex:index];
    [guessSpriteNode setTexture:guessTexture];
}

- (void)removeGuess:(int)guess {
    if (guess <= 0) {
        return;
    }
    int index = guess - 1;
    [self.guessArray setObject:@(0) atIndexedSubscript:index];
    SKSpriteNode *guessSpriteNode = [self.guessSpriteNodeArray objectAtIndex:index];
    [guessSpriteNode setTexture:nil];
}

- (CGFloat)sideLengthForGuess {
    return MIN(self.guessUnionInSpriteNode.size.width, self.guessUnionInSpriteNode.size.height) / (CGFloat)[Presenter sharedInstance].eachCount;
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
