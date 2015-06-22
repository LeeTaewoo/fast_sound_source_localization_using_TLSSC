% Release date: May 2015
% Author: Taewoo Lee, (twlee@speech.korea.ac.kr)
%
% Copyright (C) 2015 Taewoo Lee
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <http://www.gnu.org/licenses/>.
clc; clear all; close all;

filelist= ld_vadlist();
nfile= size(filelist,1);

threshold = 0.8; % Decision threshold of the likelihood ratio test
win_dur = 0.256; % Window duration in seconds
hop_dur = 0.128; % Hop duration in seconds
num_noise = 1;  % Number of noise frames at the beginning of file
argin = 1;       % Noise estimation (1: enable, 0: disable)

for i=1:nfile
    wav_file= filelist{i,1};
    results= VAD(wav_file,threshold,win_dur,hop_dur,num_noise,argin);
    len= length(wav_file);
    save_filename= [wav_file(1:len-4) '_VAD.mat'];
    save(save_filename,'results');
end
