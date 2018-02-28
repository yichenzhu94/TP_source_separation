function F=newframe(ftype,varargin);
%NEWFRAME  Construct a new frame
%   Usage: F=newframe(ftype,...);
%
%   F=NEWFRAME(ftype,...) constructs a new frame object F of type
%   ftype. Arguments following ftype are specific to the type of frame
%   chosen.
%
%   NEWFRAME('dgt',ga,gs,a,M) constructs a Gabor frame with analysis
%   window ga, synthesis window gs, time-shift a and M channels. See
%   the help on DGT for more information.
%
%   NEWFRAME('dgtreal',ga,gs,a,M) constructs a Gabor frame for real-valued
%   signals with analysis window ga, synthesis window gs,time-shift a
%   and M channels. See the help on DGTREAL for more information.
%
%   NEWFRAME('dwilt',ga,gs,M) constructs a Wilson basis with analysis window
%   ga, synthesis window gs, and M channels. See the help on DWILT for more information.
%
%   NEWFRAME('wmdct',ga,gs,M) constructs a windowed MDCT basis with
%   analysis window ga, synthesis window gs, and M channels. See the
%   help on WMDCT for more information.
%
%   NEWFRAME('filterbank',ga,gs,a,M) constructs a filterbank with analysis
%   windows ga, synthesis windows gs, time-shifts of a and M
%   channels. For the ease of implementation, it is necessary to specify
%   M, even though it strictly speaking could be deduced from the size of
%   the windows. See the help on FILTERBANK for more information on the
%   parameters. Similarly, you can construct a uniform filterbank by
%   selecting 'ufilterbank', a positive-frequency filterbank by selecting
%   'filterbankreal' or a uniform positive-frequency filterbank by
%   selecting 'ufilterbankreal'.
%
%   NEWFRAME('gen',ga,gs) constructs an general frame with analysis
%   matrix ga and synthesis matrix gs. The frame atoms must be stored
%   as column vectors in the matrices.
%
%   NEWFRAME('dft') constructs a frame where the analysis operator is the
%   DFT, and the synthesis operator is its inverse, |idft|_. Completely
%   similar to this, you can enter the name of any of the cosine or sine
%   transforms DCTI, |dctii|_, |dctiii|_, |dctiv|_, |dsti|_, |dstii|_,
%   DSTIII or |dstiv|_, or the fft transform.
%
%   NEWFRAME('fftreal',L) constructs an FFT frame for real-valued
%   signals only, using FFTREAL. You must specify the signal length
%   L, otherwise the synthesis operation cannot work.
%
%   Dual and tight frames 
%   ---------------------
%
%   All the systems that makes it possible to specify the analysis and
%   synthesis frame uses the same simple mechanism for specifying canonical
%   dual and canonical tight frames: simply specify 'dual' if one frame
%   should be the dual of the other, or 'tight' if both are normalised
%   tight frames.
%
%   This is most easily explained through three examples. The following
%   creates a Gabor frame with a Gaussian analysis window and its
%   canonical dual frame as synthesis frame:
%
%     F=newframe('dgt','gauss','dual',10,20);
%
%   The following example creates a Wilson basis with a Gaussian
%   synthesis window, and its canonical dual frame as the analysis
%   frame:
% 
%     F=newframe('dwilt','dual','gauss',20);
%
%   The following example creates a tight Gabor frame for real-valued
%   signals only. The tight frame is used for both analysis and
%   synthesis, and it is computed from a Gaussian window:
%
%     F=newframe('dgtreal','gauss','tight',10,20);
%
%   Note that the word 'tight' must always appear instead of the synthesis
%   frame definition, so it appears after the window definition.
%
%   Examples
%   --------
%
%   The following example create a Gabor frame for real-valued signals,
%   analysis and input signal and plots the frame coefficients:
%
%      F=newframe('dgtreal','gauss','dual',20,294);
%      c=frana(F,greasy);
%      plotframe(F,c);
%
%   See also: frana, frsyn, plotframe
%
%   Url: http://ltfat.sourceforge.net/doc/frames/newframe.php

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

%EXAMPLEDEFINITION 81

% CUT: Window support is not yet good enough to automatically handle
% filterbanks.
% `newframe('ufilterbank',ga,gs,a)` constructs a uniform
% filterbank with analysis windows *ga*, synthesis windows *gs* and uniform
% time-shift *a*. See the help on |ufilterbank|_ for more information.


  
if nargin<1
  error('%s: Too few input parameters.',upper(mfilename));
end;

if ~ischar(ftype)
  error(['%s: First agument must be a string denoting the type of ' ...
         'frame.'],upper(mfilename));
end;

ftype=lower(ftype);

% Handle the windowed transforms
switch(ftype)
 case {'dgt','dgtreal','dwilt','wmdct','filterbank','ufilterbank'}
  F.ga=varargin{1};
  F.gs=varargin{2};
  
  if strcmp(F.ga,'dual')    
    F.ga={'dual',F.gs};
  end;
  
  if strcmp(F.gs,'dual')
    F.gs={'dual',F.ga};
  end;
  
  if strcmp(F.gs,'tight')
    F.gs={'tight',F.ga};
    F.ga={'tight',F.ga};
  end;  

 case {'filterbankreal','ufilterbankreal'}
  F.ga=varargin{1};
  F.gs=varargin{2};
  
  if strcmp(F.ga,'dual')    
    F.ga={'realdual',F.gs};
  end;
  
  if strcmp(F.gs,'dual')
    F.gs={'realdual',F.ga};
  end;
  
  if strcmp(F.gs,'tight')
    F.gs={'realtight',F.ga};
    F.ga={'realtight',F.ga};
  end;  

  
  
end;

switch(ftype)
 case {'dgt','dgtreal'}
  F.a=varargin{3};
  F.M=varargin{4};
 case {'dwilt','wmdct'}
  F.M=varargin{3};
 case {'filterbank','ufilterbank','filterbankreal','ufilterbankreal'}
  F.a=varargin{3};
  F.M=varargin{4};

  % Sanitize 'a': Make it a column vector of length M
  F.a=F.a(:);
  [F.a,~]=scalardistribute(F.a,ones(F.M,1));

 case 'gen'
  F.ga=varargin{1};
  F.gs=varargin{2};

  if strcmp(F.ga,'dual')
    F.ga=pinv(F.gs)';
  end;
  
  if strcmp(F.gs,'dual')
    F.gs=pinv(F.ga)';
  end;
  
  if strcmp(F.gs,'tight')
    [U,sv,V] = svd(F.ga,'econ');
    
    F.ga=U*V'; 
    F.gs=F.ga;
  end;
 case {'dft','fft',...
       'dcti','dctii','dctiii','dctiv',...
       'dsti','dstii','dstiii','dstiv'}
 case 'fftreal'
  F.L=varargin{1};
 otherwise
    error('%s: Unknows frame type: %s',upper(mfilename),ftype);  
end;

F.type=ftype;
