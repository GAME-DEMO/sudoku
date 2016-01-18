//
//  GameScene.m
//  sudoku
//
//  Created by Peng Wang on 11/17/15.
//  Copyright (c) 2015 Peng Wang. All rights reserved.
//

/*
 |---------------------------------------|
 |                Head View          |   |
 |                                  064  |
 |                                   |   |
 |---------------------------------------|
 |                                       |
 |                                       |
 |                                       |
 |                                       |
 |                Body View              |
 |                                       |
 |                                       |
 |                                       |
 |                                       |
 |                                       |
 |                                       |
 |                                       |
 |---------------------------------------|
 |                                    |  |
 |                                   120 |
 |                                    |  |
 |                Foot View           |  |
 |                                    |  |
 |                                    |  |
 |                                    |  |
 |                                    |  |
 |---------------------------------------|
 */


#import "GameScene.h"
#import "Presenter.h"
#import "SudokuHeadContentNode.h"
#import "SudokuBodyContentNode.h"
#import "SudokuFootContentNode.h"

static const NSInteger HeadNodeHeight = 64;

@interface GameScene ()

@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong) SKSpriteNode *headNode;
@property (nonatomic, strong) SudokuHeadContentNode *headContentNode;
@property (nonatomic, strong) SKSpriteNode *bodyNode;
@property (nonatomic, strong) SudokuBodyContentNode *bodyContentNode;
@property (nonatomic, strong) SKSpriteNode *footNode;
@property (nonatomic, strong) SudokuFootContentNode *footContentNode;

@end

@implementation GameScene

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        [self initialize];
        [self reloadLayout];
    }
    return self;
}

- (void)initialize {
    _headNode = [SKSpriteNode node];
    [self addChild:_headNode];
    
    _headContentNode = [SudokuHeadContentNode node];
    [_headNode addChild:_headContentNode];
    
    _bodyNode = [SKSpriteNode node];
    [self addChild:_bodyNode];
    
    _bodyContentNode = [SudokuBodyContentNode node];
    [_bodyNode addChild:_bodyContentNode];
    
    _footNode = [SKSpriteNode node];
    [self addChild:_footNode];
    
    _footContentNode = [SudokuFootContentNode node];
    [_footNode addChild:_footContentNode];
    
    _initialized = YES;
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    if (self.initialized) {
        [self reloadLayout];
    }
}

- (void)reloadLayout {
    self.headNode.anchorPoint = CGPointMake(0, 0);
    self.headNode.position = CGPointMake(0, self.size.height - HeadNodeHeight);
    self.headNode.size = CGSizeMake(self.size.width, HeadNodeHeight);
    
    self.headContentNode.anchorPoint = CGPointMake(0, 0);
    self.headContentNode.position = CGPointMake(0, 0);
    self.headContentNode.size = self.headNode.size;
    
    CGFloat bodyNodeSideLength = self.size.width;

    self.footNode.anchorPoint = CGPointMake(0, 0);
    self.footNode.position = CGPointMake(0, 0);
    self.footNode.size = CGSizeMake(self.size.width, self.size.height - self.headNode.size.height - bodyNodeSideLength);
    
    self.footContentNode.anchorPoint = CGPointMake(0, 0);
    self.footContentNode.position = CGPointMake(0, 0);
    self.footContentNode.size = self.footNode.size;
    
    self.bodyNode.anchorPoint = CGPointMake(0, 0);
    self.bodyNode.position = CGPointMake(0, self.footNode.size.height);
    self.bodyNode.size = CGSizeMake(bodyNodeSideLength, bodyNodeSideLength);
    
    CGFloat cubeAreaSideLength = MIN(self.bodyNode.size.width, self.bodyNode.size.height);
    CGFloat cubeAreaBottomMargin = (self.bodyNode.size.height - cubeAreaSideLength) / 2.0;
    CGFloat cubeAreaLeftMargin = (self.bodyNode.size.width - cubeAreaSideLength) / 2.0;
    
    self.bodyContentNode.anchorPoint = CGPointMake(0, 0);
    self.bodyContentNode.position = CGPointMake(cubeAreaLeftMargin, cubeAreaBottomMargin);
    self.bodyContentNode.size = CGSizeMake(cubeAreaSideLength, cubeAreaSideLength);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */

    
}

- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
