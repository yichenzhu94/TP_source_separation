function [a,M,longestfilter,lcm_a]=assert_filterbankinput(g,a,mustbeuniform);
%
%
%   Url: http://ltfat.sourceforge.net/doc/comp/assert_filterbankinput.php

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
    mustbeuniform=0;
  end;
  
  f=dbstack;  
  callfun=f(2).name;

  if ~iscell(g)
    error('%s: g must be a cell-array.',upper(callfun));
  end;

  M=numel(g);
  
  if ~isnumeric(a)
    error('%s: a must be numeric.',upper(callfun));
  end;
  
  if mustbeuniform
    if ~isscalar(a) || a<=0
      error('%s: "a" must be a positive scalar.',upper(callfun));
    end;
    
    lcm_a=a;
  
  else

    if ~isvector(a) || any(a<=0)
      error('%s: "a" must be a vector of positive numbers.',upper(callfun));
    end;

    if length(a)>1 
      if  length(a)~=M
        error(['%s: The number of entries in "a" must match the number of ' ...
               'filters.'],upper(callfun));
      end;
    else
      a=a*ones(M,1);
    end;
    
    % This code works in Octave, but not in Matlab, so we have to iterate
    % through "a" to calculate the lcm.
    %lcm_a=lcm(num2cell(a){:});
    lcm_a=a(1);
    for m=2:M
      lcm_a=lcm(lcm_a,a(m));
    end;
  end;
    
  longestfilter=max(cellfun(@numel,g));

