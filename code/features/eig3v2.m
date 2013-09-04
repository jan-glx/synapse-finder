function [varargout] = eig3v2(A)

n=size(A,1);
p = A(:,1,2).^2 + A(:,1,3).^2 + A(:,2,3).^2;
eig1=zeros(n,1);
eig2=zeros(n,1);
eig3=zeros(n,1);
isdiagonal = (p == 0);
eig1(isdiagonal) = A(isdiagonal,1,1);
eig2(isdiagonal) = A(isdiagonal,2,2);
eig3(isdiagonal) = A(isdiagonal,3,3);
A=A(~isdiagonal,:,:);
    function y=trace3(x)
        y=sum(x(:,[1,5,9]),2);
    end
q = trace3(A)/3;
p = (A(:,1,1) - q).^2 + (A(:,2,2) - q).^2 + (A(:,3,3) - q).^2 + 2 * p;
p = sqrt(p / 6);
B = bsxfun(@times, (1 ./ p), (A - bsxfun(@times, q, permute(eye(3),[3,1,2]))));       % I is the identity matrix
    function y=det3(x)
        y=x(:,1,1).*x(:,2,2).*x(:,3,3)+x(:,1,2).*x(:,2,3).*x(:,3,1)+x(:,1,3).*x(:,2,1).*x(:,3,2)-x(:,1,3).*x(:,2,2).*x(:,3,1)-x(:,1,2).*x(:,2,1).*x(:,3,3)-x(:,1,1).*x(:,2,3).*x(:,3,2);
       %y=x(:,1,1).*x(:,2,2).*x(:,3,3)-x(:,1,1).*x(:,2,3).*x(:,3,2)+x(:,1,2).*x(:,2,3).*x(:,3,1)+x(:,1,3).*x(:,2,1).*x(:,3,2)-x(:,1,3).*x(:,2,2).*x(:,3,1)-x(:,1,2).*x(:,2,1).*x(:,3,3);
       %y=x(:,1,1).*x(:,2,2).*x(:,3,3)+x(:,1,2).*x(:,2,3).*x(:,3,1)+x(:,1,3).*x(:,2,1).*x(:,3,2)-x(:,1,3).*x(:,2,2).*x(:,3,1)-x(:,1,2).*x(:,2,1).*x(:,3,3)-x(:,1,1).*x(:,2,3).*x(:,3,2);
    end
r = det3(B) / 2;

% In exact arithmetic for a symmetric matrix  -1 <= r <= 1
% but computation error can leave it slightly outside this range.
phi=zeros(n,1);
phi(r <= -1) = pi / 3;
phi(r >= 1) = 0;
idxL=~((r <= -1)|(r >= 1));
phi(idxL) = acos(r(idxL)) / 3;
phi = acos(r) / 3;

% the eigenvalues satisfy eig3 <= eig2 <= eig1
eig1(~isdiagonal) = q + 2 * p .* cos(phi);
eig3(~isdiagonal) = q + 2 * p .* cos(phi + pi * (2/3));
eig2(~isdiagonal) = 3 * q - eig1 - eig3;     % since trace(A) = eig1 + eig2 + eig3



if(nargout<2)
    varargout={[eig1,eig2,eig3]};
end

end
