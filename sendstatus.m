function sendstatus(to,verbose)
%SENDSTATUS(TO,VERBOSE) sends an exit status report to the mail addresses 
% (specified in TO). In case of failure the function that caused the error
% will be attached. 
%
%HOW DOES IT WORK?
% SENDSTATUS must be placed as the FIRST line of code of a matlab
% script/function.
%
% - TO is either a string specifying a single address, or a cell array of
%   addresses.
% - VERBOSE (optional): [0 1 2]. Selecet the "verbosity" of 
%   the attachements in case of failure:
%           0: No attachement
%           1: sends just the file that caused the error (default)
%           2: sends all the stacked files 
%__________________________________________________________________________
%
% Author:
%   Daniele Mascali
%   Enrico Fermi Center, MARBILab, Rome
%   August, 2018
%   danielemascali@gmail.com


% The aim of this function is to wrap the calling script/function 
% within a try/catch statment so that the exit status of the calling
% script/function can be sent by mail.

global SENDSTATUS_TIC_TIMES SENDSTATUS_BEACON_TIME SENDSTATUS_ERROR_MSG 
                         %beacon time is a variable for sendbeacon
                         %error msg for an additional mail with extra info

if isempty(SENDSTATUS_TIC_TIMES) %first occurrence of the current function.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % On function termination (both properly or via a CTRL+C 
    % signal) the global variable is destroyed. This is critical
    % for future (wanted) calls to sendstatus
    cleanupObj = onCleanup(@CleanGlobalVar);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    if nargin == 0 
        error('Not enough input arguments. At least one mail address is required.');
    end

    %First let's make sure that sendstatus is not called from command line
    currFun = mfilename;   %this function name, ie, sendstatus
    ST = dbstack('-completenames');
    callingFunction = ST(end);
    if strcmpi(callingFunction.name,currFun)
        error('Function sendstatus must be called from a script or function.');
    end
    
    %------------CONFIGURE SMTP SERVER and SENDER MAIL---------------------
    sendsetup
    %----------------------------------------------------------------------
    
    %set default verbosity level
    if nargin < 2; verbose = 1; end
    
    % since the script/function might have input or output arguments we
    % have to find out how exactly it was called. Let's look at matlab
    % history
    history = ...
        com.mathworks.mlservices.MLCommandHistoryServices.getSessionHistory;
    historyText = char(history);
    command_str = deblank(historyText(end,:));  %take the last entry
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %This variable has a double function
    % 1) to skip the second call to sendstatus (see the if at the beginning) 
    %    [NB:this is critical to avoid an infinite loop! and it also 
    %    prevents any subsequent (unwanted) occurrence of sendstatus]
    % 2) to store the starting time
    SENDSTATUS_TIC_TIMES = tic;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The core of the function:
    try 
        evalin('caller',command_str);
        exit_status = 0; %SUCCESS
    catch ME
        exit_status = 1; %ERROR FOUND
    end
    t = toc(SENDSTATUS_TIC_TIMES(1)); %the row selector is needed as sendmsg can append a second tic time.
    t = readsec(t);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    if exit_status   %ERROR FOUND
        subject = ['<',callingFunction.name,'> FAILURE'];
        msg_str = sprintf('has just failed with the following error:\n');
        error_message = getReport(ME,'extended','hyperlinks','off');
        %remove the last two stacks (or more, if sendstatus was placed in a
        %subfunction) which are useless
        indx = strfind(error_message,['Error in ',currFun,' ']);
        error_message(indx:end) = [];
        %find the stack index to be removed (for later usage):
        indx = find(arrayfun(@(n) strcmp(ME.stack(n).name,currFun),1:numel(ME.stack)));
    else   %SUCCESS
        subject = ['<',callingFunction.name,'> SUCCESS'];
        msg_str = sprintf('has been successfully completed!\n');
    end
        
    %get general info
    if ispc
        username = getenv('username');
        computername = getenv('computername');
    elseif isunix || ismac   %not tested on mac
        username = getenv('USER');
        [~, computername] = system('hostname');
        computername = strtrim(computername);
    end

    info_str = sprintf(['Dear %s,\n\n',...
                       'matlab function: %s\n',...
                       'full path: %s\n',...
                       'on machine: %s\n',...
                       '%s'],username,callingFunction.name,callingFunction.file,computername,msg_str);
                           
    sign_str = sprintf(['Mail generated by:\n%s, verbose level: %d\n',...
                        '____________________________\n',...
                        'Automatic Mail Service created by\n',...
                        'Daniele Mascali, PhD\n',...
                        '"Enrico Fermi" Centre\n',...
                        'MARBILab'],ST(1).name,verbose);   
    
    running_time = sprintf(['Elapsed time: ',t,'\n']);
                    
    if exit_status   %ERROR FOUND
        message_final{1} = info_str;
        message_final{2} = error_message;
        message_final{3} = running_time;
        message_final{4} = sign_str;   
    else            %SUCCESS
        message_final{1} = info_str;
        message_final{2} = running_time;
        message_final{3} = sign_str; 
    end        
    
    if exit_status   %ERROR FOUND
        switch verbose
            case {0} %no attachment
                sendmail(to,subject,message_final);
            case {1} %just the function that caused the error
                sendmail(to,subject,message_final,ME.stack(1).file)
            case {2} % the entire stack
                n_found = 1;
                for l = 1:(indx-1) %remove the last two stacks (or more, if sendstatus was
                    % placed in a subfunction).
                    % Send only different m files. In case a stack is a
                    % subfunction of the already selected m-file, avoid
                    % sending a copy (not sure this is really necessary).
                    if l > 1 
                        if strcmpi(ME.stack(l).file,attachments{n_found})
                            continue
                        else
                            n_found = n_found +1;
                        end
                    end
                    attachments{n_found} = ME.stack(l).file;
                end
                sendmail(to,subject,message_final,attachments)
        end
        % if SENDSTATUS_ERROR_MSG has been used, send a second
        % mail with user specific info:
        if ~isempty(SENDSTATUS_ERROR_MSG)
            subject = ['<',callingFunction.name,'> FAILURE extra info'];
            sendmail(to,subject,SENDSTATUS_ERROR_MSG)
        end
    else %SUCCESS, no attachment
        sendmail(to,subject,message_final)
    end
    
    if exit_status  %ERROR FOUND
        % display error and exit (otherwise it will continue into the first
        % call of the main function)
        % we have to remove the last two stacks (or more, if sendstatus was
        % placed in a subfunction) that are useless.
        % Unfortunately ME is read only, so we can't use rethrow(ME);
        errorStruct.identifier = ME.identifier;
        errorStruct.message = ME.message;
        errorStruct.stack = ME.stack(1:indx-1,1);
        error(errorStruct);
    else %SUCCESS
        %exit (otherwise it will continue into the first call of the main
        %function)
        errorStruct.message = '';
        errorStruct.stack = dbstack('-completenames');
        errorStruct.stack(1:end) = [];
        error(errorStruct);
    end
else %second occurrence of the current function
    % skip and return to the main function
    return
end

return
end

function CleanGlobalVar
%this is critical for future (wanted) calls to this function
clearvars -global SENDSTATUS_TIC_TIMES
clearvars -global SENDSTATUS_BEACON_TIME SENDSTATUS_ERROR_MSG 
return
end
