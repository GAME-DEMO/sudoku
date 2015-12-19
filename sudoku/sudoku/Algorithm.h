//
//  Algorithm.h
//  sudoku
//
//  Created by Peng Wang on 11/21/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#ifndef Algorithm_h
#define Algorithm_h

#include <vector>

int GetEachCount();
int GetDimension();
int GetGroupsCount();
int GetCubesCountForDimension();
int GetCubesCountForAll();

std::vector<int> RandomResult();
int ResultsCount(std::vector<int> cubeValues);
int ResultsCount(std::vector<int> cubeValues, BOOL uniqueSolution);

#endif /* Algorithm_h */
