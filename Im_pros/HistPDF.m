function Density = HistPDF(Intensity, TrainingData, NumBins)
% TotalCount holds the number of data points in the training data.
TotalCount = length(TrainingData);
% BinCounts holds the number of data values that correspond each bin,
% while BinCenters hold the coordinate of the center of each bin.
% (again, you might look at the matlab function "hist"
[BinCounts, BinCenters] = hist(TrainingData,NumBins);
% BinWidth corresponds to the width of the bins.
BinWidth = BinCenters(2) - BinCenters(1);
% IntensityLow has a value corresponding to the left edge of the leftmost bin
IntensityLow = BinCenters(1) - BinWidth/2;
% Loop over the intensity values that are input to this implementation
% of a histogram based PDF.
RetrievedCounts(1:length(Intensity)) = 0;
for i = 1 : length(Intensity) %for each intensity present in the model
index = 1 + floor((Intensity(i) - IntensityLow) / BinWidth);
if (index >= 1) && (index <= size(BinCounts,2))
RetrievedCounts(i) = BinCounts(index);
end
end
% Establish a normalization of the returned PDF values such that
% the PDF being implemented integrates to one.
Normalization = 1/(TotalCount*BinWidth);
% Return the probability density corresponding to the input intensity
Density = Normalization * RetrievedCounts;