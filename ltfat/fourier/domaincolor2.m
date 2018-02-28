function c = domaincolor(w)
%DOMAINCOLOR  Convert complex values to color
%   Usage: c = domaincolor(x);
%
%   Example:
%   --------
%
%   The following example shows a patch of the complex plane:
%
%     L=51;
%     R=2;
%     x=linspace(-R,R,L);
%     dom=repmat(x,L,1)+i*repmat(x.',1,L);
%     image(x,x,domaincolor(dom));
%     axis('xy');
%     xlabel('Real axis');
%     ylabel('Imaginary axis');
%
%   The following example create a colorbar-like representation for a
%   mapping of values 0<= x<= 1 using the following mapping for the magnitude:
%
%   :
%
%     Lx=40;
%     Ly=101;
%     x=linspace(0,2*pi,Lx);
%     y=linspace(0,1,Ly);
%     dom=(exp(repmat(2.2*y.',1,Lx).^1.5)-1).*exp(i*repmat(x,Ly,1));
%     image(x,y,domaincolor(dom));
%     pbaspect([.5,1,1])
%     xlabel('Phase (rad)');
%     ylabel('Magnitude');
%
%
%   Url: http://ltfat.sourceforge.net/doc/fourier/domaincolor2.php

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

%EXAMPLEDEFINITION 7
%EXAMPLEDEFINITION 22
  
remembersize=size(w);
N=numel(w);
c = zeros(N,3);

%c = hsv2rgb([angle(w(:))/(2*pi)+.5,1-abs(w(:)),abs(w(:))]);
c = hsv2rgb([angle(w(:))/(2*pi)+.5,ones(N,1),abs(w(:))]);

max(abs(w(:)))
c=reshape(c,[remembersize,3]);
