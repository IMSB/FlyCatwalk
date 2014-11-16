// dllmain.cpp : Defines the entry point for the DLL application.
#include "stdafx.h"
#include "CatWalkLabviewDLL.h"
#include "nivision.h"

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}
/* One or more functions */
_declspec (dllexport)  long  initialize(ImProcPreferences* prefIn, char* dataDirIn)
{
  return CatWalkLabview::initialize(prefIn, dataDirIn);
}
_declspec (dllexport)  long  get_img(IMAQ_Image* image,int cropX,int cropY, int frameNumber)
{
  return CatWalkLabview::get_img(image,cropX,cropY,frameNumber);
}

_declspec (dllexport)  long  get_bg(IMAQ_Image* image)
{
  return CatWalkLabview::get_bg(image);
}

_declspec (dllexport)  long  extractBody(int minImageNumber, int* xSize,int* ySize, int* frameNumberBright, double* rotBright, double* centerXBright, double* centerYBright)
{
  return CatWalkLabview::extractBody(minImageNumber, xSize, ySize, frameNumberBright, rotBright, centerXBright, centerYBright);
}

_declspec (dllexport)  long  getWSImage()
{
  return CatWalkLabview::getWSImage();
}

_declspec (dllexport)  long  cleanUp()
{
  return CatWalkLabview::cleanUp();
}