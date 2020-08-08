function folPath = getBinFolder()
% Get path to git binary folder on windows machine (ispc)
% function folPath = getBinFolder()
%
% OUTPUT:
%  - folPath - Path to git binary folder
%
% DESCRIPTION:
% NB! Only implemented for windows (ispc == true)
% Returns empty for mac/linux. Git is assumed to be available on
% bash/terminal path.

persistent fol

if isempty(fol)
    fol = char.empty;
end

if ispc
    if isempty(fol)
        allUsers = fullfile(strtrim(evalc('!echo %PROGRAMFILES%')),'Git','bin');
        if isfolder(allUsers)
            fol = allUsers;
        else
            currUser = fullpath(fullfile(strtrim(evalc('!echo %APPDATA%')),'..','Local','Programs','Git','bin'));
            if isfolder(currUser)
                fol = currUser;
            end
        end
    end
else
    fol = char.empty;
end

folPath = fol;