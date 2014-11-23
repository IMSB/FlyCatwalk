%
% b_spline_smooth.dll 
%
% Woltring's B-spline Algorithm in MATLAB
% =======================================
%
%Purpose:
%*******
%
%      Natural B-spline data smoothing subroutine, using the Generali-
%      zed Cross-Validation and Mean-Squared Prediction Error Criteria
%      of Craven & Wahba (1979). The model assumes uncorrelated, additive 
%      noise and essentially smooth, underlying functions. The noise may be
%      non-stationary, and the independent co-ordinates may be spaced
%      non-equidistantly. 
%
%
%MATLAB Calling convention:
%**************************
%
%  1.)  [ smooth_data, var_est ] =  
%
%       b_spline_smooth( x, y, x_new, w, half_order, deriv_order ) 
%
%  or
% 
%
%  2.)  [ smooth_data ] =  
%
%       b_spline_smooth( x, y, x_new, w, half_order, deriv_order, var )
%     
%
%Notes:
%%%%%%%
%
% If calling option 1 is used then it is assumed that the error variance is a
% priori unknown, the smoothing parameter is then determined by minimizing 
% the Generalized Cross-Validation function and an estimate of th error 
% variance is returned. 
%
% If the error variance is included as an input argument (var >= 0) then the
% smoothing parameter is determined so as to minimize the true mean squared 
% error which depends on var. 
% 
%
%Meaning of parameters: 
%*********************
%
%  Inputs:
% 
%       x               (Nx1 double array) Independent variables
%
%		y               (Nx1 double array) Data to smooth and interpolate
%
%		x_new           (Mx1 double array) "new" independent varibales or interpoloation 
%				        points. x(0) <= x_new(i) <= x(N) for all i =1,...,M. 
%
%		w               (Nx1 double array) Weight factors, where each w(i) corresponds
%			            with the relative inverse variance of point y(i). If no relative 
%			            weighting information is available the w(i) should be set to 1. 
%			            Note the w(i) must be > 0. 
%
%		half_order      (1x1 double) half order of the required B-spline. Must be 
%					    greater than zero and less than or equal to number of data 
%					    points. The values 1, 2, 3, 4 correspond to linear, cubic, 
%					    quintic, and heptic slpines respectively. Spline degree = 
%				        2%half_order - 1.
%					  
%
%		deriv_order     (1x1 double) the order of the desired derivative. This must 
%					    be greater than 0 and less than or equal to 2*half_order. 
%
%
%		var             (1x1 double) Error Variance. 
%
%
%  Outputs:
%
%       smooth_data     (Mx1 double array) Smoothed data corresponding to the 
%                       (deriv_order)-th derivative of y. 
%
%
%       var_est         (1x1 double) Estimate of error variance.       
%
% 
%
%Remarks:
%%%%%%%%
%
%      The function calculates a natural spline of order 2*half_order 
%      (degree 2*half_oder-1) which smoothes or interpolates a given set 
%      of data points, using statistical considerations to determine the
%      amount of smoothing required (Craven & Wahba, 1979). If the
%      error variance is a priori known, it should be supplied to
%      the routine in var (call option 2). The degree of smoothing is then 
%      determined to minimize an unbiased estimate of the true mean squared 
%      error. On the other hand, if the error variance is not known 
%      (call option 1). The routine then determines the degree of smoothing 
%      to minimize the generalized cross validation function. This is 
%      asymptotically the same as minimizing the true predicted mean squared 
%      error (Craven & Wahba, 1979). If the estimates from call option 1 do 
%      not appear suitable to the user (as apparent from the smoothness of the
%      M-th derivative, the user may use call option 2 and select a value for 
%      the noise variance var.  
%
%      The number of arithmetic operations and the amount of storage required 
%      are both proportional to N, so very large datasets may be accomodated. 
%      The data points do not have to be equidistant in the independant variable 
%      X or uniformly weighted in the dependant variable Y. However, the data
%      points in X must be strictly increasing. 
%
%
%References:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%      P. Craven & G. Wahba (1979), Smoothing noisy data with
%      spline functions. Numerische Mathematik 31, 377-403.
%
%      A.M. Erisman & W.F. Tinney (1975), On computing certain
%      elements of the inverse of a sparse matrix. Communications
%      of the ACM 18(3), 177-179.
%
%      M.F. Hutchinson & F.R. de Hoog (1985), Smoothing noisy data
%      with spline functions. Numerische Mathematik 47(1), 99-106.
%
%      M.F. Hutchinson (1985), Subroutine CUBGCV. CSIRO Division of
%      Mathematics and Statistics, P.O. Box 1965, Canberra, ACT 2601,
%      Australia.
%
%      T. Lyche, L.L. Schumaker, & K. Sepehrnoori (1983), Fortran
%      subroutines for computing smoothing and interpolating natural
%      splines. Advances in Engineering Software 5(1), 2-5.
%
%      F. Utreras (1980), Un paquete de programas para ajustar curvas
%      mediante funciones spline. Informe Tecnico MA-80-B-209, Depar-
%      tamento de Matematicas, Faculdad de Ciencias Fisicas y Matema-
%      ticas, Universidad de Chile, Santiago.
%
%      Wahba, G. (1980). Numerical and statistical methods for mildly,
%      moderately and severely ill-posed problems with noisy data.
%      Technical report nr. 595 (February 1980). Department of Statis-
%      tics, University of Madison (WI), U.S.A.