%
%   Url: http://ltfat.sourceforge.net/doc/fourier/plotdomaincolor.php

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
maxval=25;
exponent=1.5;

Lx=40;
Ly=101;

scale=log(maxval+1).^(1/exponent);

x=linspace(0,2*pi,Lx);
y=linspace(0,1,Ly);
yy=exp((scale*y).^exponent)-1;
dom=repmat(yy.',1,Lx).*exp(i*repmat(x,Ly,1));

figure(1);
image(x,y,domaincolor(dom));
pbaspect([.5,1,1])
xlabel('Phase (rad)');
ylabel('Magnitude');

%figure(2);
%plot(y,yy)

figure(2)
dom=repmat(y.',1,Lx).*exp(i*repmat(x,Ly,1));
w=domaincolor2(dom);
image(x,y,domaincolor2(dom));
pbaspect([.5,1,1])
xlabel('Phase (rad)');
ylabel('Magnitude');


figure(3);
c=dgtreal(greasy,'gauss',10,588);

s=20*log10(abs(c));
s=s-max(s(:))+90;
s(s<0)=0;
s=s/90;

if 1
  
  ss=exp((scale*s).^exponent)-1;
  dom=ss.*exp(i*angle(c));
  
  image(domaincolor(dom)); axis('xy');
end;

figure(4);
if 1

  dom=s.*exp(i*angle(c));
  
  image(domaincolor2(dom)); axis('xy');
end;
