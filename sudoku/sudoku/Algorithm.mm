//
//  Algorightm.cpp
//  sudoku_alg
//
//  Created by Wang Peng on 8/3/15.
//  Copyright (c) 2015 Wang Peng. All rights reserved.
//

#include <cstdio>
#include <string>
#include <cstdlib>
#include <memory.h>
#include <ctime>
#include <vector>
#include <cstdarg>
#include <functional>

#include "Algorithm.h"

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

typedef enum _ALGORITHM_FUNCTION
{
    ALGORITHM_FUNCTIONS_UPDATE_GUESS,
    ALGORITHM_FUNCTIONS_CRME,
    ALGORITHM_FUNCTIONS_LONG_RANGER,
    ALGORITHM_FUNCTIONS_TWINS,
    ALGORITHM_FUNCTIONS_TRIPLES,
    ALGORITHM_FUNCTIONS_BRUTE_FORCE,
    ALGORITHM_FUNCTIONS_ALL
} ALGORITHM_FUNCTION;

class CXYCube;
class CXYGroup;
class CHistoryNode;

using namespace std;

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

#define CHR()                                       \
{                                                   \
    if (result == CHECK_RESULT_ERROR)               \
    {                                               \
        return;                                     \
    }                                               \
}

#define CHRB()                                      \
{                                                   \
    if (result == CHECK_RESULT_ERROR)               \
    {                                               \
        return false;                               \
    }                                               \
}

#define CHRD()                                      \
{                                                   \
    if (result == CHECK_RESULT_DONE)                \
    {                                               \
        break;                                      \
    }                                               \
    else if (result == CHECK_RESULT_ERROR)          \
    {                                               \
        continue;                                   \
    }                                               \
}



#define CHRBL(block)                                \
{                                                   \
    if (result == CHECK_RESULT_ERROR)               \
    {                                               \
        block();                                    \
    }                                               \
}



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
    int m_randomGuessIndex;
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
    bool IsOnlyOneNoneZeroGuess();
    
    int FirstNonZeroGuessValue();
    int NextGuessValue(int fromGuessValue);
    int FirstNonZeroGuessValueFromRandomGuessIndex();
    int NextGuessValueFromRandomGuessIndex(int fromGuessValue);
    
    bool ApplyOnlyOneNoneZeroGuess();
    void SetOnlyOneNoneZeroGuess(int guessValue);
    GUESS_VALUE_VECTOR NonZeroGuessVector();
    bool HasThisGuessValue(int guessValue);
    bool HasSameGuess(CXYCube *cube);
    void MergeNoneZeroGuessIntoGuessVector(GUESS_VALUE_VECTOR *guessValueVector);
    
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
    
    int GetNextGuessValueFromRandomGuessIndex();
    bool HasNextGuessFromRandomGuessIndex();
    
    void SetParentNode(CHistoryNode *parentNode);
    CHistoryNode * GetParentNode();
    
    virtual string Description();
};

/////////////////////////////////////////
// Data
#pragma mark - Data
CXYGroup * g_pGroups[eachCount][eachCount];
CXYCube * g_pCubes[cubesCount][cubesCount]; // Global coordination
bool g_bCubeValueChanged;
bool g_bCubeGuessValueChanged;
ALGORITHM_FUNCTION g_currentFunction;
bool g_bCubeValueChangedInFunction[ALGORITHM_FUNCTIONS_ALL];
bool g_bCubeGuessValueChangedInFunction[ALGORITHM_FUNCTIONS_ALL];
CHistoryNode * g_pHistoryHeadNode;
CHistoryNode * g_pHistoryTailNode;


/////////////////////////////////////////
// Algorithm Helper
#pragma mark - Algorithm Helper
void SetValueChanged()
{
    g_bCubeValueChanged = true;
}

void SetGuessValueChanged()
{
    g_bCubeGuessValueChanged = true;
}

void ClearValueChangedFlags()
{
    g_bCubeValueChanged = false;
    g_bCubeGuessValueChanged = false;
}

bool IsValueChanged()
{
    return g_bCubeValueChanged || g_bCubeGuessValueChanged;
}

void SetValueChangedForFunction(ALGORITHM_FUNCTION function)
{
    g_bCubeValueChangedInFunction[function] = true;
}

void SetValueChangedForCurrentFunction()
{
    SetValueChangedForFunction(g_currentFunction);
}

void SetGuessValueChangedForFunction(ALGORITHM_FUNCTION function)
{
    g_bCubeGuessValueChangedInFunction[function] = true;
}

void SetGuessValueChangedForCurrentFunction()
{
    SetGuessValueChangedForFunction(g_currentFunction);
}

void ClearValueChangedFlagsForFunction(ALGORITHM_FUNCTION function)
{
    g_bCubeValueChangedInFunction[function] = false;
    g_bCubeGuessValueChangedInFunction[function] = false;
}

void ClearValueChangedFlagsForCurrentFunction()
{
    ClearValueChangedFlagsForFunction(g_currentFunction);
}

bool IsValueChangedForFunction(ALGORITHM_FUNCTION function)
{
    return g_bCubeValueChangedInFunction[function] || g_bCubeGuessValueChangedInFunction[function];
}

bool IsValueChangedForCurrentFunction()
{
    return IsValueChangedForFunction(g_currentFunction);
}

void ClearValueChangedFlagsForAllFunctions()
{
    for (int i = 0; i < ALGORITHM_FUNCTIONS_ALL; ++i)
    {
        ClearValueChangedFlagsForFunction((ALGORITHM_FUNCTION)i);
    }
}


/////////////////////////////////////////
// Class Implements
/////////////////////////////////////////
#pragma mark - Class Implements
#pragma mark - CXYCube Implement
// CXYCube
CXYCube::CXYCube() :
m_localX(0),
m_localY(0),
m_globalX(0),
m_globalY(0),
m_value(0)
{
    for (int i = 0; i < guessesCount; ++i)
    {
        m_guess[i] = i + 1;
    }
    m_randomGuessIndex = rand() % guessesCount;
}

void CXYCube::SetLocalX(int localX)
{
    m_localX = localX;
}

void CXYCube::SetLocalY(int localY)
{
    m_localY = localY;
}

void CXYCube::SetGlobalX(int globalX)
{
    m_globalX = globalX;
}

void CXYCube::SetGlobalY(int globalY)
{
    m_globalY = globalY;
}

int CXYCube::GetLocalX()
{
    return m_localX;
}

int CXYCube::GetLocalY()
{
    return m_localY;
}

int CXYCube::GetGlobalX()
{
    return m_globalX;
}

int CXYCube::GetGlobalY()
{
    return m_globalY;
}

int CXYCube::GetGroupX()
{
    return m_globalX / eachCount;
}

int CXYCube::GetGroupY()
{
    return m_globalY / eachCount;
}

void CXYCube::SetValue(int value)
{
    if (m_value != value)
    {
        m_value = value;
        SetValueChanged();
        SetValueChangedForCurrentFunction();
    }
}

int CXYCube::GetValue()
{
    return m_value;
}

bool CXYCube::HasValue()
{
    return m_value > 0;
}

