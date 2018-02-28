function [tc,relres,iter,xrec] = framegrouplasso(F,x,lambda,varargin)
%FRAMEGROUPLASSO  Group LASSO regression in the TF-domain
%   Usage: [tc,xrec] = framegrouplasso(F,x,group,lambda,C,maxit,tol)
%
%   Input parameters:
%       F        : Frame definition
%       x        : Input signal
%       lambda   : Regularization parameter, controls sparsity of the
%                  solution
%   Output parameters:
%      tc        : Thresholded coefficients
%      relres    : Vector of residuals.
%      iter      : Number of iterations done.
%      xrec      : Reconstructed signal
%
%   FRAMEGROUPLASSO(F,x) solves the group LASSO regression problem in
%   the time-frequency domain: minimize a functional of the synthesis coefficients
%   defined as the sum of half the l^2 norm of the approximation error and
%   the mixed l^1 / l^2 norm of the coefficient sequence, with a penalization
%   coefficient lambda.
%  
%   The matrix of time-frequency coefficients is labelled in terms of groups
%   and members.  By default, the obtained expansion is sparse in terms of
%   groups, no sparsity being imposed to the members of a given group. This
%   is achieved by a regularization term composed of l^2 norm within a
%   group, and l^1 norm with respect to groups. See the help on
%   GROUPTHRESH for more information.
%
%   [tc,relres,iter] = FRAMEGROUPLASSO(...) returns the residuals relres in
%   a vector and the number of iteration steps done, maxit.
%
%   [tc,relres,iter,xrec] = FRAMEGROUPLASSO(...) returns the reconstructed
%   signal from the coefficients, xrec. Note that this requires additional
%   computations.
%
%   The function takes the following optional parameters at the end of
%   the line of input arguments:
%
%     'freq'     Group in frequency (search for tonal components). This is the
%                default.
%
%     'time'     Group in time (search for transient components). 
%
%     'C',cval   Landweber iteration parameter: must be larger than
%                square of upper frame bound. Default value is the upper
%                frame bound.
%
%     'maxit',maxit
%                Stopping criterion: maximal number of iterations. Default value is 100.
%
%     'tol',tol  Stopping criterion: minimum relative difference between
%              norms in two consecutive iterations. Default value is
%              1e-2.
%
%     'print'    Display the progress.
%
%     'quiet'    Don't print anything, this is the default.
%
%     'printstep',p
%                If 'print' is specified, then print every p'th
%                iteration. Default value is 10;
%
%   In addition to these parameters, this function accepts all flags from
%   the GROUPTHRESH and |thresh|_ functions. This makes it possible to
%   switch the grouping mechanism or inner thresholding type.
%
%   The parameters C, maxit and tol may also be specified on the
%   command line in that order: FRAMEGROUPLASSO(x,g,a,M,lambda,C,tol,maxit).
%
%   The solution is obtained via an iterative procedure, called Landweber
%   iteration, involving iterative group thresholdings.
%
%   The relationship between the output coefficients is given by :
%
%     xrec = frsyn(F,tc);
%
%   See also: framelasso, framebounds
%
%   Url: http://ltfat.sourceforge.net/doc/frames/framegrouplasso.php

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

if ~isvector(x)
    error('Input signal must be a vector.');
end

% Define initial value for flags and key/value pairs.
definout.import={'thresh','groupthresh'};
definput.flags.group={'freq','time'};

definput.keyvals.C=[];
definput.keyvals.maxit=100;
definput.keyvals.tol=1e-2;
definput.keyvals.printstep=10;
definput.flags.print={'quiet','print'};

[flags,kv]=ltfatarghelper({'C','tol','maxit'},definput,varargin);

L=framelengthsignal(F,length(x));

F=frameaccel(F,L);

if isempty(kv.C)
  [A_dummy,kv.C] = framebounds(F,L,'s');
end;

% Various parameter initializations
threshold = lambda/kv.C;

% Initialization of thresholded coefficients
c0 = frsynadj(F,x);

% We have to convert the coefficients to time-frequency layout to
% discover their size
tc = framecoef2tf(F,c0);
[M,N]=size(tc);

% Normalization to turn lambda to a value comparable to lasso
if flags.do_time
  lambda = lambda*sqrt(N);
else
  lambda = lambda*sqrt(M);
end

tc0 = c0;
relres = 1e16;
iter = 0;

% Choose the dimension to group along
if flags.do_freq
  kv.dim=2;
else
  kv.dim=1;
end;
  
% Main loop
while ((iter < kv.maxit)&&(relres >= kv.tol))
    tc = c0 - frsynadj(F,frsyn(F,tc0));
    tc = tc0 + tc/kv.C;
    
    %  ------------ Convert to TF-plane ---------
    tc = framecoef2tf(F,tc);

    tc = groupthresh(tc,threshold,'argimport',flags,kv);
    
    % Convert back from TF-plane
    tc=frametf2coef(F,tc);
    % -------------------------------------------
    
    relres = norm(tc(:)-tc0(:))/norm(tc0(:));
    tc0 = tc;
    iter = iter + 1;
    if flags.do_print
      if mod(iter,kv.printstep)==0        
        fprintf('Iteration %d: relative error = %f\n',iter,relres);
      end;
    end;
end

% Reconstruction
if nargout>3
  xrec = frsyn(F,tc);
end;

