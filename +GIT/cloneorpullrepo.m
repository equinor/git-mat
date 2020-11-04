function cloneorpullrepo(folPath,repo,update,branch,verbose)
% Clone or fetch repo
% function cloneorpullrepo(folPath,repo,update,branch,verbose)
%
% INPUT:
%  - folPath - Path to folder
%
% OPTIONAL INPUT:
%  - update  - Set true to pull
%  - repo    - URL to repo.
%              Defaults to sprintf('https://github.com/Equinor/%s.git',folPath)
%  - branch  - Defaults to 'master'
%  - verbose - Set false to silence status output.
%              Defaults to true
%
% DESCRIPTION:
% Hint: Call function from folder where repo shall be cloned and use
% relative folder path
%
% EXAMPLE:
% GIT.cloneorpullrepo(pwd);

narginchk(1,5);

if ~exist('update','var') || isempty(update)
    update = false;
end

if ~exist('branch','var') || isempty(branch)
    branch = 'master';
end

if ~exist('verbose','var') || isempty(verbose)
    verbose = true;
end

if ~isfolder(folPath)
    if nargin < 2 || isempty(repo)
        repo = sprintf('https://github.com/Equinor/%s.git',folPath);
    end
    git('clone',repo,folPath)
    if ~strcmp(branch,'master')
        git(['checkout ' branch]);
    end
elseif update
    % todo: get remote?
    currBranch = GIT.getCurrBranch(folPath);
    if ~strcmp(currBranch,branch)
        warning('cloneGitInterFaces:notInMasterBranch','Repo %s is not updated because not in branch %s',folPath,branch);
        return
    end
    
    if GIT.isdirty(folPath)
        warning('cloneGitInterFaces:dirtyTree','Repo %s is not updated because tree is dirty',folPath);
        return
    end
    
    [ahead,behind] = GIT.compareRemote(folPath,currBranch);
    if ahead > 0
        warning('cloneGitInterFaces:localAhead','Repo %s is not updated because local is ahead of remote',folPath);
        return
    end
    
    if behind > 0
        currDir = pwd;
        c = onCleanup(@()cd(currDir));
        cd(folPath);
        if verbose
            fprintf(1,'Pulls branch %s from %s\n',branch,folPath);
        end
        git('pull');
    else
        if verbose
            fprintf(1,'Repo %s is already up to date\n',folPath);
        end
    end
end