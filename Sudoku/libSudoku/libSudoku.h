//
//  libSudoku.h
//  Sudoku
//
//  Created by Chen Xi on 14/12/27.
//  Copyright (c) 2014 Chen Xi. All rights reserved.
//

#ifndef Sudoku_libSudoku_h
#define Sudoku_libSudoku_h

#import <Foundation/Foundation.h>

typedef enum {
    ssUnknown, ssSolved, ssInvalid,
    ssUnsolvable, ssOnlySolution, ssMultiSolution,
    ssCrossing, ssCrossDone,
}	SudokuStatus;

typedef union U_SudokuData {
    UInt8	tiles[81];
    UInt8	rows[9][9];
}	SudokuData, *PSudokuData;

typedef bool (*EventCrossSudoku)(SudokuStatus, int, const SudokuData * const, void*);

// API
  SudokuData    CreateSudoku(UInt8 *);
SudokuStatus    CheckSudokuStatus(const SudokuData *const sd, bool checkSolvable);
        bool	SolveSudoku(SudokuData *sd);
NSPointerArray*	FindAllSolutions(const SudokuData *const sd);
  SudokuData	GenerateSudoku();
SudokuStatus	CrossSudoku(SudokuData *sd, EventCrossSudoku cb, void * ud);

#define	RELATIVE_COUNT	20

extern const int Relative[81][RELATIVE_COUNT];

#endif
