//
//  Algorithm.h
//  sudoku
//
//  Created by Peng Wang on 11/21/15.
//  Copyright © 2015 Peng Wang. All rights reserved.
//

#ifndef Algorithm_h
#define Algorithm_h

using namespace std;

static const int eachCount = 3;
static const int dimension = eachCount * eachCount;
static const int groupsCount = dimension;
static const int cubesCount = dimension;
static const int guessesCount = dimension;

typedef enum _PRINT_TYPE
{
    PRINT_NONE,
    PRINT_CUBE_VALUE,
    PRINT_CUBE_GUESS,
    PRINT_CUBE_LOCAL_XY,
    PRINT_CUBE_GLOABAL_XY
} PRINT_TYPE;

typedef enum _PARM_TYPE
{
    PARM_TYPE_NONE,
    PARM_TYPE_ROW,
    PARM_TYPE_COL,
    PARM_TYPE_GROUP,
    PARM_TYPE_ALL
} PARM_TYPE;

typedef enum _CHECK_RESULT
{
    CHECK_RESULT_NONE       = 0x0,
    CHECK_RESULT_ERROR      = 0x1 << 0,
    CHECK_RESULT_UNFINISH   = 0x1 << 1,
    CHECK_RESULT_DONE       = 0x1 << 2
} CHECK_RESULT;

class CXYCube;
class CXYGroup;
class CHistoryNode;

typedef CXYGroup * (*GROUP)[eachCount][eachCount];
typedef CXYCube * (*GROUP_CUBE)[eachCount][eachCount];
typedef vector<CXYCube *> CUBE_VECTOR;
typedef CUBE_VECTOR::iterator CUBE_ITERATOR;
typedef vector<int> GUESS_VALUE_VECTOR;
typedef GUESS_VALUE_VECTOR::iterator GUESS_VALUE_ITERATOR;
typedef function<void (CXYCube *)> CUBE_FN;
typedef function<void (CXYCube *, int)> CUBE_VALUE_FN;
typedef function<void (CUBE_VECTOR)> CUBE_VECTOR_FN;
typedef function<void (void)> VOID_FN;
typedef vector<int> INDEX_VECTOR;
typedef INDEX_VECTOR::iterator INDEX_ITERATOR;

void PrintFunc(PRINT_TYPE type);

/////////////////////////////////////////
// Class Headers
#pragma mark - CXYNode Class
/////////////////////////////////////////
// Compose coordinate system
/// Y, ROW
/// |-------------------
/// |----6----7----8----
/// |----3----4----5----
/// |----0----1----2----
/// |------------------- X, COL
/////////////////////////////////////////
// CXYCube Class Headers
class CXYCube
{
private:
    int m_localX;
    int m_localY;
    int m_globalX;
    int m_globalY;
    int m_value;
    int m_guess[guessesCount];
public:
    CXYCube();
    
    void SetLocalX(int localX);
    void SetLocalY(int localY);
    void SetGlobalX(int globalX);
    void SetGlobalY(int globalY);
    
    int GetLocalX();
    int GetLocalY();
    int GetGlobalX();
    int GetGlobalY();
    
    int GetGroupX();
    int GetGroupY();
    
    void SetValue(int value);
    int GetValue();
    bool HasValue();
    
    bool SetGuess(int index, int guessValue);
    int GetGuess(int index);
    int * GetGuess();
    bool ClearGuessAt(int index);
    bool ClearGuessValue(int guessValue);
    void ClearGuess();
    
    int NonZeroGuessCount();
    int FirstNonZeroGuessValue();
    bool IsOnlyOneNoneZeroGuess();
    bool ApplyOnlyOneNoneZeroGuess();
    void SetOnlyOneNoneZeroGuess(int guessValue);
    GUESS_VALUE_VECTOR NonZeroGuessVector();
    bool HasThisGuessValue(int guessValue);
    bool HasSameGuess(CXYCube *cube);
    void MergeNoneZeroGuessIntoGuessVector(GUESS_VALUE_VECTOR *guessValueVector);
    int NextGuessValue(int fromGuessValue);
    
    CXYCube * DeepCopyTo();
    void DeepCopyTo(CXYCube *cube);
    
    virtual string Description();
};

/////////////////////////////////////////
// CXYGroup Class Headers
#pragma mark - CXYGroup Class
class CXYGroup
{
private:
    int m_X;
    int m_Y;
    CXYCube * m_pCubes[eachCount][eachCount]; // Local coordination
public:
    CXYGroup(int x, int y);
    ~CXYGroup();
    
    int GetX();
    int GetY();
    CXYCube * GetCube(int row, int col); // Local coordination
    CXYCube * GetCube(int index);
    GROUP_CUBE GetCube();
    
    CXYGroup * DeepCopyTo();
    void DeepCopyTo(CXYGroup *group);
};

/////////////////////////////////////////
// CHistoryNode Class Headers
class CHistoryNode
{
private:
    CXYGroup *m_pGroups[eachCount][eachCount]; // All data cache
    CXYCube *m_pCube; // Set guess from this node
    int m_guessValue;
    
    CHistoryNode * m_pParentNode; // One direction tree
    
public:
    CHistoryNode();
    ~CHistoryNode();
    
    void SetGroups(CXYGroup * groups[eachCount][eachCount]);
    GROUP GetGroups();
    void RestoreGroups(CXYGroup * groups[eachCount][eachCount]);
    
    void SetCube(CXYCube *cube);
    CXYCube * GetCube();
    
    void SetGuessValue(int guessValue);
    int GetGuessValue();
    
    int GetNextGuessValue();
    bool HasNextGuess();
    
    void SetParentNode(CHistoryNode *parentNode);
    CHistoryNode * GetParentNode();
};




#endif /* Algorithm_h */
