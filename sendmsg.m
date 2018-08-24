function sendmsg(to,subject,message,attachments)
%SENDMSG uses matlab SENDMAIL function to send mails pre-compiled with a set 
% of useful info. The input arguments are the same of SENDMAIL:
%
% sendmail(TO,SUBJECT,MESSAGE,ATTACHMENTS) sends an e-mail.  TO is either a
%     string specifying a single address, or a cell array of addresses.  SUBJECT
%     is a string.  MESSAGE is either a string or a cell array.  If it is a
%     string, the text will automatically wrap at 75 characters.  If it is a cell
%     array, it won't wrap, but each cell starts a new line.  In either case, use
%     char(10) to explicitly specify a new line.  ATTACHMENTS is a string or a
%     cell array of strings listing files to send along with the message. 
%__________________________________________________________________________
%
% Author:
%   Daniele Mascali
%   Enrico Fermi Center, MARBILab, Rome
%   August, 2018
%   danielemascali@gmail.com

if nargin == 0
    error('Not enough input arguments. At least one mail address is required.');
end
 
if nargin < 2 
    subject = '';
    message = '';
elseif nargin < 3
    message = '';
end

%empty subj and message are not allowed by sendmail, let's take care of it
if isempty(subject); subject = ''; end;
if isempty(message); message = ''; end;

%------------CONFIGURE SMTP SERVER and SENDER MAIL-------------------------
sendsetup
%--------------------------------------------------------------------------

ST = dbstack('-completenames');
callingFunction = ST(end);
if ~strcmpi(callingFunction.name,mfilename)
    % put the calling function as prefix of the subject
    subject = ['<',callingFunction.name,'> ',subject];
    %and create a info string in the body message
    info_str = sprintf(['by function: ',callingFunction.name,' (at line: ',num2str(callingFunction.line),')\n(full path: ',callingFunction.file,')\n']);
else
    % don't modify the subject.
    %and empty info string in the body message
    info_str = '';
end

if ispc
    username = getenv('username');
    computername = getenv('computername');
elseif isunix || ismac   %not tested on mac
    username = getenv('USER');
    [~, computername] = system('hostname');
    computername = strtrim(computername);
end
                
info_str = sprintf(['Dear %s,\n\n',...
                           'this message has been generated from: %s\n',...
                           '%s'],username,computername,info_str);
sign_str = sprintf(['Mail generated by: %s\n',...
                    '____________________________\n',...
                    'Automatic Mail Service created by\n',...
                    'Daniele Mascali, PhD\n',...
                    '"Enrico Fermi" Centre\n',...
                    'MARBILab'],ST(1).name);     
if isempty(message)
    message_final{1} = info_str;
    message_final{2} = sign_str;
else
    message_final{1} = info_str;
    message_final{2} = sprintf([message,'\n']);
    message_final{3} = sign_str; 
end

if nargin <= 3
    sendmail(to,subject,message_final)
else
    sendmail(to,subject,message_final,attachments)
end

return
end