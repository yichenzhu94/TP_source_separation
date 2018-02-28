function [AF,BF]=filterbankbounds(g,a,varargin);
%FILTERBANKBOUNDS  Frame bounds of filter bank
%   Usage: fcond=filterbankbounds(g,a);
%          [A,B]=filterbankbounds(g,a);
%
%   FILTERBANKBOUNDS(g,a) calculates the ratio B/A of the frame bounds of
%   the filterbank specified by g and a. The ratio is a measure of the
%   stability of the system.
%
%   [A,B]=FILTERBANKBOUNDS(g,a) returns the lower and upper frame bounds
%   explicitly.
%
%   See also: filterbank, filterbankdual
%
%   Url: http://ltfat.sourceforge.net/doc/filterbank/filterbankbounds.php

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

AF=Inf;
BF=0;

if all(a==a(1))
  % Uniform filterbank, use polyphase representation
  a=a(1);  

  N=L/a;
  
  G=zeros(L,M);
  for ii=1:M
    G(:,ii)=fft(fir2long(g{ii},L));
  end;
  
  H=zeros(a,M);
    
  for w=0:N-1
    idx = mod(w-(0:a-1)*N,L)+1;
    H = G(idx,:);
    
    % A 'real' is needed here, because the matrices are known to be
    % Hermitian, but sometimes Matlab/Octave does not recognize this.
    work=real(eig(H*H'));
    AF=min(AF,min(work));
    BF=max(BF,max(work));
    
  end;
  
  AF=AF/a;
  BF=BF/a;

else

  error('Not implemented yet.');
  
end;
  
if nargout<2
    % Avoid the potential warning about division by zero.
    if AF==0
    AF=Inf;
  else
    AF=BF/AF;
  end;
end;

