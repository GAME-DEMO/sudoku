//
//  SudokuBodyContentNode.m
//  sudoku
//
//  Created by Peng Wang on 12/20/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#import "SudokuBodyContentNode.h"
#import "SudokuCubeNode.h"
#import "Presenter.h"

@interface SudokuBodyContentNode ()

@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong) SKShapeNode *backgroundNode;
@property (nonatomic, strong) NSArray<SKSpriteNode *> *backgroundChipArray;
@property (nonatomic, strong) NSArray<SKSpriteNode *> *backgroundLineArray;
@property (nonatomic, strong) SKSpriteNode *backgroundFrameSprite;
@property (nonatomic, strong) NSArray<SudokuCubeNode *> *cubeArray;

@property (nonatomic, strong) SudokuCubeNode *currentSelectedCube;

@end

@implementation SudokuBodyContentNode

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
    self.userInteractionEnabled = YES;
    
    _backgroundNode = [SKShapeNode node];
    SKShader *backgroundShapeShader = [SKShader shaderWithFileNamed:@"shader_body_content_background.fsh"];
    _backgroundNode.fillShader = backgroundShapeShader;
    _backgroundNode.lineWidth = 0;
    _backgroundNode.zPosition = 0;
    [self addChild:_backgroundNode];
    
    NSMutableArray *cubes = [NSMutableArray array];
    NSMutableArray *chips = [NSMutableArray array];
    for (int i = 0; i < [Presenter sharedInstance].cubesCountForAll; ++i) {
        SKSpriteNode *chip = [SKSpriteNode spriteNodeWithTexture:[[Presenter sharedInstance].gameTextureAtlas textureNamed:@"background_wave.png"]];
        chip.anchorPoint = CGPointMake(0, 0);
        chip.zPosition = 1;
        [self addChild:chip];
        [chips addObject:chip];
        
        SudokuCubeNode *cube = [SudokuCubeNode node];
        cube.index = i;
        cube.anchorPoint = CGPointMake(0, 0);
        cube.zPosition = 2;
        [self addChild:cube];
        [cubes addObject:cube];
    }
    _cubeArray = [NSArray arrayWithArray:cubes];
    _backgroundChipArray = [NSArray arrayWithArray:chips];
    
    NSMutableArray *lines = [NSMutableArray array];
    UIColor *lineColor = [UIColor colorWithRed:11.0 / 255.0 green:37.0 / 255.0 blue:65.0 / 255.0 alpha:1];
    for (int i = 0; i < ([Presenter sharedInstance].dimension - 1); ++i) {
        SKSpriteNode *line = [SKSpriteNode node];
        line.anchorPoint = CGPointMake(0, 0.5);
        line.zPosition = 1;
        line.color = lineColor;
        [lines addObject:line];
        [self addChild:line];
    }
    
    for (int i = 0; i < ([Presenter sharedInstance].dimension - 1); ++i) {
        SKSpriteNode *line = [SKSpriteNode node];
        line.anchorPoint = CGPointMake(0.5, 0);
        line.zPosition = 1;
        line.color = lineColor;
        [lines addObject:line];
        [self addChild:line];
    }
    _backgroundLineArray = [NSArray arrayWithArray:lines];
    
    _backgroundFrameSprite = [[SKSpriteNode alloc] initWithTexture:[[Presenter sharedInstance].gameTextureAtlas textureNamed:@"background_frame.png"]];
    _backgroundFrameSprite.centerRect = CGRectMake(1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0, 1.0 / 3.0);
    _backgroundFrameSprite.zPosition = 3;
    self.backgroundFrameSprite.anchorPoint = CGPointMake(0.5, 0.5);
    [self addChild:_backgroundFrameSprite];

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
    
    self.backgroundNode.path = CGPathCreateWithRect(CGRectMake(0, 0, self.size.width, self.size.height), nil);
    
    CGFloat cubeSideLength = self.size.width / ((CGFloat)[Presenter sharedInstance].dimension);
    for (int i = 0; i < [Presenter sharedInstance].cubesCountForAll; ++i) {
        SKSpriteNode *chip = [self.backgroundChipArray objectAtIndex:i];
        chip.position = CGPointMake([[Presenter sharedInstance] colFromCubeIndex:i] * cubeSideLength,
                                    [[Presenter sharedInstance] rowFromCubeIndx:i] * cubeSideLength);
        chip.size = CGSizeMake(cubeSideLength, cubeSideLength);
        
        SudokuCubeNode *cube = [self.cubeArray objectAtIndex:i];
        cube.position = CGPointMake([[Presenter sharedInstance] colFromCubeIndex:i] * cubeSideLength,
                                    [[Presenter sharedInstance] rowFromCubeIndx:i] * cubeSideLength);
        cube.size = CGSizeMake(cubeSideLength, cubeSideLength);
    }
    
    for (int i = 0; i < ([Presenter sharedInstance].dimension - 1); ++i) {
        SKSpriteNode *line = [self.backgroundLineArray objectAtIndex:i];
        line.size = CGSizeMake(self.size.width, 1);
        line.position = CGPointMake(0, cubeSideLength * (i + 1));
    }
    
    for (int i = 0; i < ([Presenter sharedInstance].dimension - 1); ++i) {
        SKSpriteNode *line = [self.backgroundLineArray objectAtIndex:i + ([Presenter sharedInstance].dimension - 1)];
        line.size = CGSizeMake(1, self.size.height);
        line.position = CGPointMake(cubeSideLength * (i + 1), 0);
    }

    self.backgroundFrameSprite.size = self.size;
    self.backgroundFrameSprite.position = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
}

