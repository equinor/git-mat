function rollBack(folPath,numCommits,forceReset)
% Roll back commits and reset repo.
% function rollBack(folPath,numCommits,forceReset)
%
% OPTIONAL:
%  - folPath    - Path to repo. Defaults to pwd.
%  - numCommits - Number of commits to roll back. Must be non-negative.
%  - forceReset - Set true to skip checking for dirty tree.
%
% DESCRIPTION:
% Roll back commits and reset repo.
% If numCommits == 0, only reset will be done.
% Checks if tree is dirty before rolling back.
%
% EXAMPLE:
% GIT.rollback();
% GIT.rollBack(pwd,0);
% GIT.rollBack(pwd,1);
% GIT.rollBack(pwd,1,true);

% VERSION:
%   - 0.9: Created by asmf, 04-Nov-20.

% Checks inputs and outputs:
narginchk(0,3)

if nargin > 0 && ~isempty(folPath)
    if ~isfolder(folPath)
        error('GIT:resetCommit:folderNotFound','Folder %s is not found',folPath);
    end
    currDir = pwd;
    c = onCleanup(@()cd(currDir));
    cd(folPath);
end

if ~exist('numCommits','var') || isempty(numCommits)
    numCommits = 0;
elseif numCommits < 0
    error('GIT:rollBack:invalidNumCommits','Number of commits to roll back must non-negative.');
end

if ~exist('forceReset','var') || isempty(forceReset)
    forceReset = false;
end

if ~GIT.isrepo()
    error('GIT:rollBack:notRepo','Folder %s does not contain a git repo.',pwd);
end

if forceReset || ~GIT.isdirty()
    reset = true;
else
    inp = input(sprintf('Repo tree %s is dirty, really reset local changes? Y/N [N]:',pwd),'s');
    if isempty(inp)
        inp = 'N';
    end
    reset = strcmp(inp,'Y');
end

if numCommits > 0
    [status,result] = git(sprintf('reset head~%d',numCommits));
    if ~(status == 0)
        disp(result)
        error('GIT:rollBack:failedResetHead','Failed resetting head');
    end
end

if reset
    [~,~] = git('reset --hard');
end