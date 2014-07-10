#include <mex.h>
#include "MT_Polygon400_SDK.h"
#include <Windows.h>

void mexFunction(
    int nlhs, mxArray *plhs[],
    int nrhs, const mxArray *prhs[])
{
    // nlhs: Number Left Hand Side parameters
    // *plhs: pointer to Parameters Left Hand Side
    // nrhs: Number Right Hand Side parameters
    // *prhs: pointer to Parameters Reft Hand Side
    
    int a,b,c,d;
    int* e;
    UINT bd;
    char* f = new char[32];
    //HBITMAP* bmp;   // All bitmaps must be Width = 608 & Height = 684
    SDK_RETURN_CODE code = 111;
    /* check for proper number of arguments */
    if(nrhs > 6) 
      mexErrMsgIdAndTxt( "MATLAB:polymex:invalidNumInputs",
              "Too many inputs.  Functions use 6 parameters at most.");
    else if(nlhs > 2) 
      mexErrMsgIdAndTxt( "MATLAB:polymex:maxlhs",
              "Too many output arguments.");
    
    char *input_buf;
    size_t buflen;
    
    
    /* input must be a string */
    if ( mxIsChar(prhs[0]) != 1)
      mexErrMsgIdAndTxt( "MATLAB:polymex:inputNotString",
              "Input must be a string.");

    /* input must be a row vector */
    if (mxGetM(prhs[0])!=1)
      mexErrMsgIdAndTxt( "MATLAB:polymex:inputNotVector",
              "Input must be a row vector.");
    
    /* get the length of the input string */
    buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;
    
    /* copy the string data from prhs[0] into a C string input_ buf.    */
    input_buf = mxArrayToString(prhs[0]);
    
    if(input_buf == NULL) 
      mexErrMsgIdAndTxt( "MATLAB:polymex:conversionFailed",
              "Could not convert input to string.");
    
    // FOR DEVELOPMENT - Check for MEX file functionality
    if (strcmp(input_buf,"Hello") == 0)
    {
        code = 222;
    }
    
    /* call the indicated dll function */
    if (strcmp(input_buf,"InitDevice") == 0 && nrhs == 3)
    { // parameters: Number of Devices or -1, IP Addresses or NULL
        a = mxGetScalar(prhs[1]);
        e = (int*)mxGetData(prhs[2]);
        code = MTPLG_InitDevice(a,e);
    }
    if (strcmp(input_buf,"UnInitDevice") == 0 && nrhs == 1)
    { // parameters: none
        code = MTPLG_UnInitDevice();
    }
    if (strcmp(input_buf,"GetDeviceModuleNo") == 0 && nrhs == 2 && nlhs == 2)
    { // parameters: Device Index
        a = mxGetScalar(prhs[1]);
        code = MTPLG_GetDeviceModuleNo(a,f);
        plhs[1] = mxCreateString(f);
    }
    if (strcmp(input_buf,"ConnectDev") == 0 && nrhs == 2)
    { // parameters: Device Index
        a = mxGetScalar(prhs[1]);
        code = MTPLG_ConnectDev(a);
    }
    if (strcmp(input_buf,"DisconnectDev") == 0 && nrhs == 2)
    { // parameters: Device Index
        a = mxGetScalar(prhs[1]);
        code = MTPLG_DisconnectDev(a);
    }
    if (strcmp(input_buf,"SetDevLEDCurrent") == 0 && nrhs == 5)
    { // parameters: Device Id, Red, Green, Blue (Int) 0-1000 1000 = 100%
        a = mxGetScalar(prhs[1]);
        b = mxGetScalar(prhs[2]);
        c = mxGetScalar(prhs[3]);
        d = mxGetScalar(prhs[4]);
        code = MTPLG_SetDevLEDCurrent(a,b,c,d);
    }
    if (strcmp(input_buf,"SetDevDisplaySetting") == 0 && nrhs == 4)
    {// parameters: Device Index, Verticle Mirror, Horizontal Mirror (Int) 0 or 1
        a = mxGetScalar(prhs[1]);
        b = mxGetScalar(prhs[2]);
        c = mxGetScalar(prhs[3]);
        code = MTPLG_SetDevDisplaySetting(a,b,c);
    }
    if (strcmp(input_buf,"SetDevDisplayMode") == 0 && nrhs == 3)
    { // parameters: Device Index, Mode (Int) 0 = Color 1 = Patterns
        a = mxGetScalar(prhs[1]);
        b = mxGetScalar(prhs[2]);
        code = MTPLG_SetDevDisplayMode(a,b);
    }
    if (strcmp(input_buf,"SetDevBmp") == 0 && nrhs == 4)
    {// parameters: Device Index, Dit Depth (Int), Packed Image (24 Bit)
        a = mxGetScalar(prhs[1]);
        bd = (UINT)mxGetScalar(prhs[2]);
        const void* Bits;
        Bits = mxGetData(prhs[3]);
        HBITMAP hbmp = CreateBitmap(608,684,1,bd,Bits);
        code = MTPLG_SetDevBmp(a,hbmp);
    }
    if (strcmp(input_buf,"SetDevPtnSetting") == 0 && nrhs == 3)
    { // patameters: Device Index, 7 Element Settings Array (Int)
        tPtnSetting tps;
        a = mxGetScalar(prhs[1]);
        e = (int*)mxGetData(prhs[2]);
        tps.bitDepth = e[0];
        tps.PtnNumber = e[1];
        tps.ABuffer1 = 0;
        tps.TrigType = e[2];
        tps.TrigDelay = e[3];
        tps.TrigPeriod = e[4];
        tps.ExposureTime = e[5];
        tps.LEDSelection = e[6];
        tps.ABuffer2 = 0;
        code = MTPLG_SetDevPtnSetting(a,tps);
    }
    if (strcmp(input_buf,"SetDevPtnDef") == 0 && nrhs == 5)
    { // parameters: Device Index, Pattern Number, Bit Depth, Packed Image
        a = mxGetScalar(prhs[1]);
        b = mxGetScalar(prhs[2]);
        bd = (UINT)mxGetScalar(prhs[3]);
        const void* Bits;
        Bits = mxGetData(prhs[4]);
        HBITMAP hbmp = CreateBitmap(608,684,1,bd,Bits); // Trying to fix image
        if (hbmp) {
            code = MTPLG_SetDevPtnDef(a,b,hbmp);
        }
        else {
            code = 101;
        }
    }
    if (strcmp(input_buf,"SetOutTrigSetting") == 0 && nrhs == 3)
    { // parameters: Device Index, 3 Element Settings Array (Int)
        tOutTrigSetting tots;
        a = mxGetScalar(prhs[1]);
        e = (int*)mxGetData(prhs[2]);
        tots.Enable = e[0];
        tots.TrigDelay = e[1];
        tots.TrigPulseWidth = e[2];
        tots.ABuffer1 = 0;
        tots.ABuffer2 = 0;
        code = MTPLG_SetOutTrigSetting(a,tots);
    }
    if (strcmp(input_buf,"StartPattern") == 0 && nrhs == 2)
    { // parameters: Device Index
        a = mxGetScalar(prhs[1]);
        code = MTPLG_StartPattern(a);
    }
    if (strcmp(input_buf,"StopPattern") == 0 && nrhs == 2)
    { // parameters: Device Index
        a = mxGetScalar(prhs[1]);
        code = MTPLG_StopPattern(a);
    }
    if (strcmp(input_buf,"NextPattern") == 0 && nrhs == 2)
    { // parameters: Device Index
        a = mxGetScalar(prhs[1]);
        code = MTPLG_NextPattern(a);
    }
    if (strcmp(input_buf,"BitmapLD") == 0 && nrhs == 4)
    {
        a = mxGetScalar(prhs[1]);
        bd = (UINT)mxGetScalar(prhs[2]);
        const void* Bits;
        Bits = mxGetData(prhs[3]);
        HBITMAP bmp = CreateBitmap(608,684,1,bd,Bits);
        HBITMAP *hbmp = &bmp;
        code = MTPLG_BitmapLD(a,hbmp);
    }
    if (strcmp(input_buf,"BitmapLD2") == 0 && nrhs == 6)
    {
        a = mxGetScalar(prhs[1]);
        b = mxGetScalar(prhs[2]);
        c = mxGetScalar(prhs[3]);
        bd = (UINT)mxGetScalar(prhs[4]);
        const void* Bits;
        Bits = mxGetData(prhs[5]);
        HBITMAP bmp = CreateBitmap(608,684,1,bd,Bits);
        HBITMAP *hbmp = &bmp;
        code = MTPLG_BitmapLD2(hbmp,a,b,c);
    }
    if (strcmp(input_buf,"BitmapTD") == 0 && nrhs == 4)
    {
        a = mxGetScalar(prhs[1]);
        bd = (UINT)mxGetScalar(prhs[2]);
        const void* Bits;
        Bits = mxGetData(prhs[3]);
        HBITMAP bmp = CreateBitmap(608,684,1,bd,Bits);
        HBITMAP *hbmp = &bmp;
        code = MTPLG_BitmapTD(a,hbmp);
    }
    if (strcmp(input_buf,"BitmapTD2") == 0 && nrhs == 6)
    {
        a = mxGetScalar(prhs[1]);
        b = mxGetScalar(prhs[2]);
        c = mxGetScalar(prhs[3]);
        bd = (UINT)mxGetScalar(prhs[4]);
        const void* Bits;
        Bits = mxGetData(prhs[5]);
        HBITMAP bmp = CreateBitmap(608,684,1,bd,Bits);
        HBITMAP *hbmp = &bmp;
        code = MTPLG_BitmapTD2(hbmp,a,b,c);
    }
    
    mxFree(input_buf);
    plhs[0] = mxCreateDoubleScalar(code);
    return;
}


