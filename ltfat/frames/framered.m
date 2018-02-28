function red=framered(F);
%FRAMERED  Redundancy of a frame
%   Usage  red=framered(F);
%
%   FRAMERED(F) computes the redundancy of a given frame F. If the
%   redundancy is larger than 1 (one), the frame transform will produce more
%   coefficients than it consumes. If the redundancy is exactly 1 (one),
%   the frame is a basis.
%
%   Examples:
%   ---------
%
%   The following simple example shows how to obtain the redundancy of a
%   Gabor frame:
%
%     F=newframe('dgt','gauss','dual',30,40);
%     framered(F)
%
%   The redundancy of a basis is always one:
%
%     F=newframe('wmdct','gauss','dual',40);
%     framered(F)
%
%   See also: newframe, frana, framebounds
%
%   Url: http://ltfat.sourceforge.net/doc/frames/framered.php

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

%EXAMPLEDEFINITION 13
%EXAMPLEDEFINITION 18

% Default value: works for all the bases.
red=1;

switch(F.type)
 case 'gen'
  red=size(F.ga,2)/size(F.ga,1);
 case 'dgt'
  red=F.M/F.a;
 case 'dgtreal'
  red=F.M/F.a;
 case {'ufilterbank','filterbank'}
  red=sum(1./F.a);
 case {'ufilterbankreal','filterbankreal'}
  red=2*sum(1./F.a);
end;

  