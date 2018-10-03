function sendsetup
%Configuration file for setting up the SMTP mail server. 
%
% You have to specify the sender email and its password before using 
% "sendstatus" or "sendmsg". The SMTP service preferences are already configured
% for a GMAIL account. If you wish to use a different mail service, change
% them accordingly. 
%__________________________________________________________________________
%
% Author:
%   Daniele Mascali
%   Enrico Fermi Center, MARBILab, Rome
%   August, 2018
%   danielemascali@gmail.com

try 
    [sender_mail,password] = sendsetup_dm;
catch
    sender_mail = '';  %specify here the sender email (eg: danielemascali@gmail.com)
    password = '';     %specify here the sender email password  
end

if isempty(sender_mail)
    fname = mfilename;
    fpath = mfilename('fullpath');
    error(sprintf('You have to specify a sender email in %s.m.\nNB: %s is preconfigured for a GMAIL address.',fpath,fname));
elseif isempty(password) 
    fname = mfilename;
    fpath = mfilename('fullpath');
    error('You have to specify the password of the sender email in send_setup.m');
end

% The below configuration is for GMAIL, change the smtp server accordingly
% to your mail provider. 
setpref('Internet','E_mail',sender_mail);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',sender_mail);
setpref('Internet','SMTP_Password',password);
% for unix system:
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

return
end