% LTFAT - Frames
%
%  Peter L. Soendergaard, 2012.
%
%  Basic methods
%    NEWFRAME          - Construct a new frame
%    FRANA             - Frame analysis
%    FRSYN             - Frame synthesis
%    FRANAADJ          - Frame analysis adjoint operator
%    FRSYNADJ          - Frame synthesis adjoint operator
%    PLOTFRAME         - Plot frame coefficients
%    FRAMEACCEL        - Precompute arrays for faster application
%
%  Information about a frame
%    FRAMETYPE         - Type of frame
%    FRAMEBOUNDS       - Frame bounds
%    FRAMERED          - Redundancy of frame
%    FRAMEMATRIX       - Frame transform matrix
%    FRAMELENGTHSIGNAL - Length of frame to expand signal
%    FRAMELENGTHCOEF   - Length of frame given a set of coefficients
%
%  Coefficients conversions
%    FRAMECOEF2NATIVE  - Convert to native transform format
%    FRAMENATIVE2COEF  - Convert native to column format
%    FRAMECOEF2TF      - Convert to time-frequency plane layout
%    FRAMETF2COEF      - Convert TF-plane layout to native
%
%  Advanced methods on frames
%    FRSYNABS          - Frame synthesis from magnitude of coefficients
%    FRSYNITER         - Iterative frame inversion
%    FRAMEMULEIGS      - Eigenpairs of a frame multiplier
%    FRAMELASSO        - LASSO threshholding using Landweber iterations.
%    FRAMEGROUPLASSO   - Group LASSO threshholding.
%
%  For help, bug reports, suggestions etc. please send email to
%
%   Url: http://ltfat.sourceforge.net/doc/frames/Contents.php

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
%  ltfat-help@lists.sourceforge.net
