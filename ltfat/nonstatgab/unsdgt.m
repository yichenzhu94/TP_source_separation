function [c,Ls] = unsdgt(f,g,a,M)
%UNSDGT  Uniform Nonstationary Discrete Gabor transform
%   Usage:  c=unsdgt(f,g,a,M);
%           [c,Ls]=unsdgt(f,g,a,M);
%
%   Input parameters:
%         f     : Input signal.
%         g     : Cell array of window functions.
%         a     : Vector of time positions of windows.
%         M     : Numbers of frequency channels.
%   Output parameters:
%         c     : Cell array of coefficients.
%         Ls    : Length of input signal.
%
%   UNSDGT(f,g,a,M) computes the uniform nonstationary Gabor coefficients
%   of the input signal f. The signal f can be a multichannel signal,
%   given in the form of a 2D matrix of size Ls x W, with Ls being
%   the signal length and W the number of signal channels.
%
%   The non-stationary Gabor theory extends standard Gabor theory by
%   enabling the evolution of the window over time. It is therefor necessary
%   to specify a set of windows instead of a single window.  This is done by
%   using a cell array for g. In this cell array, the n'th element g{n}
%   is a row vector specifying the n'th window. However, the uniformity
%   means that the number of channels is fixed.
%
%   The resulting coefficients is stored as a M x N x W
%   array. c(m,n,l) is thus the value of the coefficient for time index n,
%   frequency index m and signal channel l.
%
%   The variable a contains the distance in samples between two consequtive
%   blocks of coefficients. a is a vectors of integers. The variables g and
%   a must have the same length.
%   
%   The time positions of the coefficients blocks can be obtained by the
%   following code. A value of 0 correspond to the first sample of the
%   signal:
%
%     timepos = cumsum(a)-a(1);
%
%   [c,Ls]=nsdgt(f,g,a,M) additionally returns the length Ls of the input 
%   signal f. This is handy for reconstruction:
%
%     [c,Ls]=unsdgt(f,g,a,M);
%     fr=iunsdgt(c,gd,a,Ls);
%
%   will reconstruct the signal f no matter what the length of f is, 
%   provided that gd are dual windows of g.
%
%   Notes:
%   ------
%
%   UNSDGT uses circular border conditions, that is to say that the signal is
%   considered as periodic for windows overlapping the beginning or the 
%   end of the signal.
%
%   The phaselocking convention used in UNSDGT is different from the
%   convention used in the DGT function. UNSDGT results are phaselocked
%   (a phase reference moving with the window is used), whereas DGT results
%   are not phaselocked (a fixed phase reference corresponding to time 0 of
%   the signal is used). See the help on PHASELOCK for more details on
%   phaselocking conventions.
%
%   See also:  insdgt, nsgabdual, nsgabtight, phaselock
%
%   Demos:  demo_nsdgt
%
%   References:
%     F. Jaillet, M. Dörfler, and P. Balazs. LTFAT-note 10: Nonstationary
%     Gabor Frames. In Proceedings of SampTA, 2009.
%     
%
%   Url: http://ltfat.sourceforge.net/doc/nonstatgab/unsdgt.php

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
  
%   AUTHOR : Florent Jaillet
%   TESTING: TEST_NSDGT
%   REFERENCE: 

% Notes:
% - The variable names used in this function are intentionally similar to
%   the variable names used in dgt as nsdgt is a generalization of dgt.
% - The choice of a different phaselocking convention than the one used in
%   dgt is motivated by the will to keep a diagonal frame operator in the
%   painless case and to keep the circular border condition. With the other
%   convention, there is in general a problem for windows overlapping the
%   beginning and the end of the signal (except if time positions and
%   signal length have some special ratio properties).

% todo: 
% - It would be good to check the validity of the inputs. Some things to
%   check: g,a,M must have the same length, each cell of g must be a
%   vector, values of a and M must be intergers,...


timepos=cumsum(a)-a(1);
  
Ls=length(f);

N=length(a); % Number of time positions

W=size(f,2); % Number of signal channels


c=zeros(M,N,W); % Initialisation of the result

for ii=1:N
  shift=floor(length(g{ii})/2);
  temp=zeros(M,W);
  
  % Windowing of the signal.
  % Possible improvements: The following could be computed faster by 
  % explicitely computing the indexes instead of using modulo and the 
  % repmat is not needed if the number of signal channels W=1 (but the time 
  % difference when removing it whould be really small)
  temp(1:length(g{ii}))=f(mod((1:length(g{ii}))+timepos(ii)-shift-1,Ls)+1,:).*...
    repmat(conj(circshift(g{ii},shift)),1,W);
  
  temp=circshift(temp,-shift);
  if M<length(g{ii}) 
    % Fft size is smaller than window length, some aliasing is needed
    x=floor(length(g{ii})/M);
    y=length(g{ii})-x*M;
    % Possible improvements: the following could probably be computed 
    % faster using matrix manipulation (reshape, sum...)
    temp1=temp;
    temp=zeros(M,size(temp,2));
    for jj=0:x-1
      temp=temp+temp1(jj*M+(1:M),:);
    end
    temp(1:y,:)=temp(1:y,:)+temp1(x*M+(1:y),:);
  end
  
  % FFT of the windowed signal
  c(:,ii,:) = reshape(fft(temp),M,1,W); 
end
