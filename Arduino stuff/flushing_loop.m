function flushing_loop(volume_flushed, flow_loop_volume, tank_is_full, time_step, conductivity_list, distance_list, conductivity_pin +...
    arduino_object, distance_list, trigger_pin, echo_pin, flowrate_list, flowrate_pin, t)
   
    while volume_flused < flow_loop_volume && tank_is_full == 0
        time_then = tic()
        
        % DATA COLLECTION
        conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin)
        [distance_list, distance] = distance_reading(arduino_object, distance_list, trigger_pin, echo_pin)    
        [flowrate_list, current_flowrate] = flowrate_reading(arduino_object, flowrate_list, flowrate_pin)  
        % (insert scale reading)
        time_now = toc(t); 
        time_list = time_readings(time_list, time_now)
    
        time_now = toc(time_then); 
        time_step_flushing == time_now - time_then; 
        added_volume = volume_step_approx(time_step_flushing, last_flowrate, current_flowrate)
        volume_flushed = volume_flushed + added volume;
        disp("Volume flushed: " + volume_flushed + "ml")
        last_flowrate == current flowrate;
        delay(0.5)
        
        
        else 
            
end
