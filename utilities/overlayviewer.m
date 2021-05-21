function overlayviewer(floatIm, refIm, ...
    sufloat, suref, floatDir, refDir, ...
    videogate, idx2sel, fijiDir, imjDir)
% overlayviewer: overlays up to 8 volumes using imageJ
%
% Usage:
%   overlayviewer(floatIm, refIm, ...
%      sufloat, suref, floatDir, refDir, ...
%      videogate, idx2sel, fijiDir, imjDir)
%
% Args:
%   floatIm: floating image(s) (1st: red, 2nd: green)
%   refIm: reference image (gray)
%   sufloat: suffix floating image
%   suref: suffix reference image
%   floatDir: floating image directory
%   refDir: reference image directory
%   videogate: gate to make video
%   idx2sel: float image indeces to use
%   fijiDir: directory of FIJI executable (full path)
%   imjDir: directory of FIJI macro imj file (full path)

% default params

if ~exist('suref', 'var')
    suref = [];
end

if ~exist('sufloat', 'var')
    sufloat = [];
end

if ~exist('floatDir', 'var') || ...
        isempty(floatDir)
    floatDir = {['.', filesep]};
end

if ~exist('refDir', 'var') || isempty(refDir)
    refDir = ['.', filesep];
end

if ~exist('videogate', 'var') || isempty(videogate)
    videogate = 0;
end

if ~exist('idx2sel', 'var') || isempty(idx2sel)
    idx2sel = [];
end

if ~exist('fijiDir', 'var') || isempty(fijiDir)
    fijiDir = [];
end

if ~exist('imjDir', 'var') || isempty(imjDir)
    imjDir = [];
end

p.cDir = pwd;
p.videogate = videogate;
p.maxfloatIm = 8;
suffix2del = 'cb'; %'_02_'; % remove all 2nd channels

% getting rname
cd(refDir)

if ~isempty(refIm)
    if ~contains(refIm, 'nrrd')
        refIm = rdir(['.', filesep, '*', refIm, '*.nrrd']);
    else
        refIm = rdir(['.', filesep, '*', refIm]);
    end
else
    refIm = rdir(['.', filesep, '*.nrrd']);
end

refIm = str2match(suref, refIm);
refIm = str2rm(suffix2del, refIm);
refIm = refIm(1).name;
refIm = strrep(refIm, ['.', filesep], '');

% collect full Im directory
p.refDir = pwd;
cd(p.cDir)

% getting fname
if ~iscell(floatDir)
   floatDir = {floatDir}; 
end

if ~isempty(floatIm)
    
    if iscell(floatIm)
        
        if length(floatIm) ~= length(floatDir)
            floatDir = repmat(floatDir, [1, length(floatIm)]);
        end
        
        floatIm_int = [];
        
        for ic = 1:numel(floatIm)
            
            cd(floatDir{ic})
            floatDir{ic} = pwd;
            
            if isempty(strfind(floatIm{ic}, 'nrrd'))
                fImt = rdir(['.', filesep, ...
                    '*', floatIm{ic}, '*.nrrd']);
            else
                fImt = rdir(['.', filesep, ...
                    '*', floatIm{ic}]);
            end
            
            if ic == 1
                floatIm_int = fImt;
            else
                floatIm_int = cat(1, floatIm_int, fImt);
            end
            
            cd(p.cDir)
            
        end
        
    else
        
        cd(floatDir{1})
        floatDir{1} = pwd;
        
        if ~contains(floatIm, 'nrrd')
            floatIm_int = rdir(['.', filesep, ...
                '*', floatIm, '*.nrrd']);
        else
            floatIm_int = rdir(['.', filesep, ...
                '*', floatIm]);
        end
        
    end
    
else
    
    cd(floatDir{1})
    floatDir{1} = pwd;
    floatIm_int = rdir(['.', filesep, '*.nrrd']);
    
end

floatIm_int = str2match(sufloat, floatIm_int);
floatIm_int = str2rm(suffix2del, floatIm_int);
floatIm_int = {floatIm_int.name};
floatIm_int = strrep(floatIm_int, ['.', filesep], '');

if ~isempty(idx2sel)
    floatIm_int = floatIm_int(idx2sel);
end

% collect full Im directory
if numel(floatIm_int) > 1 && numel(floatDir) == 1
    floatDir = repmat(floatDir, [1, numel(floatIm_int)]);
end

p.floatDir = floatDir;
cd(p.cDir)

% getting image info
cd(p.refDir)
[~, prem] = nrrdread(refIm);
prem = prem.sizes;
sprem = strsplit2(prem, ' ');
p.znum = sprem{3};
clear prem;
cd(p.cDir)

% Run overlay
if numel(floatIm_int) <= p.maxfloatIm
    
    mat2imj(refIm, floatIm_int, fijiDir, imjDir, p);
    
else
    
    fprintf(['Found ', ...
        num2str(numel(floatIm_int)), ...
        ' floating images\n'])
    
end

end

