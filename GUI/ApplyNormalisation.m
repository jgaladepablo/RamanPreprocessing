function Yn = ApplyNormalisation(X,Y)

x1 = find(round(X)==1630,1);
x2 = find(round(X)==1680,1);

Yn = Y ./ ...
    max(sgolayfilt(Y(x1:x2),2,31));

end