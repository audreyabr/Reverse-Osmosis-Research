% M = [1,2,3,4];
% csvwrite("myFile.csv","Time", M)
% type("myFile.csv")
% csvread("myFile.csv")
% y = [];
% for i = 1:20
% y(end+1) = input('Enter the value of y = ');
% csvwrite("myFile_y.txt",y)
% end 
dlmwrite('Test.csv',Header{1},'');           %% Write first row with no delimiter
for line={Header{2:end}}'                    %% Assign rest of the Header to line and loop over its elements
  dlmwrite('Test.csv',line,'','-append');    %% Append every line with no delimiter
end

%% Write the Data
dlmwrite('Test.csv' ,Data,'-append')          %% Append Data with default delimiter - comma