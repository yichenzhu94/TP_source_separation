function G=framematrix(F,L);
%FRAMEMATRIX  Frame matrix
%   Usage: G=framematrix(F,L);
%
%   G=FRAMEMATRIX(F,L) returns the matrix representation G of the frame
%   analysis operator for a frame F of length L. The frame object F
%   must have been created using NEWFRAME.
%
%   The frame matrix contains all the frame atoms as column vectors. It has
%   dimensions L x Ncoef, where Ncoef is the number of
%   coefficients. The number of coefficients can be found as
%   Ncoef=framered(F)*L. This means than the frame matrix is usually
%   *very* large, and this routine should only be used for small values
%   of L.
%
%   The action of the frame transform operator FRANA is equal to
%   multiplication with the Hermitean transpose of the frame
%   matrix. Consider the following simple example:
%
%     L=200;
%     F=newframe('dgt','gauss','dual',10,20);
%     G=framematrix(F,L);
%     testsig = randn(L,1);
%     res = frana(F,testsig)-G'*testsig;
%     norm(res)
%
%   See also: newframe, frana, frsyn, franaadj
%
%   Url: http://ltfat.sourceforge.net/doc/frames/framematrix.php

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

%EXAMPLEDEFINITION 17

if nargin<2
  error('%s: Too few input parameters.',upper(mfilename));
end;

switch(F.type)
 case {'dgtreal','fftreal'}
  error('%s: The analysis operator of this frame does not have a matrix representation.',upper(mfilename));
 otherwise
  
  Lcheck=framelengthsignal(F,L);
  if Lcheck~=L
    error('%s: Incompatible frame length.',upper(mfilename));
  end;
  
  % Generic code handles all frames where there are no extra coefficients
  % in the representation
  Ncoef=framered(F)*L;
  coef=eye(Ncoef);
  G = franaadj(F,coef);  
end;

