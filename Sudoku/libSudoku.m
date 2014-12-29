#import "libSudoku.h"
#import "libSudokuStatics.h"

SudokuData    CreateSudoku(UInt8 *src)
{
    SudokuData r;
    memcpy(&r, src, sizeof(r));
    return r;
}

static void tryNext(PSdkData psd)
{
    if (psd->idxCount == 0)
    {
        // found!
        if (psd->cb)
        {
            SudokuData tmp;
            for (int i = 0; i < 81; i++)
                tmp.tiles[i] = psd->tiles[i].digit;
            psd->stop = !psd->cb(++ psd->solutionCount, &tmp, psd->userdata);
        }
        return;
    }
    
    // greater count == less possible numbers, so find the max one
    int maxId = --psd->idxCount,
        maxTid = psd->index[maxId],
        maxCnt = psd->tiles[maxTid].mskCnt;
    if (maxCnt < 8)
        for (int i = 0; i < psd->idxCount; i++)
        {
            int tid = psd->index[i];
            UInt16 cnt = psd->tiles[tid].mskCnt;
            if (cnt <= maxCnt)
                continue;
            maxId = i;
            maxTid = tid;
            maxCnt = cnt;
            
            if (maxCnt == 8)
                // only 1 possible number
                break;
        }
    
    // backup
    Tile bakTiles[RELATIVE_COUNT+1];
    psd->index[maxId] = psd->index[psd->idxCount];
    bakTiles[RELATIVE_COUNT] = psd->tiles[maxTid];
    for (int i = 0; i < RELATIVE_COUNT; i++)
        bakTiles[i] = psd->tiles[Relative[maxTid][i]];
    
    UInt16 mask = psd->tiles[maxTid].umask;
    //enumMaskOutter:
    for (int _ = 0, _M = 9-maxCnt; _ < _M; _++)
    {
        /*	for exp.		[..654321]
         to be found:	  --- v = 3
         mask (m) 	=	0b_010011	PLUS	1 =>
         :	mask+1  =	0b_010100	XOR	 mask =>
         -> t=m^(m+1)=	0b_000111
         ->	flag =		0b_000100	OR	 mask =>
         ->	mask =		0b_010111	( save for next loop )
         
         bsf returns the number of tail's 0
         =>	bsf(t) => 3
         */
        UInt16 t = (mask+1) ^ mask, flag = (t+1) >> 1;
        psd->tiles[maxTid].digit = (UInt8) popcnt(t);
        mask |= flag;
        bool goonOuter = false;
        
        for (int i = 0; i < RELATIVE_COUNT; i++)
        {
            int rid = Relative[maxTid][i];
            // if the cell is already filled, skip it.
            if (psd->tiles[rid].digit)
                continue;
            
            UInt16 msk = bakTiles[i].umask;
            if (msk & flag) {
                // already set, just restore
                psd->tiles[rid] = bakTiles[i];
            } else {
                // not set yet. reduce candidate number first.
                UInt8 newCnt = bakTiles[i].mskCnt+1;
                if(newCnt == 9)
                {
                    // while candidate number becomes to 0, it won't work. so give up.
                    goonOuter = true;
                    break;
                }
                
                psd->tiles[rid].umask = (UInt16)(msk | flag);
                psd->tiles[rid].mskCnt = newCnt;
            }
        }
        
        if (goonOuter)
            continue;
        
        tryNext(psd);
        
        if (psd->stop)
            return;
    }
    
    // restore
    psd->tiles[maxTid] = bakTiles[RELATIVE_COUNT];
    for (int i = 0; i < RELATIVE_COUNT; i++)
        psd->tiles[Relative[maxTid][i]] = bakTiles[i];
    psd->index[maxId] = maxTid;
    ++ psd->idxCount;
}

static int doSolveSudoku(const SudokuData * const sd, EventSolveSudoku cb, void * ud)
{
    // init
    SdkData sdata;
    memset(&sdata, 0, sizeof(sdata));
    sdata.cb = cb;
    sdata.userdata = ud;
    
    for (int idx = 0; idx < 81; idx++)
    {
        UInt8 v = sdata.tiles[idx].digit = sd->tiles[idx];
        if(v==0)
        {
            // if the cell is 0 then append to the remains list.
            sdata.index[sdata.idxCount++] = idx;
            continue;
        }
        
        // set the flag of relative cells.
        UInt16 mask = 1<<(v-1);
        for (int i = 0; i < RELATIVE_COUNT; i++)
            sdata.tiles[Relative[idx][i]].umask |= mask;
    }
    
    // update "count". popcnt returns the number of bit 1.
    for (int i = 0; i < 81; i++)
    {
        PTile t = &sdata.tiles[i];
        t->mskCnt = (UInt8) popcnt(t->umask);
    }
    
    tryNext(&sdata);
    return sdata.solutionCount;
}

static bool cbSolutionMoreThanOne(int index, const SudokuData * const sd, void * ud)
{
    return index <= 1;
}

SudokuStatus	CheckSudokuStatus(const SudokuData *const sd, bool checkSolvable)
{
	bool isFull = true;
	const UInt16 FULL_MASK = 0x1FF;

	for (int i = 0; i < 9; i++)
	{
		UInt16 rowMask = 0, colMask = 0, mtxMask = 0;
		int mr = i / 3 * 3, mc = i % 3 * 3;
		for (int j = 0; j < 9; j++)
		{
			if ( isInvalid(sd->rows[i][j], &rowMask)
			  || isInvalid(sd->rows[j][i], &colMask)
			  || isInvalid(sd->rows[mr+j/3][mc+j%3], &mtxMask) )
				return ssInvalid;
		}

		//writefln("%x\t%x\t%x", rowMask, colMask, mtxMask);
		isFull = isFull && rowMask==FULL_MASK && colMask==FULL_MASK && mtxMask==FULL_MASK;
	}

	if (isFull)
		return ssSolved;

	if (checkSolvable)
	{
		switch ( doSolveSudoku(sd, &cbSolutionMoreThanOne, NULL) )
		{
			case 0:
				return ssUnsolvable;
			case 1:
				return ssOnlySolution;
			default:
				return ssMultiSolution;
		}
	}
	return ssUnknown;
}

