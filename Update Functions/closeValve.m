function closeValve(valve_name)
%closes the valve with the corresponding name
%batch valve is closed at 0 and brine and feed valve close with 1
if valve_name == "batch"
    writeDigitalPin(a,batch_valve_pin,0);
elseif valve_name == "feed"
    writeDigitalPin(a,feed_valve_pin,1);
elseif valve_name == "brine"
    writeDigitalPin(a,brine_valve_pin,1);
else
    display("Invalid valve name")
end

end