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

@property (nonatomic, strong) NSArray<SudokuCubeNode *> *cubeArray;

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
    NSMutableArray *cubes = [NSMutableArray array];
    for (int i = 0; i < [Presenter sharedInstance].cubesCountForAll; ++i) {
        SudokuCubeNode *node = [SudokuCubeNode node];
        node.index = i;
        node.anchorPoint = CGPointMake(0, 0);
        [self addChild:node];
        [cubes addObject:node];
    }
    self.cubeArray = [NSArray arrayWithArray:cubes];
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    [self reloadLayout];
}

- (void)reloadLayout {
    CGFloat cubeSideLength = self.size.width / ((CGFloat)[Presenter sharedInstance].dimension);
    for (int i = 0; i < [Presenter sharedInstance].cubesCountForAll; ++i) {
        SudokuCubeNode *node = [self.cubeArray objectAtIndex:i];
        node.position = CGPointMake([[Presenter sharedInstance] colFromCubeIndex:i] * cubeSideLength,
                                    [[Presenter sharedInstance] rowFromCubeIndx:i] * cubeSideLength);
        if ([[Presenter sharedInstance] groupIndexFromCubeIndex:i] % 2 == 0) {
            node.texture = [[Presenter sharedInstance].gameTextureAtlas textureNamed:@"cube_white@2x.png"];
        } else {
            node.texture = [[Presenter sharedInstance].gameTextureAtlas textureNamed: @"cube_gray@2x.png"];
        }
        
        node.size = CGSizeMake(cubeSideLength, cubeSideLength);
    }
}

@end
