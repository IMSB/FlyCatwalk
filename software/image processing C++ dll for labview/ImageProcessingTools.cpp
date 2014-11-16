#include "stdafx.h"
#include "ImageProcessingTools.h"

void ImProcTools::resizeImg(Mat& src, Mat& dst, float scale)
{
  if(scale != 1.0f)
    resize(src,dst,cvSize(cvRound((float)src.cols*scale),cvRound((float)src.rows*scale)),INTER_NEAREST);
  else
    src.copyTo(dst);
}

void ImProcTools::convertToOpenCV(Image* image,Mat& dstI)
{
  ImageInfo info;
  //convert to OpenCV image
  IplImage* CVImageSrc;
  imaqGetImageInfo(image,&info);

  if(info.imageType==IMAQ_IMAGE_U8)
  {
    CVImageSrc = cvCreateImageHeader( cvSize(info.xRes,info.yRes), IPL_DEPTH_8U, 1);
    CVImageSrc->imageData = (char*)info.imageStart;
    CVImageSrc->widthStep = info.pixelsPerLine; //correct padding
  }
  else if(info.imageType==IMAQ_IMAGE_RGB)
  {
    CVImageSrc = cvCreateImageHeader( cvSize(info.xRes,info.yRes), IPL_DEPTH_8U, 4);
    CVImageSrc->imageData = (char*)info.imageStart;
    CVImageSrc->widthStep = 4*info.pixelsPerLine; //correct padding
  }
  dstI=Mat(CVImageSrc,false); //no copy just change container  
}

void ImProcTools::convertToIMAQColor(Mat& CVImageMat,IMAQ_Image* red,IMAQ_Image* green,IMAQ_Image* blue)
{
  ImageInfo info;
  //convert to OpenCV image
  vector<Mat> singleChannels;
  vector<IplImage*> CVImageSrc;
  split(CVImageMat,singleChannels);
  for(int i=0;i<3;i++)
  {
    if(i==0)
    {
      imaqGetImageInfo(blue->address,&info);
    }
    else if(i==1)
    {
      imaqGetImageInfo(green->address,&info);
    }
    else if(i==2)
    {
      imaqGetImageInfo(red->address,&info);
    }
    CVImageSrc.push_back(cvCreateImageHeader( cvSize(info.xRes,info.yRes), IPL_DEPTH_8U, 1));
    CVImageSrc.at(i)->imageData = (char*)info.imageStart;
    CVImageSrc.at(i)->widthStep = info.pixelsPerLine; //correct padding
    //CVImageMat.convertTo(CVImageMat,CV_8UC4);
    IplImage* temp;
    temp = cvCreateImageHeader( cvSize(info.xRes,info.yRes), IPL_DEPTH_8U, 1);
    //temp->widthStep = info.pixelsPerLine;
    singleChannels.at(i).step=info.pixelsPerLine;
    temp->imageData = (char*)singleChannels.at(i).data;
    cvCopy(temp,CVImageSrc.at(i));
    //cvShowImage("converted",CVImageSrc.at(i));
    //cvWaitKey(0);
  }
}

void ImProcTools::BGsubtract(Mat& srcI,Mat& bgI,Mat& thresOffset,Mat& rI,Mat& bI,Mat& subBI)
{
  //Mat subR(srcI.size(),1);
  //Mat subB(srcI.size(),1);
  vector<Mat> imSplit;
  vector<Mat> bgSplit;
  vector<Mat> thresSplit;
  split(srcI,imSplit);
  split(bgI,bgSplit);
  split(thresOffset,thresSplit);

  rI=imSplit[2];//-bgSplit[0];
  bI=imSplit[0];//bgSplit[2]-imSplit[2];
  #ifdef _DEBUG
  imshow("croppedBG",bgI);
  imshow("rawImage",srcI);
  cvWaitKey(1);
  #endif

  //conversion to signed
  Mat tempBG, tempBI, tempSubBI;
  bgSplit[0].convertTo(tempBG,CV_32S);
  bI.convertTo(tempBI,CV_32S);
  tempSubBI=tempBG-thresSplit[0]-tempBI;
  tempSubBI.convertTo(subBI,CV_8U);
  //subBI=bgSplit[0]-thresSplit[0]-bI;
  //absdiff(srcI,bgI,subI);
}

void ImProcTools::cropBG(Mat& srcBG,Mat& srcTH,Mat& dstBG,Mat& dstTH,int cropX,int cropY,int width,int height)
{
#ifdef _DEBUG
  imshow("background raw",srcBG);
#endif

  if(srcBG.cols<cropX+width)
  {
    cropX=srcBG.cols-width;
  }
  if(srcBG.rows<cropY+height)
  {
    cropY=srcBG.rows-height;
  }

  if(cropX<0||cropY<0)
  {
    return;
  }
  CvRect cropRect= cvRect(cropX,cropY,width,height);
  dstBG=srcBG(cropRect);
  dstTH=srcTH(cropRect);
#ifdef _DEBUG
  imshow("background cropped",dstBG);
  cvWaitKey(1);
#endif
}

