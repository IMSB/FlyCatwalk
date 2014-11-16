#ifndef CATWALKLABVIEWDLL_H
#define CATWALKLABVIEWDLL_H

#include "stdafx.h"
#include "nivision.h"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/contrib/contrib.hpp"
#include "ImageProcessingTools.h"

using namespace cv;
using namespace std;

typedef struct
{
  double rot;
  double centerX;
  double centerY;
}RotCropParam;

class CatWalkLabview
{
public:
  CatWalkLabview(ImProcPreferences* prefIn, char* dataDirIn);
  ~CatWalkLabview();
  static CatWalkLabview* gCatWalkLabview;
  static long initialize(ImProcPreferences* prefIn, char* dataDirIn);
  static long cleanUp();
  static long get_img(IMAQ_Image* image,int cropX,int cropY, int frameNumber);
  static long get_bg(IMAQ_Image* image);
  static long extractBody(int minImageNumber, int* xSize,int* ySize, int* frameNumberBright, double* rotBright, double* centerXBright, double* centerYBright);
  static long getWSImage();
  void checkIfBrightest(double newBrigthness, int newIx, double* cropAndRotParameters);
  double* getCropAndRotParametersForBrightest();

private:
  ImProcPreferences* pref;
  char* dataDir;
  cv::Rect bBox; //bounding box needed for keeping the same size when cropping
  int brightestIx;
  double brigthnessInRed;
  RotCropParam* rotCropParam;
  vector<Mat> I;
  Mat BG;
  Mat ThresMat;
  Mat IWS;
  Mat IWSUF;
  vector<int> labelWS;
  vector<std::string> analysisMessages;
  vector<int> framesForMessages;
};

#endif