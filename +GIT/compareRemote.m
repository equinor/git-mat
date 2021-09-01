function [ahead, behind] = compareRemote(folPath,branch)
% Get number of commits differing between local and remote git repo
% function [ahead, behind] = compareRemote(folPath,branch)
%
% OPTIONAL INPUT:
%  - folPath - Folder to compare. Defaults to pwd.
%  - branch  - Branch to compare. Defaults to GIT.getCurrBranch()
%
% OUTPUT:
%  - ahead  - Number of commits local is ahead of remote
%  - behind - Number of commits remote has that are not in local
%
% DESCRIPTION:
% Get number of commits differing between local and remote git repo
% Summary of result from git branch -vv

narginchk(0,2);
nargoutchk(0,2);

if nargin > 0 && ~isempty(folPath)
    if ~isfolder(folPath)
        error('GIT:getCurrBranch:folderNotFound','Folder %s is not found',folPath);
    end
    currDir = pwd;
    c = onCleanup(@()cd(currDir));
    cd(folPath);
end

if nargin < 2 || isempty(branch)
    branch = GIT.getCurrBranch();
end

if ~GIT.isrepo()
    error('GIT:compareRemote:notRepo','Folder %s does not contain a git repo.',pwd);
end

[~,~] = git('fetch --all');
[~,~] = git('fetch --prune');
[~,result] = git('branch -vv');
C = cellfun(@strtrim,strsplit(result,newline),'UniformOutput',false);
indBranch = startsWith(C,[branch ' ']) | startsWith(C,['* ' branch ' ']);
ahead = -1;
behind = -1;
if any(indBranch)
    if contains(C{indBranch},'[')
        branchStatus = C{indBranch};
        if contains(branchStatus,'ahead')
            ahead = str2double(replace(regexp(branchStatus,'ahead [\d]+','match'),'ahead ',''));
        else
            ahead = 0;
        end
        if contains(branchStatus,'behind')
            behind = str2double(replace(regexp(branchStatus,'behind [\d]+','match'),'behind ',''));
        else
            behind = 0;
        end
    end
end