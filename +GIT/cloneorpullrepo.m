function cloneorpullrepo(folPath,repo,update,branch)
% Clone or fetch repo
% function cloneorpullrepo(folPath,repo,update,branch)
%
% INPUT:
%  - folPath - Path to folder
%
% OPTIONAL INPUT:
%  - update  - Set true to pull
%  - repo    - URL to repo.
%              Defaults to sprintf('https://github.com/Equinor/%s.git',folPath)
%  - branch  - Defaults to 'master'
%
% DESCRIPTION:
% Hint: Call function from folder where repo shall be cloned and use
% relative folder path
%
% EXAMPLE:
% GIT.cloneorpullrepo(pwd);

narginchk(1,4);

if nargin < 3
    update = false;
end
        
if nargin < 4
    branch = 'master';
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
    currBranch = GIT.getCurrBranch(folPath);
    if ~strcmp(currBranch,branch)
        warning('cloneGitInterFaces:notInMasterBranch','Repo %s is not updated because not in branch %',folPath,branch);
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
        fprintf(1,'Pulls branch %s from repo %s\n',branch,folPath);
        git('pull');
    else
        fprintf(1,'Repo %s is already up to date\n',folPath);
    end
end