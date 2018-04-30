count = 0;
for i = 1:size(newdata,1)
    if isempty(newdata{i,1}) && isempty(newdata{i,2}) && isempty(newdata{i,3}) && isempty(newdata{i,4})
        disp(newdata{i,5});
        count = count +1;
    end
end
disp(count);