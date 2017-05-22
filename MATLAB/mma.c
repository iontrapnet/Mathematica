enum {false,true};

#include <mathlink.h>
#include <math.h>
#include <matrix.h>
#include <mex.h>

#ifndef NULL
#define NULL ((void *) 0)
#endif

/* Global variables for this MEX-file */
bool registeredExitFunction = false;
bool first_time = true;
bool swapEOL = false;
MLENV mlenv = NULL;
MLINK mlp = NULL;

/* Named constants */
#define MEXARGUMENTERROR            0
#define EVALUATE                    1
#define PROCESSEDOPENLINKARGUMENTS  2

extern void mexmain(void);
static bool OpenMathLink( int nlhs, mxArray *plhs[], 
                             int nrhs, const mxArray*prhs[] );
static void CloseMathLink(void);
static void MathLinkEvaluate( int nlhs, mxArray *plhs[], 
                                int nrhs, const mxArray*prhs[] );
static int  ParseMatlabArgs( int nlhs, mxArray *plhs[], 
                             int nrhs, const mxArray*prhs[] );
static void MatToStr(const mxArray *mat, char **str);
static void StrToMat(char *str, mxArray **mat);
static int  WaitForReturnPacket(MLINK mlp);
static void HandleMathLinkError(MLINK mlp, mxArray **mat);
static void SwapLineTerminators(char *str, unsigned int len);

/* This is the main function for the MEX-file */
void mexFunction( int nlhs, mxArray *plhs[], 
		  int nrhs, const mxArray*prhs[] )
{
  /* Check for proper number of arguments */
  switch (ParseMatlabArgs(nlhs, plhs, nrhs, prhs)) {
  case MEXARGUMENTERROR:
    mexErrMsgTxt("Not valid format for mma().");
    break;
  case EVALUATE:
    MathLinkEvaluate(nlhs, plhs, nrhs, prhs);
    break;
  }
  return;
}

static
int ParseMatlabArgs( int nlhs, mxArray *plhs[], 
                     int nrhs, const mxArray*prhs[] )
{
  int res = MEXARGUMENTERROR;
    
  if (!registeredExitFunction) {
    registeredExitFunction = (mexAtExit(CloseMathLink) == 0);
  }
    
  if (first_time) {
    if (OpenMathLink(nlhs, plhs, nrhs, prhs))
      return PROCESSEDOPENLINKARGUMENTS;
  }
    
  if (nlhs > 1)
    mexErrMsgTxt("mma() requires zero or one output arguments.");
  else if (nrhs < 1)
    mexErrMsgTxt("mma() requires at least one input argument.");
  else  {
    res = EVALUATE;
  }
    
  return res;
}

static
mxArray* GetComplex()
{
    mxArray *r = NULL;
    double  *realPtr, *imagPtr;
    int t;
    __int64 d;
    
    if (mlp == NULL)
        mexErrMsgTxt("MathLink connection unexpectedly NULL!");
        
    r = mxCreateDoubleMatrix(1, 1, mxCOMPLEX);
    realPtr = mxGetPr(r);
    imagPtr = mxGetPi(r);
    t = MLGetNext(mlp);
    if (t == MLTKREAL) {
        MLGetReal64(mlp, realPtr);
    } else {
        MLGetInteger64(mlp, &d);
        *realPtr = (double)d;
    }
    t = MLGetNext(mlp);
    if (t == MLTKREAL) {
        MLGetReal64(mlp, imagPtr);
    } else {
        MLGetInteger64(mlp, &d);
        *imagPtr = (double)d;
    }
    return r;
}