bool CXYCube::SetGuess(int index, int guessValue)
{
    if (index >= 0 && index < guessesCount)
    {
        if (m_guess[index] != guessValue)
        {
            m_guess[index] = guessValue;
            SetGuessValueChanged();
            SetGuessValueChangedForCurrentFunction();
            return true;
        }
    }
    return false;
}

int CXYCube::GetGuess(int index)
{
    if (index >= 0 && index < guessesCount)
    {
        return m_guess[index];
    }
    return 0;
}

int * CXYCube::GetGuess()
{
    return m_guess;
}

bool CXYCube::ClearGuessAt(int index)
{
    if (index >= 0 && index < guessesCount)
    {
        bool hasValue = m_guess[index] > 0;
        SetGuess(index, 0);
        return hasValue;
    }
    return false;
}

bool CXYCube::ClearGuessValue(int guessValue)
{
    return ClearGuessAt(guessValue - 1);
}

void CXYCube::ClearGuess()
{
    for (int i = 0; i < guessesCount; ++i)
    {
        SetGuess(i, 0);
    }
}

int CXYCube::NonZeroGuessCount()
{
    int cnt = 0;
    for (int i = 0; i < guessesCount; ++i)
    {
        if (m_guess[i] > 0)
        {
            ++cnt;
        }
    }
    return cnt;
}

bool CXYCube::IsOnlyOneNoneZeroGuess()
{
    return NonZeroGuessCount() == 1;
}

int CXYCube::FirstNonZeroGuessValue()
{
    for (int i = 0; i < guessesCount; ++i)
    {
        if (m_guess[i] > 0)
        {
            return m_guess[i];
        }
    }
    return 0;
}

int CXYCube::NextGuessValue(int fromGuessValue)
{
    for (int i = fromGuessValue; i < guessesCount; ++i)
    {
        if (m_guess[i] > 0)
        {
            return m_guess[i];
        }
    }
    return 0;
}

int CXYCube::FirstNonZeroGuessValueFromRandomGuessIndex()
{
    for (int i = m_randomGuessIndex; i < m_randomGuessIndex + guessesCount; ++i)
    {
        if (m_guess[i % guessesCount] > 0)
        {
            return m_guess[i % guessesCount];
        }
    }
    return 0;
}

int CXYCube::NextGuessValueFromRandomGuessIndex(int fromGuessValue)
{
    for (int i = fromGuessValue; i < m_randomGuessIndex + guessesCount; ++i)
    {
        if (m_guess[i % guessesCount] > 0)
        {
            return m_guess[i % guessesCount];
        }
    }
    return 0;
}

bool CXYCube::ApplyOnlyOneNoneZeroGuess()
{
    if (IsOnlyOneNoneZeroGuess())
    {
        SetValue(FirstNonZeroGuessValue());
        ClearGuess();
        return true;
    }
    return false;
}

void CXYCube::SetOnlyOneNoneZeroGuess(int guessValue)
{
    int guessIndex = guessValue - 1;
    for (int i = 0; i < guessesCount; ++i)
    {
        SetGuess(i, i == guessIndex ? guessValue : 0);
    }
}

GUESS_VALUE_VECTOR CXYCube::NonZeroGuessVector()
{
    GUESS_VALUE_VECTOR guessVector;
    for (int i = 0; i < guessesCount; ++i)
    {
        if (m_guess[i] > 0)
        {
            guessVector.push_back(m_guess[i]);
        }
    }
    return guessVector;
}

bool CXYCube::HasThisGuessValue(int guessValue)
{
    for (int i = 0; i < guessesCount; ++i)
    {
        if (m_guess[i] == guessValue)
        {
            return true;
        }
    }
    return false;
}

bool CXYCube::HasSameGuess(CXYCube *cube)
{
    for (int i = 0; i < guessesCount; ++i)
    {
        if (m_guess[i] != cube->GetGuess()[i])
        {
            return false;
        }
    }
    return true;
}

void CXYCube::MergeNoneZeroGuessIntoGuessVector(GUESS_VALUE_VECTOR *guessValueVector)
{
    if (guessValueVector == NULL) return;
    
    for (int i = 0; i < guessesCount; ++i)
    {
        int guessValue = m_guess[i];
        if (guessValue == 0) continue;
        
        bool bFound = false;
        for (int k = 0; k < guessValueVector->size(); ++k)
        {
            if (guessValueVector->at(k) == guessValue)
            {
                bFound = true;
                break;
            }
        }
        
        if (bFound == false)
        {
            guessValueVector->push_back(guessValue);
        }
    }
}

CXYCube * CXYCube::DeepCopyTo()
{
    CXYCube * cube = new CXYCube();
    DeepCopyTo(cube);
    return cube;
}

void CXYCube::DeepCopyTo(CXYCube *cube)
{
    cube->m_globalX = m_globalX;
    cube->m_globalY = m_globalY;
    cube->m_localX = m_localX;
    cube->m_localY = m_localY;
    cube->m_value = m_value;
    for (int i = 0; i < guessesCount; i++)
    {
        cube->m_guess[i] = m_guess[i];
    }
    cube->m_randomGuessIndex = m_randomGuessIndex;
}

string CXYCube::Description()
{
    const int cnt = 128;
    static char buf[cnt];
    
    memset(buf, 0, cnt * sizeof(char));
    sprintf(buf, "CXYCube: (%d, %d):%d, guess count: %d",
            GetGlobalX(), GetGlobalY(), GetValue(), NonZeroGuessCount());
    
    return buf;
}

/////////////////////////////////////////
// CXYGroup
#pragma mark - CXYGroup Implement
CXYGroup::CXYGroup(int x, int y):
m_X(x),
m_Y(y)
{
    for (int row = 0; row < eachCount; ++row)
    {
        for (int col = 0; col < eachCount; ++col)
        {
            m_pCubes[row][col] = new CXYCube();
            m_pCubes[row][col]->SetLocalX(col);
            m_pCubes[row][col]->SetLocalY(row);
            int baseGlobalX = m_X * eachCount;
            int baseGlobalY = m_Y * eachCount;
            m_pCubes[row][col]->SetGlobalX(baseGlobalX + col);
            m_pCubes[row][col]->SetGlobalY(baseGlobalY + row);
        }
    }
}

CXYGroup::~CXYGroup()
{
    for (int row = 0; row < eachCount; ++row)
    {
        for (int col = 0; col < eachCount; ++col)
        {
            delete m_pCubes[row][col];
            m_pCubes[row][col] = NULL;
        }
    }
}

int CXYGroup::GetX()
{
    return m_X;
}

int CXYGroup::GetY()
{
    return m_Y;
}

CXYCube * CXYGroup::GetCube(int row, int col)
{
    return m_pCubes[row][col];
}

CXYCube * CXYGroup::GetCube(int index)
{
    if (index >= 0 && index < cubesCount)
    {
        int row = index / eachCount;
        int col = index % eachCount;
        
        return GetCube(row, col);
    }
    return NULL;
}

GROUP_CUBE CXYGroup::GetCube()
{
    return &m_pCubes;
}

CXYGroup * CXYGroup::DeepCopyTo()
{
    CXYGroup * group = new CXYGroup(m_X, m_Y);
    DeepCopyTo(group);
    return group;
}


