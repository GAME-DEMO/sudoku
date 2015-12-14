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
 |                                   128 |
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

static const NSInteger HeaderNodeHeight = 64;
static const NSInteger TailNodeHeight = 128;

@interface GameScene ()

@property (nonatomic, strong) SKTextureAtlas *gameTextureAtlas;
@property (nonatomic, strong) SKShapeNode *backgroundNode;

@property (nonatomic, strong) SKShapeNode *headNode;
@property (nonatomic, strong) SKShapeNode *bodyNode;
@property (nonatomic, strong) SKShapeNode *tailNode;
@property (nonatomic, strong) NSArray<SudokuCubeNode *> *cubeArray;


@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    if (view) {
        [self reloadLayout];
    }
}

- (void)reloadLayout {
    if (!self.gameTextureAtlas) {
        self.gameTextureAtlas = [SKTextureAtlas atlasNamed:@"Game"];
    }
    
    if (!self.headNode) {
        self.headNode = [SKShapeNode node];
        [self addChild:self.headNode];
        self.headNode.zPosition = 3;
    }
    
    if (!self.bodyNode) {
        self.bodyNode = [SKShapeNode node];
        [self addChild:self.bodyNode];
        self.bodyNode.zPosition = 4;
    }
    
    if (!self.tailNode) {
        self.tailNode = [SKShapeNode node];
        [self addChild:self.tailNode];
        self.tailNode.zPosition = 5;
    }
    
    if (!self.backgroundNode) {
        self.backgroundNode = [SKShapeNode node];
        [self addChild:self.backgroundNode];
    }
    
    self.backgroundNode.path = CGPathCreateWithRect(CGRectMake(0, 0, self.size.width, self.size.height), nil);

    SKShader *backgroundShapeShader = [SKShader shaderWithFileNamed:@"shader_game_scene_background.fsh"];
    self.backgroundNode.fillShader.uniforms = @[[SKUniform uniformWithName:@"sceneSize" floatVector2:GLKVector2Make(self.size.width, self.size.height)]];
    self.backgroundNode.fillShader = backgroundShapeShader;
    self.backgroundNode.lineWidth = 0;
    
    self.headNode.position = CGPointMake(0, self.size.height - HeaderNodeHeight);
    self.headNode.path = CGPathCreateWithRect(CGRectMake(0, 0, self.size.width, HeaderNodeHeight), nil);
    self.headNode.fillColor = [UIColor clearColor];
    self.headNode.lineWidth = 0;
    
    self.tailNode.position = CGPointMake(0, 0);
    self.tailNode.path = CGPathCreateWithRect(CGRectMake(0, 0, self.size.width, TailNodeHeight), nil);
    self.tailNode.fillColor = [UIColor clearColor];
    self.tailNode.lineWidth = 0;
    
    self.bodyNode.position = CGPointMake(0, TailNodeHeight);
    self.bodyNode.path = CGPathCreateWithRect(CGRectMake(0, 0, self.size.width, self.size.height - HeaderNodeHeight - TailNodeHeight), nil);
    self.bodyNode.fillColor = [UIColor clearColor];
    self.bodyNode.lineWidth = 0;
    
    if (!self.cubeArray) {
        NSMutableArray *cubes = [NSMutableArray array];
        
        for (int i = 0; i < [Presenter sharedInstance].cubesCountForAll; ++i) {
            
        }
        
        self.cubeArray = [NSArray arrayWithArray:cubes];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}


// TODO: remove this function and update reloadLayout to use viewWillTransitionToSize to display animation
- (void)viewDidLayoutSubviews {
    [self reloadLayout];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */


}

- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
