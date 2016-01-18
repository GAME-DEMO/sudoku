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

@property (nonatomic, assign) BOOL initialized;

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
    
    _valueSpriteNode = [SKSpriteNode node];
    _valueSpriteNode.anchorPoint = CGPointMake(0, 0);
    _valueSpriteNode.position = CGPointMake(0, 0);
    _valueSpriteNode.size = self.size;
    [self addChild:_valueSpriteNode];
    
    _guessUnionInSpriteNode = [SKSpriteNode node];
    _guessUnionInSpriteNode.anchorPoint = CGPointMake(0, 0);
    _guessUnionInSpriteNode.position = CGPointMake(0, 0);
    _guessUnionInSpriteNode.size = self.size;
    [self addChild:_guessUnionInSpriteNode];
    
    _guessArray = [NSMutableArray arrayWithCapacity:[Presenter sharedInstance].dimension];
    for (int i = 0; i < [Presenter sharedInstance].dimension; ++i) {
        [_guessArray addObject:@(0)];
    }
    _guessSpriteNodeArray = [NSMutableArray arrayWithCapacity:[Presenter sharedInstance].dimension];
    for (int i = 0; i < [Presenter sharedInstance].dimension; ++i) {
        SKSpriteNode *guessSpriteNode = [SKSpriteNode node];
        guessSpriteNode.anchorPoint = CGPointMake(0, 0);
        guessSpriteNode.position = [self positionForGuess:i];
        guessSpriteNode.size = [self sizeForGuess];
        [_guessUnionInSpriteNode addChild:guessSpriteNode];
        [_guessSpriteNodeArray addObject:guessSpriteNode];
    }
    
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
    self.valueSpriteNode.size = self.size;
    self.guessUnionInSpriteNode.size = self.size;
    for (int i = 0; i < [Presenter sharedInstance].dimension; ++i) {
        SKSpriteNode *guessSpriteNode = [self.guessSpriteNodeArray objectAtIndex:i];
        guessSpriteNode.position = [self positionForGuess:i];
        guessSpriteNode.size = [self sizeForGuess];
    }
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self updateCubeNodeTexture];
    [[Presenter sharedInstance] cubeDidSelect:self];
}

- (void)updateCubeNodeTexture {

}

- (void)setValue:(int)value {
    if (_value != value) {
        _value = value;
        
        if (self.value != 0) {
            SKTexture *valueTexture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:[NSString stringWithFormat:@"s%d.png", self.value]];
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
    
    SKTexture *guessTexture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:[NSString stringWithFormat:@"s%d.png", [[self.guessArray objectAtIndex:index] intValue]]];
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
