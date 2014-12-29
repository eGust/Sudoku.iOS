//
//  libSudoku_test.h
//  Sudoku
//
//  Created by Chen Xi on 14/12/27.
//  Copyright (c) 2014年 Chen Xi. All rights reserved.
//

#ifndef Sudoku_libSudoku_test_h
#define Sudoku_libSudoku_test_h

#import <Foundation/Foundation.h>
#import "libSudoku.h"

void    dbgPrintSudoku(SudokuData *const sd);
void    dbgTestSolve();
void    dbgTestCrossing();

#endif
