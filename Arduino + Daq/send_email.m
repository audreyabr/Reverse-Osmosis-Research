function [email] = send_email(flowrate_list,email)
% sends email if batch flowrate drops to slightly above 0 mL/min
%
% Args
%   flowrate_list
%   email
%
% Returns
%   email: 0 if email is not sent
%          1 if email is sent

    if length(flowrate_list) > 10 && email == 0
        if mean(flowrate_list(end-10:end)) < 50 
            email = 1;
        
            % email set up
            h = actxserver('outlook.Application');
            mail = h.CreateItem('olMail');
            mail.Subject = 'system is dry';
            mail.To = 'aabraham@olin.edu';
            mail.cc = 'aabraham@olin.edu'; % change to someone else's email
            mail.BodyFormat = 'olFormatHTML';
            mail.HTMLBody = [num2str(mean(flowrate_list(end-10:end))), ' mL/min'];
        
            % send message and release object
            mail.Send;
            h.release;
        end
    end
end