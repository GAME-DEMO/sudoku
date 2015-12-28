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

static const NSInteger HeadNodeHeight = 64;
static const NSInteger FootNodeHeight = 120;

@interface GameScene ()

@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong) SKShapeNode *backgroundNode;
@property (nonatomic, strong) SKSpriteNode *headNode;
@property (nonatomic, strong) SudokuHeadContentNode *headContentNode;
@property (nonatomic, strong) SKSpriteNode *bodyNode;
@property (nonatomic, strong) SudokuBodyContentNode *bodyContentNode;
@property (nonatomic, strong) SKSpriteNode *footNode;


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
    _backgroundNode = [SKShapeNode node];
    SKShader *backgroundShapeShader = [SKShader shaderWithFileNamed:@"shader_game_scene_background.fsh"];
    _backgroundNode.fillShader = backgroundShapeShader;
    _backgroundNode.lineWidth = 0;
    [self addChild:_backgroundNode];
    
    _headNode = [SKSpriteNode node];
    [self addChild:_headNode];
    
    _headContentNode = [SudokuHeadContentNode node];
    [_headNode addChild:_headContentNode];
    
    _footNode = [SKSpriteNode node];
    [self addChild:_footNode];
    
    _bodyNode = [SKSpriteNode node];
    [self addChild:_bodyNode];
    
    _bodyContentNode = [SudokuBodyContentNode node];
    [_bodyNode addChild:_bodyContentNode];
    
    _initialized = YES;
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    if (self.initialized) {
        [self reloadLayout];
    }
}

- (void)reloadLayout {
    self.backgroundNode.path = CGPathCreateWithRect(CGRectMake(0, 0, self.size.width, self.size.height), nil);
    
    self.headNode.anchorPoint = CGPointMake(0, 0);
    self.headNode.position = CGPointMake(0, self.size.height - HeadNodeHeight);
    self.headNode.size = CGSizeMake(self.size.width, HeadNodeHeight);
    
    self.headContentNode.anchorPoint = CGPointMake(0, 0);
    self.headContentNode.position = CGPointMake(0, 0);
    self.headContentNode.size = self.headNode.size;

    self.footNode.anchorPoint = CGPointMake(0, 0);
    self.footNode.position = CGPointMake(0, 0);
    self.footNode.size = CGSizeMake(self.size.width, FootNodeHeight);
    
    self.bodyNode.anchorPoint = CGPointMake(0, 0);
    self.bodyNode.position = CGPointMake(0, FootNodeHeight);
    self.bodyNode.size = CGSizeMake(self.size.width, self.size.height - HeadNodeHeight - FootNodeHeight);
    
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
