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
// Data
#pragma mark - Data
CXYGroup * g_pGroups[eachCount][eachCount];
CXYCube * g_pCubes[cubesCount][cubesCount]; // Global coordination
bool g_bCubeValueChanged;
bool g_bCubeGuessValueChanged;
CHistoryNode * g_pHistoryHeadNode;
CHistoryNode * g_pHistoryTailNode;

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
    
    CXYCube * DeepCopy();
    void DeepCopy(CXYCube *cube);
    
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
    
    CXYGroup * DeepCopy();
    void DeepCopy(CXYGroup *group);
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
    
    void SetCube(CXYCube *cube);
    CXYCube * GetCube();
    
    void SetGuessValue(int guessValue);
    int GetGuessValue();
    
    bool HasNextGuess();
    
    void SetParentNode(CHistoryNode *parentNode);
    CHistoryNode * GetParentNode();
};



/////////////////////////////////////////
// Algorithm Helper
#pragma mark - Algorithm Helper
void clearAllFlags()
{
    g_bCubeValueChanged = false;
    g_bCubeGuessValueChanged = false;
}

bool isValueFlagChanged()
{
    return g_bCubeValueChanged || g_bCubeGuessValueChanged;
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
        g_bCubeValueChanged = true;
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
            g_bCubeGuessValueChanged = true;
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

bool CXYCube::IsOnlyOneNoneZeroGuess()
{
    return NonZeroGuessCount() == 1;
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

CXYCube * CXYCube::DeepCopy()
{
    CXYCube * cube = new CXYCube();
    DeepCopy(cube);
    return cube;
}

void CXYCube::DeepCopy(CXYCube *cube)
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
}

string CXYCube::Description()
{
    const int cnt = 128;
    static char buf[cnt];
    
    memset(buf, 0, cnt * sizeof(char));
    sprintf(buf, "CXYCube: (%d, %d):%d",
            GetGlobalX(), GetGlobalY(), GetValue());
    
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

CXYGroup * CXYGroup::DeepCopy()
{
    CXYGroup * group = new CXYGroup(m_X, m_Y);
    DeepCopy(group);
    return group;
}


void CXYGroup::DeepCopy(CXYGroup *group)
{
    group->m_X = m_X;
    group->m_Y = m_Y;
    for (int row = 0; row < eachCount; ++row)
    {
        for (int col = 0; col < eachCount; ++col)
        {
            if (group->m_pCubes[row][col])
            {
                m_pCubes[row][col]->DeepCopy(group->m_pCubes[row][col]);
            }
            else
            {
                group->m_pCubes[row][col] = m_pCubes[row][col]->DeepCopy();
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
                groups[row][col]->DeepCopy(m_pGroups[row][col]);
            }
            else
            {
                m_pGroups[row][col] = groups[row][col]->DeepCopy();
            }
        }
    }
}

GROUP CHistoryNode::GetGroups()
{
    return &m_pGroups;
}

void CHistoryNode::SetCube(CXYCube *cube)
{
    if (m_pCube)
    {
        cube->DeepCopy(m_pCube);
    }
    else
    {
        m_pCube = cube->DeepCopy();
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

bool CHistoryNode::HasNextGuess()
{
    return m_pCube->NextGuessValue(m_guessValue) > 0;
}

void CHistoryNode::SetParentNode(CHistoryNode *parentNode)
{
    m_pParentNode = parentNode;
}

CHistoryNode * CHistoryNode::GetParentNode()
{
    return m_pParentNode;
}

/////////////////////////////////////////
// Initialize
#pragma mark - Initialize
bool InitializeData()
{
    for (int row = 0; row < eachCount; ++row)
    {
        for (int col = 0; col < eachCount; ++col)
        {
            g_pGroups[row][col] = new CXYGroup(col, row);
            
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
    
    clearAllFlags();
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
bool AddHistoryNode(CHistoryNode *node)
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

bool AddNewHistoryNode()
{
    CHistoryNode *node = new CHistoryNode();
    node->SetGroups(g_pGroups);
    
    CXYCube *firstGuessCube = AlgFirstGuessCube();
    if (firstGuessCube == NULL)
    {
        return false;
    }
    node->SetCube(firstGuessCube);
    
    int guessValue = firstGuessCube->FirstNonZeroGuessValue();
    if (guessValue == 0)
    {
        return false;
    }
    node->SetGuessValue(guessValue);
    
    return AddHistoryNode(node);
}

bool RemoveLastHistoryNode()
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
    return AddNewHistoryNode();
}

bool StepOut()
{
    if (isHistoryEmpty())
    {
        return false;
    }
    
    CHistoryNode *tail = g_pHistoryTailNode;
    
    
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

void AlgAdvancedLongRangerForRow(CXYCube *cube = NULL)
{
    auto advancedLongRangerFnForRow = [](CUBE_VECTOR longRangerCubeVector)
    {
        AlgAdvancedLongRangerChip(longRangerCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllRow(advancedLongRangerFnForRow);
    else AlgCubeVectorTravelForOneRow(cube, advancedLongRangerFnForRow);
}

void AlgAdvancedLongRangerForCol(CXYCube *cube = NULL)
{
    auto advancedLongRangerFnForCol = [](CUBE_VECTOR longRangerCubeVector)
    {
        AlgAdvancedLongRangerChip(longRangerCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllCol(advancedLongRangerFnForCol);
    else AlgCubeVectorTravelForOneCol(cube, advancedLongRangerFnForCol);
}

void AlgAdvancedLongRangerForGroup(CXYCube *cube = NULL)
{
    auto advancedLongRangerFnForGroup = [](CUBE_VECTOR longRangerCubeVector)
    {
        AlgAdvancedLongRangerChip(longRangerCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllGroup(advancedLongRangerFnForGroup);
    else AlgCubeVectorTravelForOneGroup(cube, advancedLongRangerFnForGroup);
}

void AlgAdvancedLongRanger(CXYCube *cube = NULL, PARM_TYPE parmType = PARM_TYPE_ALL)
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


/////////////////////////////////////////
// Twins means two cubes have the same two guess
// Step1: looking for a twin
// Step2: remove all others' guess value for twins
// Step3: continue step1 until no more guess updated

void AlgAdvancedTwinsChip(CUBE_VECTOR twinCubeVector)
{
    clearAllFlags();
    for (CUBE_ITERATOR it = twinCubeVector.begin(); it != twinCubeVector.end(); ++it)
    {
        if ((*it)->NonZeroGuessCount() != 2) continue;
        for (CUBE_ITERATOR kt = it + 1; kt != twinCubeVector.end(); ++kt)
        {
            if ((*kt)->NonZeroGuessCount() != 2) continue;
            if ((*it)->HasSameGuess(*kt))
            {
                for (int i = 0; i < guessesCount; ++i)
                {
                    int guessValue = (*it)->GetGuess()[i];
                    if (guessValue == 0) continue;
                    for (CUBE_ITERATOR mt = twinCubeVector.begin(); mt != twinCubeVector.end(); ++mt)
                    {
                        if ((*mt) == (*it) || (*mt) == (*kt)) continue;
                        if ((*mt)->ClearGuessValue(guessValue))
                        {
                            if ((*mt)->IsOnlyOneNoneZeroGuess())
                            {
                                AlgAdvancedCRMEChip((*mt), PARM_TYPE_ALL);
                            }
                            
                            AlgAdvancedLongRanger(*mt);
                        }
                    }
                }
            }
        }
    }
    
    if (isValueFlagChanged())
    {
        // if twin made some change, do again.
        AlgAdvancedTwinsChip(twinCubeVector);
    }
}

void AlgAdvancedTwinsForRow(CXYCube *cube = NULL)
{
    auto advancedTwinFnForRow = [](CUBE_VECTOR advancedTwinCubeVector)
    {
        AlgAdvancedTwinsChip(advancedTwinCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllRow(advancedTwinFnForRow);
    else AlgCubeVectorTravelForOneRow(cube, advancedTwinFnForRow);
}

void AlgAdvancedTwinsForCol(CXYCube *cube = NULL)
{
    auto advancedTwinFnForCol = [](CUBE_VECTOR advancedTwinCubeVector)
    {
        AlgAdvancedTwinsChip(advancedTwinCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllCol(advancedTwinFnForCol);
    else AlgCubeVectorTravelForOneCol(cube, advancedTwinFnForCol);
}

void AlgAdvancedTwinsForGroup(CXYCube *cube = NULL)
{
    auto advancedTwinFnForGroup = [](CUBE_VECTOR advancedTwinCubeVector)
    {
        AlgAdvancedTwinsChip(advancedTwinCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllGroup(advancedTwinFnForGroup);
    else AlgCubeVectorTravelForOneGroup(cube, advancedTwinFnForGroup);
}

void AlgAdvancedTwins(CXYCube *cube = NULL, PARM_TYPE parmType = PARM_TYPE_ALL)
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

/////////////////////////////////////////
// Triples means three cubes share three value
// Step1: looking for a triple
// Step2: remove all others' guess value for triple
// Step3: continue step1 until no more guess updated

void AlgAdvancedTriplesChip(CUBE_VECTOR tripleCubeVector)
{
    clearAllFlags();
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
                                
                                AlgAdvancedLongRanger(*qt);
                                //AlgAdvancedTwins(*qt);
                            }
                        }
                    }
                }
            }
        }
    }
    
    if (isValueFlagChanged())
    {
        // if triple made some change, do again.
        AlgAdvancedTriplesChip(tripleCubeVector);
        //AlgAdvancedTwinsChip(tripleCubeVector);
    }
}

void AlgAdvancedTriplesForRow(CXYCube *cube = NULL)
{
    auto advancedTripleFnForRow = [](CUBE_VECTOR advancedTripleCubeVector)
    {
        AlgAdvancedTriplesChip(advancedTripleCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllRow(advancedTripleFnForRow);
    else AlgCubeVectorTravelForOneRow(cube, advancedTripleFnForRow);
}

void AlgAdvancedTriplesForCol(CXYCube *cube = NULL)
{
    auto advancedTripleFnForRow = [](CUBE_VECTOR advancedTripleCubeVector)
    {
        AlgAdvancedTriplesChip(advancedTripleCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllCol(advancedTripleFnForRow);
    else AlgCubeVectorTravelForOneCol(cube, advancedTripleFnForRow);
}

void AlgAdvancedTriplesForGroup(CXYCube *cube = NULL)
{
    auto advancedTripleFnForGroup = [](CUBE_VECTOR advancedTripleCubeVector)
    {
        AlgAdvancedTriplesChip(advancedTripleCubeVector);
    };
    if (cube == NULL) AlgCubeVectorTravelForAllGroup(advancedTripleFnForGroup);
    else AlgCubeVectorTravelForOneGroup(cube, advancedTripleFnForGroup);
}

void AlgAdvancedTriples(CXYCube *cube = NULL, PARM_TYPE parmType = PARM_TYPE_ALL)
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

CHECK_RESULT AlgBruteForce()
{
    CHECK_RESULT result = CHECK_RESULT_NONE;
//    CXYCube *cube = AlgMakeNextConjecture(NULL);
//    result = AlgCheckResult();
    
//    // TODO: Update performance here:
//    while(cube != NULL && result != CHECK_RESULT_DONE)
//    {
//        printf("AlgBruteForce continue %s, %d\n", cube->Description().c_str(), result);
//        AlgUpdateGuess();
//        AlgAdvancedCRME();
//        int preHistoryCount = 0;
//        int posHistoryCount = 0;
//        do
//        {
//            preHistoryCount = GetHistoryCount();
//            AlgAdvancedLongRanger();
//            posHistoryCount = GetHistoryCount();
//        }
//        while (preHistoryCount != posHistoryCount);
//        preHistoryCount = 0;
//        posHistoryCount = 0;
//        do
//        {
//            preHistoryCount = GetHistoryCount();
//            AlgAdvancedTwins();
//            AlgAdvancedTriples();
//            posHistoryCount = GetHistoryCount();
//        }
//        while (preHistoryCount != posHistoryCount);
//        
//        result = AlgCheckResult();
//        if (result == CHECK_RESULT_DONE) break;
//        if (result == CHECK_RESULT_UNFINISH)
//        {
//            printf("CHECK_RESULT_UNFINISH: BEFORE: %s \n", cube->Description().c_str());
//            cube = AlgMakeNextConjecture(NULL);
//            if (cube)
//            {
//                printf("CHECK_RESULT_UNFINISH: AFTER: %s \n", cube->Description().c_str());
//            }
//        }
//        
//        while (result == CHECK_RESULT_ERROR || cube == NULL)
//        {
//            printf("AlgBruteForce cube continue\n");
//            CCubeValueHistory *history = (CCubeValueHistory *)AlgFindPreviousConjecture();
//            if (history == NULL) return CHECK_RESULT_ERROR;
//            printf("Find History: %s\n", history->Description().c_str());
//            CXYCube *historyCube = history->GetCube();
//            int historyValue = history->GetValue();
//            history->Backtrack();
//            PopHistory();
//            cube = AlgMakeNextConjecture(historyCube, historyValue);
//            result = CHECK_RESULT_NONE;
//            if (cube)
//            {
//                printf("Next Cube: %s \n", cube->Description().c_str());
//            }
//        }
//    }
    
    return result;
}

/////////////////////////////////////////
// Main
//int main (int argc, char **argv)
//{
//    InitializeData();
//    AlgInitRandom();
//    AlgRandomGroup(0, 0);

    // TODO: write a command line input init data.
    /*
     g_pCubes[0][0]->SetValue(8);
     g_pCubes[0][1]->SetValue(0);
     g_pCubes[0][2]->SetValue(5);
     g_pCubes[0][3]->SetValue(0);
     g_pCubes[0][4]->SetValue(0);
     g_pCubes[0][5]->SetValue(1);
     g_pCubes[0][6]->SetValue(0);
     g_pCubes[0][7]->SetValue(0);
     g_pCubes[0][8]->SetValue(0);
     g_pCubes[1][0]->SetValue(0);
     g_pCubes[1][1]->SetValue(7);
     g_pCubes[1][2]->SetValue(0);
     g_pCubes[1][3]->SetValue(0);
     g_pCubes[1][4]->SetValue(8);
     g_pCubes[1][5]->SetValue(0);
     g_pCubes[1][6]->SetValue(0);
     g_pCubes[1][7]->SetValue(6);
     g_pCubes[1][8]->SetValue(0);
     g_pCubes[2][0]->SetValue(0);
     g_pCubes[2][1]->SetValue(3);
     g_pCubes[2][2]->SetValue(0);
     g_pCubes[2][3]->SetValue(0);
     g_pCubes[2][4]->SetValue(0);
     g_pCubes[2][5]->SetValue(0);
     g_pCubes[2][6]->SetValue(0);
     g_pCubes[2][7]->SetValue(0);
     g_pCubes[2][8]->SetValue(0);
     g_pCubes[3][0]->SetValue(6);
     g_pCubes[3][1]->SetValue(8);
     g_pCubes[3][2]->SetValue(0);
     g_pCubes[3][3]->SetValue(2);
     g_pCubes[3][4]->SetValue(0);
     g_pCubes[3][5]->SetValue(0);
     g_pCubes[3][6]->SetValue(0);
     g_pCubes[3][7]->SetValue(7);
     g_pCubes[3][8]->SetValue(0);
     g_pCubes[4][0]->SetValue(0);
     g_pCubes[4][1]->SetValue(0);
     g_pCubes[4][2]->SetValue(3);
     g_pCubes[4][3]->SetValue(0);
     g_pCubes[4][4]->SetValue(0);
     g_pCubes[4][5]->SetValue(0);
     g_pCubes[4][6]->SetValue(1);
     g_pCubes[4][7]->SetValue(0);
     g_pCubes[4][8]->SetValue(0);
     g_pCubes[5][0]->SetValue(0);
     g_pCubes[5][1]->SetValue(1);
     g_pCubes[5][2]->SetValue(0);
     g_pCubes[5][3]->SetValue(0);
     g_pCubes[5][4]->SetValue(0);
     g_pCubes[5][5]->SetValue(6);
     g_pCubes[5][6]->SetValue(0);
     g_pCubes[5][7]->SetValue(3);
     g_pCubes[5][8]->SetValue(4);
     g_pCubes[6][0]->SetValue(0);
     g_pCubes[6][1]->SetValue(0);
     g_pCubes[6][2]->SetValue(0);
     g_pCubes[6][3]->SetValue(0);
     g_pCubes[6][4]->SetValue(0);
     g_pCubes[6][5]->SetValue(0);
     g_pCubes[6][6]->SetValue(0);
     g_pCubes[6][7]->SetValue(8);
     g_pCubes[6][8]->SetValue(0);
     g_pCubes[7][0]->SetValue(0);
     g_pCubes[7][1]->SetValue(6);
     g_pCubes[7][2]->SetValue(0);
     g_pCubes[7][3]->SetValue(0);
     g_pCubes[7][4]->SetValue(7);
     g_pCubes[7][5]->SetValue(0);
     g_pCubes[7][6]->SetValue(0);
     g_pCubes[7][7]->SetValue(1);
     g_pCubes[7][8]->SetValue(0);
     g_pCubes[8][0]->SetValue(0);
     g_pCubes[8][1]->SetValue(0);
     g_pCubes[8][2]->SetValue(0);
     g_pCubes[8][3]->SetValue(3);
     g_pCubes[8][4]->SetValue(0);
     g_pCubes[8][5]->SetValue(0);
     g_pCubes[8][6]->SetValue(9);
     g_pCubes[8][7]->SetValue(0);
     g_pCubes[8][8]->SetValue(5);
     */
    
    // Long Ranger
    /*
     g_pCubes[0][0]->SetValue(2);
     g_pCubes[0][1]->SetValue(0);
     g_pCubes[0][2]->SetValue(0);
     g_pCubes[0][3]->SetValue(0);
     g_pCubes[0][4]->SetValue(0);
     g_pCubes[0][5]->SetValue(0);
     g_pCubes[0][6]->SetValue(0);
     g_pCubes[0][7]->SetValue(0);
     g_pCubes[0][8]->SetValue(8);
     g_pCubes[1][0]->SetValue(9);
     g_pCubes[1][1]->SetValue(0);
     g_pCubes[1][2]->SetValue(0);
     g_pCubes[1][3]->SetValue(0);
     g_pCubes[1][4]->SetValue(2);
     g_pCubes[1][5]->SetValue(8);
     g_pCubes[1][6]->SetValue(0);
     g_pCubes[1][7]->SetValue(5);
     g_pCubes[1][8]->SetValue(0);
     g_pCubes[2][0]->SetValue(0);
     g_pCubes[2][1]->SetValue(5);
     g_pCubes[2][2]->SetValue(6);
     g_pCubes[2][3]->SetValue(9);
     g_pCubes[2][4]->SetValue(4);
     g_pCubes[2][5]->SetValue(1);
     g_pCubes[2][6]->SetValue(0);
     g_pCubes[2][7]->SetValue(0);
     g_pCubes[2][8]->SetValue(0);
     g_pCubes[3][0]->SetValue(3);
     g_pCubes[3][1]->SetValue(8);
     g_pCubes[3][2]->SetValue(0);
     g_pCubes[3][3]->SetValue(0);
     g_pCubes[3][4]->SetValue(7);
     g_pCubes[3][5]->SetValue(0);
     g_pCubes[3][6]->SetValue(0);
     g_pCubes[3][7]->SetValue(0);
     g_pCubes[3][8]->SetValue(6);
     g_pCubes[4][0]->SetValue(6);
     g_pCubes[4][1]->SetValue(0);
     g_pCubes[4][2]->SetValue(4);
     g_pCubes[4][3]->SetValue(2);
     g_pCubes[4][4]->SetValue(0);
     g_pCubes[4][5]->SetValue(3);
     g_pCubes[4][6]->SetValue(5);
     g_pCubes[4][7]->SetValue(0);
     g_pCubes[4][8]->SetValue(0);
     g_pCubes[5][0]->SetValue(7);
     g_pCubes[5][1]->SetValue(0);
     g_pCubes[5][2]->SetValue(5);
     g_pCubes[5][3]->SetValue(0);
     g_pCubes[5][4]->SetValue(6);
     g_pCubes[5][5]->SetValue(0);
     g_pCubes[5][6]->SetValue(0);
     g_pCubes[5][7]->SetValue(0);
     g_pCubes[5][8]->SetValue(0);
     g_pCubes[6][0]->SetValue(5);
     g_pCubes[6][1]->SetValue(0);
     g_pCubes[6][2]->SetValue(8);
     g_pCubes[6][3]->SetValue(0);
     g_pCubes[6][4]->SetValue(0);
     g_pCubes[6][5]->SetValue(7);
     g_pCubes[6][6]->SetValue(0);
     g_pCubes[6][7]->SetValue(0);
     g_pCubes[6][8]->SetValue(4);
     g_pCubes[7][0]->SetValue(0);
     g_pCubes[7][1]->SetValue(0);
     g_pCubes[7][2]->SetValue(7);
     g_pCubes[7][3]->SetValue(4);
     g_pCubes[7][4]->SetValue(0);
     g_pCubes[7][5]->SetValue(2);
     g_pCubes[7][6]->SetValue(6);
     g_pCubes[7][7]->SetValue(8);
     g_pCubes[7][8]->SetValue(0);
     g_pCubes[8][0]->SetValue(4);
     g_pCubes[8][1]->SetValue(0);
     g_pCubes[8][2]->SetValue(9);
     g_pCubes[8][3]->SetValue(8);
     g_pCubes[8][4]->SetValue(5);
     g_pCubes[8][5]->SetValue(6);
     g_pCubes[8][6]->SetValue(7);
     g_pCubes[8][7]->SetValue(0);
     g_pCubes[8][8]->SetValue(0);
     */
//    
//    AlgUpdateGuess();
//    AlgAdvancedCRME();
//    
//    
//    int preHistoryCount = 0;
//    int posHistoryCount = 0;
//    do
//    {
//        preHistoryCount = GetHistoryCount();
//        AlgAdvancedLongRanger();
//        posHistoryCount = GetHistoryCount();
//    }
//    while (preHistoryCount != posHistoryCount);
//    
//    preHistoryCount = 0;
//    posHistoryCount = 0;
//    do
//    {
//        preHistoryCount = GetHistoryCount();
//        AlgAdvancedTwins();
//        AlgAdvancedTriples();
//        posHistoryCount = GetHistoryCount();
//    }
//    while (preHistoryCount != posHistoryCount);
//    
//    PrintFunc(PRINT_CUBE_VALUE);
//    PrintFunc(PRINT_CUBE_GUESS);
//    
//    CHECK_RESULT result = AlgBruteForce();
//    printf("%d\n", result);
//    
//    // PrintFunc(PRINT_CUBE_GUESS);
//    // PrintFunc(PRINT_CUBE_VALUE);
//    
//    //PrintFunc(PRINT_HISTORY_VALUE);
//}
