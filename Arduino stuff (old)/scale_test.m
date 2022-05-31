% https://www.mathworks.com/help/supportpkg/arduinoio/ref/matlabshared.serial.device.read.html
% https://www.sjsu.edu/people/burford.furman/docs/me190/Serial%20Communication%20in%20Matlab%20V2%20-%20Esposito.pdf
clear all
% 

    if ~isempty(instrfind)
     fclose(instrfind);
      delete(instrfind);
    end


s = serial('COM7', 'baudrate', 9600)
 set(s,'Parity', 'none');
 set(s,'DataBits', 8);
 set(s,'StopBit', 1);
 
fopen(s)
mass_list = []
for i = 1:100
    a = fscanf(s);% 
    b = strtrim(a);
    c = erase(b,"g");
    d = erase(c,"?");
    e = strtrim(d);
    f = str2double(e);
    disp(f)
    pause(1)
end



