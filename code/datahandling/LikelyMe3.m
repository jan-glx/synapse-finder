function [ l ] = LikelyMe3(t0,t1,k1,k)
%LIKELYME Summary of this function goes here
%   Detailed explanation goes here
% t0=in(1);
% t1=in(2);
% k1=in(3:end);
N=numel(k)-1;
n=sum(k);
k0=k-k1;
n0=sum(k0);
n1=sum(k1);
K=0:N;

bino=log(gamma(N+1)./(gamma(K+1).*gamma(N-K+1)));
l=logfac(n1)+logfac(n0)-sum(logfac(k1))-sum(logfac(k0))+sum(k1.*(bino+K.*log(t1)+(N-K).*log(1-t1)))+sum(k0.*(bino+K.*log(t0)+(N-K).*log(1-t0)));
fprintf('t0:%f t1:%f k1: %f %f %f %f  --- l: %f\n',t0,t1,k1,l);

end

%@(x)-LikelyMe2(x)
%[100,0.4,0.1,0.9]