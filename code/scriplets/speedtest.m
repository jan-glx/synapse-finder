a=randn(100,100,100);
n=100
tic,
for i=1:n
a(:,1,i);
end
toc;

tic,
for i=1:n
a(i,1,:);
end
toc;

%% s

nn=10000;
n=10*nn;
for i=1:nn
    a=randn(i,1);
    b=randn(10,1);
    m=n/i;
    sstime=tic;
    for j=1:m
        c=convn(a,b);
    end
    t(i)=toc(sstime)/m;
end
plot(t);