static
mxArray* GetArray()
{
  mxArray   *r = NULL;
  double    *data, *currPtr, *realPtr, *imagPtr = NULL;
  int    depth, i, *dims;
  char    **heads;
  mwSize    *mdims, ndim, size = 1;

  if (mlp == NULL)
    mexErrMsgTxt("MathLink connection unexpectedly NULL!");
  
  if (!MLGetReal64Array(mlp, &data, &dims, &heads, &depth)) {
    HandleMathLinkError(mlp, &r);
    return r;
  }
  ndim = depth;
  mdims = (mwSize*)malloc((ndim + 1) * sizeof(mwSize));
  mdims[0] = 1;
  for (i = 0; i < ndim; ++i) {
    mdims[i + 1] = dims[ndim - 1 - i];
    size *= mdims[i + 1];
  }
  if (strcmp(heads[ndim - 1], "Complex")) {
    if (ndim == 1)
        ++ndim;
    else
        ++mdims;
    r = mxCreateNumericArray(ndim, mdims, mxDOUBLE_CLASS, mxREAL);
    realPtr = mxGetPr(r);
  } else {
    size /= 2;
    --ndim;
    if (ndim == 1)
        ++ndim;
    else
        ++mdims;
    r = mxCreateNumericArray(ndim, mdims, mxDOUBLE_CLASS, mxCOMPLEX);
    realPtr = mxGetPr(r);
    imagPtr = mxGetPi(r);
  }
  if (imagPtr) {
    currPtr = data - 1;
    for (i = 0; i < size; ++i) {
        realPtr[i] = *(++currPtr);
        imagPtr[i] = *(++currPtr);
    }
  } else {
    memcpy(realPtr, data, size * sizeof(double));
  }
  MLReleaseReal64Array(mlp, data, dims, heads, depth);
  return r;
}

static
void PutArray(mxArray *expr)
{
  double    *data, *currPtr, *realPtr, *imagPtr;
  mwSize    depth, size, *mdims;
  int       *dims, i;
  char      **heads;
  char  *list = "List", *complex = "Complex";

  if (mlp == NULL)
    mexErrMsgTxt("MathLink connection unexpectedly NULL!");
  
  depth = mxGetNumberOfDimensions(expr);
  mdims = mxGetDimensions(expr);
  dims = (int*)malloc((depth + 1) * sizeof(int));
  heads = (char**)malloc((depth + 1) * sizeof(char*));
  for (i = 0; i < depth; ++i) {
    dims[i] = mdims[depth -1 - i];
    heads[i] = list;
  }
  realPtr = mxGetPr(expr);
  imagPtr = mxGetPi(expr);

  if (depth == 2 && dims[0] == 1 && dims[1] == 1) {
      if (imagPtr) {
          MLPutFunction(mlp, complex, 2);
          MLPutReal64(mlp, *realPtr);
          MLPutReal64(mlp, *imagPtr);
      } else {
          MLPutReal64(mlp, *realPtr);
      }
      return;
  }
  while (dims[depth - 1] == 1) --depth;
  if (imagPtr) {
    size = mxGetNumberOfElements(expr);
    data = (double*)malloc(2 * size * sizeof(double));
    currPtr = data - 1;
    for (i = 0; i < size; ++i) {
        *(++currPtr) = realPtr[i];
        *(++currPtr) = imagPtr[i];
    }
    dims[depth] = 2;
    heads[depth] = complex;
  } else
    data = realPtr;
  if (depth > 1) MLPutFunction(mlp, "Transpose", 2);
  if (imagPtr)
    MLPutReal64Array(mlp, data, dims, heads, depth + 1);
  else
    MLPutReal64Array(mlp, data, dims, heads, depth);
  if (depth > 1) {
    MLPutFunction(mlp, "Range", 3);
    MLPutInteger(mlp, depth);
    MLPutInteger(mlp, 1);
    MLPutInteger(mlp, -1);
  }
  free(dims);
  free(heads);
}

