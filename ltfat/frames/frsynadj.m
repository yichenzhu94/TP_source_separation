function outsig=frsynadj(F,insig);
%FRSYNADJ  Adjoint synthesis operator
%   Usage: c=frsynadj(F,f);
%
%   c=FRSYNADJ(F,f) computes the frame coefficients c of the input
%   signal f using the frame F. The frame object F must have been
%   created using NEWFRAME.
%
%   If f is a matrix, the transform will be applied along the columns
%   of f. If f is an N-D array, the transform will be applied along
%   the first non-singleton dimension.
%
%   The output coefficients are stored as columns. This is usually
%   *not* the same format as the 'native' format of the frame. As an
%   examples, the output from FRSYNADJ for a gabor frame cannot be
%   passed to IDGT without a reshape.
%
%   See also: newframe, frsyn, plotframe
%
%   Url: http://ltfat.sourceforge.net/doc/frames/frsynadj.php

% Copyright (C) 2005-2012 Peter L. Soendergaard.
% This file is part of LTFAT version 1.1.0
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
if nargin<2
  error('%s: Too few input parameters.',upper(mfilename));
end;

if ~isstruct(F)
  error('%s: First agument must be a frame definition structure.',upper(mfilename));
end;

switch(F.type)
 case 'gen'
  outsig=F.gs'*insig; 
 case 'dgt'
  outsig=framenative2coef(F,dgt(insig,F.gs,F.a,F.M));
 case 'dgtreal'
  outsig=framenative2coef(F,dgtreal(insig,F.gs,F.a,F.M));
 case 'dwilt'
  outsig=framenative2coef(F,dwilt(insig,F.gs,F.M));
 case 'wmdct'
  outsig=framenative2coef(F,wmdct(insig,F.gs,F.M));
  
 case 'filterbank'
  outsig=framenative2coef(F,filterbank(insig,F.gs,F.a));
 case 'filterbankreal'
  outsig=framenative2coef(F,filterbank(insig,F.gs,F.a));
 case 'ufilterbank'
  outsig=framenative2coef(F,ufilterbank(insig,F.gs,F.a));
 case 'ufilterbankreal'
  outsig=framenative2coef(F,ufilterbank(insig,F.gs,F.a));
 
 case {'dft',...
       'dcti','dctii','dctiii','dctiv',...
       'dsti','dstii','dstiii','dstiv'}
  outsig=feval(F.type,insig);
 case 'fft'
  L=size(insig,1);
  outsig=fft(insig)/L;
 case 'fftreal'
  outsig=fftreal(insig,F.L)/F.L;  
end;

  