int ImProcTools::rotAndCrop(Mat& I,ImProcPreferences* pref,cv::Rect& bBox,Mat& dstI,Mat& maskI,Mat& IR,double* cropAndRotParameters,string& message)
{
  // Binarize image:
  Mat thIBody(I.size(),CV_8U);
  Mat thIBodyAndWings(I.size(),CV_8U);
  Mat WingsMask(I.size(),CV_8U);
  Size eSize(pref->elSizeImOpen,pref->elSizeImOpen);
  Mat elem = getStructuringElement(MORPH_ELLIPSE,eSize);
  threshold(I,thIBody,cvRound(255.0*pref->thresholdBinarizationBody),255,CV_THRESH_BINARY);
  threshold(I,thIBodyAndWings,cvRound(255.0*pref->thresholdBinarizationWings),255,CV_THRESH_BINARY);
  erode(thIBody,thIBody,elem);
  dilate(thIBody,thIBody,elem);
  erode(thIBodyAndWings,thIBodyAndWings,elem);
  WingsMask=thIBodyAndWings-thIBody;
  dilate(WingsMask,WingsMask,elem);
  //erode(thIBodyAndWings,thIBodyAndWings,elem);
  //dilate(thIBodyAndWings,thIBodyAndWings,elem);
  int areaBody=countNonZero(thIBody);
  if(areaBody==0)
  {
    message="DISCARDED Fly body not found";
    return 1;
  }

  int areaWings=countNonZero(WingsMask);
  if(areaWings==0)
  {
    message="DISCARDED Fly wings not found";
    return 1;
  }

  vector<cv::Point> contour;
  findBiggestBlob(WingsMask,WingsMask,contour);
  //check if it is touching the borders
  cv::Rect bBoxBorderCheck=boundingRect(Mat(contour));
  if(bBoxBorderCheck.x==0||
    bBoxBorderCheck.x+bBoxBorderCheck.width==WingsMask.cols-1||
    bBoxBorderCheck.y==0||
    bBoxBorderCheck.y+bBoxBorderCheck.height==WingsMask.rows-1)
  {
    message="DISCARDED Fly wings are touching the image borders";
    return 1;
  }

  findBiggestBlob(thIBody,maskI,contour);
  //check if it is touching the borders
  bBoxBorderCheck=boundingRect(Mat(contour));
  if(bBoxBorderCheck.x==0||
    bBoxBorderCheck.x+bBoxBorderCheck.width==maskI.cols-1||
    bBoxBorderCheck.y==0||
    bBoxBorderCheck.y+bBoxBorderCheck.height==maskI.rows-1)
  {
    message="DISCARDED Fly body is touching the image borders";
    return 1;
  }

  //int areaBodyAndWings=countNonZero(thIBodyAndWings);
  //int areaWings=areaBodyAndWings-areaBody;
  //int areaWings=countNonZero(WingsMask);

#ifdef _DEBUG
  imshow("IMaskBody",maskI);
  imshow("IMaskWings",WingsMask);
  cvWaitKey(1);
#endif


  if(areaWings<pref->minWingsArea*pref->scale)
  {
    message="DISCARDED Wings area too small";
    return 1;
  }

  //check for reflections
  if(checkReflections(IR,WingsMask,pref))
  {
    message="DISCARDED Reflections in the wings";
    return 1;
  }

  //check focus
  if(ImProcTools::checkFocus(I,WingsMask,pref))
  {
    message="DISCARDED Image is out of focus";
    return 1;
  }

  //check upsideDown
  if(ImProcTools::checkUpSideDown(IR,maskI,pref))
  {
    message="DISCARDED Fly is walking on the ceiling";
    return 1;
  }
  //imshow("result of imOpening",thI);
  //cvWaitKey(1);

  // Check if the blob is touching the borders
  for(int i=0;i<maskI.rows;i++)
  {
    if(maskI.at<unsigned char>(i,1)>0 || maskI.at<unsigned char>(i,maskI.cols-2)>0)
    {
      message="DISCARDED Should not have ended up in here!";
      return 1;
    } 
  }

  // PCA:
  cv::Point center;
  cv::Point centerWings;
  int area;
  float theta, thetaWings, ecc, eccWings;
  cv::Rect bbox, bbox1(0,0,0,0);
  int blobColor=255;
  PCAMat(WingsMask,blobColor,centerWings,areaWings,thetaWings,eccWings);
  PCAMat(maskI,blobColor,center,area,theta,ecc);

  //check if fly is walking up
  double angleOffset=0.0;
  if(centerWings.x>center.x)
  {
    message="DISCARDED Fly was walking backwards (maybe it'll be used in the future, but for now it's ignored)";
    return 1;
    //angleOffset=180.0;
  }
  //check if rotation is not too high
  double angle = theta*180.0/CV_PI+angleOffset;
  if(angle>180.0)
    angle-=360.0;
  if(angle>90.0)
    angle-=180.0;
  else if(angle<-90.0)
    angle+=180;
  double scale = 1.0;

  if(angle>pref->maxAllowedRotation||angle<-pref->maxAllowedRotation)
  {
    message="DISCARDED Fly rotation too high";
    return 1;
  }
  // Rotate image:
  int diag;
  diag = cvRound(sqrt((float)( maskI.cols * maskI.cols + maskI.rows * maskI.rows )));
  Mat  rotMask(maskI.rows,diag,CV_8U);
  Mat  rotI(maskI.rows,diag,CV_8U), rmat;
  //rotMask.setTo(0);
  rotI.setTo(0);
  cropAndRotParameters[0]=angle;
  rmat = getRotationMatrix2D(center,angle,scale);
  //warpAffine(maskI,rotMask,rmat,rotI.size());
  warpAffine(I,rotI,rmat,rotI.size(),INTER_NEAREST);
  warpAffine(maskI,rotMask,rmat,rotI.size(),INTER_NEAREST);
  warpAffine(WingsMask,WingsMask,rmat,rotI.size(),INTER_NEAREST);
#ifdef _DEBUG
  imshow("rotated Image",rotI);
  cvWaitKey(1);
#endif

  // Crop image:
  float growthFac = .2f;
  //the first time the fly is seen one determines the size of the bounding box
  if(bBox.area()==0)
  {
    bbox = boundingRect(Mat(contour));
    bbox1.width = cvRound(sqrt((float)( bbox.width * bbox.width + bbox.height * bbox.height ))*(1.0+growthFac));
    bbox1.height = cvRound(bbox.height*(1.0+growthFac));
  }
  else
  {
    bbox1 = bBox;
  }
  int w = bbox1.width;
  int h = bbox1.height;
  int hh = rotI.rows;
  int ww = rotI.cols;
  int ulx = center.x-cvRound((float)w/2.0);
  int uly = center.y-cvRound((float)h/2.0);

  if(uly<0 || uly+h>hh || ulx<0 || ulx+w>ww)
  {
    message="DISCARDED Fly is touching borders after cropping growth";
    return 1;
  }
  else{
    bbox1 = cv::Rect(ulx,uly,w,h);
    cropAndRotParameters[1]=(double)center.x/pref->scale;
    cropAndRotParameters[2]=(double)center.y/pref->scale;
    //maskIRot = Mat(rotMask,bbox1);
    dstI = Mat(rotI,bbox1);
  }
  bBox = bbox1;
  rotMask=Mat(rotMask,bBox);
  WingsMask=Mat(WingsMask,cvRect(0,bBox.y,WingsMask.cols,bBox.height));
  //check if image is symmetric
  //cut in two
  double blobSizeBody=sum(rotMask).val[0];
  double blobSizeWings=sum(WingsMask).val[0];
  //body symmetry
  if(pref->symmetryMinOverlapBody!=0)
  {
    Mat symI1=rotMask(cvRect(0,0,rotMask.cols,rotMask.rows/2));
    Mat symI2=rotMask(cvRect(0,rotMask.rows/2,rotMask.cols,rotMask.rows/2));
    Mat symCheckI;
    flip(symI2,symI2,0);
    absdiff(symI1,symI2,symCheckI);
    double percentNoOverlapBody=sum(symCheckI).val[0]/blobSizeBody*50;
    #ifdef _DEBUG
    imshow("symmetry check1",symI1);
    imshow("symmetry check2",symI2);
    imshow("symmetry check",symCheckI);
    cvWaitKey(1);
    #endif
    if(100.0-percentNoOverlapBody<pref->symmetryMinOverlapBody)
    {
      message="DISCARDED Body symmetry is too low";
      return 1;
    }
  }
  //wings symmetry
  if(pref->symmetryMinOverlapWings!=0)
  {
    Mat symWI1=WingsMask(cvRect(0,0,WingsMask.cols,WingsMask.rows/2));
    Mat symWI2=WingsMask(cvRect(0,WingsMask.rows/2,WingsMask.cols,WingsMask.rows/2));
    Mat symCheckWI;
    flip(symWI2,symWI2,0);
    absdiff(symWI1,symWI2,symCheckWI);
    double percentNoOverlapWings=sum(symCheckWI).val[0]/blobSizeWings*50;
    #ifdef _DEBUG
    imshow("symmetry check W1",symWI1);
    imshow("symmetry check W2",symWI2);
    imshow("symmetry check W",symCheckWI);
    cvWaitKey(1);
    #endif
    if(100.0-percentNoOverlapWings<pref->symmetryMinOverlapWings)
    {
      message="DISCARDED Wings symmetry is too low";
      return 1;
    }
  }

  return 0;
}

