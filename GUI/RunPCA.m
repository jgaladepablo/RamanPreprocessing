function PCAResults = RunPCA(DataMatrix,VarianceThreshold)

% RunPCA
%
% DataMatrix:
%   rows    = Raman shifts
%   columns = spectra
%
% VarianceThreshold:
%   e.g. 95
%
% Output:
%   PCAResults structure

%% SNV normalisation

SpectrumMean = mean(DataMatrix,1);
SpectrumSTD  = std(DataMatrix,0,1);

DataMatrixNorm = ...
    (DataMatrix - SpectrumMean) ./ SpectrumSTD;

%% PCA

[coeff,score,latent,tsquared,explained,mu] = ...
    pca(DataMatrixNorm.');

%% Components required

NumComponents = ...
    find(cumsum(explained) >= VarianceThreshold,1);

if isempty(NumComponents)
    NumComponents = length(explained);
end

% Need at least two PCs for score plots
NumComponents = max(2,NumComponents);

% Cannot exceed the available PCs
NumComponents = min(NumComponents,...
    size(score,2));

%% Save results

PCAResults.coeff = coeff;
PCAResults.score = score;
PCAResults.latent = latent;
PCAResults.tsquared = tsquared;
PCAResults.explained = explained;
PCAResults.mu = mu;

PCAResults.NumComponents = NumComponents;
PCAResults.CumulativeExplained = cumsum(explained);

PCAResults.VarianceThreshold = VarianceThreshold;

end