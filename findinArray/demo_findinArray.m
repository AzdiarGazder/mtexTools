clc; clear all;

%% "dateTime" arrays
% Example array of elements to find
% findThis = [datetime(2022, 10, 18, 14, 45, 0), ...
%                  datetime(2022, 10, 16, 12, 15, 0)];
% findThis = ['18-Oct-2022 14:45:00'; '16-Oct-2022 12:15:00'];
findThis = [datetime(2022, 10, 18, 14, 45, 0), ...
                 '16-Oct-2022 12:15:00'];
% Example dateTime array to look within
inThat = [datetime(2022, 10, 15, 8, 30, 0), ...
                 datetime(2022, 10, 16, 12, 15, 0), ...
                 datetime(2022, 10, 17, 9, 0, 0), ...
                 datetime(2022, 10, 18, 14, 45, 0), ...
                 datetime(2022, 10, 19, 10, 20, 0)];

idx = findElement(findThis,inThat)
[r,c] = findElement(findThis,inThat,'subscript')
return



%% "categorical" array
% % Example array of elements to find
% findThis = ["apple"];
% % Example categorical array to look within
% inThat = categorical({'apple', 'banana', 'apple', 'orange'}, {'apple', 'banana', 'orange'});
% 
% idx = findElement(findThis,inThat)
% [r,c] = findElement(findThis,inThat,'subscript')
% return



%% "sparse" arrays
% % Example array of elements to find
% findThis = ["3"; '2'; 1];
% % Example sparse array to look within
% inThat = sparse([1 0 0; 0 0 2; 0 3 0]);
% 
% idx = findElement(findThis,inThat)
% [r,c] = findElement(findThis,inThat,'subscript')
% return



%% "table" array
% % Example array of elements to find
% findThis = ["Toby"; 30; 34; "Alice"; 54];
% % Example table array to look within
% inThat = table({'John'; 'Alice'; 'Toby'; 'James'}, [25; 30; 54; 87], 'VariableNames', {'Name', 'Age'});
% 
% idx = findElement(findThis,inThat)
% [r,c] = findElement(findThis,inThat,'subscript')
% return



%% "struct" arrays
% % Example array of elements to find
% findThis = ["Jim"; '30'];
% % Example struct array to look within
% inThat(1).name = 'John';
% inThat(1).age = 25;
% inThat(2).name = 'Alice';
% inThat(2).age = 30;
% inThat(3).name = 'Jim';
% inThat(3).age = 84;
% 
% idx = findElement(findThis,inThat)
% [r,c] = findElement(findThis,inThat,'subscript')
% return



%% "double" array
% % % Example array of elements to find
% findThis = [1 2 3];
% % % Example table array to look within
% inThat = [3 4 5 6 3 6 5 1 2 3 5 6 5 8]';
% 
% idx = findElement(findThis,inThat)
% [r,c] = findElement(findThis,inThat,'subscript')
% return