static
void PutExpr(mxArray *expr)
{
    char *buf = NULL;
    int len = 0;
    void *pr = NULL;
    mxArray *head = NULL;
    mwSize size = 0;
    mwIndex index = 0;
    
    if (mlp == NULL)
        mexErrMsgTxt("MathLink connection unexpectedly NULL!");
    
    if (mxIsCell(expr)) {
        size = mxGetNumberOfElements(expr);
        head = mxGetCell(expr, index);
        if (mxIsChar(head)) {
            MatToStr(head, &buf);
            MLPutFunction(mlp, buf, size - 1);
            free(buf);
        } else {
            MLPutNext(mlp, MLTKFUNC);
            MLPutArgCount(mlp, size - 1);
            PutExpr(head);
        }
        for (index = 1; index < size; ++index) {
            PutExpr(mxGetCell(expr, index));
        }
    } else if (mxIsChar(expr)) {
        MatToStr(expr, &buf);
        if (buf[0] == '"') {
            len = strlen(buf);
            buf[len - 1] = '\0';
            MLPutString(mlp, buf + 1);
        } else {
            MLPutSymbol(mlp, buf);
        }
        free(buf);
    } else if (mxIsInt32(expr)) {
        pr = mxGetData(expr);
        MLPutInteger32(mlp, *(__int32*)pr);
    } else if (mxIsInt64(expr)) {
        pr = mxGetData(expr);
        MLPutInteger64(mlp, *(__int64*)pr);
    } else {
        PutArray(expr);
    }
}

static
mxArray* GetExpr() {
    int t, i, n;
    mxArray *r = NULL, *head = NULL;
    char *str = NULL, *buf = NULL;
    
    t = MLGetNext(mlp);
    if (t == MLTKSYM) {
        MLGetSymbol(mlp, &str);
        StrToMat(str, &r);
        MLReleaseSymbol(mlp, str);
    } else if (t == MLTKSTR) {
        MLGetByteString(mlp, &str, &n, '\0');
        buf = (char*)malloc(n + 3);
        strcpy(buf + 1, str);
        MLReleaseByteString(mlp, str, n);
        buf[0] = '"';
        buf[n + 1] = '"';
        buf[n + 2] = '\0';
        StrToMat(buf, &r);
        free(buf);
    } else if (t == MLTKINT) {
        r = mxCreateNumericMatrix(1, 1, mxINT64_CLASS, mxREAL);
        MLGetInteger64(mlp, mxGetData(r));
    } else if (t == MLTKREAL) {
        r = mxCreateDoubleMatrix(1, 1, 0);
        MLGetReal64(mlp, mxGetPr(r));
    } else if (t == MLTKFUNC) {
        MLGetArgCount(mlp, &n);
        head = GetExpr();
        if (mxIsChar(head)) {
            MatToStr(head, &str);
            if (!strcmp(str, "Complex")) {
                r = GetComplex();
                free(str);
                return r;
            }
            if (!strcmp(str, "MATLABArray")) {
                r = GetArray();
                free(str);
                return r;
            }
        }
        r = mxCreateCellMatrix(1, n + 1);
        mxSetCell(r, 0, head);
        for (i = 0; i < n; ++i) {
            mxSetCell(r, i + 1, GetExpr());
        }
    }
    return r;
}

static
mxArray* GetAnswer() {
  mxArray *r = NULL;
  
  if (WaitForReturnPacket(mlp)) {
    r = GetExpr();
  } else {
    HandleMathLinkError(mlp, &r);
  }
  MLNewPacket(mlp);
  return r;
}

static
bool OpenMathLink( int nlhs, mxArray *plhs[], 
                      int nrhs, const mxArray*prhs[] )
{
  bool  flag = false;
  int   res;
  char  *str = NULL, *cmd = NULL;
    
  if (nrhs >= 1 && mxIsChar(prhs[0])) {
      MatToStr(prhs[0], &str);
      if (flag = !strncmp(str, "-link", 5))
        cmd = str;
  }
  if (!cmd)
    cmd = "-linklaunch -linkname math";
  mlenv = MLInitialize(0);
  mlp = MLOpenString(mlenv, cmd, &res);
  if (str)
    free(str);
  
  if (mlp == NULL) {
    mexErrMsgTxt("MathLink connection unexpectedly NULL!");
  }
    
  first_time = false;
  mexPrintf("Mathematica Kernel loading...\n");
    
  /* now preload some convenient definitions into the Mathematica kernel */
  MLPutFunction(mlp, "ToExpression", 1);
  MLPutString(mlp,
  "MATLABQ[x_]:=TensorQ[x,NumberQ[N[#]]&];\
  $[x_?MATLABQ] := MATLABArray[Transpose[#,Range[Length@Dimensions@#,1,-1]]&@N[x]];\
  SetAttributes[$,HoldFirst];\
  $[x_,y_] := (x=y;);");
  GetAnswer();
  
  return flag;
}

