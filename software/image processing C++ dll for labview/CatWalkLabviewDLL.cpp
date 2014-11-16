// CatWalkLabviewDLL.cpp : Defines the exported functions for the DLL application.
//
#include "stdafx.h"
#include "CatWalkLabviewDLL.h"

CatWalkLabview* CatWalkLabview::gCatWalkLabview=NULL;

CatWalkLabview::CatWalkLabview(ImProcPreferences* prefIn, char* dataDirIn)
{
  pref=prefIn;
  bBox=cvRect(0,0,0,0);
  brigthnessInRed=-1;
  dataDir=dataDirIn;
};

CatWalkLabview::~CatWalkLabview()
{
  delete rotCropParam;
  //destructor code here
}
long CatWalkLabview::initialize(ImProcPreferences* prefIn, char* dataDirIn)
{
  if (gCatWalkLabview) { return 1; }
  gCatWalkLabview=new CatWalkLabview(prefIn, dataDirIn);
  gCatWalkLabview->rotCropParam=new RotCropParam;
  return 0;
}

long CatWalkLabview::get_img(IMAQ_Image* image,int cropX,int cropY, int frameNumber)
{
  Mat IRaw, IBgCrop, IThCrop, IR, IB, ISubB, IRotAndCrop, IMask;
  double cropAndRotParameters[3]={0,0,0};
  String message;
  ImProcTools::convertToOpenCV(image->address,IRaw);
  //imresize
  ImProcTools::resizeImg(IRaw,IRaw,gCatWalkLabview->pref->scale);
  //crop background
  cropX=(int)floor(double(cropX)*gCatWalkLabview->pref->scale);
  cropY=(int)floor(double(cropY)*gCatWalkLabview->pref->scale);
  ImProcTools::cropBG(gCatWalkLabview->BG,gCatWalkLabview->ThresMat,IBgCrop,IThCrop,cropX,cropY,IRaw.cols,IRaw.rows);
  //subtract background
  ImProcTools::BGsubtract(IRaw,IBgCrop,IThCrop,IR,IB,ISubB);

  if(ImProcTools::rotAndCrop(ISubB,gCatWalkLabview->pref,gCatWalkLabview->bBox,IRotAndCrop,IMask,IR,cropAndRotParameters,message))
  {
    gCatWalkLabview->analysisMessages.push_back(message);
    gCatWalkLabview->framesForMessages.push_back(frameNumber);
    return 1;
  }
  else
  {
    gCatWalkLabview->analysisMessages.push_back("SELECTED");
    gCatWalkLabview->framesForMessages.push_back(frameNumber);
  }
  Scalar meanBrightness= cv::mean(IR,IMask);
  meanBrightness.val[0];
  gCatWalkLabview->checkIfBrightest(meanBrightness.val[0],frameNumber,cropAndRotParameters);
  gCatWalkLabview->I.push_back(IRotAndCrop);

#ifdef _DEBUG
  //imshow("IR",IR);
  //imshow("IB",IB);
  //imshow("IsubB",ISubB);
  //imshow("IMask",IMask);
  imshow("IRotAndCrop",IRotAndCrop);
  //imwrite("E:\\vasco\\testOpenCV.bmp",gCatWalkLabview->I.at(0));
  //imshow("converted to opencv",gCatWalkLabview->I.at(0));
  cvWaitKey(1);
#endif
  return 0;
}

long CatWalkLabview::extractBody(int minImageNumber, int* xSize,int* ySize, int* frameNumberBright, double* rotBright, double* centerXBright, double* centerYBright)
{
  //write analysis results file
  FILE * AnalysisFile;
  char fileName[512];
  char message[512];
  sprintf_s(fileName,512,"%s\\OpenCVAnalysisResult.txt",gCatWalkLabview->dataDir);
  fopen_s(&AnalysisFile,fileName,"w");
  for(int i=0; i<(int)gCatWalkLabview->analysisMessages.size(); i++)
  {
    sprintf_s(message, 512,"%05d: %s\n",gCatWalkLabview->framesForMessages.at(i),gCatWalkLabview->analysisMessages.at(i).c_str());
    fputs(message,AnalysisFile);
  }
  fclose(AnalysisFile);

  int numCollectedImages =(int)gCatWalkLabview->I.size();
  if(numCollectedImages<minImageNumber)
  {
    return 1;
    *xSize=-1;
    *ySize=-1;
    *centerXBright=0.0;
    *centerYBright=0.0;
    *rotBright=0.0;
    *frameNumberBright=-1;
  }

  Mat IQ, II, IMask, IH;
  ImProcTools::quantileImg(gCatWalkLabview->I,IQ,gCatWalkLabview->pref->quantile);
  #ifdef _DEBUG
  imshow("quantile image",IQ);
  #endif
  ImProcTools::flyBodyIdent(IQ,II,IMask,gCatWalkLabview->pref);
  #ifdef _DEBUG
  imshow("body ident image",II);
  imshow("body ident mask",IMask);
  cvWaitKey(1);
  #endif
  ImProcTools::imHMin(II,IH,IMask,gCatWalkLabview->pref);
  #ifdef _DEBUG
  imshow("IHMin",IH);
  #endif
  ImProcTools::regionGrowing(IH,gCatWalkLabview->IWS,gCatWalkLabview->labelWS,IMask);

  //get brightest image rotation and cropping parameters
  *rotBright=gCatWalkLabview->rotCropParam->rot;
  *centerXBright=gCatWalkLabview->rotCropParam->centerX;
  *centerYBright=gCatWalkLabview->rotCropParam->centerY;
  *xSize = gCatWalkLabview->IWS.cols;
  *ySize = gCatWalkLabview->IWS.rows;
  *frameNumberBright = gCatWalkLabview->brightestIx;
  return 0;
}

