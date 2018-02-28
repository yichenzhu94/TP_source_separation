function gd=nsgabdual(g,a,M,varargin)
%NSGABDUAL  Canonical dual window for non-stationary Gabor frames
%   Usage:  gd=nsgabdual(g,a,L)
%
%   Input parameters:
%         g     : Cell array of windows.
%         a     : Vector of time shift.
%         M     : Vector of numbers of channels.
%         L     : Transform length.
%   Output parameters:
%         gd : Cell array of canonical dual windows
%
%   NSGABDUAL(g,a,M,L) computes the canonical dual windows of the 
%   non-stationary discrete Gabor frame defined by windows given in g an
%   time-shifts given by a.
%   
%   NSGABDUAL is designed to be used with the functions NSDGT and
%   INSDGT.  See the help on |nsdgt|_ for more details about the variables
%   structure.
%
%   The computed dual windows are only valid for the 'painless case', that
%   is to say that they ensure perfect reconstruction only if for each 
%   window the number of frequency channels used for computation of NSDGT is
%   greater than or equal to the window length. This correspond to cases
%   for which the frame operator is diagonal.
%
%   See also:  nsgabtight, nsdgt, insdgt
%
%   References:
%     F. Jaillet, M. Dörfler, and P. Balazs. LTFAT-note 10: Nonstationary
%     Gabor Frames. In Proceedings of SampTA, 2009.
%     
%
%   Url: http://ltfat.sourceforge.net/doc/nonstatgab/nsgabdual.php

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

if nargin<3
  error('%s: Too few input parameters.',upper(mfilename));
end;

definput.keyvals.L=sum(a);
[flags,kv,L]=ltfatarghelper({'L'},definput,varargin);

timepos=cumsum(a)-a(1);

N=length(a); % Number of time positions
f=zeros(L,1); % Diagonal of the frame operator

% Compute the diagonal of the frame operator:
% sum up in time (overlap-add) all the contributions of the windows as if 
% we where using windows in g as analysis and synthesis windows
for ii=1:N
  shift=floor(length(g{ii})/2);
  temp=abs(circshift(g{ii},shift)).^2*length(g{ii});
  tempind=mod((1:length(g{ii}))+timepos(ii)-shift-1,L)+1;
  f(tempind)=f(tempind)+temp;
end

% Initialize the result with g
gd=g;

% Correct each window to ensure perfect reconstrution
for ii=1:N
  shift=floor(length(g{ii})/2);
  tempind=mod((1:length(g{ii}))+timepos(ii)-shift-1,L)+1;
  gd{ii}(:)=circshift(circshift(g{ii},shift)./f(tempind),-shift);
end
