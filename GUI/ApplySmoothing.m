function Ys = ApplySmoothing(Y,polyorder,window)

Ys = sgolayfilt(Y,polyorder,window);

end