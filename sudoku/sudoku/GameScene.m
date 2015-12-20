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
 |                Tail View           |  |
 |                                    |  |
 |                                    |  |
 |                                    |  |
 |                                    |  |
 |---------------------------------------|
 */


#import "GameScene.h"
#import "Presenter.h"
#import "SudokuBodyContentNode.h"

static const NSInteger HeadNodeHeight = 64;
static const NSInteger TailNodeHeight = 120;

@interface GameScene ()

@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong) SKShapeNode *backgroundNode;
@property (nonatomic, strong) SKSpriteNode *headNode;
@property (nonatomic, strong) SKSpriteNode *bodyNode;
@property (nonatomic, strong) SudokuBodyContentNode *bodyContentNode;
@property (nonatomic, strong) SKSpriteNode *tailNode;


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
    self.backgroundNode = [SKShapeNode node];
    SKShader *backgroundShapeShader = [SKShader shaderWithFileNamed:@"shader_game_scene_background.fsh"];
    self.backgroundNode.fillShader = backgroundShapeShader;
    self.backgroundNode.lineWidth = 0;
    [self addChild:self.backgroundNode];
    
    self.headNode = [SKSpriteNode node];
    [self addChild:self.headNode];
    
    self.tailNode = [SKSpriteNode node];
    [self addChild:self.tailNode];
    
    self.bodyNode = [SKSpriteNode node];
    [self addChild:self.bodyNode];
    
    self.bodyContentNode = [SudokuBodyContentNode node];
    [self.bodyNode addChild:self.bodyContentNode];
    
    self.initialized = YES;
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

    self.tailNode.anchorPoint = CGPointMake(0, 0);
    self.tailNode.position = CGPointMake(0, 0);
    self.tailNode.size = CGSizeMake(self.size.width, TailNodeHeight);
    
    self.bodyNode.anchorPoint = CGPointMake(0, 0);
    self.bodyNode.position = CGPointMake(0, TailNodeHeight);
    self.bodyNode.size = CGSizeMake(self.size.width, self.size.height - HeadNodeHeight - TailNodeHeight);
    
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
