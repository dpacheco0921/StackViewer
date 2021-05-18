function stackviewer(floatIm, floatDir, fijiexeDir, ...
    ijmDir, dir_depth, cha_n)
% stackviewer: uses ImajeJ to display Zstack
%
% Usage:
%   stackviewer(floatIm, floatDir, fijiexeDir, ...
%       ijmDir, dir_depth, cha_n)
%
% Args:
%   floatIm: floating image
%   	(default, [])
%   floatDir: floating image directory (full path)
%   	(default, [])
%   fijiexeDir: directory of FIJI executable (full path)
%   	(default, user defined at 'fiji_fullpath.m')
%   ijmDir: directory of FIJI macro imj file (full path)
%   	(default, fiji_fullpath)
%   dir_depth: depth of directory search
%   	(default, 0)
%   cha_n: number of channels
%   	(cha_n, 2)

if ~exist('dir_depth', 'var') || isempty(dir_depth)
    dir_depth = 0;
end

if ~exist('floatDir', 'var') || isempty(floatDir)
    if dir_depth == 0
        floatDir = ['.', filesep];
    elseif dir_depth == 1
        floatDir = ['.', filesep, '*', ...
            filesep];
    elseif dir_depth == 2
        floatDir = ['.', filesep, '*', ...
            filesep, '*', filesep];
    end
end

if ~exist('fijiexeDir', 'var')
    fijiexeDir = [];
end

if ~exist('ijmDir', 'var')
    ijmDir = [];
end

if ~exist('cha_n', 'var')
    cha_n = 2;
end

if isempty(fijiexeDir) || isempty(ijmDir)
    stvpars.ij = fiji_fullpath;
    repoDir = which('StackViewer_demo');
    repoDir = strrep(repoDir, 'StackViewer_demo.m', '');
    stvpars.converterScript = ...
        [repoDir, 'utilities\stackviewer.ijm'];
else
    stvpars.ij = fijiexeDir;
    stvpars.converterScript = ijmDir;    
end

stvpars.cha_n = cha_n;
stvpars.iDir = floatDir;
if stvpars.iDir(end) ~= filesep
    stvpars.iDir(end+1) = filesep;
end

% get file dir
floatIm = strrep(floatIm, '.nrrd', '');
fIm = rdir([stvpars.iDir, floatIm, '.nrrd']);
fIm = {fIm.name};

if isempty(fIm)
	fprintf('No floating images found in: \n')
    stvpars.iDir
end

[fIm, stvpars.iDir] = split_path(fIm);
stvpars.iDir = stvpars.iDir{1};
if stvpars.iDir(end) ~= filesep
    stvpars.iDir(end+1) = filesep;
end

% Run overlay
if numel(fIm) < 2
    
    [~, prem] = nrrdread([stvpars.iDir, fIm{1}]);
    
    prem = prem.sizes;
    sprem = strsplit2(prem, ' ');
    stvpars.z_n = str2double(sprem{3})/stvpars.cha_n;
    stvpars.z_n = num2str(stvpars.z_n);
    
    clear prem;
    
    mat2imj(fIm{1}, stvpars);
    
else
    
    fprintf('There are more than one possible options')
    
end

end

function mat2imj(floatIm, iparams)
% mat2imj: use ij to plot image
%
% Usage:
%   mat2imj(fIm, iparams)
%
% Args:
%   floatIm: floating image
%   iparams: input parameters
%       (iDir, z_n, cha_n, ij, converterScript)

% add input arg
inputarg = [strrep(iparams.iDir, ['.', filesep], [pwd, filesep]), ...
    '*', iparams.z_n, '*', num2str(iparams.cha_n), '*', floatIm];

% execute
CommandStr = sprintf('%s -macro %s %s', iparams.ij, ...
    iparams.converterScript, inputarg);
coexecuter(CommandStr)

end
