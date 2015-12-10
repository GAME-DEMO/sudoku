//
//  GameScene.m
//  sudoku
//
//  Created by Peng Wang on 11/17/15.
//  Copyright (c) 2015 Peng Wang. All rights reserved.
//

#import "GameScene.h"
#import "Presenter.h"

//
//  |---------------------------------------|
//  |                Head View              |
//  |                                       |
//  |---------------------------------------|
//  |                                       |
//  |                                       |
//  |                                       |
//  |                                       |
//  |                Body View              |
//  |                                       |
//  |                                       |
//  |                                       |
//  |                                       |
//  |                                       |
//  |                                       |
//  |                                       |
//  |---------------------------------------|
//  |                                       |
//  |                                       |
//  |                                       |
//  |                Tail View              |
//  |                                       |
//  |                                       |
//  |                                       |
//  |                                       |
//  |---------------------------------------|
@interface GameScene ()

@property (nonatomic, strong) SKTextureAtlas *gameTextureAtlas;
@property (nonatomic, strong) SKSpriteNode *backgroundSpriteNode;
@property (nonatomic, strong) SKTexture *backgroundTexture;

@property (nonatomic, strong) SKSpriteNode *headNode;
@property (nonatomic, strong) SKSpriteNode *bodyNode;
@property (nonatomic, strong) SKSpriteNode *tailNode;


@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = NSLocalizedString(@"Sudoku", nil);
    myLabel.fontSize = 45;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));
    
    [self addChild:myLabel];
    
    if (view) {
        if (!self.gameTextureAtlas) {
            self.gameTextureAtlas = [SKTextureAtlas atlasNamed:@"Game"];
        }
        
        if (!self.backgroundTexture) {
            self.backgroundTexture = [self.gameTextureAtlas textureNamed:@"background@2x.png"];
        }
        
        if (!self.backgroundSpriteNode) {
            self.backgroundSpriteNode = [SKSpriteNode spriteNodeWithTexture:self.backgroundTexture];
            [self addChild:self.backgroundSpriteNode];
        }
        
        if (!self.headNode) {
            self.headNode = [SKSpriteNode node];
            [self addChild:self.headNode];
        }
        
        if (!self.bodyNode) {
            self.bodyNode = [SKSpriteNode node];
            [self addChild:self.bodyNode];
        }
        
        if (!self.tailNode) {
            self.tailNode = [SKSpriteNode node];
            [self addChild:self.tailNode];
        }
        
        [self reloadLayout];
    }
}

- (void)reloadLayout {
    self.backgroundSpriteNode.anchorPoint = CGPointMake(0.5, 0.5);
    self.backgroundSpriteNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    self.backgroundSpriteNode.blendMode = SKBlendModeReplace;
    
    self.backgroundSpriteNode.xScale = self.size.width / self.backgroundTexture.size.width;
    self.backgroundSpriteNode.yScale = self.size.height / self.backgroundTexture.size.height;
    
    if ([Presenter isPortrait]) {
        
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
    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        
////        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//
//        SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"Game"];
//        SKTexture *b1 = [atlas textureNamed:@"background@2x.png"];
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:b1];
//        
//        sprite.xScale = 0.5;
//        sprite.yScale = 0.5;
//        sprite.position = location;
//        
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
//    }


}

- (void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
