%DEMO_ISGRAM  Contruction of a signal with a given spectrogram
%
%   This demo demonstrates iterative reconstruction of a spectrogram.
%
%   FIGURE 1 Original spectrogram
%
%      This figure shows the target spectrogram
%
%   FIGURE 2 Linear reconstruction
%
%      This figure shows a spectrogram of a linear reconstruction of the
%      target spectrogram.
%
%   FIGURE 3 Iterative reconstruction using the Griffin-Lim method.
%
%      This figure shows a spectrogram of an iterative reconstruction of the
%      target spectrogram using the Griffin-Lim projection method.
%
%   FIGURE 4 Iterative reconstruction using the BFGS method
%
%      This figure shows a spectrogram of an iterative reconstruction of the
%      target spectrogram using the BFGS method.
%
%   See also:  isgramreal, isgram, 

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

s=ltfattext;

figure(1);
imagesc(s);
colormap(gray);
axis('xy');

figure(2);
sig_lin = idgtreal(sqrt(s),'gauss',8,800);
sgram(sig_lin,'dynrange',100);

figure(3);
sig_iter = isgramreal(s,'gauss',8,800);
sgram(sig_iter,'dynrange',100);

figure(4);
sig_iter = isgramreal(s,'gauss',8,800,'bfgs');
sgram(sig_iter,'dynrange',100);

