function [tc,relres,iter,xrec] = gablasso(x,g,a,M,lambda,varargin)
%GABLASSO  LASSO regression in Gabor domain
%   Usage: [tc,xrec] = gablasso(x,a,M,lambda,C,tol,maxit)
%
%   GABLASSO has been deprecated. Please use FRAMELASSO instead.
%
%   A call to GABLASSO(x,g,a,M,lambda) can be replaced by :
%
%     F=newframe('dgt',[],g,a,M);
%     tc=framelasso(F,lambda);
%
%   Any additional parameters passed to GABLASSO can be passed to
%   FRAMELASSO in the same manner.
%
%   See also: newframe, framelasso
%
%   Url: http://ltfat.sourceforge.net/doc/deprecated/gablasso.php

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

warning(['LTFAT: GABLASSO has been deprecated, please use FRAMELASSO ' ...
         'instead. See the help on GABLASSO for more details.']);   

F=newframe('dgt',[],g,a,M);
[tc,relres,iter,xrec] = framelasso(F,lambda,varargin{:});
