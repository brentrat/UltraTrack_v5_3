% SHUTDOWN - turn off a Windows machine from within Matlab
%
% USAGE:
%
% shutdown          % turn off the computer in 60 seconds
% shutdown(numsec)  % turn off the computer in numsec seconds
% shutdown(-1)      % abort the shutdown; don't turn off the computer
%
% numsec = optional number of seconds to pause after system shutdown
%          window is displayed (defualt is 60 seconds). If numsec is
%          -1, then the command aborts a shutdown countdown currently
%          in progress.
%
% Notes: I find this function very useful for automatically turning
%        off my Windows computer after a long, unattended calculation
%        is complete. Of course, the usual issues with Windows processes
%        occasionally refusing to halt emerges, but when Matlab is
%        the only "serious" process executing, I find that the
%        SHUTDOWN function almost always works in turning off
%        the computer. The system shudown command is executed
%        with the appropriate options to force any running
%        applications to close, so be sure so save your data and close
%        other applications before beginning your unattended Matlab
%        calculation (and design your Matlab calculation to save its
%        own data before terminating). You can use this function BEFORE
%        starting your calculation, by estimating the required execution
%        time, or you can use this function AFTER the calculation
%        (recommended) by calling it when your calculation is complete.
%        I've used this function myself with no problems, but,
%        there are no warranties; use at your own risk.
%
% Michael Kleder, Oct 2005

function shutdown(varargin)
if nargin
   if isnumeric(varargin{1})
       if varargin{1} == -1
           evalc('!shutdown -a');
           return
       end
       t = ceil(varargin{1});
    else
       t = 60;
    end
else
   t = 60;
end
eval(['!shutdown -s -f -t ' num2str(t)])