void CXYGroup::DeepCopyTo(CXYGroup *group)
{
    group->m_X = m_X;
    group->m_Y = m_Y;
    for (int row = 0; row < eachCount; ++row)
    {
        for (int col = 0; col < eachCount; ++col)
        {
            if (group->m_pCubes[row][col])
            {
                m_pCubes[row][col]->DeepCopyTo(group->m_pCubes[row][col]);
            }
            else
            {
                group->m_pCubes[row][col] = m_pCubes[row][col]->DeepCopyTo();
            }
        }
    }
}

/////////////////////////////////////////
// CNode
#pragma mark - CNode Implement
CHistoryNode::CHistoryNode() :
m_pCube(NULL),
m_guessValue(0),
m_pParentNode(NULL)
{
    for (int row = 0; row < eachCount; ++row)
    {
        for (int col = 0; col < eachCount; ++col)
        {
            m_pGroups[row][col] = new CXYGroup(col, row);
        }
    }
}

CHistoryNode::~CHistoryNode()
{
    for (int row = 0; row < eachCount; ++row)
    {
        for (int col = 0; col < eachCount; ++col)
        {
            delete m_pGroups[row][col];
            m_pGroups[row][col] = NULL;
        }
    }
    
    if (m_pCube)
    {
        delete m_pCube;
        m_pCube = NULL;
    }
}

void CHistoryNode::SetGroups(CXYGroup * groups[eachCount][eachCount])
{
    for (int row = 0; row < eachCount; ++row)
    {
        for (int col = 0; col < eachCount; ++col)
        {
            if (m_pGroups[row][col])
            {
                groups[row][col]->DeepCopyTo(m_pGroups[row][col]);
            }
            else
            {
                m_pGroups[row][col] = groups[row][col]->DeepCopyTo();
            }
        }
    }
}

GROUP CHistoryNode::GetGroups()
{
    return &m_pGroups;
}

void CHistoryNode::RestoreGroups(CXYGroup * groups[eachCount][eachCount])
{
    for (int row = 0; row < eachCount; ++row)
    {
        for (int col = 0; col < eachCount; ++col)
        {
            if (groups[row][col])
            {
                m_pGroups[row][col]->DeepCopyTo(groups[row][col]);
            }
            else
            {
                groups[row][col] = m_pGroups[row][col]->DeepCopyTo();
            }
        }
    }
}

void CHistoryNode::SetCube(CXYCube *cube)
{
    if (m_pCube)
    {
        cube->DeepCopyTo(m_pCube);
    }
    else
    {
        m_pCube = cube->DeepCopyTo();
    }
}

CXYCube * CHistoryNode::GetCube()
{
    return m_pCube;
}

void CHistoryNode::SetGuessValue(int guessValue)
{
    m_guessValue = guessValue;
}

int CHistoryNode::GetGuessValue()
{
    return m_guessValue;
}

int CHistoryNode::GetNextGuessValue()
{
    return m_pCube->NextGuessValue(m_guessValue);
}

bool CHistoryNode::HasNextGuess()
{
    return GetNextGuessValue() > 0;
}

int CHistoryNode::GetNextGuessValueFromRandomGuessIndex()
{
    return m_pCube->NextGuessValueFromRandomGuessIndex(m_guessValue);
}

bool CHistoryNode::HasNextGuessFromRandomGuessIndex()
{
    return GetNextGuessValueFromRandomGuessIndex() > 0;
}

void CHistoryNode::SetParentNode(CHistoryNode *parentNode)
{
    m_pParentNode = parentNode;
}

CHistoryNode * CHistoryNode::GetParentNode()
{
    return m_pParentNode;
}

string CHistoryNode::Description()
{
    const int cnt = 1024;
    static char buf[cnt];
    
    memset(buf, 0, cnt * sizeof(char));
    sprintf(buf, "CHistoryNode: Node:(%d, %d): %d, guessValue: %d",
            m_pCube->GetGlobalX(), m_pCube->GetGlobalY(), m_pCube->GetValue(), m_guessValue);
    
    return buf;
}

/////////////////////////////////////////
// Initialize
#pragma mark - Initialize
bool ClearData()
{
    for (int row = 0; row < eachCount; ++row)
    {
        for (int col = 0; col < eachCount; ++col)
        {
            delete g_pGroups[row][col];
            g_pGroups[row][col] = NULL;
        }
    }
    
    ClearValueChangedFlags();
    ClearValueChangedFlagsForAllFunctions();
    
    if (g_pHistoryHeadNode != NULL && g_pHistoryTailNode != NULL)
    {
        while (g_pHistoryTailNode && g_pHistoryTailNode != g_pHistoryHeadNode)
        {
            CHistoryNode *tailNode = g_pHistoryTailNode;
            g_pHistoryTailNode = tailNode->GetParentNode();
            delete tailNode;
            tailNode = NULL;
        }
    }
    
    if (g_pHistoryHeadNode)
    {
        delete g_pHistoryHeadNode;
        g_pHistoryHeadNode = NULL;
    }
    
    g_pHistoryTailNode = NULL;
    
    return true;
}

bool InitializeData()
{
    ClearData();

    for (int row = 0; row < eachCount; ++row)
    {
        for (int col = 0; col < eachCount; ++col)
        {
            if (g_pGroups[row][col] == NULL)
            {
                g_pGroups[row][col] = new CXYGroup(col, row);
            }
            
            for (int cubeRow = 0; cubeRow < eachCount; ++cubeRow)
            {
                for (int cubeCol = 0; cubeCol < eachCount; ++cubeCol)
                {
                    CXYCube * cube = g_pGroups[row][col]->GetCube(cubeRow, cubeCol);
                    g_pCubes[cube->GetGlobalY()][cube->GetGlobalX()] = cube;
                }
            }
        }
    }
    
    ClearValueChangedFlags();
    ClearValueChangedFlagsForAllFunctions();
    
    g_pHistoryHeadNode = new CHistoryNode();
    g_pHistoryTailNode = g_pHistoryHeadNode;
    
    return true;
};

int LocalRowMinX(int row)
{
    return row * eachCount;
}

int LocalRowMaxX(int row)
{
    return LocalRowMinX(row + 1) - 1;
}

/////////////////////////////////////////
// Print function
#pragma mark - Print Function
string ConvertIntToString(int i)
{
    const int cnt = 12;
    static char buf[cnt];
    memset(buf, 0, cnt * sizeof(char));
    sprintf(buf, "%d", i);
    return buf;
}

bool isPrintForCube(PRINT_TYPE type)
{
    return
    type == PRINT_CUBE_VALUE ||
    type == PRINT_CUBE_GUESS ||
    type == PRINT_CUBE_LOCAL_XY ||
    type == PRINT_CUBE_GLOABAL_XY;
}

