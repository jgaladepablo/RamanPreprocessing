function [Yaligned,Xintvalues] = AlignSpectrum(Spectrum,MeasuredPeak,ReferencePeak)

Xintvalues = 110:0.5:3190;

Yaligned = spline( ...
    Spectrum(:,1)+(ReferencePeak-MeasuredPeak), ...
    Spectrum(:,2), ...
    Xintvalues).';

end