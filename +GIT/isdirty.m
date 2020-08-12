 function [TF, T] = isdirty(folPath)
% Check if there are changes not committed in tree
% function [TF,T] = isdirty(folPath)
%
%  - folPath - Path to repo. Defaults to pwd.
%
% OUTPUT:
%  - TF - True if any files are modified, removed or
%  - T  - Parsed result from git status -s
%
% DESCRIPTION:
% Check if there are changes not committed in tree.
% NB! Does not compare against remote.

if nargin > 0 && ~isempty(folPath)
    if ~isfolder(folPath)
        error('GIT:isdirty:folderNotFound','Folder %s is not found',folPath);
    end
    currDir = pwd;
    c = onCleanup(@()cd(currDir));
    cd(folPath);
end

if ~GIT.isrepo()
    error('GIT:isdirty:notRepo','Folder %s does not contain a git repo.',pwd);
end
% git status is porcelain, should use plumbing
% https://stackoverflow.com/questions/3878624/how-do-i-programmatically-determine-if-there-are-uncommitted-changes
[~,out] = git('status -s');

TF = ~isempty(out);
if nargout > 1
    T = parseStatus(out);
end
end
function T = parseStatus(status)

% X          Y     Meaning
% -------------------------------------------------
%          [AMD]   not updated
% M        [ MD]   updated in index
% A        [ MD]   added to index
% D                deleted from index
% R        [ MD]   renamed in index
% C        [ MD]   copied in index
% [MARC]           index and work tree matches
% [ MARC]     M    work tree changed since index
% [ MARC]     D    deleted in work tree
% [ D]        R    renamed in work tree
% [ D]        C    copied in work tree
% -------------------------------------------------
% D           D    unmerged, both deleted
% A           U    unmerged, added by us
% U           D    unmerged, deleted by them
% U           A    unmerged, added by them
% D           U    unmerged, deleted by us
% A           A    unmerged, both added
% U           U    unmerged, both modified
% -------------------------------------------------
% ?           ?    untracked
% !           !    ignored
% -------------------------------------------------
if ~isempty(status)
    str = strsplit(status,newline);
    str = cellfun(@strtrim,str,'UniformOutput',false);
    str(cellfun(@isempty,str)) = [];
    C = str(:);
    C = replace(C,'  ',' ');
    C = replace(C,' -> ','->');
    D = cellfun(@strsplit,C,'UniformOutput',false);
    T = cell2table(cat(1,D{:}),'VariableNames',{'Status','File'});
end
end