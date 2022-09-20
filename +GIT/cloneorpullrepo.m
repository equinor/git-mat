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
%  - branch  - Defaults to current branch.
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

if ~exist('branch','var')
    branch = '';
end

if ~exist('verbose','var') || isempty(verbose)
    verbose = true;
end

if ~isfolder(folPath)
    if nargin < 2 || isempty(repo)
        repo = sprintf('https://github.com/Equinor/%s.git',folPath);
    end
    git('clone',repo,folPath)
    if ~isempty(branch) && ~strcmp(branch,'master')
        git(['checkout ' branch]);
    end
elseif update
    currBranch = GIT.getCurrBranch(folPath);

    if isempty(branch)
        branch = currBranch;
    end

    if ~strcmp(currBranch,branch)
        warning('cloneorpullrepo:wrongBranch','Repo %s is not updated because local branch is %s, not %s',folPath,currBranch,branch);
        return
    end

    if pull(true)
        return
    end

    [ahead,behind] = GIT.compareRemote(folPath,currBranch);
    if ahead < 0 && behind < 0
        warning('cloneorpullrepo:localBranch','Repo %s, branch %s is only local. Not possible to update\n',folPath,branch);
        return
    end

    if ahead > 0
        warning('cloneorpullrepo:localAhead','Repo %s is not updated because local is ahead of remote',folPath);
        return
    end

    if GIT.isdirty(folPath)
        % todo: pull(true) could return output which actually knows what
        % files would be overwritten
        warning('cloneorpullrepo:dirtyTree','Repo %s is not updated because tree is dirty and local files would be overwritten by merge',folPath);
        return
    end

    if behind > 0
        pull(false);
    else
        if verbose
            fprintf(1,'Repo %s, branch %s is already up to date\n',folPath,branch);
        end
    end
end

    function TF = pull(ff)
        currDir = pwd;
        c = onCleanup(@()cd(currDir));
        cd(folPath);
        if verbose
            if ff
                fprintf(1,'Attempts to fast-forward branch %s from %s\n',branch,folPath);
            else
                fprintf(1,'Pulls branch %s from %s\n',branch,folPath);
            end
        end

        TF = false;
        if ff
            [s,out] = git('pull --ff-only');
        else
            [s,out] = git('pull');
        end
        % if fast forward fails, s will not be 0
        if isa(s,'double') && s == 0
            if contains(out,"Already up to date")
                if verbose
                    fprintf(1,'Repo %s, branch %s is already up to date\n',folPath,branch);
                end
                TF = true;
            elseif contains(out,sprintf('Fast-forward%s',newline))
                TF = true;
            else
                % disp(out)
            end
        else
            % Check if branch exists, typically master has become main
            remBranches = GIT.getRemoteBranches();
            if ~contains(remBranches,sprintf('origin/%s',GIT.getCurrBranch()))
                if strcmp(GIT.getCurrBranch(),'master')
                    if contains(remBranches,'origin/main')
                        if verbose
                            fprintf(1,'Branch master has been renamed to main in remote. Renames local branch.')
                        end
                        git('branch -m main');
                        git('branch main --set-upstream-to origin/main');
                        TF = pull(ff);
                    end
                end
            end
        end
    end
end