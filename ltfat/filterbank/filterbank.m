function c=filterbank(f,g,a,varargin);  
%FILTERBANK   Apply filterbank
%   Usage:  c=filterbank(f,g,a);
%
%   FILTERBANK(f,g,a) applies the filters given in g to the signal
%   f. Each subband will be subsampled by a factor of a (the
%   hop-size). In contrast to UFILTERBANK, a can be a vector so the
%   hop-size can be channel-dependant. If f is a matrix, the
%   transformation is applied to each column.
%
%   The filters g must be a cell-array, where each entry in the cell
%   array corresponds to an FIR filter.
%
%   The output coefficients are stored a cell array. More precisely, the
%   n'th cell of c, c{m}, is a 2D matrix of size M(n) x W and
%   containing the output from the m'th channel subsampled at a rate of
%   a(m).  c{m}(n,l) is thus the value of the coefficient for time index
%   n, frequency index m and signal channel l.
%
%   References:
%     H. Bölcskei, F. Hlawatsch, and H. G. Feichtinger. Frame-theoretic
%     analysis of oversampled filter banks. Signal Processing, IEEE
%     Transactions on, 46(12):3256-3268, 2002.
%
%   Url: http://ltfat.sourceforge.net/doc/filterbank/filterbank.php

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
    
if nargin<3
  error('%s: Too few input parameters.',upper(mfilename));
end;

definput.keyvals.L=[];
[flags,kv,L]=ltfatarghelper({'L'},definput,varargin);

[f,Ls,W,wasrow,remembershape]=comp_sigreshape_pre(f,'FILTERBANK',0);

mustbeuniform=0;
  
if ~isnumeric(a)
  error('%s: a must be numeric.',upper(callfun));
end;
  
if isempty(L)
  L=filterbanklengthsignal(Ls,a);
end;

[g,info]=filterbankwin(g,a,L,'normal');
M=info.M;

if length(a)>1 
  if  length(a)~=M
    error(['%s: The number of entries in "a" must match the number of ' ...
           'filters.'],upper(callfun));
  end;
else
  a=a*ones(M,1);
end;

N=L./a;

c=cell(M,1);
for m=1:M
  c{m}=zeros(N(m),W);
end;
  
G=zeros(L,M);
for ii=1:M
  G(:,ii)=fft(fir2long(g{ii},L));
end;

for w=1:W
  F=fft(postpad(f(:,w),L));
  for m=1:M
    c{m}(:,w)=ifft(sum(reshape(F.*G(:,m),N(m),a(m)),2))/a(m);
  end;
end;
