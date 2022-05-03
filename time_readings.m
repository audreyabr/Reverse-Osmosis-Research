function time_list = time_readings(time_list, time_now)
% Takes the current time and adds it to a list. 
   
% Args:
%     current_time: An integer representing the current time in seconds
% Returns:
%     time_list: A list of recorded times

time_list(end+1, 1) = time_now;

end
