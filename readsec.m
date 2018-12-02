function varargout = readsec(t)
%READSEC(T) converts seconds to a readable format (DAY:HH:MM:SS.mmm)
%   It is handy when evaluating tic/toc output, e.g.:
%     tic; %do stuff; t = toc;
%     readsec(t);
%__________________________________________________________________________
%Daniele Mascali - danielemascali@gmail.com

if nargin == 0
    help readsec
    return
end

days = 0;
hours = 0;
mins = 0;

time_string = [];

if t >= 24*3600
    days = floor(t/(24*3600));
    time_string = [time_string,num2str(days),' day(s), '];
end

if t >= 3600
    hours = floor((t-days*(24*3600))/3600);
    time_string = [time_string,num2str(hours),' hour(s), '];
end

if t >= 60
    mins = floor((t-days*(24*3600)-hours*(3600))/60);
    time_string = [time_string,num2str(mins),' min, '];
end

sec = t-days*(24*3600)-hours*(3600)-mins*60;
time_string = [time_string,sprintf('%2.3f s.',sec)];

if nargout == 0 
    disp([num2str(t,'%15.3f'),'s -> ',time_string]);
else
    varargout{1} = time_string;
end

return
end