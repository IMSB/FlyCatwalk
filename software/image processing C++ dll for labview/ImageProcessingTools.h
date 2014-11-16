#ifndef IMAGEPROCESSINGTOOLS_H
#define IMAGEPROCESSINGTOOLS_H

#include "stdafx.h"
#include "nivision.h"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"

using namespace cv;
using namespace std;

typedef struct
{
  float scale;
  int elSizeImOpen;
  float thresholdBinarizationBody;
  float thresholdBinarizationWings;
  int minWingsArea;
  float quantile;
  int elSizeImOpenIdent1;
  int elSizeImOpenIdent2;
  float thresholdBinarizationIdent;
  int elSizeImHMin;
  float raiseParImHMin;
  int focusLimit;
  float maxAllowedRotation;
  int elSizeImClose;
  int numIterImClose;
  float symmetryMinOverlapBody;
  float symmetryMinOverlapWings;
  float thresholdReflectionCheck;
  int elSizeReflection;
  int maxReflectionArea;
  float upSideDownCheck;
}ImProcPreferences;

typedef struct 
{
  int label;
  bool min;
}plateau;

typedef struct
{
  char* name;
  Image* address;
}IMAQ_Image;

typedef struct
{
  IMAQ_Image* blueChannel;
  IMAQ_Image* redChannel;
  IMAQ_Image* greenChannel;
}IMAQ_Color_Image;

class ImProcTools
{
public:
  static void convertToOpenCV(Image* image,Mat& dstI);
  static void convertToIMAQColor(Mat& CVImageMat,IMAQ_Image* red,IMAQ_Image* green,IMAQ_Image* blue);
  static void resizeImg(Mat& src, Mat& dst, float scale);
  static void cropBG(Mat& srcBG,Mat& srcTH,Mat& dstBG,Mat& dstTH,int cropX,int cropY,int width,int height);
  static void BGsubtract(Mat& srcI,Mat& bgI,Mat& thresOffset,Mat& rI,Mat& bI,Mat& subBI);
  static int  rotAndCrop(Mat& I,ImProcPreferences* pref,cv::Rect& bBox,Mat& dstI,Mat& maskI, Mat& IR, double* cropAndRotParameters,string& message);
  static void PCAMat( Mat& src, int color, cv::Point& center, int& area, float& theta, float& ecc);
  static void quantileImg(vector<Mat> src, Mat& dst, float quant);
  static void flyBodyIdent(Mat& src, Mat& dst, Mat& mask,ImProcPreferences* pref);
  static void extractBlobsMat(Mat& src, Mat& dst, int blobColor=255);
  static void imHMin( cv::Mat& src,CV_OUT cv::Mat& dst, Mat mask, ImProcPreferences* pref);
  static void regionGrowing(cv::Mat& src, cv::Mat& dst,vector<int>& label, cv::Mat& mask);
  static void findExtendedLocalMin(Mat& src, CvSeq* ptSeq, CvMemStorage* storage0, CvSeq* cntSeq, CvMemStorage* storage1, Mat mask);
  static void neighborhoodMat(int x, int y, int w, int h,vector<cv::Point>& dst, int typeconn);
  static bool checkFocus(Mat& src, Mat& mask, ImProcPreferences* pref);
  static bool checkUpSideDown(Mat& src, Mat& mask, ImProcPreferences* pref);
  static int histQuantile(const Mat& hist, float quantile);
  static void findBiggestBlob(Mat& src,Mat& dst,vector<cv::Point>& contour,int blobColor = 255);
  static void imOpen(Mat& src,Mat& dst,int kernelSize, int iterations=1);
  static void imClose(Mat& src,Mat& dst,int kernelSize, int iterations=1);
  static bool checkReflections(Mat& I, Mat& mask, ImProcPreferences* pref);
  static void createThresholdMat(Mat& src, Mat& dst);
};
#endif