void PrintFunc(PRINT_TYPE type)
{
    if (isPrintForCube(type))
    {
        string lines[dimension];
        for (int row = cubesCount - 1; row >= 0; --row)
        {
            for (int col = 0; col < cubesCount; ++col)
            {
                CXYCube * cube = g_pCubes[row][col];
                
                switch (type)
                {
                    case PRINT_CUBE_VALUE:
                    {
                        lines[cube->GetGlobalY()] += ConvertIntToString(cube->GetValue());
                        lines[cube->GetGlobalY()] += " ";
                        break;
                    }
                    case PRINT_CUBE_GUESS:
                    {
                        int * guess = cube->GetGuess();
                        for (int i = 0; i < dimension; ++i)
                        {
                            lines[cube->GetGlobalY()] += ConvertIntToString(guess[i]);
                            if (i != dimension - 1)
                            {
                                lines[cube->GetGlobalY()] += ",";
                            }
                        }
                        lines[cube->GetGlobalY()] += "  ";
                        break;
                    }
                    case PRINT_CUBE_LOCAL_XY:
                    {
                        lines[cube->GetGlobalY()] += ConvertIntToString(cube->GetLocalX());
                        lines[cube->GetGlobalY()] += ",";
                        lines[cube->GetGlobalY()] += ConvertIntToString(cube->GetLocalY());
                        lines[cube->GetGlobalY()] += " ";
                        break;
                    }
                    case PRINT_CUBE_GLOABAL_XY:
                    {
                        lines[cube->GetGlobalY()] += ConvertIntToString(cube->GetGlobalX());
                        lines[cube->GetGlobalY()] += ",";
                        lines[cube->GetGlobalY()] += ConvertIntToString(cube->GetGlobalY());
                        lines[cube->GetGlobalY()] += " ";
                        break;
                    }
                    case PRINT_NONE:
                    default:
                    {
                        break;
                    }
                }
                
                if ((col + 1) % eachCount == 0)
                {
                    lines[cube->GetGlobalY()] += " ";
                }
            }
        }
        
        for (int i = dimension - 1; i >= 0; --i)
        {
            printf("%s\n", lines[i].c_str());
            if (i % eachCount == 0)
            {
                printf("\n");
            }
        }
    }
}

#pragma mark - Algorithms

/////////////////////////////////////////
// Algorithm Preperation
#pragma mark - Algorithm Preperation
void AlgInitRandom()
{
    srand((unsigned int)time(0)); // use current time as seed for random generator
}

void AlgRandomGroup(int row, int col, bool initRandom = true)
{
    CXYGroup * group = g_pGroups[row][col];
    for (int row = 0; row < eachCount; ++row)
    {
        for (int col = 0; col < eachCount; ++col)
        {
            int value = row * eachCount + col + 1;
            CXYCube * cube = group->GetCube(row, col);
            cube->SetValue(value);
        }
    }
    
    if (initRandom)
    {
        AlgInitRandom();
    }
    
    for (int i = 0; i < 100; ++i)
    {
        int row1 = rand() % eachCount;
        int col1 = rand() % eachCount;
        int row2 = rand() % eachCount;
        int col2 = rand() % eachCount;
        
        CXYCube * cube1 = group->GetCube(row1, col1);
        CXYCube * cube2 = group->GetCube(row2, col2);
        
        int cube1Value = cube1->GetValue();
        cube1->SetValue(cube2->GetValue());
        cube2->SetValue(cube1Value);
    }
}

/////////////////////////////////////////
// Algorithm Get Cube by linearity

CXYCube *AlgGetCubeByLinear(int cubeIndex)
{
    if (cubeIndex < 0 ||
        cubeIndex >= cubesCount * cubesCount)
    {
        return NULL;
    }
    
    int cubeRow = cubeIndex / cubesCount;
    int cubeCol = cubeIndex % cubesCount;
    return g_pCubes[cubeRow][cubeCol];
}

CXYCube *AlgFirstGuessCube()
{
    for (int i = 0; i < cubesCount * cubesCount; i++)
    {
        CXYCube *cube = AlgGetCubeByLinear(i);
        if (cube->HasValue() == false)
        {
            return cube;
        }
    }
    return NULL;
}

CXYGroup *AlgGetGroupByLinear(int groupIndex)
{
    if (groupIndex < 0 ||
        groupIndex >= eachCount * eachCount)
    {
        return NULL;
    }
    
    int groupRow = groupIndex / eachCount;
    int groupCol = groupIndex % eachCount;
    return g_pGroups[groupRow][groupCol];
}

int AlgCubeLinearIndex(CXYCube *cube)
{
    int cubeRow = cube->GetGlobalY();
    int cubeCol = cube->GetGlobalX();
    return cubeRow * cubesCount + cubeCol;
}

/////////////////////////////////////////
// Algorithm Find Functions

bool AlgFindIndex(INDEX_VECTOR indexVector, int indexValue)
{
    for (INDEX_ITERATOR it = indexVector.begin(); it != indexVector.end(); ++it)
    {
        if ((*it) == indexValue)
        {
            return true;
        }
    }
    return false;
}

bool AlgFindCube(CUBE_VECTOR cubeVector, CXYCube *cube)
{
    for (CUBE_ITERATOR it = cubeVector.begin(); it != cubeVector.end(); ++it)
    {
        if ((*it) == cube)
        {
            return true;
        }
    }
    return false;
}

int AlgValueCount(CUBE_VECTOR cubeVector, int value)
{
    int count = 0;
    for (int i = 0; i < cubeVector.size(); ++i)
    {
        if (cubeVector[i]->GetValue() == value)
        {
            ++count;
        }
    }
    return count;
}

/////////////////////////////////////////
// One way linked list
#pragma mark - History List
bool AttachHistoryNode(CHistoryNode *node)
{
    if (node == NULL)
    {
        return false;
    }
    
    if (g_pHistoryTailNode->GetParentNode() == NULL)
    {
        node->SetParentNode(g_pHistoryHeadNode);
        g_pHistoryTailNode = node;
    }
    else
    {
        node->SetParentNode(g_pHistoryTailNode);
        g_pHistoryTailNode = node;
    }
    return true;
}

bool DetachHistoryNode()
{
    if (g_pHistoryTailNode->GetParentNode())
    {
        CHistoryNode* tailNode = g_pHistoryTailNode;
        g_pHistoryTailNode = g_pHistoryTailNode->GetParentNode();
        delete tailNode;
        tailNode = NULL;
        return true;
    }
    
    return false;
}

bool isHistoryEmpty()
{
    return g_pHistoryHeadNode == g_pHistoryTailNode;
}

bool StepIn()
{
    printf("StepIn Enter \n");
    CHistoryNode *node = new CHistoryNode();
    node->SetGroups(g_pGroups);
    
    CXYCube *firstGuessCube = AlgFirstGuessCube();
    if (firstGuessCube == NULL)
    {
        printf("StepIn firstGuessCube NULL, return false \n");
        return false;
    }
    node->SetCube(firstGuessCube);
    
    int guessValue = firstGuessCube->FirstNonZeroGuessValueFromRandomGuessIndex();
    if (guessValue == 0)
    {
        printf("StepIn no guess value, return false \n");
        return false;
    }
    node->SetGuessValue(guessValue);
    
    firstGuessCube->SetValue(firstGuessCube->FirstNonZeroGuessValueFromRandomGuessIndex());
    
    printf("StepIn Leave with Node: %s \n", node->Description().c_str());
    return AttachHistoryNode(node);
}

