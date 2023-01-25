a = [];
for i = 1:1:26
    a(end+1) = i;
end 
b = movmean(a,2);
b = b(1:end-1);
avg = sum(b)/length(b);

% x_list = [];
% y_list = [];
% for x = 0:0.01:5
%     x_list(end+1) = x;
%     y = x ^2 + 1;
%     y_list(end+1) = y;
% end 
% mean(y_list)

   