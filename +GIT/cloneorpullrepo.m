function cloneorpullrepo(folPath,update,repo,branch,verbose)
% Clone or fetch repo
% function cloneorpullrepo(folPath,update,repo,branch,verbose)
%
% INPUT:
%  - folPath - Path to folder
%
% OPTIONAL INPUT:
%  - update  - Set true to pull if already cloned.
%  - repo    - URL to repo.
%              Defaults to sprintf('https://github.com/Equinor/%s.git',folPath)
%  - branch  - Defaults to current branch.
%  - verbose - Set false to silence status output.
%              Defaults to true
%
% DESCRIPTION:
% Hint: Call function from folder where repo shall be cloned and use
% relative folder path.
%
% Will first try to pull using ff.
%
% EXAMPLE:
% GIT.cloneorpullrepo(pwd);

narginchk(1,5);

if isempty(folPath) || (isstring(folPath) && strlength(folPath) == 0)
    error("GIT:cloneorpullrepo:invalidInput", "Input folPath can not be empty.")
end

if ~exist('verbose','var') || isempty(verbose)
    verbose = true;
end

if ~exist('branch','var')
    branch = "";
end
branch = string(branch);

if ~exist('update','var')
    update = false;
else
    if exist('repo','var') && ~isempty(repo) && (islogical(repo) || isnumeric(repo))
        % input repo which previously was update seems to contain an order
        if ischar(update) || isstring(update)
            % additionally input update seems to be a repo
            tmp_repo = update;
            update = repo;
            repo = tmp_repo;
        elseif isempty(update)
            % update is empty
            update = repo;
        end
        warning("GIT:cloneorpullrepo:inputOrder","Verify if inputs repo and update are swapped.");
    end
    update = logical(update);
end

if ~exist('repo','var')
    repo = "";
end
repo = string(repo);

if strcmp(folPath,".")
    folPath = pwd;
end

if ~isfolder(folPath)
    if strlength(repo) == 0
        tmp_folpath = folPath;
        if contains(tmp_folpath,filesep)
            [~, tmp_folpath] = fileparts(tmp_folpath);
        end
        repo = sprintf('https://github.com/Equinor/%s.git',tmp_folpath);
    end
    git('clone',repo,folPath)
    if strlength(branch) == 0 && ~strcmp(branch,'master')
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
        if s == 0
            if contains(out,"Already up to date")
                if verbose
                    fprintf(1,'Repo %s, branch %s is already up to date\n',folPath,branch);
                end
                TF = true;
            elseif contains(out,sprintf('Fast-forward%s',newline))
                TF = true;
                if verbose
                    disp(out)
                end
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