bool StepOut()
{
    printf("StepOut Enter \n");
    if (isHistoryEmpty())
    {
        printf("StepOut isHistoryEmpty, return false \n");
        return false;
    }
    
    CHistoryNode *tail = g_pHistoryTailNode;
    if (!tail->HasNextGuessFromRandomGuessIndex())
    {
        if (!DetachHistoryNode())
        {
            printf("StepOut DetachHistoryNode, return false \n");
            return false;
        }
        return StepOut();
    }
    else
    {
        tail->RestoreGroups(g_pGroups);
        int nextGuessValue = tail->GetNextGuessValueFromRandomGuessIndex();
        tail->SetGuessValue(nextGuessValue);
        CXYCube *cube = AlgGetCubeByLinear(AlgCubeLinearIndex(tail->GetCube()));
        cube->SetValue(nextGuessValue);
        printf("StepOut Leave with Node: %s \n", tail->Description().c_str());
        return true;
    }
    
    return false;
}


/////////////////////////////////////////
// Algorithm Cube Vector Functions
#pragma mark - Algorithm Cube Vector Functions
CUBE_VECTOR AlgCubeVectorForCol(int col)
{
    CUBE_VECTOR cubeVector;
    for (int row = 0; row < cubesCount; ++row)
    {
        cubeVector.push_back(g_pCubes[row][col]);
    }
    return cubeVector;
}

CUBE_VECTOR AlgCubeVectorForCol(int col, INDEX_VECTOR exceptRowIndexVector)
{
    CUBE_VECTOR cubeVector;
    for (int row = 0; row < cubesCount; ++row)
    {
        if (AlgFindIndex(exceptRowIndexVector, row) == false)
        {
            cubeVector.push_back(g_pCubes[row][col]);
        }
    }
    return cubeVector;
}

CUBE_VECTOR AlgCubeVectorForCol(CXYCube *cube)
{
    return AlgCubeVectorForCol(cube->GetGlobalX());
}

CUBE_VECTOR AlgCubeVectorForCol(CXYCube *cube, CUBE_VECTOR exceptRowCubeVector)
{
    INDEX_VECTOR exceptRowIndexVector;
    for (CUBE_ITERATOR it = exceptRowCubeVector.begin(); it != exceptRowCubeVector.end(); ++it)
    {
        exceptRowIndexVector.push_back((*it)->GetGlobalY());
    }
    return AlgCubeVectorForCol(cube->GetGlobalX(), exceptRowIndexVector);
}


CUBE_VECTOR AlgCubeVectorForRow(int row)
{
    CUBE_VECTOR cubeVector;
    for (int col = 0; col < cubesCount; ++col)
    {
        cubeVector.push_back(g_pCubes[row][col]);
    }
    return cubeVector;
}

CUBE_VECTOR AlgCubeVectorForRow(int row, INDEX_VECTOR exceptColIndexVector)
{
    CUBE_VECTOR cubeVector;
    for (int col = 0; col < cubesCount; ++col)
    {
        if (AlgFindIndex(exceptColIndexVector, col) == false)
        {
            cubeVector.push_back(g_pCubes[row][col]);
        }
    }
    return cubeVector;
}

CUBE_VECTOR AlgCubeVectorForRow(CXYCube *cube)
{
    return AlgCubeVectorForRow(cube->GetGlobalY());
}

CUBE_VECTOR AlgCubeVectorForRow(CXYCube *cube, CUBE_VECTOR exceptColCubeVector)
{
    INDEX_VECTOR exceptColIndexVector;
    for (CUBE_ITERATOR it = exceptColCubeVector.begin(); it != exceptColCubeVector.end(); ++it)
    {
        exceptColIndexVector.push_back((*it)->GetGlobalX());
    }
    return AlgCubeVectorForRow(cube->GetGlobalY(), exceptColIndexVector);
}


CUBE_VECTOR AlgCubeVectorForGroup(int groupRow, int groupCol)
{
    CUBE_VECTOR cubeVector;
    CXYGroup *group = g_pGroups[groupRow][groupCol];
    for (int i = 0; i < cubesCount; ++i)
    {
        cubeVector.push_back(group->GetCube(i));
    }
    return cubeVector;
}

CUBE_VECTOR AlgCubeVectorForGroup(int groupIndex)
{
    int row = groupIndex / eachCount;
    int col = groupIndex % eachCount;
    return AlgCubeVectorForGroup(row, col);
}

CUBE_VECTOR AlgCubeVectorForGroup(CXYCube *cube)
{
    return AlgCubeVectorForGroup(cube->GetGroupY(), cube->GetGroupX());
}

CUBE_VECTOR AlgCubeVectorForGroup(CXYCube *cube, CUBE_VECTOR exceptCubeVector)
{
    CUBE_VECTOR cubeVector;
    CXYGroup *group = g_pGroups[cube->GetGroupY()][cube->GetGroupX()];
    for (int i = 0; i < cubesCount; ++i)
    {
        CXYCube *cube = group->GetCube(i);
        if (AlgFindCube(exceptCubeVector, cube) == false)
        {
            cubeVector.push_back(cube);
        }
    }
    return cubeVector;
}


/////////////////////////////////////////
// Algorithm Travel Functions

void AlgCubeTravel(CUBE_FN func)
{
    for (int row = 0; row < cubesCount; ++row)
    {
        for (int col = 0; col < cubesCount; ++col)
        {
            CXYCube *cube = g_pCubes[row][col];
            func(cube);
        }
    }
}

void AlgCubeTravel(CUBE_VECTOR cubeVector, CUBE_FN func)
{
    for (int i = 0; i < cubeVector.size(); ++i)
    {
        func(cubeVector[i]);
    }
}

void AlgCubeTravel(CUBE_VECTOR cubeVector, CUBE_VALUE_FN func, int value)
{
    for (int i = 0; i < cubeVector.size(); ++i)
    {
        func(cubeVector[i], value);
    }
}

void AlgCubeVectorTravelForAllRow(CUBE_VECTOR_FN func)
{
    for (int row = 0; row < cubesCount; ++row)
    {
        func(AlgCubeVectorForRow(row));
    }
}

void AlgCubeVectorTravelForAllCol(CUBE_VECTOR_FN func)
{
    for (int col = 0; col < cubesCount; ++col)
    {
        func(AlgCubeVectorForCol(col));
    }
}

void AlgCubeVectorTravelForAllGroup(CUBE_VECTOR_FN func)
{
    for (int groupIndex = 0; groupIndex < groupsCount; ++groupIndex)
    {
        func(AlgCubeVectorForGroup(groupIndex));
    }
}

void AlgCubeVectorTravel(CUBE_VECTOR_FN func)
{
    AlgCubeVectorTravelForAllRow(func);
    AlgCubeVectorTravelForAllCol(func);
    AlgCubeVectorTravelForAllGroup(func);
}

void AlgCubeVectorTravelForOneRow(CXYCube *cube, CUBE_VECTOR_FN func)
{
    func(AlgCubeVectorForRow(cube));
}

void AlgCubeVectorTravelForOneCol(CXYCube *cube, CUBE_VECTOR_FN func)
{
    func(AlgCubeVectorForCol(cube));
}

void AlgCubeVectorTravelForOneGroup(CXYCube *cube, CUBE_VECTOR_FN func)
{
    func(AlgCubeVectorForGroup(cube));
}

