function [Xz,Yz] = ApplyZap(X,Y,zap1,zap2)

idx = ~(X>zap1 & X<zap2);

Xz = X(idx);
Yz = Y(idx);

end