function plotdgtreal(coef,a,M,varargin)
%PLOTDGTREAL  Plot DGTREAL coefficients
%   Usage: plotdgtreal(coef,a,M);
%          plotdgtreal(coef,a,M,fs);
%          plotdgtreal(coef,a,M,fs,dynrange);
%
%   PLOTDGTREAL(coef,a,M) plots Gabor coefficient from DGTREAL. The
%   parameters a and M must match those from the call to DGTREAL.
%
%   PLOTDGTREAL(coef,a,M,fs) does the same assuming a sampling rate of fs
%   Hz of the original signal.
%
%   PLOTDGTREAL(coef,a,M,fs,dynrange) additionally limits the dynamic
%   range.
%   
%   PLOTDGTREAL supports all the optional parameters of TFPLOT. Please
%   see the help of TFPLOT for an exhaustive list.
%
%   See also:  dgtreal, tfplot, sgram, plotdgt
%
%   Url: http://ltfat.sourceforge.net/doc/gabor/plotdgtreal.php

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

if nargin<3
  error('%s: Too few input parameters.',upper(mfilename));
end;

definput.import={'ltfattranslate','tfplot'};

[flags,kv,fs]=ltfatarghelper({'fs','dynrange'},definput,varargin);

if rem(M,2)==0
  yr=[0,1];
else
  yr=[0,1-2/M];
end;

tfplot(coef,a,yr,'argimport',flags,kv);