/////////////////////////////////////////
// Algorithm Check Result
#pragma mark - Algorithm Check Result
CHECK_RESULT AlgCheckResultChip(CUBE_VECTOR checkResultCubeVector)
{
    bool unfinished = false;
    for (int value = 1; value <= dimension; ++value)
    {
        int count = AlgValueCount(checkResultCubeVector, value);
        if (count == 0) unfinished = true;
        if (count > 1) return CHECK_RESULT_ERROR;
    }
    return unfinished ? CHECK_RESULT_UNFINISH : CHECK_RESULT_DONE;
}

bool IsCheckResultUnfinish(unsigned int checkResultNum)
{
    return (checkResultNum & (unsigned int) CHECK_RESULT_UNFINISH);
}

bool IsCheckResultFinish(unsigned int checkResultNum)
{
    return (checkResultNum & (unsigned int) CHECK_RESULT_DONE);
}

bool IsCheckResultUnright(unsigned int checkResultNum)
{
    return (checkResultNum & (unsigned int) CHECK_RESULT_ERROR);
}

CHECK_RESULT AlgCheckResult()
{
    unsigned int checkResultNum = 0;
    
    auto checkResultFn = [&checkResultNum](CUBE_VECTOR checkResultCubeVector)
    {
        if (IsCheckResultUnright(checkResultNum)) return;
        checkResultNum = checkResultNum | (unsigned int) AlgCheckResultChip(checkResultCubeVector);
    };
    
    AlgCubeVectorTravelForAllRow(checkResultFn);
    if (IsCheckResultUnright(checkResultNum)) return CHECK_RESULT_ERROR;
    AlgCubeVectorTravelForAllCol(checkResultFn);
    if (IsCheckResultUnright(checkResultNum)) return CHECK_RESULT_ERROR;
    AlgCubeVectorTravelForAllGroup(checkResultFn);
    if (IsCheckResultUnright(checkResultNum)) return CHECK_RESULT_ERROR;
    
    if (IsCheckResultUnfinish(checkResultNum)) return CHECK_RESULT_UNFINISH;
    return CHECK_RESULT_DONE;
}

/////////////////////////////////////////
// Algorithms
#pragma mark - Algorithms

/////////////////////////////////////////
// Algorithm update guess by value

// Here is kind of skeleton in my opinion, through row, col, or group operation.
void AlgUpdateGuessChip(CXYCube *cube, PARM_TYPE parmType)
{
    int cubeValue = cube->GetValue();
    
    auto removeGuessFn = [&cubeValue](CXYCube *removeGuessCube)
    {
        removeGuessCube->ClearGuessValue(cubeValue);
    };
    
    if (cubeValue > 0)
    {
        cube->ClearGuess();
        
        switch (parmType)
        {
            case PARM_TYPE_ROW:
            {
                AlgCubeTravel(AlgCubeVectorForRow(cube), removeGuessFn);
                break;
            }
                
            case PARM_TYPE_COL:
            {
                AlgCubeTravel(AlgCubeVectorForCol(cube), removeGuessFn);
                break;
            }
                
            case PARM_TYPE_GROUP:
            {
                AlgCubeTravel(AlgCubeVectorForGroup(cube), removeGuessFn);
                break;
            }
                
            case PARM_TYPE_ALL:
            {
                AlgCubeTravel(AlgCubeVectorForRow(cube), removeGuessFn);
                AlgCubeTravel(AlgCubeVectorForCol(cube), removeGuessFn);
                AlgCubeTravel(AlgCubeVectorForGroup(cube), removeGuessFn);
                break;
            }
                
            case PARM_TYPE_NONE:
            default:
            {
                break;
            }
        }
    }
}

void AlgUpdateGuess()
{
    g_currentFunction = ALGORITHM_FUNCTIONS_UPDATE_GUESS;
    auto updateGuessFn = [](CXYCube *updateGuessCube)
    {
        AlgUpdateGuessChip(updateGuessCube, PARM_TYPE_ALL);
    };
    AlgCubeTravel(updateGuessFn);
}

/////////////////////////////////////////
// Algorithm CRME, return CRME has updated cube or not
// continue on cube value changed

// Called from AlgAdvancedCRME
void AlgAdvancedCRMEChip(CXYCube *cube, PARM_TYPE parmType)
{
    if (cube->ApplyOnlyOneNoneZeroGuess())
    {
        //printf("AlgAdvancedCRMEChip, Cube (X: %d, Y: %d) V: %d\n", cube->GetGlobalX(), cube->GetGlobalY(), cube->GetValue());
        int cubeValue = cube->GetValue();
        
        auto AdvancedCRMEFn = [&cubeValue](CXYCube *cube)
        {
            cube->ClearGuessValue(cubeValue);
            if (cube->IsOnlyOneNoneZeroGuess())
            {
                AlgAdvancedCRMEChip(cube, PARM_TYPE_ALL);
            }
        };
        
        if (cubeValue > 0)
        {
            switch (parmType)
            {
                case PARM_TYPE_ROW:
                {
                    AlgCubeTravel(AlgCubeVectorForRow(cube), AdvancedCRMEFn);
                    break;
                }
                    
                case PARM_TYPE_COL:
                {
                    AlgCubeTravel(AlgCubeVectorForCol(cube), AdvancedCRMEFn);
                    break;
                }
                    
                case PARM_TYPE_GROUP:
                {
                    AlgCubeTravel(AlgCubeVectorForGroup(cube), AdvancedCRMEFn);
                    break;
                }
                    
                case PARM_TYPE_ALL:
                {
                    AlgCubeTravel(AlgCubeVectorForRow(cube), AdvancedCRMEFn);
                    AlgCubeTravel(AlgCubeVectorForCol(cube), AdvancedCRMEFn);
                    AlgCubeTravel(AlgCubeVectorForGroup(cube), AdvancedCRMEFn);
                    break;
                }
                    
                case PARM_TYPE_NONE:
                default:
                {
                    break;
                }
            }
        }
    }
}

// Advanced CRME is a algorithm that cube will apply the only guess immediately and apply to its related row, col and group
void AlgAdvancedCRME()
{
    g_currentFunction = ALGORITHM_FUNCTIONS_CRME;
    
    auto advancedCRMEFn = [](CXYCube *advancedCRMECube)
    {
        AlgAdvancedCRMEChip(advancedCRMECube, PARM_TYPE_ALL);
    };
    AlgCubeTravel(advancedCRMEFn);
}


/////////////////////////////////////////
// Long ranger is a term that I use to refer to a number
// that is one of multiple possible values for a cell
// but appears only once in a row, column, or minigrid.

