function [AF,BF]=framebounds(F,varargin);
%FRAMEBOUNDS  Frame bounds
%   Usage: fcond=framebounds(F);
%          [A,B]=framebounds(F);
%
%   FRAMEBOUNDS(F) calculates the ratio B/A of the frame bounds
%   of the frame given by F.
%
%   FRAMEBOUNDS(F,L) additionally specifies the length of the
%   transform. This is necessary for the 'fft' frame.
%
%   [A,B]=FRAMEBOUNDS(F) returns the frame bounds A and B instead of
%   just their ratio.
%
%   FRAMEBOUNDS(F,'s') returns the framebounds of the synthesis frame
%   instead of those of the analysis frame.
%
%   See also: newframe, framered
%
%   Url: http://ltfat.sourceforge.net/doc/frames/framebounds.php

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

definput.keyvals.L=[];
definput.flags.system={'a','s'};
[flags,kv,L]=ltfatarghelper({'L'},definput,varargin);
 
% Default values, works for the pure frequency transforms.
AF=1;
BF=1;

if isfield(F,'ga')
  if flags.do_a
    g=F.ga;
  else
    g=F.gs;
  end;
end;

switch(F.type)
 case 'gen'
  V=svd(g);
  AF=min(V)^2;
  BF=max(V)^2;
 case {'dgt','dgtreal'}
  [AF,BF]=gabframebounds(g,F.a,F.M); 
 case {'dwilt','wmdct'}
  [AF,BF]=wilbounds(g,F.M); 
 case {'filterbank','ufilterbank'}
  [AF,BF]=filterbankbounds(g,F.a);
 case {'filterbankreal','ufilterbankreal'}
  [AF,BF]=filterbankrealbounds(g,F.a); 
 case 'fft'
  AF=L;
  BF=L;
 case 'fftreal'
  AF=F.L;
  BF=F.L;  
end;

if nargout<2
  % Avoid the potential warning about division by zero.
  if AF==0
    AF=Inf;
  else
    AF=BF/AF;
  end;
end;


  