function mat2imj(refIm, floatIm, fijiDir, imjDir, iparams)
% mat2imj: use ij to plot image
%
% Usage:
%   mat2imj(refIm, fIm, fijiDir, imjDir, p)
%
% Args:
%   refIm: reference image (gray)
%   floatIm: floating image(s) (1st: red, 2nd: green)
%   fijiDir: directory of FIJI executable (full path)
%   imjDir: directory of FIJI macro imj file (full path)
%   iparams: input parameters

% Directories
if ~isempty(fijiDir) && ~isempty(imjDir)

    stvpars.ij = fijiDir;
    stvpars.converterScript = imjDir;  
    
else
    
    if ~exist('fiji_fullpath.m', 'file')
       fprintf('fiji_fullpath.m does not exist, edit fiji_fullpathtoedit.m or add paths')
    end
    
    stvpars.ij = fiji_fullpath;
    repoDir = which('StackViewer_demo');
    repoDir = strrep(repoDir, 'StackViewer_demo.m', '');
    stvpars.converterScript = ...
        [repoDir, 'utilities\overlayviewer.ijm'];
    
end

% displaying which files are taking into account and their order
fprintf(['Ref Im ', refIm, '\n']);

for i = 1:numel(floatIm)
	fprintf(['Float Im ', num2str(i), ' ', floatIm{i}, '\n']);
end

% parsing inputs

% total number of images (refIm + floatIm)
FNum = num2str(numel(floatIm) + 1);
inputarg = [iparams.znum, '*', FNum, '*', num2str(iparams.videogate), ...
    '*', iparams.refDir, filesep, '*', refIm, ...
    '*', iparams.floatDir{1}, filesep, '*', floatIm{1}];

if numel(floatIm) > 1
    
    for i = 2:numel(floatIm)
        inputarg = [inputarg, '*', iparams.floatDir{i}, filesep, '*', floatIm{i}];
    end
    for i = (numel(floatIm) + 1):iparams.maxfloatIm
        inputarg = [inputarg, '*', 'empty', '*', 'empty'];
    end
    
else
    
    for i = (numel(floatIm) + 1):iparams.maxfloatIm
        inputarg = [inputarg, '*', 'empty', '*', 'empty'];
    end
    
end

% add repo directory
inputarg = [inputarg, '*', strrep(stvpars.converterScript, 'overlayviewer.ijm', '')];

% execute
CommandStr = sprintf('"%s" -macro "%s" "%s"', stvpars.ij, stvpars.converterScript, inputarg);

if ispc
    system(CommandStr)
else
    unix(CommandStr)
end

end

function [i_file, sel_idx] = str2match(i_str, i_file, mtype)
% str2match: function to find group of strings with overlapping names
%
% Usage:
%   [i_file, sel_idx] = str2match(i_str, i_file, mtype)
%
% Args:
%   i_str: is a string or a cell of strings (pattern to look for)
%   i_file: is a string or a cell of strings (input files)
%   mtype: ignore case
%       (1: ignore lower/cap case)
%       (0: otherwise, default)
% 
% Returns:
%   i_file: subset of i_file that matches i_str
%   sel_idx: indeces of selected i_file

if ~exist('mtype', 'var') || isempty(mtype); mtype = 0; end

if ~isempty(i_str)
    
    if ~iscell(i_str); i_str = {i_str}; end
    
    Strnum = numel(i_str);
    
    for Str_idx = 1:Strnum
        
        if iscell(i_file)
            
            if mtype
                BinM = strcmpi(i_file, i_str{Str_idx});
            else
                BinM = contains(i_file, i_str{Str_idx});
            end
            
        else
            
            if mtype
                BinM = strcmpi(i_file, i_str{Str_idx});
            else
                BinM = contains({i_file.name}, i_str{Str_idx});
            end
            
        end
        
        if sum(BinM) == 0
            fprintf('No Match\n');
        else
            f2keep(Str_idx, :) = BinM;
        end
        
    end
    
    if exist('f2keep', 'var')
        
        sel_idx = sum(f2keep, 1) > 0;
        i_file(~sel_idx) = [];
        clear Str2Del
        
    else
        
        i_file(:) = [];
        sel_idx = true(numel(i_file), 1)';
        
    end
    
else
    
    sel_idx = true(numel(i_file), 1)';
    
end

end

function i_file = str2rm(i_str, i_file)
% str2rm: function to find group of strings with
%   non-overlapping names to i_str
%
% Usage:
%   i_file = str2rm(i_str, i_file)
%
% Args:
%   i_str: is a string or a cell of strings (pattern to remove)
%   i_file: is a string or a cell of strings (input files)
% 
% Returns:
%   i_file: subset of i_file that matches i_str

if ~isempty(i_str)
    
    if ~iscell(i_str)
        i_str = {i_str};
    end
    
    Strnum = numel(i_str);
    
    if isstruct(i_file)
        
        for i = 1:Strnum
            file2clear = strfind({i_file.name}, i_str{i});
            i_file(~cellfun(@isempty, file2clear)) = [];
            clear file2clear
        end
        
    else
        
        for i = 1:Strnum
            file2clear = strfind(i_file, i_str{i});
            i_file(~cellfun(@isempty, file2clear)) = [];
            clear file2clear
        end
        
    end
    
else
    
    %fprintf('no input str \n')
    
end

end
