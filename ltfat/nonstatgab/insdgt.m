function f=insdgt(c,g,a,varargin)
%INSDGT  Inverse nonstationary discrete Gabor transform
%   Usage:  f=insdgt(c,g,a,Ls);
%
%   Input parameters:
%         c     : Cell array of coefficients.
%         g     : Cell array of window functions.
%         a     : Vector of time positions of windows.
%         Ls    : Length of input signal.
%   Output parameters:
%         f     : Signal.
%
%   INSDGT(c,g,a,Ls) computes the inverse non-stationary Gabor transform
%   of the input coefficients c.
%
%   INSDGT is used to invert the functions NSDGT and |unsdgt|_. Please
%   read the help of these functions for details of variables format and
%   usage.
%
%   For perfect reconstruction, the windows used must be dual windows of the
%   ones used to generate the coefficients. The windows can be generated
%   using NSGABDUAL or |nsgabtight|_.
%
%   See also:  nsdgt, nsgabdual, nsgabtight
%
%   Demos:  demo_nsdgt
%
%   References:
%     F. Jaillet, M. Dörfler, and P. Balazs. LTFAT-note 10: Nonstationary
%     Gabor Frames. In Proceedings of SampTA, 2009.
%     
%
%   Url: http://ltfat.sourceforge.net/doc/nonstatgab/insdgt.php

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

%   AUTHOR : Florent Jaillet
%   TESTING: TEST_NSDGT
%   REFERENCE: 
%   Last changed 2009-05


% todo: 
% - It would be good to check the validity of the inputs. Some things to
%   check: chack the coherence of sizes in c, g, a, check that each cell of
%   g is vector, that values of a are intergers,...

% XXX There might be a bug when the window is bigger than the fft and that 
% the window length is odd (anyway, nsdgt, insdgt, nsgabdual and
% nonstatgabtight have not been extensively tested, so there might be other
% bugs. Sytematic testing would be good). 

if nargin<3
  error('%s: Too few input parameters.',upper(mfilename));
end;

if numel(g)==1
  error('g must be a vector (you probably forgot to supply the window function as input parameter.)');
end;

definput.keyvals.Ls=sum(a);
[flags,kv,Ls]=ltfatarghelper({'Ls'},definput,varargin);

timepos=cumsum(a)-a(1);

if iscell(c)
  
  % ---- invert the non-uniform case ---------
      
  N=length(c); % Number of time positions
  
  W=size(c{1},2); % Number of signal channels
  
  f=zeros(Ls,W); % Initialisation of the result
  
  for ii=1:N
    shift=floor(length(g{ii})/2);
    % Note: the *size(c{ii},1) in the following is here to ensure the 
    % coherence of the ifft normalisation convention with the function dgt 
    % of ltfat
    temp=ifft(c{ii})*size(c{ii},1); 
    
    if size(c{ii},1)<length(g{ii}) 
      % The number of frequency channels is smaller than window length, 
      % we need to periodize.
      % We have to periodize symetrically around time 0 which requires
      % some heavy indexing because time zero is index 1 and negative times
      % are at the end of the vector.
      temp=circshift(temp,mod(floor(length(g{ii})/2),length(g{ii})));
      x=floor(length(g{ii})/size(c{ii},1));
      y=length(g{ii})-x*size(c{ii},1);
      temp=[repmat(temp,x,1);temp(1:y,:)];
    else
      temp=circshift(temp,shift);
    end
    
    % Windowing with the synthesis window
    % Possible improvement: the following repmat is not needed if W=1 
    % (but the time difference when removing it should be really small)
    temp=temp(1:length(g{ii}),:).*repmat(circshift(g{ii},shift),1,W);
    
    % Possible improvement: the following could be computed faster by 
    % explicitely computing the indexes instead of using modulo
    tempind=mod((1:length(g{ii}))+timepos(ii)-shift-1,Ls)+1;
    f(tempind,:)=f(tempind,:)+temp;
  end
  
else   
  
  % ---- invert the uniform case ----------------
  
  [M, N, W]=size(c);

  f=zeros(Ls,W); % Initialisation of the result

  for ii=1:N
    shift=floor(length(g{ii})/2);
    % Note: the *size(c{ii},1) in the following is here to ensure the 
    % coherence of the ifft normalisation convention with the function dgt 
    % of ltfat
    temp=ifft(squeeze(c(:,ii,:)))*M;
    
    if M<length(g{ii}) 
      % The number of frequency channels is smaller than window length, 
      % we need to periodize.
      % We have to periodize symetrically around time 0 which requires
      % some heavy indexing because time zero is index 1 and negative times
      % are at the end of the vector.
      temp=circshift(temp,mod(floor(length(g{ii})/2),length(g{ii})));
      x=floor(length(g{ii})/M);
      y=length(g{ii})-x*M;
      temp=[repmat(temp,x,1);temp(1:y,:)];
    else
      temp=circshift(temp,shift);
    end
    
    % Windowing with the synthesis window
    % Possible improvement: the following repmat is not needed if W=1 
    % (but the time difference when removing it should be really small)
    temp=temp(1:length(g{ii}),:).*repmat(circshift(g{ii},shift),1,W);
    
    % Possible improvement: the following could be computed faster by 
    % explicitely computing the indexes instead of using modulo
    tempind=mod((1:length(g{ii}))+timepos(ii)-shift-1,Ls)+1;
    f(tempind,:)=f(tempind,:)+temp;
  end
  
end;