void AlgAdvancedLongRangerChip(CUBE_VECTOR longRangerCubeVector)
{
    int guessStat[guessesCount] = {0};
    memset(guessStat, 0, guessesCount * sizeof(int));
    
    auto guessStatFn = [&guessStat](CXYCube *longRangerCube)
    {
        for (int i = 0; i < guessesCount; ++i)
        {
            if (longRangerCube->GetGuess(i))
            {
                guessStat[i] += 1;
            }
        }
    };
    AlgCubeTravel(longRangerCubeVector, guessStatFn);
    
    
    int guessIndex = 0;
    int guessValue[guessesCount] = {0};
    memset(guessValue, 0, guessesCount * sizeof(int));
    bool longRangerChanged = false;
    
    for (int i = 0; i < guessesCount; ++i)
    {
        if (guessStat[i] == 1)
        {
            longRangerChanged = true;
            guessValue[guessIndex++] = i + 1;
        }
    }
    
    if (longRangerChanged)
    {
        auto longRangerFn = [&guessValue](CXYCube *longRangerCube)
        {
            for (int i = 0; i < guessesCount; ++i)
            {
                if (guessValue[i] <= 0) break;
                if (longRangerCube->HasThisGuessValue(guessValue[i]))
                {
                    longRangerCube->SetOnlyOneNoneZeroGuess(guessValue[i]);
                    //                    printf("AlgAdvancedLongRangerChip, Cube (X: %d, Y: %d) V: %d\n",
                    //                           longRangerCube->GetGlobalX(),
                    //                           longRangerCube->GetGlobalY(),
                    //                           longRangerCube->FirstNonZeroGuessValue());
                    AlgAdvancedCRMEChip(longRangerCube, PARM_TYPE_ALL);
                }
            }
        };
        
        AlgCubeTravel(longRangerCubeVector, longRangerFn);
        
        // If long ranger made change, do again.
        AlgAdvancedLongRangerChip(longRangerCubeVector);
    }
}

