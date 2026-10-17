function LDAResults = RunLDA( ...
    DataMatrix,...
    Classes,...
    VarianceThreshold,...
    KFolds,...
    RandomSeed)

%% PCA

PCAResults = RunPCA( ...
    DataMatrix,...
    VarianceThreshold);

NPC = PCAResults.NumComponents;
X = PCAResults.score(:,1:NPC);

%% Cross-validation setup

rng(RandomSeed)

CV = cvpartition( ...
    Classes,...
    'KFold',...
    KFolds);

UniqueClasses = unique(Classes);
NClasses = length(UniqueClasses);
NSpectra = numel(Classes);

PredictedClass = cell(NSpectra,1);

%% Preallocation

Models = cell(NClasses,1);

SpectralLoadings = zeros( ...
    size(DataMatrix,1),...
    NClasses);

FoldAccuracy = zeros(KFolds,1);

FoldConfusionMatrices = cell(KFolds,1);
FoldConfusionMatricesPercent = cell(KFolds,1);

TestIndices = cell(KFolds,1);

LDAScores = nan( ...
    NSpectra,...
    NClasses);

%% Cross-validation

for Fold = 1:KFolds

    TrainIdx = training(CV,Fold);
    TestIdx = test(CV,Fold);

    TestIndices{Fold} = TestIdx;

    XTrain = X(TrainIdx,:);
    XTest = X(TestIdx,:);

    ClassTrain = Classes(TrainIdx);
    ClassTest = Classes(TestIdx);

    Scores = zeros( ...
        sum(TestIdx),...
        NClasses);

    for c = 1:NClasses

        PositiveClass = UniqueClasses(c);

        BinaryTrain = strcmp( ...
            ClassTrain,...
            PositiveClass);

        Model = fitcdiscr( ...
            XTrain,...
            BinaryTrain);

        [~,Score] = predict( ...
            Model,...
            XTest);

        Scores(:,c) = Score(:,2);

    end

    LDAScores(TestIdx,:) = Scores;

    [~,MaxIdx] = max(Scores,[],2);

    PredictedFold = UniqueClasses(MaxIdx);

    PredictedClass(TestIdx) = PredictedFold;

    FoldAccuracy(Fold) = mean( ...
        strcmp( ...
        PredictedFold,...
        ClassTest));

    CM = confusionmat( ...
        ClassTest,...
        PredictedFold,...
        'Order',...
        UniqueClasses);

    FoldConfusionMatrices{Fold} = CM;

    RowSums = sum(CM,2);
    CMPercent = 100*CM./RowSums;

    FoldConfusionMatricesPercent{Fold} = CMPercent;

end

ConfusionStack = cat(3,...
    FoldConfusionMatricesPercent{:});

MeanConfusionMatrix = mean( ...
    ConfusionStack,3);

SEMConfusionMatrix = std( ...
    ConfusionStack,0,3) ./ sqrt(KFolds);

%% Final models for loadings only

for c = 1:NClasses

    PositiveClass = UniqueClasses(c);

    BinaryLabels = strcmp( ...
        Classes,...
        PositiveClass);

    Models{c} = fitcdiscr( ...
        X,...
        BinaryLabels);

    LDACoeffs = ...
        Models{c}.Coeffs(1,2).Linear;

    SpectralLoadings(:,c) = ...
        PCAResults.coeff(:,1:NPC) * LDACoeffs;

end

%% Overall confusion matrix

ConfMat = confusionmat( ...
    Classes,...
    PredictedClass,...
    'Order',...
    UniqueClasses);

%% Overall accuracy

Accuracy = mean( ...
    strcmp( ...
    Classes,...
    PredictedClass));

%% LD names

LDNames = cell(NClasses,1);

for k = 1:NClasses

    LDNames{k} = sprintf( ...
        'LD%d - %s',...
        k,...
        UniqueClasses{k});

end

%% Save results

LDAResults.Scores = LDAScores;

LDAResults.Models = Models;

LDAResults.Classes = UniqueClasses;
LDAResults.ClassNames = UniqueClasses;

LDAResults.LDNames = LDNames;

LDAResults.PCAResults = PCAResults;

LDAResults.Loadings = SpectralLoadings;

LDAResults.PredictedClass = PredictedClass;

LDAResults.FoldConfusionMatrices = FoldConfusionMatrices;

LDAResults.TestIndices = TestIndices;

LDAResults.Accuracy = Accuracy;

LDAResults.FoldAccuracy = FoldAccuracy;
LDAResults.MeanFoldAccuracy = mean(FoldAccuracy);
LDAResults.StdFoldAccuracy = std(FoldAccuracy);
LDAResults.SemFoldAccuracy = std(FoldAccuracy)/sqrt(KFolds);

LDAResults.NumComponents = NPC;

LDAResults.KFolds = KFolds;
LDAResults.RandomSeed = RandomSeed;

LDAResults.MeanConfusionMatrix = MeanConfusionMatrix;
LDAResults.SEMConfusionMatrix = SEMConfusionMatrix;

LDAResults.FoldConfusionMatrices = FoldConfusionMatrices;
LDAResults.FoldConfusionMatricesPercent = ...
    FoldConfusionMatricesPercent;

end