//
//  GameScene.m
//  sudoku
//
//  Created by Peng Wang on 11/17/15.
//  Copyright (c) 2015 Peng Wang. All rights reserved.
//

#import "GameScene.h"
#import "Presenter.h"

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

static const NSInteger HeaderNodeHeight = 64;
static const NSInteger TailNodeHeight = 128;

@interface GameScene ()

@property (nonatomic, strong) SKTextureAtlas *gameTextureAtlas;
@property (nonatomic, strong) SKShapeNode *backgroundShapeNode;

@property (nonatomic, strong) SKShapeNode *headShapeNode;
@property (nonatomic, strong) SKShapeNode *bodyShapeNode;
@property (nonatomic, strong) SKShapeNode *tailShapeNode;

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
    
    if (!self.headShapeNode) {
        self.headShapeNode = [SKShapeNode node];
        [self addChild:self.headShapeNode];
        self.headShapeNode.zPosition = 3;
    }
    
    if (!self.bodyShapeNode) {
        self.bodyShapeNode = [SKShapeNode node];
        [self addChild:self.bodyShapeNode];
        self.bodyShapeNode.zPosition = 4;
    }
    
    if (!self.tailShapeNode) {
        self.tailShapeNode = [SKShapeNode node];
        [self addChild:self.tailShapeNode];
        self.tailShapeNode.zPosition = 5;
    }
    
    if (!self.backgroundShapeNode) {
        self.backgroundShapeNode = [SKShapeNode node];
        [self addChild:self.backgroundShapeNode];
    }
    
    self.backgroundShapeNode.path = CGPathCreateWithRect(CGRectMake(0, 0, self.size.width, self.size.height), nil);

    SKShader *backgroundShapeShader = [SKShader shaderWithFileNamed:@"shader_game_scene_background.fsh"];
    self.backgroundShapeNode.fillShader.uniforms = @[[SKUniform uniformWithName:@"sceneSize" floatVector2:GLKVector2Make(self.size.width, self.size.height)]];
    self.backgroundShapeNode.fillShader = backgroundShapeShader;
    self.backgroundShapeNode.lineWidth = 0;
    
    self.headShapeNode.position = CGPointMake(0, self.size.height - HeaderNodeHeight);
    self.headShapeNode.path = CGPathCreateWithRect(CGRectMake(0, 0, self.size.width, HeaderNodeHeight), nil);
    self.headShapeNode.fillColor = [UIColor clearColor];
    self.headShapeNode.lineWidth = 0;
    
    self.tailShapeNode.position = CGPointMake(0, 0);
    self.tailShapeNode.path = CGPathCreateWithRect(CGRectMake(0, 0, self.size.width, TailNodeHeight), nil);
    self.tailShapeNode.fillColor = [UIColor clearColor];
    self.tailShapeNode.lineWidth = 0;
    
    self.bodyShapeNode.position = CGPointMake(0, TailNodeHeight);
    self.bodyShapeNode.path = CGPathCreateWithRect(CGRectMake(0, 0, self.size.width, self.size.height - HeaderNodeHeight - TailNodeHeight), nil);
    self.bodyShapeNode.fillColor = [UIColor clearColor];
    self.bodyShapeNode.lineWidth = 0;
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