void AlgAdvancedLongRangerForRow(CXYCube *cube)
{
    auto advancedLongRangerFnForRow = [](CUBE_VECTOR longRangerCubeVector)
    {
        AlgAdvancedLongRangerChip(longRangerCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllRow(advancedLongRangerFnForRow);
    else AlgCubeVectorTravelForOneRow(cube, advancedLongRangerFnForRow);
}

void AlgAdvancedLongRangerForCol(CXYCube *cube)
{
    auto advancedLongRangerFnForCol = [](CUBE_VECTOR longRangerCubeVector)
    {
        AlgAdvancedLongRangerChip(longRangerCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllCol(advancedLongRangerFnForCol);
    else AlgCubeVectorTravelForOneCol(cube, advancedLongRangerFnForCol);
}

void AlgAdvancedLongRangerForGroup(CXYCube *cube)
{
    auto advancedLongRangerFnForGroup = [](CUBE_VECTOR longRangerCubeVector)
    {
        AlgAdvancedLongRangerChip(longRangerCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllGroup(advancedLongRangerFnForGroup);
    else AlgCubeVectorTravelForOneGroup(cube, advancedLongRangerFnForGroup);
}

void AlgAdvancedLongRanger(CXYCube *cube, PARM_TYPE parmType)
{
    switch (parmType)
    {
        case PARM_TYPE_ROW:
        {
            AlgAdvancedLongRangerForRow(cube);
            break;
        }
            
        case PARM_TYPE_COL:
        {
            AlgAdvancedLongRangerForCol(cube);
            break;
        }
            
        case PARM_TYPE_GROUP:
        {
            AlgAdvancedLongRangerForGroup(cube);
            break;
        }
            
        case PARM_TYPE_ALL:
        {
            AlgAdvancedLongRangerForRow(cube);
            AlgAdvancedLongRangerForCol(cube);
            AlgAdvancedLongRangerForGroup(cube);
            break;
        }
            
        case PARM_TYPE_NONE:
        default:
        {
            break;
        }
    }
}

void AlgAdvancedLongRanger()
{
    g_currentFunction = ALGORITHM_FUNCTIONS_LONG_RANGER;
    ClearValueChangedFlagsForCurrentFunction();
    
    AlgAdvancedLongRanger(NULL, PARM_TYPE_ALL);
    
    if (IsValueChangedForCurrentFunction())
    {
        AlgAdvancedLongRanger();
    }
}


/////////////////////////////////////////
// Twins means two cubes have the same two guess
// Step1: looking for a twin
// Step2: remove all others' guess value for twins
// Step3: continue step1 until no more guess updated

void AlgAdvancedTwinsChip(CUBE_VECTOR twinCubeVector)
{
    ClearValueChangedFlags();
    for (CUBE_ITERATOR it = twinCubeVector.begin(); it != twinCubeVector.end(); ++it)
    {
        if ((*it)->NonZeroGuessCount() != 2) continue;
        for (CUBE_ITERATOR kt = it + 1; kt != twinCubeVector.end(); ++kt)
        {
            if ((*kt)->NonZeroGuessCount() != 2) continue;
            if ((*it)->HasSameGuess(*kt))
            {
                printf("IT: %s Equals to KT: %s \n", (*it)->Description().c_str(), (*kt)->Description().c_str());
                for (int i = 0; i < guessesCount; ++i)
                {
                    int guessValue = (*it)->GetGuess()[i];
                    printf("GuessValue: %d \n", guessValue);
                    if (guessValue == 0) continue;
                    for (CUBE_ITERATOR mt = twinCubeVector.begin(); mt != twinCubeVector.end(); ++mt)
                    {
                        if ((*mt) == (*it) || (*mt) == (*kt)) continue;
                        if ((*mt)->ClearGuessValue(guessValue))
                        {
                            printf("MT: %s", (*mt)->Description().c_str());
                            if ((*mt)->IsOnlyOneNoneZeroGuess())
                            {
                                AlgAdvancedCRMEChip((*mt), PARM_TYPE_ALL);
                            }
                            
                            AlgAdvancedLongRanger(*mt, PARM_TYPE_ALL);
                        }
                    }
                }
            }
        }
    }
    
    if (IsValueChanged())
    {
        // if twin made some change, do again.
        AlgAdvancedTwinsChip(twinCubeVector);
    }
}

void AlgAdvancedTwinsForRow(CXYCube *cube)
{
    auto advancedTwinFnForRow = [](CUBE_VECTOR advancedTwinCubeVector)
    {
        AlgAdvancedTwinsChip(advancedTwinCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllRow(advancedTwinFnForRow);
    else AlgCubeVectorTravelForOneRow(cube, advancedTwinFnForRow);
}

void AlgAdvancedTwinsForCol(CXYCube *cube)
{
    auto advancedTwinFnForCol = [](CUBE_VECTOR advancedTwinCubeVector)
    {
        AlgAdvancedTwinsChip(advancedTwinCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllCol(advancedTwinFnForCol);
    else AlgCubeVectorTravelForOneCol(cube, advancedTwinFnForCol);
}

void AlgAdvancedTwinsForGroup(CXYCube *cube)
{
    auto advancedTwinFnForGroup = [](CUBE_VECTOR advancedTwinCubeVector)
    {
        AlgAdvancedTwinsChip(advancedTwinCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllGroup(advancedTwinFnForGroup);
    else AlgCubeVectorTravelForOneGroup(cube, advancedTwinFnForGroup);
}

void AlgAdvancedTwins(CXYCube *cube, PARM_TYPE parmType)
{
    switch (parmType)
    {
        case PARM_TYPE_ROW:
        {
            AlgAdvancedTwinsForRow(cube);
            break;
        }
            
        case PARM_TYPE_COL:
        {
            AlgAdvancedTwinsForCol(cube);
            break;
        }
            
        case PARM_TYPE_GROUP:
        {
            AlgAdvancedTwinsForGroup(cube);
            break;
        }
            
        case PARM_TYPE_ALL:
        {
            AlgAdvancedTwinsForRow(cube);
            AlgAdvancedTwinsForCol(cube);
            AlgAdvancedTwinsForGroup(cube);
            break;
        }
            
        case PARM_TYPE_NONE:
        default:
        {
            break;
        }
    }
}

void AlgAdvancedTwins()
{
    g_currentFunction = ALGORITHM_FUNCTIONS_TWINS;
    ClearValueChangedFlagsForCurrentFunction();

    AlgAdvancedTwins(NULL, PARM_TYPE_ALL);
    
    if (IsValueChangedForCurrentFunction())
    {
        AlgAdvancedTwins();
    }
}

/////////////////////////////////////////
// Triples means three cubes share three value
// Step1: looking for a triple
// Step2: remove all others' guess value for triple
// Step3: continue step1 until no more guess updated

void AlgAdvancedTriplesChip(CUBE_VECTOR tripleCubeVector)
{
    ClearValueChangedFlags();
    for (CUBE_ITERATOR it = tripleCubeVector.begin(); it != tripleCubeVector.end(); ++it)
    {
        int itGuessCount = (*it)->NonZeroGuessCount();
        if (itGuessCount != 2 && itGuessCount != 3) continue;
        for (CUBE_ITERATOR kt = it + 1; kt != tripleCubeVector.end(); ++kt)
        {
            int ktGuessCount = (*kt)->NonZeroGuessCount();
            if (ktGuessCount != 2 && ktGuessCount != 3) continue;
            for (CUBE_ITERATOR mt = kt + 1; mt != tripleCubeVector.end(); ++mt)
            {
                int mtGuessCount = (*mt)->NonZeroGuessCount();
                if (mtGuessCount != 2 && mtGuessCount != 3) continue;
                
                GUESS_VALUE_VECTOR guessVector;
                (*it)->MergeNoneZeroGuessIntoGuessVector(&guessVector);
                (*kt)->MergeNoneZeroGuessIntoGuessVector(&guessVector);
                (*mt)->MergeNoneZeroGuessIntoGuessVector(&guessVector);
                
                if (guessVector.size() == 3)
                {
                    for (int i = 0; i < guessVector.size(); ++i)
                    {
                        int guessValue = guessVector[i];
                        if (guessValue == 0) continue;
                        for (CUBE_ITERATOR qt = tripleCubeVector.begin(); qt != tripleCubeVector.end(); ++qt)
                        {
                            if ((*qt) == (*it) || (*qt) == (*kt) || (*qt) == (*mt)) continue;
                            if ((*qt)->ClearGuessValue(guessValue))
                            {
                                if ((*qt)->IsOnlyOneNoneZeroGuess())
                                {
                                    AlgAdvancedCRMEChip((*qt), PARM_TYPE_ALL);
                                }
                                
                                AlgAdvancedLongRanger(*qt, PARM_TYPE_ALL);
                                //AlgAdvancedTwins(*qt);
                            }
                        }
                    }
                }
            }
        }
    }
    
    if (IsValueChanged())
    {
        // if triple made some change, do again.
        AlgAdvancedTriplesChip(tripleCubeVector);
        //AlgAdvancedTwinsChip(tripleCubeVector);
    }
}

void AlgAdvancedTriplesForRow(CXYCube *cube)
{
    auto advancedTripleFnForRow = [](CUBE_VECTOR advancedTripleCubeVector)
    {
        AlgAdvancedTriplesChip(advancedTripleCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllRow(advancedTripleFnForRow);
    else AlgCubeVectorTravelForOneRow(cube, advancedTripleFnForRow);
}

void AlgAdvancedTriplesForCol(CXYCube *cube)
{
    auto advancedTripleFnForRow = [](CUBE_VECTOR advancedTripleCubeVector)
    {
        AlgAdvancedTriplesChip(advancedTripleCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllCol(advancedTripleFnForRow);
    else AlgCubeVectorTravelForOneCol(cube, advancedTripleFnForRow);
}

void AlgAdvancedTriplesForGroup(CXYCube *cube)
{
    auto advancedTripleFnForGroup = [](CUBE_VECTOR advancedTripleCubeVector)
    {
        AlgAdvancedTriplesChip(advancedTripleCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllGroup(advancedTripleFnForGroup);
    else AlgCubeVectorTravelForOneGroup(cube, advancedTripleFnForGroup);
}

void AlgAdvancedTriples(CXYCube *cube, PARM_TYPE parmType)
{
    switch (parmType)
    {
        case PARM_TYPE_ROW:
        {
            AlgAdvancedTriplesForRow(cube);
            break;
        }
            
        case PARM_TYPE_COL:
        {
            AlgAdvancedTriplesForCol(cube);
            break;
        }
            
        case PARM_TYPE_GROUP:
        {
            AlgAdvancedTriplesForGroup(cube);
            break;
        }
            
        case PARM_TYPE_ALL:
        {
            AlgAdvancedTriplesForRow(cube);
            AlgAdvancedTriplesForCol(cube);
            AlgAdvancedTriplesForGroup(cube);
            break;
        }
            
        case PARM_TYPE_NONE:
        default:
        {
            break;
        }
    }
}

void AlgAdvancedTriples()
{
    g_currentFunction = ALGORITHM_FUNCTIONS_TRIPLES;
    ClearValueChangedFlagsForCurrentFunction();
    
    AlgAdvancedTriples(NULL, PARM_TYPE_ALL);
    
    if (IsValueChangedForCurrentFunction())
    {
        AlgAdvancedTriples();
    }
}

CHECK_RESULT AlgBruteForce()
{
    CHECK_RESULT result = CHECK_RESULT_NONE;
    
    do
    {
        printf("CRME B: \n");
        AlgUpdateGuess();
        AlgAdvancedCRME();
        PrintFunc(PRINT_CUBE_VALUE);
        result = AlgCheckResult();
        printf("CRME E: %d \n", result);
        CHRD();
        
        printf("LongRanger B: \n");
        AlgAdvancedLongRanger();
        PrintFunc(PRINT_CUBE_VALUE);
        result = AlgCheckResult();
        printf("LongRanger E: %d \n", result);
        CHRD();
        
        printf("Twins B: \n");
        AlgAdvancedTwins();
        PrintFunc(PRINT_CUBE_VALUE);
        result = AlgCheckResult();
        printf("Twins E: %d \n", result);
        CHRD();
        
        printf("Triples B: \n");
        AlgAdvancedTriples();
        PrintFunc(PRINT_CUBE_VALUE);
        result = AlgCheckResult();
        printf("Triples E: %d \n", result);
        CHRD();
    }
    while ((result == CHECK_RESULT_UNFINISH && StepIn()) ||
           (result == CHECK_RESULT_ERROR && StepOut()));

    
    printf("Result E: %d \n", result);
    PrintFunc(PRINT_CUBE_VALUE);
    
    return result;
}

/////////////////////////////////////////
// Main
void MainTest()
{
    InitializeData();
    AlgInitRandom();
    AlgRandomGroup(0, 0);
    AlgBruteForce();
}
