typedef int SDK_RETURN_CODE;
typedef unsigned int DEV_HANDLE;

#include <Windows.h>

#ifdef SDK_EXPORTS
#define SDK_API extern "C" __declspec(dllexport) SDK_RETURN_CODE _cdecl
#define SDK_HANDLE_API extern "C" __declspec(dllexport) DEV_HANDLE _cdecl
#define SDK_POINTER_API extern "C" __declspec(dllexport) unsigned short * _cdecl
#else
#define SDK_API extern "C" __declspec(dllimport) SDK_RETURN_CODE _cdecl
#define SDK_HANDLE_API extern "C" __declspec(dllimport) DEV_HANDLE _cdecl
#define SDK_POINTER_API extern "C" __declspec(dllimport) unsigned short * _cdecl
#endif

typedef struct
{
  int bitDepth; //value can be either 1,2,4,8
  int PtnNumber;//value in the range [1,96]
  int ABuffer1; //skipped, should be set to 0
  int TrigType; //value can be 0,1,2,3
  int TrigDelay;// in microseconds.
  int TrigPeriod;// in microseconds.
  int ExposureTime;//in microseconds.
  int LEDSelection;//0 for Red, 1 for Green, 2 for Blue
  int ABuffer2;//skipped, should be set to 0
}tPtnSetting;

typedef struct
{
  int Enable; //0 for disable, 1 for enable.
  int TrigDelay;//in MicroSeconds
  int TrigPulseWidth;//in MicroSeconds
  int ABuffer1;//skipped, should be set to 0
  int ABuffer2;//skipped, should be set to 0
}tOutTrigSetting;

SDK_API MTPLG_InitDevice(int DeviceCount, int* DevIPs);
SDK_API MTPLG_UnInitDevice(void);
SDK_API MTPLG_GetDeviceModuleNo(int DeviceIndex, char* ModuleNo);  
SDK_API MTPLG_ConnectDev(int DeviceIndex);        
SDK_API MTPLG_DisconnectDev(int DeviceIndex); 
SDK_API MTPLG_SetDevLEDCurrent(int DeviceIndex, int RLED, int GLED,int BLED);
SDK_API MTPLG_SetDevDisplaySetting(int DeviceIndex, int VMirror, int HMirror);
SDK_API MTPLG_SetDevDisplayMode(int DeviceIndex, int Mode);  
SDK_API MTPLG_SetDevBmp(int DeviceIndex, HBITMAP hbitmap);  
SDK_API MTPLG_SetDevPtnSetting(int DevinceIndex, tPtnSetting ASetting);        
SDK_API MTPLG_SetDevPtnDef(int DeviceIndex, int PatternIndex, HBITMAP hbitmap);                 
SDK_API MTPLG_SetOutTrigSetting(int DeviceIndex, tOutTrigSetting ASetting);       
SDK_API MTPLG_StartPattern(int DeviceIndex);            
SDK_API MTPLG_StopPattern(int DeviceIndex);
SDK_API MTPLG_NextPattern(int DeviceIndex); 
SDK_API MTPLG_BitmapLD(int DeviceIndex,HBITMAP* hbitmap);
SDK_API MTPLG_BitmapLD2(HBITMAP *hbitmap, int LDDegree, int CenterOffX,int CenterOffY);
SDK_API MTPLG_BitmapTD(int DeviceIndex,HBITMAP* hbitmap);    
SDK_API MTPLG_BitmapTD2(HBITMAP *hbitmap, int TDDegree, int CenterOffX, int CenterOffY);

     