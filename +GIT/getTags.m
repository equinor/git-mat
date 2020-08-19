function tags = getTags(folPath)
% Get list of tags for repo
% function tags = getTags(folPath)
%
% OPTIONAL INPUT:
%  - folPath - Path where repo is located. Defaults to pwd.
%
% OUTPUT:
%  - tags    - List of tags. Sorted from old to new.
%
% DESCRIPTION:
% Get list of tags for repo
% Fetches tags from remote and returns result of git tag

if nargin > 0 && ~isempty(folPath)
    if ~isfolder(folPath)
        error('GIT:getTags:folderNotFound','Folder %s is not found',folPath);
    end
    currDir = pwd;
    c = onCleanup(@()cd(currDir));
    cd(folPath);
end

tmp = git('fetch --all --tags'); %#ok<NASGU>
[~,tags] = git('tag');

tags = strsplit(tags,newline);
tags = strtrim(tags);
tags(cellfun(@isempty,tags)) = [];
end