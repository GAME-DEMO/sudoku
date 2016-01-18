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

@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong) SudokuButton *backButton;
@property (nonatomic, strong) SudokuButton *setButton;
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
    self.texture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:@"background_above.png"];
    
    _backButton = [SudokuButton node];
    _backButton.buttonNormalTexture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:@"button_back.png"];
    _backButton.buttonHighlightTexture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:@"button_back_highlight.png"];
    [_backButton addTarget:self action:@selector(returnButtonDidTouchUp) withObject:nil forButtonEvent:SudokuButtonEventTouchUpInside];
    [self addChild:_backButton];
    
    _setButton = [SudokuButton node];
    _setButton.buttonNormalTexture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:@"button_set.png"];
    _setButton.buttonHighlightTexture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:@"button_set_highlight.png"];
    [self addChild:_setButton];
    
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
    
    CGFloat buttonHeight = self.size.height - 20;
    CGFloat setButtonHeight = MIN(buttonHeight, self.setButton.buttonNormalTexture.size.height);
    CGFloat setButtonWidth = self.setButton.buttonNormalTexture.size.width / self.setButton.buttonNormalTexture.size.height * setButtonHeight;
    self.setButton.size = CGSizeMake(setButtonWidth, setButtonHeight);
    self.setButton.anchorPoint = CGPointMake(0, 0);
    self.setButton.position = CGPointMake(self.size.width - setButtonWidth - 20, 0);
    
    CGFloat backButtonHeight = MIN(buttonHeight, self.backButton.buttonNormalTexture.size.height);
    CGFloat backButtonWidth = self.backButton.buttonNormalTexture.size.width / self.backButton.buttonNormalTexture.size.height * backButtonHeight;
    self.backButton.size = CGSizeMake(backButtonWidth, backButtonHeight);
    self.backButton.anchorPoint = CGPointMake(0, 0);
    self.backButton.position = CGPointMake(self.setButton.position.x - backButtonWidth - 8, self.setButton.position.y);
}

- (void)returnButtonDidTouchUp {
    NSLog(@"returnButtonDidTouchUp");
}

@end
