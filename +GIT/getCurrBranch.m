function br = getCurrBranch(folPath)
% Get name of current branch
% function br = getCurrBranch(folPath)
%
% OPTIONAL INPUT:
%  - folPath - Path to repo. Defaults to pwd.
%
% OUTPUT:
%  - br      - Name of checked out branch
%
% DESCRIPTION:
% Get name of current branch

if nargin > 0 && ~isempty(folPath)
    if ~isfolder(folPath)
        error('GIT:getCurrBranch:folderNotFound','Folder %s is not found',folPath);
    end
    currDir = pwd;
    c = onCleanup(@()cd(currDir));
    cd(folPath);
end

if ~GIT.isrepo()
    error('GIT:getCurrBranch:notRepo','Folder %s does not contain a git repo.',pwd);
end

[~,br] = git('symbolic-ref --short HEAD');
br = strtrim(br);