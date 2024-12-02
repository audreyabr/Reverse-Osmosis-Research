function openValve(valve_name)
%opens the valve with the corresponding name
%batch valve is open at 1 and brine and feed valve open with 0
if valve_name == "batch"
    writeDigitalPin(a,batch_valve_pin,1);
elseif valve_name == "feed"
    writeDigitalPin(a,feed_valve_pin,0);
elseif valve_name == "brine"
    writeDigitalPin(a,brine_valve_pin,0);
else
    display("Invalid valve name")
end

end