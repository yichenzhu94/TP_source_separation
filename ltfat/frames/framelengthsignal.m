function L=framelengthsignal(F,Ls);
%FRAMELENGTHSIGNAL  Frame length from signal
%   Usage: L=framelengthsignal(F,Ls);
%
%   FRAMELENGTHSIGNAL(F,Ls) returns the length of the frame F, such that
%   F is long enough to expand a signal of length Ls.
%
%   If the frame length is longer than the signal length, the signal will be
%   zero-padded by FRANA.
%
%   If instead a set of coefficients are given, call FRAMELENGTHCOEF.
%
%   See also: newframe, framelengthcoef
%
%   Url: http://ltfat.sourceforge.net/doc/frames/framelengthsignal.php

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
  
% Default value, the frame works for all input lengths
L=Ls;
  
switch(F.type)
 case {'dgt','dgtreal'}
  L = longpar('dgt',Ls,F.a,F.M);
 case {'dwilt','wmdct'}
  L = longpar('dwilt',Ls,F.M);
 case {'gen'}
  L = size(F.ga,1);
 case {'filterbank','ufilterbank','filterbankreal','ufilterbankreal'}
  L = filterbanklengthsignal(Ls,F.a);
end;