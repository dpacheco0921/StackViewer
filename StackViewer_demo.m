%% demo
%% 1) add paths

% it assumes you have already add the repository folders to your path
addpath(genpath(pwd))

%% 2) Move to folder and Download demo data

tDir = strrep(which('StackViewer_demo'), 'StackViewer_demo.m', '');
cd(tDir)

url = 'https://www.dropbox.com/s/xdj3w3m1vh8ytuu/demodata.zip?dl=1';
filename = 'demodata.zip';

if ~exist('demodata', 'dir')
    mkdir('demodata')
end
cd demodata

outfilename = websave(filename, url);
unzip(outfilename);
clear url outfilename

%% 3) visualize a single stack of 2 channels
cd(tDir)

floatIm = '20200319_1_Zstack';
floatDir = '.\demodata';
cha_n = 2;

stackviewer(floatIm, floatDir, [], [], 1, cha_n)
% stackviewer(floatIm, floatDir, fijiexeDir, ...
%   ijmDir, dir_depth, cha_n)

%% 4) overlay 4 stacks of 1 channel each
cd(tDir)

refIm = 'JFRC2.nrrd';
floatIm = {'VFB_00005401', 'VFB_00007748', ...
    'VFB_00014262'};

floatDir = {'.\demodata', '.\demodata', ...
    '.\demodata'};
refDir = '.\demodata';

overlayviewer(floatIm, refIm, [], [], floatDir, refDir)

% overlayviewer(floatIm, refIm, ...
%     sufloat, suref, floatDir, refDir, ...
%     videogate, idx2sel, fijiDir, imjDir)
