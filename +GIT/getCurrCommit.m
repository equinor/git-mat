function br = getCurrCommit(folPath)
% Get short hash of current commit
% function br = getCurrCommit(folPath)
%
% OPTIONAL INPUT:
%  - folPath - Path to repo. Defaults to pwd.
%
% OUTPUT:
%  - has     - Short hash of current commit
%
% DESCRIPTION:
% Get short hash of current commit

if nargin > 0 && ~isempty(folPath)
    if ~isfolder(folPath)
        error('GIT:getCurrCommit:folderNotFound','Folder %s is not found',folPath);
    end
    currDir = pwd;
    c = onCleanup(@()cd(currDir));
    cd(folPath);
end

if ~GIT.isrepo()
    error('GIT:getCurrCommit:notRepo','Folder %s does not contain a git repo.',pwd);
end

[~,br] = git('rev-parse --short HEAD');
br = strtrim(br);