void ImProcTools::PCAMat( Mat& src, int color, cv::Point& center, int& area, float& theta, float& ecc)
{
  Mat _src;
  Moments m;
  float cm11, cm20, cm02, gamma_max, gamma_min;
  src.copyTo(_src);

  m = moments(_src);

  // Center:
  center.x = (int)cvRound(m.m10/m.m00);
  center.y = (int)cvRound(m.m01/m.m00);
  // Area:
  area = (int)cvRound(m.m00/color);
  // get central moments;
  cm11 = (float)m.mu11;
  cm20 = (float)m.mu20;
  cm02 = (float)m.mu02;
  // centroid
  gamma_max = (float)(0.5*(cm20 + cm02) 
    + 0.5*sqrt(cm20*cm20 
    + cm02*cm02 
    - 2*cm20*cm02 
    + 4*cm11*cm11));

  gamma_min = (float)(0.5*(cm20 + cm02) 
    - 0.5*sqrt(cm20*cm20 
    + cm02*cm02 
    - 2*cm20*cm02 
    + 4*cm11*cm11));

  // eccentrity
  ecc = sqrt (gamma_max / gamma_min);

  // axis of inertia
  theta = atan((gamma_max - cm20)/cm11);
  //if (theta < 0) theta += 2 * CV_PI;
  //if (theta >= 2 * CV_PI) theta -= 2 * CV_PI;
}


