function gtout=filterbanktight(g,a,varargin);
%FILTERBANKTIGHT  Tight filters
%   Usage:  gt=filterbanktight(g,a);
%
%   filterabanktight(g,a) computes the canonical tight filters of g for a
%   channel subsampling rate of a (hop-size).
%
%   The input and output format of the filters g are described in the
%   help of FILTERBANK.
%
%   filterabanktight(g,a,L) computes canonical tight filters for a system
%   of length L. If L is not specified, the shortest possible transform
%   length is choosen.
%
%   See also: filterbank, filterbankdual, ufilterbank, ifilterbank
%
%   Url: http://ltfat.sourceforge.net/doc/filterbank/filterbanktight.php

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

[a,M,longestfilter,lcm_a]=assert_filterbankinput(g,a);

definput.keyvals.L=[];
[flags,kv,L]=ltfatarghelper({'L'},definput,varargin);

if isempty(L)
  L=ceil(longestfilter/lcm_a)*lcm_a;
end;

if all(a==a(1))
  % Uniform filterbank, use polyphase representation
  a=a(1);
  
  G=zeros(L,M);
  for ii=1:M
    G(:,ii)=fft(fir2long(g{ii},L));
  end;
  
  N=L/a;
  
  H=zeros(a,M);
  gt=zeros(N,M);
  
  for w=0:N-1
    idx = mod(w-(0:a-1)*N,L)+1;
    H = G(idx,:);
    
    [U,S,V]=svd(H,'econ');
    H=U*V';  
    
    gt(idx,:)=H;
  end;
  
  gt=ifft(gt)*sqrt(a);  

  if isreal(g)
    gt=real(gt);
  end;
  
  gtout=cell(1,M);
  for m=1:M
    gtout{m}=gt(:,m);
  end;
  
else

  error('Not implemented yet.');  
  
end;
