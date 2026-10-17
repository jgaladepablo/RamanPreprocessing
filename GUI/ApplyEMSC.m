function [Ycorr,BackgroundContribution] = ApplyEMSC(Y,Backgrounds)

[~,Ycorr,BackgroundContribution] = ...
    emsc(Y,cell2mat(Backgrounds));

end