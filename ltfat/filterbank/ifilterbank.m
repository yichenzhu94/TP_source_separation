function f=ifilterbank(c,g,a,varargin);  
%IFILTERBANK  Filter bank inversion
%   Usage:  f=ifilterbank(c,g,a);
%
%   IFILTERBANK(c,g,a) synthesizes a signal f from the coefficients c
%   using the filters stored in g for a channel subsampling rate of a (the
%   hop-size). The coefficients has to be in the format returned by
%   either FILTERBANK or |ufilterbank|_.
%
%   The filter format for g is the same as for FILTERBANK.
%
%   If perfect reconstruction is desired, the filters must be the duals
%   of the filters used to generate the coefficients. See the help on
%   FILTERBANKDUAL.
%
%   See also: filterbank, ufilterbank, filterbankdual
%
%   References:
%     H. Bölcskei, F. Hlawatsch, and H. G. Feichtinger. Frame-theoretic
%     analysis of oversampled filter banks. Signal Processing, IEEE
%     Transactions on, 46(12):3256-3268, 2002.
%
%   Url: http://ltfat.sourceforge.net/doc/filterbank/ifilterbank.php

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

definput.keyvals.Ls=[];
[flags,kv,Ls]=ltfatarghelper({'Ls'},definput,varargin);

if ~isnumeric(a)
  error('%s: a must be numeric.',upper(callfun));
end;

if iscell(c)
  Mcoef=numel(c);
else
  Mcoef=size(c,2);
  W=size(c,3);    
end;

mustbeuniform=isnumeric(c);

L=filterbanklengthcoef(c,a);

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


if ~(size(c,2)==Mcoef)
  error(['Mismatch between the size of the input coefficients and the ' ...
         'number of filters.']);
end;

if iscell(c)
  error('Not implemented yet.');
else
 
  a=a(1);
  
  G=zeros(L,M);
  for ii=1:M
    G(:,ii)=fft(fir2long(g{ii},L));
  end;
    
  f=zeros(L,W);
  for w=1:W
    for m=1:M
      f(:,w)=f(:,w)+ifft(repmat(fft(c(:,m,w)),a,1).*conj(G(:,m)));
    end;
  end;
  
end;
  
% Cut or extend f to the correct length, if desired.
if ~isempty(Ls)
  f=postpad(f,Ls);
else
  Ls=L;
end;
