clear all
close all
clc
addpath(genpath('ltfat'));
ltfatstart

% load the signal
[x,Fs] = audioread('mix.wav');
[L,M] = size(x);

% visualize observation by each micro
figure()
hold all
plot(x(:,1))
plot(x(:,2))

% dispersion diagram in time domain
figure()
plot(x(:,1),x(:,2),'o')
axis equal

% compute MDCT coefficients for each observation
for m = 1:M
    X(:,:,m) = wmdct(x(:,m),'sqrthann',512);
end
[F,N,M] = size(X);

% Spectrogram of each channel
figure()
subplot(211)
plotwmdct(abs(X(:,:,1)).^2,Fs)
subplot(212)
plotwmdct(abs(X(:,:,2)).^2,Fs)

% Dispertion diagram in time-frequency domain
figure()
plot(X(:,:,1),X(:,:,2),'o')
axis equal

% Histogram for arguments of Z(f,n)
arg = atan(X(:,:,2)./X(:,:,1));
arg = arg(:);
figure()
histogram(arg)

% Visually we mesure the number of sources and angle for each
K = 3;
theta(1) = -1.325;
theta(2) = -0.275;
theta(3) = 0.775;

% Reconstruction of the signal in time frquency domain
B = zeros(F,N,K);
S = zeros(F,N,K);
for f = 1:F
    for n = 1:N
        for k = 1:K
            B(f,n,k) = round(abs(sin(theta(k)-atan(X(f,n,2)/X(f,n,1)))));
            Y(f,n,1,k) = X(f,n,1)*B(f,n,k);
            Y(f,n,2,k) = X(f,n,2)*B(f,n,k);
            S(f,n,k) = Y(f,n,1,k)*cos(theta(k)) + Y(f,n,2,k)*sin(theta(k));
        end
    end
end

% MDCT inverse to recover and listen to the reconstructed signal
for m = 1:M
    for k = 1:K
        y(:,m,k) = iwmdct(Y(:,:,m,k),'sqrthann');
        s(:,k) = iwmdct(S(:,:,k),'sqrthann');
    end
end

% soundsc(y(:,:,1),Fs)
% soundsc(y(:,:,2),Fs)
% soundsc(y(:,:,3),Fs)
% soundsc(s(:,1),Fs)
% soundsc(s(:,2),Fs)
% soundsc(s(:,3),Fs)

% Permute the angles
theta_p = theta(randperm(3));
%theta_p = [0.5 -1 -0.2];
theta_p = theta_p';
x_p(:,1) = s*sin(theta_p);
x_p(:,2) = s*cos(theta_p);