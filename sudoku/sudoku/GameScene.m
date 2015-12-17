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
#import "SudokuCubeNode.h"

static const NSInteger HeadNodeHeight = 64;
static const NSInteger TailNodeHeight = 120;

@interface GameScene ()

@property (nonatomic, assign) BOOL initialized;
@property (nonatomic, strong) SKTextureAtlas *gameTextureAtlas;
@property (nonatomic, strong) SKShapeNode *backgroundNode;
@property (nonatomic, strong) SKSpriteNode *headNode;
@property (nonatomic, strong) SKSpriteNode *bodyNode;
@property (nonatomic, strong) SKSpriteNode *tailNode;
@property (nonatomic, strong) NSArray<SudokuCubeNode *> *cubeArray;


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
    self.gameTextureAtlas = [SKTextureAtlas atlasNamed:@"Game"];

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
    
    NSMutableArray *cubes = [NSMutableArray array];
    for (int i = 0; i < [Presenter sharedInstance].cubesCountForAll; ++i) {
        SudokuCubeNode *node = [SudokuCubeNode node];
        node.index = i;
        node.anchorPoint = CGPointMake(0, 0);
        [self.bodyNode addChild:node];
        [cubes addObject:node];
    }
    self.cubeArray = [NSArray arrayWithArray:cubes];
    
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
    
    CGFloat cubeAreaSideLength = MIN(self.bodyNode.size.width, self.bodyNode.size.height) * 0.96;
    CGFloat cubeAreaBottomMargin = (self.bodyNode.size.height - cubeAreaSideLength) / 2.0;
    CGFloat cubeAreaLeftMargin = (self.bodyNode.size.width - cubeAreaSideLength) / 2.0;
    
    CGFloat cubeSideLength = cubeAreaSideLength / ((CGFloat)[Presenter sharedInstance].dimension);
    for (int i = 0; i < [Presenter sharedInstance].cubesCountForAll; ++i) {
        SudokuCubeNode *node = [self.cubeArray objectAtIndex:i];
        node.position = CGPointMake([[Presenter sharedInstance] colFromCubeIndex:i] * cubeSideLength + cubeAreaLeftMargin,
                                    [[Presenter sharedInstance] rowFromCubeIndx:i] * cubeSideLength + cubeAreaBottomMargin);
        if ([[Presenter sharedInstance] groupIndexFromCubeIndex:i] % 2 == 0) {
            node.texture = [self.gameTextureAtlas textureNamed:@"cube_white@2x.png"];
        } else {
            node.texture = [self.gameTextureAtlas textureNamed: @"cube_gray@2x.png"];
        }
        
        node.size = CGSizeMake(cubeSideLength, cubeSideLength);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */


}

- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
