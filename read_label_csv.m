function l = read_label_csv(filename)
% alias function to easily read label of EEG dataset 
%
% Input Arguments:
%               filename:   path of the name of csv file
%
% Written by Giyoung Jeon
% Probabilistic Artificial Intelligence Lab at UNIST
% v1.0 July, 2nd, 2015
    delimiter = ',';
    startRow = 2;

    formatSpec = '%*s%f%f%f%f%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
    fclose(fileID);

    l = [dataArray{1:end-1}];
end