static
void CloseMathLink(void)
{
  if (!first_time) {
    MLClose(mlp);
    MLDeinitialize(mlenv);
    mlp = NULL;
    first_time = true;
    mexPrintf("Mathematica Kernel quitting per your request...\n");
  }
}

static
void MathLinkEvaluate( int nlhs, mxArray *plhs[], 
                         int nrhs, const mxArray*prhs[] )
{
  char *str = NULL;
  int i;

  if (mlp == NULL)
    mexErrMsgTxt("MathLink connection unexpectedly NULL!");

  MLPutFunction(mlp, "EvaluatePacket", 1);
  for (i = 0; i < nrhs; ++i) {
      if (i < nrhs - 1) {
          MLPutNext(mlp, MLTKFUNC);
          MLPutArgCount(mlp, 1);
      }
      if ((i == nrhs - 1) && mxIsChar(prhs[i])) {
        MLPutFunction(mlp, "ToExpression", 1);
        MatToStr(prhs[i], &str);
        MLPutString(mlp, str);
        free(str);
      } else {
        PutExpr(prhs[i]);
      }
  }
  MLEndPacket(mlp);
  
  plhs[0] = GetAnswer();
  return;
}

static
void MatToStr(const mxArray *mat, char **str)
{
  int     len, res;

  len = mxGetN(mat);
  *str = (char *)malloc((len + 1) * sizeof(char));
  res = mxGetString(mat, *str, len+1);
  if (swapEOL) 
    SwapLineTerminators(*str, len);
  return;
}

static
void StrToMat(char *str, mxArray **mat)
{
  int     len;

  len = strlen(str);
    
  if (swapEOL)
    SwapLineTerminators(str, len);
        
  *mat = mxCreateString(str);
  return;
}

static
int WaitForReturnPacket(MLINK mlp)
{
  int mlres;
  unsigned int len;
  char *msgStr, *destStr;
  long msglen;

  while ((mlres = MLNextPacket(mlp)) && (mlres != RETURNPKT)) {
    if (mlres == TEXTPKT) {
      MLGetByteString(mlp, (const unsigned char **)&msgStr, &msglen, '\0');
      if (!swapEOL)
        mexPrintf("%s\n", msgStr); /* easy case */
      else { /* need to copy before mutating the string */
        len = strlen(msgStr);
        destStr = (char *)malloc((len + 1) * sizeof(char));
        if (destStr) { /* copied successfully - can mutate string */
          (void)strcpy(destStr, msgStr);
          SwapLineTerminators(destStr, len);
          mexPrintf("%s\n", destStr);
          free(destStr);
        } else /* couldn't copy - should at least output string as is */
          mexPrintf("%s\n", msgStr);
      }
      MLReleaseString(mlp, msgStr);
    }
    MLNewPacket(mlp);
  }
  return mlres;
}

static
void HandleMathLinkError(MLINK mlp, mxArray **mat)
{
  mexPrintf("%s\n", MLErrorMessage(mlp));
  MLClearError(mlp);
  StrToMat("$Failed", mat);
  return;
}

static
void SwapLineTerminators(char *str, unsigned int len)
{
  unsigned int index;
  char *charPtr;
    
  for (charPtr = str, index = 0;
       index < len;
       index++)   {
    if (*charPtr == '\r')
      *charPtr = '\n';
    else if (*charPtr == '\n')
      *charPtr = '\r';
    charPtr++;
  }
  return;
}
