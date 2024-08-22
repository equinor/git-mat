function tag(tag,msg,folPath,commit)
% Tag a commit
% function tag(tag,msg,folPath,commit)
%
% INPUT:
%  - tag     - Text tag
%  - msg     - Message accompanying tag
%
% OPTIONAL INPUT:
%  - folPath - Path to repo. Defaults to pwd.
%  - commit  - Short or long commit hash to a specific commit to tag.
%              Defaults to current commit.
%
% DESCRIPTION:
% Tag a commit.
% When tagging an older commit, the commit time stamp will be used as the
% git tag date, i.e., tags will appear in the same order in github as their
% commits are listed.
% NB! Tags are not pushed, use git('push --tags')
%
% EXAMPLE:
% tag('v1.0.0','chore: first build')

narginchk(2,4);

if ~exist('folPath','var') || isempty(folPath)
    folPath = pwd;
end

if GIT.isdirty(folPath)
    error('GIT:tag:dirtyFolder','Tagging while tree in %s is dirty is not supported',folPath);
else
    if isnumeric(tag) || isempty(tag)
        error('GIT:tag:tagNotChar','Input tag must be text');
    end
    if isnumeric(msg) || isempty(msg)
        error('GIT:tag:msgNotChar','Input msg must be text');
    end

    currDir = pwd;
    c = onCleanup(@()cd(currDir));
    cd(folPath);

    if nargin > 3 && ~isempty(commit)
        if isnumeric(commit)
            error('GIT:tag:commitNotChar','Input commit must be text');
        end
        if ~ischar(commit)
            commit = char(commit);
        end

        try
            currCheckout = GIT.getCurrBranch();
        catch
            currCheckout = char.empty;
        end

        if isempty(currCheckout)
            % For instance if head is detached
            currCheckout = GIT.getCurrCommit();
        end

        % This will output to command window
        c2 = onCleanup(@()git(['checkout ' currCheckout]));

        % Checkout the commit that shall be tagged
        tmp = git(['checkout ' commit]); %#ok<NASGU>

        if ispc
            % Get time stamp of commit
            [~,b] = git(['show -s --format=%aD ' commit]);
            % Tag commit with original time stamp used for tag
            system(['set GIT_COMMITTER_DATE="' strtrim(b) '" && git tag -a ' char(tag) ' -m"' char(msg) '" && set GIT_COMMITTER_DATE=""']);
        else
            % NB! No guarantee that this works, has not been tested
            % temporarily set the date to the date of the HEAD commit, and add the tag
            git(['GIT_COMMITTER_DATE="$(git show --format=%aD | head -1)" git tag -a ' char(tag) ' -m"' char(msg) '"']);
        end
    else
        git(['tag -a ' char(tag) ' -m "' char(msg) '"']);
    end
end