long CatWalkLabview::getWSImage()
{
  //#ifdef _DEBUG
  int rMap[] = {0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0, 191, 191, 64, 0, 0, 255, 0};
  int gMap[] = {0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191, 0, 191, 64, 0, 128, 0, 191};
  int bMap[] = {255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191, 191, 0, 64, 255, 0, 0, 191};
  int compCount=(int)gCatWalkLabview->labelWS.size();
  vector<Vec3b> colorTab;
  for(int i = 0; i < compCount; i++ )
  {
    int index=i%32;
    int b = bMap[index];
    int g = gMap[index];
    int r = rMap[index];
    colorTab.push_back(Vec3b((uchar)b, (uchar)g, (uchar)r));
  }

  gCatWalkLabview->IWSUF = Mat(gCatWalkLabview->IWS.size(), CV_8UC3);

  // paint the watershed image
  for(int i = 0; i < gCatWalkLabview->IWS.rows; i++ )
    for(int j = 0; j < gCatWalkLabview->IWS.cols; j++ )
    {
      int index = gCatWalkLabview->IWS.at<int>(i,j);
      if( index == -1 )
        gCatWalkLabview->IWSUF.at<Vec3b>(i,j) = Vec3b(255,255,255);
      else if( index <= 0 || index > compCount )
        gCatWalkLabview->IWSUF.at<Vec3b>(i,j) = Vec3b(0,0,0);
      else
        gCatWalkLabview->IWSUF.at<Vec3b>(i,j) = colorTab[index - 1];
    }
    #ifdef _DEBUG
    imshow("IWSUF",gCatWalkLabview->IWSUF);
    #endif
    //ImProcTools::convertToIMAQColor(gCatWalkLabview->IWSUF,red,green,blue);
    char fileName[512];
    sprintf_s(fileName,512,"%s\\ILabels.bmp",gCatWalkLabview->dataDir);
    imwrite(fileName,gCatWalkLabview->IWS);
    sprintf_s(fileName,512,"%s\\IWS.bmp",gCatWalkLabview->dataDir);
    imwrite(fileName,gCatWalkLabview->IWSUF);
//#endif
    return 0;
}
void CatWalkLabview::checkIfBrightest(double newBrigthness, int newIx,double* cropAndRotParameters)
{
  if(newBrigthness>brigthnessInRed)
  {
    brigthnessInRed=newBrigthness;
    brightestIx=newIx;
    rotCropParam->rot=cropAndRotParameters[0];
    rotCropParam->centerX=cropAndRotParameters[1];
    rotCropParam->centerY=cropAndRotParameters[2];
  }
}

long CatWalkLabview::get_bg(IMAQ_Image* image)
{
  Mat BGRaw;
  ImProcTools::convertToOpenCV(image->address,BGRaw);
  ImProcTools::resizeImg(BGRaw,gCatWalkLabview->BG,gCatWalkLabview->pref->scale);

  //create threshold matrix
  ImProcTools::createThresholdMat(gCatWalkLabview->BG, gCatWalkLabview->ThresMat);
#ifdef _DEBUG
  imshow("rescaled BG",gCatWalkLabview->BG);
  cvWaitKey(1);
#endif
  return 0;   
}
long CatWalkLabview::cleanUp()
{
  delete CatWalkLabview::gCatWalkLabview;
  CatWalkLabview::gCatWalkLabview=NULL;  
  #ifdef _DEBUG
  cvWaitKey(1000);
  #endif
  cvDestroyAllWindows();
  return 0;
}