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
//  |                Head View          |   |
//  |                                  064  |
//  |                                   |   |
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
//  |                                    |  |
//  |                                   128 |
//  |                                    |  |
//  |                Tail View           |  |
//  |                                    |  |
//  |                                    |  |
//  |                                    |  |
//  |                                    |  |
//  |---------------------------------------|

static const NSInteger HeaderNodeHeight = 64;
static const NSInteger TailNodeHeight = 128;

@interface GameScene ()

@property (nonatomic, strong) SKTextureAtlas *gameTextureAtlas;

@property (nonatomic, strong) SKShapeNode *backgroundShapeNode;

@property (nonatomic, strong) SKShapeNode *headNode;
@property (nonatomic, strong) SKShapeNode *bodyNode;
@property (nonatomic, strong) SKShapeNode *tailNode;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    
    myLabel.text = NSLocalizedString(@"Sudoku", nil);
    myLabel.fontSize = 90;
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                   CGRectGetMidY(self.frame));


    SKLabelNode *myLabel2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    myLabel2.text = NSLocalizedString(@"Sudoku", nil);
    myLabel2.fontSize = 90;
    myLabel2.fontColor = [UIColor blackColor];
    myLabel2.position = CGPointMake(CGRectGetMidX(self.frame) + 4,
                                   CGRectGetMidY(self.frame) - 4);

    [self addChild:myLabel];
    myLabel.zPosition = 1;
    [self addChild:myLabel2];
    myLabel2.zPosition = 0;

    if (view) {
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
        
        [self reloadLayout];
    }
}

- (void)reloadLayout {
    if (self.backgroundShapeNode) {
        [self.backgroundShapeNode removeFromParent];
        self.backgroundShapeNode = nil;
    }
    
    self.backgroundShapeNode = [SKShapeNode shapeNodeWithRectOfSize:self.size];
    self.backgroundShapeNode.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    [self addChild:self.backgroundShapeNode];
    
    SKShader *backgroundShapeShader = [SKShader shaderWithFileNamed:@"shader_game_scene_background.fsh"];
    self.backgroundShapeNode.fillShader.uniforms = @[[SKUniform uniformWithName:@"sceneSize" floatVector2:GLKVector2Make(self.size.width, self.size.height)]];
    self.backgroundShapeNode.fillShader = backgroundShapeShader;
    self.backgroundShapeNode.lineWidth = 0;
    
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
