//
//  SudokuHeadContentNode.m
//  sudoku
//
//  Created by Peng Wang on 12/26/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import "SudokuHeadContentNode.h"
#import "SudokuButton.h"
#import "Presenter.h"

@interface SudokuHeadContentNode ()

@property (nonatomic, strong) SudokuButton *backButton;
@property (nonatomic, strong) SKLabelNode *titleLabel;
@property (nonatomic, strong) SudokuButton *restartButton;

@end

@implementation SudokuHeadContentNode

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
    _backButton = [SudokuButton node];
    SKTexture *backButtonTexture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:@"return@2x.png"];
    _backButton.normalTexture = backButtonTexture;
    _backButton.texture = backButtonTexture;
    _backButton.anchorPoint = CGPointMake(0, 0);
    _backButton.position = CGPointMake(12, 0);
    [_backButton addTarget:self action:@selector(returnButtonDidTouchUp) withObject:nil forButtonEvent:SudokuButtonEventTouchUp];
    [self addChild:_backButton];
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    [self reloadLayout];
}

- (void)reloadLayout {
    CGFloat backButtonHeight = self.size.height * 1.0 / 3.0;
    CGFloat backButtonWidth = self.backButton.texture.size.width / self.backButton.texture.size.height * backButtonHeight;
    self.backButton.size = CGSizeMake(backButtonWidth, backButtonHeight);

}

- (void)returnButtonDidTouchUp {
    NSLog(@"returnButtonDidTouchUp");
}

@end
