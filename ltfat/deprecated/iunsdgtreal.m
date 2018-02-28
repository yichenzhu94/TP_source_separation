function f=iunsdgtreal(c,g,a,M,Ls)
%IUNSDGTREAL  Inverse uniform nonstationary discrete Gabor transform
%   Usage:  f=iunsdgtreal(c,g,a,M,Ls);
%
%   Input parameters:
%         c     : Cell array of coefficients.
%         g     : Cell array of window functions.
%         a     : Vector of time positions of windows.
%         M     : Numbers of frequency channels.
%         Ls    : Length of input signal.
%   Output parameters:
%         f     : Signal.
%
%   IUNSDGTREAL(c,g,a,M,Ls) computes the inverse uniform nonstationary Gabor
%   expansion of the input coefficients c.
%
%   IUNSDGTREAL is used to invert the function UNSDGTREAL. Read the help of
%   UNSDGTREAL for details of variables format and usage.
%
%   For perfect reconstruction, the windows used must be dual windows of 
%   the ones used to generate the coefficients. The windows can be
%   generated unsing NSGABDUAL.
%
%   See also:  unsdgt, nsgabdual, nsgabtight
%
%   Demos:  demo_nsdgt
%
%   References:
%     F. Jaillet, M. Dörfler, and P. Balazs. LTFAT-note 10: Nonstationary
%     Gabor Frames. In Proceedings of SampTA, 2009.
%     
%
%   Url: http://ltfat.sourceforge.net/doc/deprecated/iunsdgtreal.php

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

%   AUTHOR : Florent Jaillet and Peter L. Soendergaard
%   TESTING: TEST_NSDGT
%   REFERENCE: OK


warning(['LTFAT: IUNSDGTREAL has been deprecated, use INSDGTREAL instead.']);
  
f=insdgtreal(varargin{:});
