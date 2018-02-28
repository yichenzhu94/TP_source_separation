function outsig=franaadj(F,insig);
%FRANAADJ  Adjoint frame transform operator
%   Usage: f=franaadj(F,c);
%
%   f=FRANAADJ(F,c) applies the adjoint operator of the frame transform
%   operator FRANA of F to the coefficients c. The frame object F
%   must have been created using NEWFRAME.
%
%   The adjoint operator is often used in iterative algorithms.
%
%   See also: newframe, frana, frsyn
%
%   Url: http://ltfat.sourceforge.net/doc/frames/franaadj.php

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
  outsig=F.ga*insig;  
 case 'dgt'
  outsig=idgt(framecoef2native(F,insig),F.ga,F.a);  
 case 'dgtreal'
  outsig=idgtreal(framecoef2native(F,insig),F.ga,F.a,F.M);  
 case 'dwilt'
  outsig=idwilt(framecoef2native(F,insig),F.ga);  
 case 'wmdct'
  outsig=iwmdct(framecoef2native(F,insig),F.ga);  
 
 case {'filterbank','ufilterbank'}
  outsig=ifilterbank(framecoef2native(F,insig),F.ga,F.a);   
 case {'filterbankreal','ufilterbankreal'}
  outsig=2*real(ifilterbank(framecoef2native(F,insig),F.ga,F.a));
 
 case {'dcti','dctiv','dsti','dstiv'}
  outsig=feval(F.type,insig);
  

 case 'dctii'
  outsig=dctiii(insig);
 case 'dctiii'
  outsig=dctii(insig);
 case 'dstii'
  outsig=dstiii(insig);
 case 'dstiii'
  outsig=dstii(insig);
 case 'dft'
  outsig=idft(insig);
 case 'fft'
  L=size(insig,1);
  outsig=ifft(insig)*L;
 case 'fftreal'
  outsig=ifftreal(insig,F.L)*F.L;
end;

  