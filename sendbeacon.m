function sendbeacon(to,deltaTime)
%SENDBEACON(TO,DELTATIME) sends an email to TO to confirm the machine is
% still working. The messsage is sent (approximately) every DELTATIME.
% SENDBEACON. 
%
%HOW DOES IT WORK?
% SENDBEACON needs to be placed insied a cycle (each time the function is 
% called it checks if DELTATIME has passed and in case it sends the message).  
% NB: It also requires SENDSTATUS to be present inside the script/function
%
% - TO is either a string specifying a single address, or a cell array of
%   addresses.
% - DELTATIME: time between beacon signals in minutes 
%              (e.g., DELTATIME = 60*12 -> beacon every 12 hours)  
%
%EXAMPLE:
%
%   sendstatus('danielemascali@gmail.com');
%
%   for l = 1:SUBJlist
%       %do time consuming stuff
%       sendbeacon('danielemascali@gmail.com',60*12);
%   end
%__________________________________________________________________________
%Daniele Mascali - danielemascali@gmail.com

global SENDSTATUS_BEACON_TIME % It's the time required to send the next beacon

if isempty(SENDSTATUS_BEACON_TIME) %first occurrence of the current function.
    SENDSTATUS_BEACON_TIME = deltaTime *60; %convert minutes to seconds 
end

if toc >= SENDSTATUS_BEACON_TIME 
    sendmsg(to,'beacon',sprintf(['So far so good!\nBeacon signal generated every ',readsec(deltaTime*60)]));
    % increment the time:
    SENDSTATUS_BEACON_TIME = SENDSTATUS_BEACON_TIME + deltaTime *60;
end

return
end