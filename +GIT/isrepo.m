function TF = isrepo(folPath)
% Check if a folder is part of a git repo
% function TF = isrepo(folPath)
%
% OPTIONAL INPUT:
%  - folPath - Folder to check. Defaults to pwd.
%
% OUTPUT:
%  - TF      - True if folder is part of a git repo
%
% DESCRIPTION:
% Check if a folder is part of a git repo

if nargin > 0 && ~isempty(folPath)
    if ~isfolder(folPath)
        error('GIT:isrepo:folderNotFound','Folder %s is not found',folPath);
    end
    currDir = pwd;
    c = onCleanup(@()cd(currDir));
    cd(folPath);
end

[status,~] = system('git status -s');
TF = status == 0;