void ImProcTools::quantileImg(vector<Mat> src, Mat& dst, float quant)
{
  int dim= (int)src.size();
  dst=Mat(src.at(0).size(),src.at(0).type());
  int h = dst.rows;
  int w =dst.cols;
  uchar idx = cvRound(quant*(dim-1));
  cv::Point pix;

  int x,y,k;
  //omp_set_num_threads(4);
  if (src.at(0).channels()>1)
  {
    vector<uchar> pixvalB, pixvalG, pixvalR;
#pragma omp parallel shared(h,w,dim,src,dst,idx) private(pix,x,y,k,pixvalB,pixvalG,pixvalR) 
    {
      pixvalB.resize(dim);
      pixvalG.resize(dim);
      pixvalR.resize(dim);
#pragma omp for
      for(y=0;y<h;y++)
      {
        pix.y=y;
        for(x=0;x<w;x++)
        {
          pix.x = x;
          for(k=0;k<dim;k++)
          {
            pixvalB[k] = src.at(k).at<Vec3b>(pix)[0];
            pixvalG[k] = src.at(k).at<Vec3b>(pix)[1];
            pixvalR[k] = src.at(k).at<Vec3b>(pix)[2];
          }
          // Choose median value:
          sort(pixvalB.begin(),pixvalB.end());
          sort(pixvalG.begin(),pixvalG.end());
          sort(pixvalR.begin(),pixvalR.end());

          dst.at<Vec3b>(pix)[0] = pixvalB[idx];
          dst.at<Vec3b>(pix)[1] = pixvalG[idx];
          dst.at<Vec3b>(pix)[2] = pixvalR[idx];
        }
      }  
    }
  }
  else
  {
    vector<uchar> pixval;
#pragma omp parallel shared(h,w,dim,src,dst,idx) private(pix,x,y,k,pixvalB,pixvalG,pixvalR) 
    {
      pixval.resize(dim);
#pragma omp for
      for(y=0;y<h;y++)
      {
        pix.y=y;
        for(x=0;x<w;x++)
        {
          pix.x = x;
          for(k=0;k<dim;k++)
          {
            pixval[k] = src.at(k).at<uchar>(pix);
          }
          // Choose median value:
          sort(pixval.begin(),pixval.end());
          dst.at<uchar>(pix) = pixval[idx];
        }
      }  
    }
  }
}

void ImProcTools::flyBodyIdent(Mat& src, Mat& dst, Mat& mask,ImProcPreferences* pref)
{
#ifdef TIME_CHECK
  printf( "Find mask and bwdist time: \n" );
  double t = (double)getTickCount();
#endif

  // Step 1: im resize
  Mat _src1;
  // int percent =(int)cvRound(pref->scale*100.0);
  //Mat _src(cvSize((int)((src.cols*percent)/100),(int)((src.rows*percent)/100)),CV_32F), _src1;
  // if(pref->scale!=1.0)
  //	  resize(src,_src1,cvSize((int)((src.cols*percent)/100),(int)((src.rows*percent)/100)));
  //else
  src.copyTo(_src1);
  _src1.convertTo(src,CV_32F);

#ifdef TIME_CHECK
  t = (double)getTickCount()-t;
  printf( "- resize time = %gms\n", t*1000./getTickFrequency() );
  t = (double)getTickCount();
#endif

  // Step 2: Img channels
  //tf = (double)getTickCount();
  Mat _imB, _imR, _im2, _im3;;
  vector<Mat> _imSplit;
  split(src,_imSplit);
  Size esize2(pref->elSizeImOpenIdent1,pref->elSizeImOpenIdent1);
  Size esize3(pref->elSizeImOpenIdent2,pref->elSizeImOpenIdent2);
  Mat elem2 = getStructuringElement(MORPH_ELLIPSE,esize2);
  Mat elem3 = getStructuringElement(MORPH_ELLIPSE,esize3);
  double min, max;
  _imB = _imSplit[0];
  erode(_imB,_imB,elem2);
  dilate(_imB,_imB,elem2);
  //_imR = _imSplit[2];
  //erode(_imR,_imR,elem2);
  //dilate(_imR,_imR,elem2);
  //_im2 = _imB*3.0+_imR;
  _im2 = _imB;
  minMaxLoc(_im2,&min,&max);
  _im2 = (_im2-(float)min)/float(max-min)*255;
  _im2.convertTo(_im3,CV_8U);

#ifdef TIME_CHECK
  t = (double)getTickCount()-t;
  printf( "- Channels separation time = %gms\n", t*1000./getTickFrequency() );
  t = (double)getTickCount();
#endif

  // Step 3: Image thresholding:
  //tf = (double)getTickCount();
  Mat _th(_im3.size(),CV_8U);
  threshold(_im3,_th,cvRound(255.0*pref->thresholdBinarizationIdent),255,CV_THRESH_BINARY);
  erode(_th,_th,elem3);
  dilate(_th,_th,elem3);

#ifdef TIME_CHECK
  t = (double)getTickCount()-t;
  printf( "- TH time = %gms\n", t*1000./getTickFrequency() );
  t = (double)getTickCount();
#endif

  // Mask
  Mat _blob;
  extractBlobsMat(_th,_blob);

  imClose(_blob,_blob,pref->elSizeImClose,pref->numIterImClose);

  Mat _mask;
  _mask = 255-_blob;

#ifdef TIME_CHECK
  t = (double)getTickCount()-t;
  printf( "- Blob extraction = %gms\n", t*1000./getTickFrequency() );
  t = (double)getTickCount();
#endif

  // Step 8: BW Dist (float):	
  //tf = (double)getTickCount();
  Mat _dist;
  //distanceTransform(_th,_dist,CV_DIST_L2,3);
  distanceTransform(_blob,_dist,CV_DIST_L2,3);
  minMaxLoc(_dist,&min,&max);
  _dist = 1.0f-(_dist-(float)min)/float(max-min);
  minMaxLoc(_dist,&min,&max);
  _dist.setTo(1.0f,_mask);

#ifdef TIME_CHECK
  t = (double)getTickCount()-t;
  printf( "- BW dist time = %gms\n", t*1000./getTickFrequency() );
  t = (double)getTickCount();
#endif
#ifdef SHOW_IMGS
  imshow("Resized img",_src);
  imshow("BG subtraction and channels sep",_im3);
  imshow("TH and morph transform",_th);
  imshow("BW dist",_dist);
#endif

  _dist.copyTo(dst);
  _mask.copyTo(mask);
}