static bool cbSolveSingle(int index, const SudokuData * const sd, void * ud)
{
    *((SudokuData*)ud) = *sd;
    return false;
}

bool	SolveSudoku(SudokuData *sd)
{
	switch (CheckSudokuStatus(sd, false)) {
		case ssInvalid:
			return false;
		case ssSolved:
			return true;
		default:
			return (doSolveSudoku( sd, cbSolveSingle, sd ) > 0);
	}
}

static bool cbSolveAll(int index, const SudokuData * const sd, void * ud)
{
	__weak NSPointerArray * rs = (__bridge NSPointerArray*)ud;
	PSudokuData r = malloc(sizeof(SudokuData));
	*r = *sd;
	[rs addPointer:r];
	return true;
}

NSPointerArray*	FindAllSolutions(const SudokuData *const sd)
{
	switch (CheckSudokuStatus(sd, false)) {
		case ssInvalid:
			return nil;
		case ssSolved:
			return nil;
        default:
            ;
	}
    NSPointerArray * rs = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality];
    return doSolveSudoku( sd, cbSolveAll, (__bridge void *)(rs) ) > 0 ? rs : nil;
}

SudokuData	GenerateSudoku()
{
/* Algorithm:
step.1	There are 3 INDEPENDENT 3*3 sub-squares. Shuffle each sub-square (1~9).
step.2	Set 6 single position (marked as ?) to random number.
step.3	Try to solve the sudoku. Repeat the steps if failed.
	0 1 2   3 4 5   6 7 8
  =========================
0 | 1 2 3 | . . ? | . . . |
1 | 4 5 6 | . . . | . . ? |
2 | 7 8 9 | . . . | . . . |
  |-------+-------+-------|
3 | . . . | 1 2 3 | ? . . |
4 | . . . | 4 5 6 | . . . |
5 | . . ? | 7 8 9 | . . . |
  |-------+-------+--------
6 | . . . | . ? . | 1 2 3 |
7 | ? . . | . . . | 4 5 6 |
8 | . . . | . . . | 7 8 9 |
  =========================
*/
	UInt8 ids[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, };
	NSPointerArray* sds;
	SudokuData sd;
    memset(&sd, 0, sizeof(sd));
	do {
		for (int t = 0; t < 3; t++)
		{
            const int * mb = &MTX_BASE[t][0];
            int idx = mb[0]*9 + mb[1];
			shuffle(ids, 9);
			for (int i = 0; i < 9; i++)
				sd.tiles[idx + MTX_OFFSET[i]] = ids[i];
		}

		//foreach (coord; SINGLES)
		for (int t = 0; t < 6; t++)
		{
            const int * coord = &SINGLES[t][0];
            int r = coord[0]*9, c = coord[1], mask = 0;
			for (int i = 0; i < 9; i++)
			{
				mask |= 1 << sd.tiles[r+i];
				mask |= 1 << sd.tiles[i*9+c];
			}

			UInt8 d;
			do {
				d = (UInt8)(1 + arc4random_uniform(10) );
			} while (1<<d & mask);
			sd.tiles[r+c] = d;
		}
		sds = FindAllSolutions(&sd);
	} while( sds == nil );

	int count = (int)[sds count];
	sd = *(PSudokuData)[sds pointerAtIndex:arc4random_uniform(count)];
	for (int i = 0; i < count; i++)
		free([sds pointerAtIndex:i]);
	return sd;
}

SudokuStatus	CrossSudoku(SudokuData *sd, EventCrossSudoku cb, void * ud)
{
	SudokuStatus r = CheckSudokuStatus(sd, true);
	switch (r) {
		case ssSolved: case ssOnlySolution:
			break;
		case ssInvalid: case ssUnsolvable: case ssMultiSolution:
			return r;
		default: ;
	}

	UInt8 index[81];
	/*
	index	[i0, ..., iM, ... iN, 0... ]
	            first--^       ^--last
	..iM: Failed
	iN..: Crossed
	Random select from iM..iN and try to cross. 
	*/
	UInt8 last = 0, first = 0;
	for (UInt8 i = 0; i < 81; i++)
	{
		UInt8 t = sd->tiles[i];
		if (t == 0)
			continue;
		index[last++] = i;
	}

	while (first < last)
	{
		// This way is the same as shuffle.
		int rnd = first + arc4random_uniform(last), ridx = index[rnd];
		UInt8 t = sd->tiles[ridx];
		sd->tiles[ridx] = 0;

		if ( doSolveSudoku(sd, cbSolutionMoreThanOne, NULL) == 1 )
		{
			// succ: only exists 1 solution
			if (cb)
			{
				if (!cb(ssCrossing, last-1, sd, ud))
					return ssCrossing;
			}
			index[rnd] = index[--last];
		} else {
			// failed! => Cross this number will cause more than 1 solutions, so skip it.
			sd->tiles[ridx] = t;
			index[rnd] = index[first++];
		}
	}

	if (cb)
		cb(ssCrossDone, last-1, sd, ud);
	return ssCrossDone;
}
