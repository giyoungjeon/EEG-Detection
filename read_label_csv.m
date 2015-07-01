function l = read_label_csv(filename)
    delimiter = ',';
    startRow = 2;

    formatSpec = '%*s%f%f%f%f%f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);
    fclose(fileID);

    l = [dataArray{1:end-1}];
end