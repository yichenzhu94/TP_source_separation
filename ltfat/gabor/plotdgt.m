function plotdgt(coef,a,varargin)
%PLOTDGT  Plot DGT coefficients
%   Usage: plotdgt(coef,a);
%          plotdgt(coef,a,fs);
%          plotdgt(coef,a,fs,dynrange);
%
%   PLOTDGT(coef,a) plots the Gabor coefficients coef. The coefficients
%   must have been produced with a timeshift of a.
%
%   PLOTDGT(coef,a,fs) does the same assuming a sampling rate of
%   fs Hz of the original signal.
%
%   PLOTDGT(coef,a,fs,dynrange) additionally limits the dynamic range.
%   
%   PLOTDGT supports all the optional parameters of TFPLOT. Please see
%   the help of TFPLOT for an exhaustive list.
%
%   See also:  dgt, tfplot, sgram, plotdgtreal
%
%   Url: http://ltfat.sourceforge.net/doc/gabor/plotdgt.php

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

%   AUTHOR : Peter Soendergaard.
%   TESTING: NA
%   REFERENCE: NA

if nargin<2
  error('%s: Too few input parameters.',upper(mfilename));
end;

definput.import={'ltfattranslate','tfplot'};

[flags,kv,fs]=ltfatarghelper({'fs','dynrange'},definput,varargin);

M=size(coef,1);

% Move zero frequency to the center and Nyquest frequency to the top.
if rem(M,2)==0
  coef=circshift(coef,M/2-1);
  yr=[-1+2/M, 1];
else
  coef=circshift(coef,(M-1)/2);
  yr=[-1+2/M, 1-2/M];
end;

tfplot(coef,a,yr,'argimport',flags,kv);

