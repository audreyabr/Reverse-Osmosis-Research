    clear
    % arduino setup
    a = arduino("COM5","Mega2560");
    conductivity_pin_pos = "A3";
    conductivity_pin_neg = "A4";
    batch_valve_pin = 'D4';
    brine_valve_pin = 'D3';
    feed_valve_pin = 'D5';
    conductivity_list = [];
    pause_time = 2;
    
    % append to list for 30 readings
    for i = 1:10
        writeDigitalPin(a,brine_valve_pin,0);  % open brine valve
        pause(pause_time) % valve delay time
        disp("1")
        conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin_pos, conductivity_pin_neg);
        writeDigitalPin(a,batch_valve_pin,0); % close batch valve
        pause(pause_time) % valve delay time
        disp("2")
        conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin_pos, conductivity_pin_neg);
        writeDigitalPin(a,brine_valve_pin,1);  % open brine valve
        pause(pause_time) % valve delay time
        disp("3")
        conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin_pos, conductivity_pin_neg);
        writeDigitalPin(a,batch_valve_pin,1); % close batch valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,brine_valve_pin,0);  % open brine valve
        pause(pause_time) % valve delay time
        disp("4")
        conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin_pos, conductivity_pin_neg);
        writeDigitalPin(a,batch_valve_pin,0); % close batch valve
        pause(pause_time) % valve delay time
        disp("5")
        conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin_pos, conductivity_pin_neg);
        writeDigitalPin(a,brine_valve_pin,1);  % open brine valve
        pause(pause_time) % valve delay time
        disp("6")
        conductivity_list = conductivity_reading(a,conductivity_list,conductivity_pin_pos, conductivity_pin_neg);
        writeDigitalPin(a,batch_valve_pin,1); % close batch valve
        pause(pause_time) % valve delay time
        writeDigitalPin(a,brine_valve_pin,0);  % open brine valve
        pause(pause_time) % valve delay time
    end
    
    