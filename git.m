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

% based on https://stackoverflow.com/a/42272702

% Check output arguments.
nargoutchk(0,2)

if nargin > 0
    varargin = cellfun(@char,varargin,'UniformOutput',false);
    varargin = varargin(~cellfun(@isempty,varargin));

    % Get the location of the git executable.
    gitPath = GIT.getBinFolder();

    % Construct the git command.
    if isempty(gitPath)
        cmdstr = strjoin(['git' varargin]);
    else
        cmdstr = strjoin([['"' fullfile(gitPath,'git.exe') '"'] varargin]);
    end

    if ismac
        % Change terminal type to ansi to avoid system call freezing while waiting for user input and later strip ANSI colors
        stripStr = ' | perl -pe ''s/\e\[[\x30-\x3f]*[\x20-\x2f]*[\x40-\x7e]//g;s/\e[PX^_].*?\e\\//g;s/\e\][^\a]*(?:\a|\e\\)//g;s/\e[\[\]A-Z\\^_@]//g;''';
        cmdstr = ['TERM=ansi; ' cmdstr stripStr];
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