// 一维上点到线段的距离，线段用一个数组表示，[0]表示左点坐标，[1]表示右点坐标
- (CGFloat)distanceFromDot:(CGFloat)dot toLine:(NSArray *)line {
    if (dot < [line[0] floatValue]) {
        return [line[0] floatValue] - dot;
    } else if (dot > [line[1] floatValue]) {
        return dot - [line[1] floatValue];
    } else {
        return 0;
    }
}

// 这里使用曼哈顿距离而不是用欧几里得距离，是为了减轻计算量。
- (CGFloat)distanceToCube:(SudokuCubeNode *)cube fromPoint:(CGPoint)point {
    CGRect frame = CGRectMake(cube.position.x, cube.position.y, cube.size.width, cube.size.height);
    
    CGFloat xDistance = [self distanceFromDot:point.x toLine:@[@(frame.origin.x), @(frame.origin.x + frame.size.width)]];
    CGFloat yDistance = [self distanceFromDot:point.y toLine:@[@(frame.origin.y), @(frame.origin.y + frame.size.height)]];
    
    return xDistance + yDistance;
}

- (SudokuCubeNode *)nearestCubeFromPoint:(CGPoint)point {
    SudokuCubeNode *nearestCube = nil;
    CGFloat nearestDistance = CGFLOAT_MAX;
    for (SudokuCubeNode *cube in self.cubeArray) {
        CGFloat distance = [self distanceToCube:cube fromPoint:point];
        if (distance < nearestDistance) {
            nearestDistance = distance;
            nearestCube = cube;
        }
    }
    return nearestCube;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInNode:self];
    
    SudokuCubeNode *cube = [self nearestCubeFromPoint:touchPoint];
    if (cube != self.currentSelectedCube) {
        self.currentSelectedCube.selected = NO;
        self.currentSelectedCube = cube;
        self.currentSelectedCube.selected = YES;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInNode:self];
    
    SudokuCubeNode *cube = [self nearestCubeFromPoint:touchPoint];
    if (cube != self.currentSelectedCube) {
        self.currentSelectedCube.selected = NO;
        self.currentSelectedCube = cube;
        self.currentSelectedCube.selected = YES;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

@end
