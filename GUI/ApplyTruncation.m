function [Xt,Yt] = ApplyTruncation(X,Y,lowerlim,upperlim)

idx = X>=lowerlim & X<=upperlim;

Xt = X(idx);
Yt = Y(idx);

end