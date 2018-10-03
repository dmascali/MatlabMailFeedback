# Matlab Mail Feedback

A set of functions for receiving mail feedback from Matlab.

- **sendstatus(to,verbose)**  
    sends the exit status of a script/function to the mail addresses (specified in _to_). In case of failure the function that caused the error
 will be attached. 
 
- **sendmsg(to,subject,message,attachments)**  
    uses matlab _sendmail_ function to send mail pre-compiled with a set of useful info (works as matlab _sendmail_). 

## Installation
1. Add the folder to you MATLAB path.
2. Configure **sendsetup.m** with the info of the email address from which you wish to send matlab feedback  
 - if you use a _gmail_ account, you only have to fill the fields _sender_mail_ and _password_   
 - if you use another mail service, you will also have to change the SMTP parameters.

## Usage
**sendstatus(to,verbose)** must be placed as the **FIRST** line of code of a matlab
 script/function.
 
 - _to_ is either a string specifying a single address, or a cell array of
   addresses.
 - _verbose_ (optional): [0 1 2]. Selecet the "verbosity" of the attachments in case of failure:  
           - 0: no attachment  
           - 1: sends just the file that caused the error (default)  
           - 2: sends all the stacked files  

**sendmsg(to,subject,message,attachments)** works as matlab _sendmail_ (see: https://it.mathworks.com/help/matlab/ref/sendmail.html).