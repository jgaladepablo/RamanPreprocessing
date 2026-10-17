%% EMSC background subtraction
% 14/03/2025 Julia Gala de Pablo
% Function based on the paper by Hugh Byrne's group: https://pubs.rsc.org/en/content/articlelanding/2017/ay/c6ay03308c
% This function takes in Uncorrected spectrum and a Brackgrounds
% matrix:
%
% Uncorrected Spectrum in a column array
% Background matrix where each column is a background measurement
% (independent)
% Pure Cell [OPTIONAL]: pure cell contributions without background, to
% help the fitting.
%
% It performs non-negative constrained least squares analysis and
% corrects the spectrum by subtracting the background contribution
%
% This can be done using Non negatively constrained least squares analysis
%
% x = lsqnonneg(C,d) returns the vector x that minimizes norm(C*x-d) subject to x ≥ 0. Arguments C and d must be real.
%
function [x,Corrected,BackgroundContribution]=emsc(Uncorrected,Backgrounds,PureCell)
    switch nargin
        case 2
            x=lsqnonneg(Backgrounds,Uncorrected); % x returns the multiplier
            BackgroundContribution=Backgrounds*x;
            Corrected=Uncorrected-BackgroundContribution;
        case 4
            x=lsqnonneg([Backgrounds PureCell],Uncorrected); % x returns the multiplier
            BackgroundContribution=Background*x(:,1:size(Background,2));
            Corrected=Uncorrected-BackgroundContribution;
        otherwise
            disp('Error with number of input arguments, they must be either 2 or 3')
    end
end

