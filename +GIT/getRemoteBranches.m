function br = getRemoteBranches(folPath)
% Get name of remote branches
% function br = getRemoteBranches(folPath)
%
% OPTIONAL INPUT:
%  - folPath - Path to repo. Defaults to pwd.
%
% OUTPUT:
%  - br      - Name of remote branches
%
% DESCRIPTION:
% Get name of remote branches.

if nargin > 0 && ~isempty(folPath)
    if ~isfolder(folPath)
        error('GIT:getRemoteBranches:folderNotFound','Folder %s is not found',folPath);
    end
    currDir = pwd;
    c = onCleanup(@()cd(currDir));
    cd(folPath);
end

if ~GIT.isrepo()
    error('GIT:getRemoteBranches:notRepo','Folder %s does not contain a git repo.',pwd);
end

[s,br] = git('branch --remote');
if s > 0
    error("GIT:getRemoteBranches:failed","Something failed")
end
br = strtrim(strsplit(br,newline));
% remove empty lines
br(cellfun(@isempty,br)) = [];
% Remove origin/head
br(startsWith(br,"origin/HEAD -> ")) = [];