void ImProcTools::extractBlobsMat(Mat& src, Mat& dst, int blobColor)
{
  Mat _src, _dst(src.size(),CV_8U);
  _dst.setTo(0);
  src.copyTo(_src);
  vector<vector<cv::Point>> contours;
  vector<Vec4i> hierarchy;
  int l=0, idx=0;
  cv::Rect _bbox;

  findContours(_src, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
  // Find biggest blob:
  for(int i=0;i<(int)contours.size();i++)
  {
    if((int)contours[i].size()>l)
    {
      l = contours[i].size();
      idx = i;
    }
  }
  drawContours(_dst, contours,idx, Scalar(blobColor),CV_FILLED,8,noArray(),0);

  _dst.copyTo(dst);
}

void ImProcTools::imHMin( cv::Mat& src,CV_OUT cv::Mat& dst, Mat mask,ImProcPreferences* pref)
{
  cv::Mat _src(src.size(),CV_32FC1), _im(src.size(),CV_32FC1);
  src.copyTo(_src);
  //cv::imshow("imtest1",cv::abs(src));
  int kpar = pref->elSizeImHMin;

  cv::add(_src,pref->raiseParImHMin,_im);
  cv::Mat kernel(kpar,kpar,src.depth());
  kernel = cv::Scalar::all(1);
  cv::Mat cmpM;
  cv::compare(_src-_im,0,cmpM,cv::CMP_GT);
  double* cmpv = cv::sum(cmpM).val;
  while(cmpv[0]==0)
  {
    erode(_im,_im,kernel);
    cv::compare(_src-_im,0,cmpM,cv::CMP_GT);
    cmpv = cv::sum(cmpM).val;
    //printf( "sum = %d\n", cmpv );
    //cv::imshow("imtest",cv::abs(_im));
  }
  double max = 0;
  double min = 0;
  cv::minMaxLoc(_im,&min,&max);
  _im=(_im-min)/(max-min);

  _im.setTo(1.0f,mask);
  _im.copyTo(dst);
}

void ImProcTools::regionGrowing(cv::Mat& src, cv::Mat& dst,vector<int>& label, cv::Mat& mask)
{
  cv::Mat _mask = mask, _src(src.size(),CV_32F), _dst(src.size(),CV_32S), _cnt(src.size(),CV_8U);
  int h = src.rows;
  int w = src.cols;
  int dv, current_label=1;
  float v, nv;
  vector<cv::Point> nmat;
  vector<vector<cv::Point>> contours;
  vector<cv::Vec4i> hierarchy;
  cv::Point nPix;

  MemStorage storage0(cvCreateMemStorage());
  CvSeq* seq = cvCreateSeq(0, sizeof(CvSeq), sizeof(CvSeq), storage0);
  MemStorage storage1(cvCreateMemStorage());
  CvSeq* grseq = cvCreateSeq(0, sizeof(CvSeq), sizeof(CvSeq), storage1);

  src.copyTo(_src);
  _src.setTo(1.0f,mask);
  _dst.setTo(0);

  // Find local minima:
  findExtendedLocalMin(_src,seq,storage0,grseq,storage1,mask);

  //label = (int*) calloc (seq->total, sizeof(int) );
  label.resize(seq->total);
  for(int i=0;i<(int)seq->total;i++)
  {
    CvSeq** pixels = (CvSeq**)cvGetSeqElem(seq,i);
    for(int j=0;j<(int)(*pixels)->total;j++)
    {
      cv::Point pix = *(cv::Point*)cvGetSeqElem(*pixels,j);
      _dst.at<int>(pix) = current_label;
    }
    //label[i] = current_label;
    label[i] = current_label;
    current_label++;
  }

#ifdef WRITE_IMGS
  writeIntImg(_dst,"locMin");
#endif

  _dst.setTo(-1,_mask);
  int stop = 0, cnt = 0;
  while(1)
  {
    cnt++;
    stop = 0;
    int dim = grseq->total;
    for(int i=0;i<dim;i++)
    {
      CvSeq** grpix = (CvSeq**)cvGetSeqElem(grseq,i);
      CvSeq** seqpix = (CvSeq**)cvGetSeqElem(seq,i);
      int dimj = (*grpix)->total;
      for(int j=0;j<dimj;j++)
      {
        cv::Point pix = *(cv::Point*)cvGetSeqElem(*grpix,0);
        cvSeqRemove(*grpix,0);
        v = _src.at<float>(pix);
        _dst.at<int>(pix)=label[i];
        neighborhoodMat(pix.x,pix.y,w,h,nmat,4);
        for(int k=0;k<(int)nmat.size();k++)
        {
          nPix = pix + nmat[k];
          nv = _src.at<float>(nPix);
          dv = _dst.at<int>(nPix);
          if(dv==0 && nv>=v)
          {
            _dst.at<int>(nPix)=label[i];
            cvSeqPush(*seqpix,&nPix);
            cvSeqPush(*grpix,&nPix);
          }
        }
      }
      stop += (*grpix)->total;
    }
    if(!stop)
      break;
#ifdef WRITE_IMGS
    char imname[1000];
    sprintf_s(imname,"../../img/outputs/growingtest_%05d.png",cnt);
    imwrite(imname,_dst);
#endif
  }
  _dst.copyTo(dst);
}

void ImProcTools::findExtendedLocalMin(Mat& src, CvSeq* ptSeq, CvMemStorage* storage0, CvSeq* cntSeq, CvMemStorage* storage1, Mat mask)
{
  Mat _dst(src.size(),CV_32S), _src;
  cv::Point pix, nPix;
  int currentLabel=1, niter, singleMinCount;
  int h, w;
  float nv, v;
  int dv;
  bool iscontour=false;
  //int cnt=0;
  plateau newPt;
  vector<cv::Point> nmat;

  MemStorage storage2(cvCreateMemStorage());
  CvSeq* ptType = cvCreateSeq(0, sizeof(CvSeq), sizeof(plateau), storage2);
  MemStorage storage3(cvCreateMemStorage());
  CvSeq* grSeq = cvCreateSeq(0, sizeof(CvSeq), sizeof(CvSeq), storage3);

  h = src.rows;
  w = src.cols;
  src.copyTo(_src);
  _dst.setTo(0);
  _dst.setTo(-1,mask);

  for (int y = 0; y < h; ++y)
  {
    pix.y=y;
    for (int x = 0; x < w; ++x)
    {
      pix.x=x;

      dv = _dst.at<int>(pix);
      if(dv == 0)
      {
        neighborhoodMat(x,y,w,h,nmat,8);
        singleMinCount = 0;
        v = src.at<float>(pix);
        niter = 0;
        while(niter < (int)nmat.size())
        {
          nPix.x = pix.x + nmat[niter].x;
          nPix.y = pix.y + nmat[niter].y;
          niter++;
          nv = src.at<float>(nPix);
          if(v == nv)
          {
            niter=(int)nmat.size();
            // create new plateau:
            newPt.label = currentLabel;
            newPt.min = true;
            currentLabel++;
            CvSeq* ptpix = cvCreateSeq(0, sizeof(CvSeq), sizeof(cv::Point2i),storage0);
            CvSeq* grpix = cvCreateSeq(0, sizeof(CvSeq), sizeof(cv::Point2i),storage3);
            CvSeq* cntpix = cvCreateSeq(0, sizeof(CvSeq), sizeof(cv::Point2i),storage1);
            cvSeqPush(ptpix,&pix);
            cvSeqPush(ptpix,&nPix);
            cvSeqPush(grpix,&nPix);
            cvSeqPush(cntpix,&pix);

            while(grpix->total > 0)
            {
              for(int j=0;j<grpix->total;j++)
              {
                cv::Point pix1 = *(cv::Point*)cvGetSeqElem(grpix,0);
                cvSeqRemove(grpix,0);
                neighborhoodMat(pix1.x,pix1.y,w,h,nmat,8);
                v = src.at<float>(pix1);
                iscontour = false;
                for(int k=0;k<(int)nmat.size();k++)
                {
                  nPix = pix1 + nmat[k];
                  nv = src.at<float>(nPix);
                  dv = _dst.at<int>(nPix);
                  if(dv == 0 && nv == v)
                  {
                    _dst.at<int>(nPix)=newPt.label;
                    cvSeqPush(ptpix,&nPix);
                    cvSeqPush(grpix,&nPix);
                  }
                  else if(nv < v && newPt.min)
                    newPt.min = false;
                  if(nv != v)
                    iscontour = true;
                }
                if(iscontour)
                  cvSeqPush(cntpix,&pix1);
              }
            }

            if(newPt.min)
            {
              cvSeqPush(ptType,&newPt);
              cvSeqPush(ptSeq,&ptpix);
              cvSeqPush(grSeq,&grpix);
              cvSeqPush(cntSeq,&cntpix);

              // Write img to txt file
              //  FILE* im32S = new FILE();
              //  char imname[100];
              //sprintf_s(imname,"../../img/outputs/mintest_%05d.txt",cnt);
              //  cnt++;
              //  im32S = fopen(imname,"wt");
              //  for(int y=0;y<_dst.rows;y++)
              //  {
              //    for(int x=0;x<_dst.cols;x++)
              //    {
              //      int val = _dst.at<int>(y,x);
              //      if(val==newPt.label)
              //        fprintf(im32S,"%d, ",newPt.label);
              //      else
              //        fprintf(im32S,"%d, ",0);
              //    }
              //    fprintf(im32S," \n");
              //  }
              //  fclose(im32S);
            }
          }
          else if(v > nv)
          {
            singleMinCount++;
            if(singleMinCount == (int)nmat.size())
            {
              // Single minima found
              //newPt.label = currentLabel;
              //newPt.min = true;
              //_dst.at<int>(pix)=newPt.label;
              //currentLabel++;
              //CvSeq* ptpix = cvCreateSeq(0, sizeof(CvSeq), sizeof(cv::Point2i),storage1);
              //CvSeq* cntpix = cvCreateSeq(0, sizeof(CvSeq), sizeof(cv::Point2i),storage3);
              //cvSeqPush(ptpix,&pix);
              //cvSeqPush(cntpix,&pix);
              //cvSeqPush(ptType,&newPt);
              //cvSeqPush(ptSeq,&ptpix);
              //cvSeqPush(cntSeq,&cntpix);

              //  char imname[100];
              //  sprintf_s(imname,"../../img/outputs/mintest_%05d.png",cnt);
              //  imwrite(imname,_dst);
              //  cnt++;
            }
          }
        }
      }
    }
  }
}

void ImProcTools::neighborhoodMat(int x, int y, int w, int h,vector<cv::Point>& dst, int typeconn)
{
  cv::MemStorage storage(cvCreateMemStorage());
  CvSeq* ndirs = cvCreateSeq(0, sizeof(CvSeq), sizeof(cv::Point), storage);
  dst.clear();

  if(typeconn==8)
  {
    if(y!=0 && x!=w-1)
    {
      cv::Point p(1,-1);
      cvSeqPush(ndirs,&p);
    }
    if(x!=w-1 && y!=h-1)
    {
      cv::Point p(1,1);
      cvSeqPush(ndirs,&p);
    }
    if(y!=h-1 && x!=0)
    {
      cv::Point p(-1,1);
      cvSeqPush(ndirs,&p);
    }
    if(x!=0 && y!=0)
    {
      cv::Point p(-1,-1);
      cvSeqPush(ndirs,&p);
    }
    if(y!=0)
    {
      cv::Point p(0,-1);
      cvSeqPush(ndirs,&p);
    }
    if(x!=w-1)
    {
      cv::Point p(1,0);
      cvSeqPush(ndirs,&p);
    }
    if(y!=h-1)
    {
      cv::Point p(0,1);
      cvSeqPush(ndirs,&p);
    }
    if(x!=0)
    {
      cv::Point p(-1,0);
      cvSeqPush(ndirs,&p);
    }
    if(ndirs->total>0)
    {
      dst.resize(ndirs->total);
      cv::Seq<cv::Point> seq(ndirs);
      seq.copyTo(dst);
    }else{
      printf("Error: neighborhood array is empty!");
    }
  }

  if(typeconn==4)
  {
    if(y!=0)
    {
      cv::Point p(0,-1);
      cvSeqPush(ndirs,&p);
    }
    if(x!=w-1)
    {
      cv::Point p(1,0);
      cvSeqPush(ndirs,&p);
    }
    if(y!=h-1)
    {
      cv::Point p(0,1);
      cvSeqPush(ndirs,&p);
    }
    if(x!=0)
    {
      cv::Point p(-1,0);
      cvSeqPush(ndirs,&p);
    }
    if(ndirs->total>0)
    {
      dst.resize(ndirs->total);
      cv::Seq<cv::Point> seq(ndirs);
      seq.copyTo(dst);
    }else{
      printf("Error: neighborhood array is empty!");
    }
  }
}

bool ImProcTools::checkFocus(Mat& src,Mat& mask, ImProcPreferences* pref)
{
  if(pref->focusLimit==0)
  {
    return 0;
  }
  //convolute with laplacian kernel
  /*Mat kernel;
  Mat filteredI;
  cv::Point anchor;
  int kernel_size=3;
  kernel = Mat( kernel_size, kernel_size, CV_32F );
  kernel.at<float>(0,0)=0;
  kernel.at<float>(0,1)=1;
  kernel.at<float>(0,2)=0;
  kernel.at<float>(1,0)=1;
  kernel.at<float>(1,1)=-4;
  kernel.at<float>(1,2)=1;
  kernel.at<float>(2,0)=0;
  kernel.at<float>(2,1)=1;
  kernel.at<float>(2,2)=0;

  filter2D(src, filteredI, -1 , kernel, anchor, 0, BORDER_DEFAULT );
  imshow("filter check",filteredI);
  cvWaitKey(0);*/

  Mat laplI;
  Mat filteredI;
  int ddepth = CV_32F;
  int kernel_size=5;
  Laplacian( src, laplI, ddepth, kernel_size, 1, 0, BORDER_DEFAULT );
  /*double maxVal;
  double minVal;
  minMaxIdx(laplI, &minVal, &maxVal, 0);*/
  #ifdef _DEBUG
  Mat focusI;
  convertScaleAbs( laplI,focusI,255.0/3000.0);
  imshow("filter check",focusI);
  cvWaitKey(1);
  #endif
  filteredI=abs(laplI);

  MatND hist;
  int nbins = 256; // lets hold 256 levels
  int hsize[] = { nbins }; // just one dimension
  float range[] = { 0, 3000.0 };
  const float *ranges[] = { range };
  int chnls[] = {0};
  calcHist(&filteredI, 1, chnls, mask, hist,1,hsize,ranges);
  /*int nbins=256;
  int channels=0;
  int histSize=256;
  float ranges[] = {0, 256};
  const float* _ranges = ranges;*/
  //calcHist(&filteredI, 1, &channels, Mat(), hist, histSize, &nbins, &_ranges);
  int focus = histQuantile(hist, 0.999f);

  if(focus>pref->focusLimit)
  {
    return 0;
  }
  else
  {
    return 1;
  }
}

bool ImProcTools::checkUpSideDown(Mat& src,Mat& mask, ImProcPreferences* pref)
{
  //convolute with laplacian kernel
  Mat laplI;
  Mat filteredI;
  Mat erodedMask;
  int ddepth = CV_32F;
  int kernel_size=5;
  cv::Mat kernel(31,31,src.depth());
  erode(mask,erodedMask,kernel);

  #ifdef _DEBUG
  Mat usdI;
  src.copyTo(usdI,erodedMask);
  imshow("upsidedown check",usdI);
  cvWaitKey(1);
  #endif

  Laplacian( src, laplI, ddepth, kernel_size, 1, 0, BORDER_DEFAULT );
  double usdCheck=mean(abs(laplI),erodedMask).val[0];
  if(usdCheck>pref->upSideDownCheck)
  {
    return 0;
  }
  else
  {
    return 1;
  }
}
int ImProcTools::histQuantile(const Mat& hist, float quantile)
{   
    float cur_sum = 0;
    float total_sum = (float)sum(hist).val[0];
    float quantile_sum = total_sum*quantile;
    for(int j = 0; j < hist.size[0]; j++)
    {
        cur_sum += (float)hist.at<float>(j,0);
        if(cur_sum > quantile_sum)
        {
          return j;
        }
    }
    
    return hist.size[0] - 1;
}

void ImProcTools::findBiggestBlob(Mat& src,Mat& dst,vector<cv::Point>& contour,int blobColor)
{
  Mat _dst(src.size(),CV_8U);
  _dst.setTo(0);
  vector<vector<cv::Point>> contours;
  vector<Vec4i> hierarchy;
  int l=0, idx=0;
  findContours(src, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
  for(int i=0;i<(int)contours.size();i++)
  {
    if((int)contours[i].size()>l)
    {
      l = contours[i].size();
      idx = i;
    }
  }

  // Draw biggest blob:
  drawContours(_dst, contours,idx, Scalar(blobColor),CV_FILLED);
  contour=contours.at(idx);
  dst=_dst;
  //imshow("biggest Blob",maskI);
  //cvWaitKey(1);
}

void ImProcTools::imOpen(Mat& src,Mat& dst,int kernelSize, int iterations)
{
  src.copyTo(dst);
  Mat elem = getStructuringElement(MORPH_ELLIPSE,cvSize(kernelSize,kernelSize));
  for(int i=0;i<iterations;i++)
  {
    erode(dst,dst,elem);
  }
  for(int i=0;i<iterations;i++)
  {
    dilate(dst,dst,elem);
  }
}

void ImProcTools::imClose(Mat& src,Mat& dst,int kernelSize, int iterations)
{
  src.copyTo(dst);
  Mat elem = getStructuringElement(MORPH_ELLIPSE,cvSize(kernelSize,kernelSize));
  for(int i=0;i<iterations;i++)
  {
    dilate(dst,dst,elem);
  }
  for(int i=0;i<iterations;i++)
  {
    erode(dst,dst,elem);
  }
}

bool ImProcTools::checkReflections(Mat& I, Mat& mask, ImProcPreferences* pref)
{
  Mat tI;
  I.copyTo(tI,mask);
  #ifdef _DEBUG
  imshow("reflection check 1",tI);
  cvWaitKey(1);
  #endif
  threshold(tI,tI,cvRound(255.0*pref->thresholdReflectionCheck),255,CV_THRESH_BINARY);
  imOpen(tI,tI,pref->elSizeReflection,1);
  #ifdef _DEBUG
  imshow("reflection check 2",tI);
  cvWaitKey(1);
  #endif
  int reflectionArea=countNonZero(tI);
  if(reflectionArea>int(pref->maxReflectionArea*pref->scale))
  {
    return true;
  }
  else
  {
    return false;
  }
}

void ImProcTools::createThresholdMat(Mat& src, Mat& dst)
{
  dst=Mat(src.rows,src.cols,CV_32S);
  Mat temp;
  src.convertTo(temp, CV_32S);
  dst=temp-mean(temp);

  #ifdef _DEBUG
  imshow("threshold offset",dst);
  cvWaitKey(1);
  #endif
}