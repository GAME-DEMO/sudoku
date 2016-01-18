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
    for (int i = 0; i < [Presenter sharedInstance].cubesCountForAll; ++i) {
        SudokuCubeNode *cube = [SudokuCubeNode node];
        cube.index = i;
        cube.anchorPoint = CGPointMake(0, 0);
        cube.zPosition = 2;
        [self addChild:cube];
        [cubes addObject:cube];
    }
    _cubeArray = [NSArray arrayWithArray:cubes];
    
    _backgroundFrameSprite = [[SKSpriteNode alloc] initWithImageNamed:@"background_frame.png"];
    _backgroundFrameSprite.centerRect = CGRectMake(200 / 600, 200 / 600, 200 / 600, 122 / 522);
//    self.backgroundFrameSprite.anchorPoint = CGPointMake(0, 0);
//    [self addChild:_backgroundFrameSprite];

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
        SudokuCubeNode *cube = [self.cubeArray objectAtIndex:i];
        cube.position = CGPointMake([[Presenter sharedInstance] colFromCubeIndex:i] * cubeSideLength,
                                    [[Presenter sharedInstance] rowFromCubeIndx:i] * cubeSideLength);
        if ([[Presenter sharedInstance] groupIndexFromCubeIndex:i] % 2 == 0) {
            cube.backgroundTextureName = @"cube_white.png";
        } else {
            cube.backgroundTextureName = @"cube_gray.png";
        }
        cube.selectedTextureName = @"cube_red.png";
        cube.size = CGSizeMake(cubeSideLength, cubeSideLength);
    }

//    self.backgroundFrameSprite.size = self.size;
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
