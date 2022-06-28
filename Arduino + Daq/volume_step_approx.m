function volume_step = volume_step_approx(time_step, last_flowrate, current_flowrate)

% Calculates the step volume of water (mL) that flowed through the pipe
% system by approximating the integral of flowrate data using the Midpoint Rule. 
% This function helps calculate whether the brine has been flushed from the system
%     
% Args:
%     time_step: an integer representing the time step from the last volume measurement taken
%     last_flowrate: an integer representing the last flowrate measurement taken in mL/min 
%     current_flowrate: an integer representing the current flowrate in mL/min
%         
% Returns:
%     volume_step: an integer representing the volume that flowed through
%     the meter within the timestep (mL)
    
volume_step = ((last_flowrate + current_flowrate)/2) *(time_step/60);
    
end
