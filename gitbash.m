function gitbash(folPath)
% Open git bash/terminal in current folder
% function gitbash(folPath)
%
% DESCRIPTION:
% Open git bash/terminal in current folder
%
% EXAMPLE:
% gitbash();

% VERSION:
%   - 1.2: Update by asmf. Refactored and added input folPath
%   - 1.1: Update by asmf. Works for mac as well
%   - 1.0: Update by asmf, 28-Jul-19. Searches more locations for
%   git-executable.
%   - 0.9: Created by asmf, 23-Nov-18.

if nargin > 0
    currDir = pwd;
    c = onCleanup(@()cd(currDir));
    cd(folPath);
end

if ispc
    folPath = GIT.getBinFolder();
    if isempty(folPath)
        error('gitbash:gitNotFound','Git is not found.');
    end
    
    % What is the difference of these bash-windows?
    system(sprintf('start "" "%s" --login',fullfile(GIT.getBinFolder,'sh.exe')));
    %     system(sprintf('start "" "%s" --login',fullfile(GIT.getBinFolder,'bash.exe')));
    %     system([fullfile(getGitFolder,'..','git-bash.exe') '&']);
elseif ismac
    % cheating by only opening terminal
    strActivateTermina = '''tell application "Terminal"'''; % to activate''';
    strChangeFol = ['''do script "cd ''' pwd '''" '''];
    str = ['osascript -e ' strActivateTermina ' -e activate' ' -e ' strChangeFol ' -e  ''end tell'''];
    system(str);
end