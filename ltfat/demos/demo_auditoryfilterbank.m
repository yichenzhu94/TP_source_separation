%DEMO_AUDITORYFILTERBANK
%
%   In this file we construct a uniform filterbank using a the impulse
%   response of a 4th order gammatone for each channel. The center frequencies
%   are equidistantly spaced on an ERB-scale, and the width of the filter are
%   choosen to match the auditory filter bandwidth as determined by Moore.
%
%   Each channel is subsampled by a factor of 8 (a=8), and to generate a
%   nice plot, 4 channels per Erb has been used.
%
%   The filterbank cover only the positive frequencies, so we must use
%   filterbankrealdual and filterbankrealbounds.
%
%   FIGURE 1 Classic spectrogram 
%
%     A classic spectrogram of the spoken sentense. The dynamic range has
%     been set to 50 dB, to highlight the most important features.
%
%   FIGURE 2 Auditory filterbank representation
%
%     Auditory filterbank representation of the spoken sentense using
%     gammatone filters on an Erb scale.  The dynamic range has been set to
%     50 dB, to highlight the most important features.
%
%   FIGURE 3 Auditory filterbank representation using Gaussian filters
%
%     Auditory filterbank representation of the spoken sentense using
%     Gaussian filters on an Erb scale.  The dynamic range has been set to
%     50 dB, to highlight the most important features.
%
%   See also: freqtoaud, audfiltbw, gammatonefir, ufilterbank, filterbankrealdual
%
%   References:
%     B. R. Glasberg and B. Moore. Derivation of auditory filter shapes from
%     notched-noise data. Hearing Research, 47(1-2):103, 1990.
%     

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


% Use the 'cocktailparty' spoken sentense.
f=cocktailparty;
fs=44100;
a=8;
channels_per_erb=4;
filterlength=5000;
dynrange_for_plotting=50;

% Determine minimal transform length
Ls=length(f);
L=ceil(filterlength/a)*a;

% Number of channels, slightly less than 1 ERB(Cambridge) per channel.
M=ceil(freqtoerb(fs/2)*channels_per_erb);

% Compute center frequencies.
fc=erbspace(0,fs/2,M);

%% --------------- display classic spectrogram -------------------
figure(1);
sgram(f,fs,dynrange_for_plotting);


%% ---------------  Gammatone filters ----------------------------

g_gam=gammatonefir(fc,fs,filterlength,'peakphase');

% In production code, it is not necessary to call 'filterbankrealbounds',
% this is just for veryfying the setup.
disp('Frame bound ratio for gammatone filterbank, should be close to 1 if the filters are choosen correctly.');
filterbankrealbounds(g_gam,a,L)

% Create reconstruction filters
gd_gam=filterbankrealdual(g_gam,a,L);

% Analysis transform
coef_gam=ufilterbank(f,g_gam,a);

% Synthesis transform
r_gam=2*real(ifilterbank(coef_gam,gd_gam,a,Ls));

disp('Relative error in reconstruction, should be close to zero.');
norm(f-r_gam)/norm(f)

figure(2);
plotfilterbank(coef_gam,a,fc,fs,dynrange_for_plotting,'audtick');


%% ---------------  Gauss filters ----------------------------


g_gauss=cell(M,1);

% Account for the bandwidth specification to PGAUSS is for 79% of the ERB(integral).  
bw_gauss=audfiltbw(fc)/0.79*1.5;

for m=1:M
  g_gauss{m}=pgauss(filterlength,'fs',fs,'bw',bw_gauss(m),'cf',fc(m));
end;

disp('Frame bound ratio for Gaussian filterbank, should be close to 1 if the filters are choosen correctly.');
filterbankrealbounds(g_gauss,a,filterlength)

% Synthesis filters
gd_gauss=filterbankrealdual(g_gauss,a,filterlength);

% Analysis transform
coef_gauss=ufilterbank(f,g_gauss,a);

% Synthesis transform
r_gauss=2*real(ifilterbank(coef_gauss,gd_gauss,a));

disp('Error in reconstruction, should be close to zero.');
norm(f-r_gauss)/norm(f)


figure(3);
plotfilterbank(coef_gauss,a,fc,fs,dynrange_for_plotting,'audtick');


