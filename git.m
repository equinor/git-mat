function varargout = git(varargin)
% GIT Execute a git command.
%
% GIT <ARGS>, when executed in command style, executes the git command and
% displays the git outputs at the MATLAB console.
%
% STATUS = GIT(ARG1, ARG2,...), when executed in functional style, executes
% the git command and returns the output status STATUS.
%
% [STATUS, CMDOUT] = GIT(ARG1, ARG2,...), when executed in functional
% style, executes the git command and returns the output status STATUS and
% the git output CMDOUT.

% Check output arguments.
nargoutchk(0,2)

if nargin > 0
    varargin = cellfun(@char,varargin,'UniformOutput',false);
    
    % Get the location of the git executable.
    gitPath = GIT.getBinFolder();
    
    % Construct the git command.
    if isempty(gitPath)
        cmdstr = strjoin(['git' varargin]);
    else
        cmdstr = strjoin([['"' fullfile(gitPath,'git.exe') '"'] varargin]);
    end
    
    % Execute the git command.
    [status, cmdout] = system(cmdstr);
    
    switch nargout
        case 0
            disp(cmdout)
        case 1
            varargout{1} = status;
        case 2
            varargout{1} = status;
            varargout{2} = cmdout;
    end
end