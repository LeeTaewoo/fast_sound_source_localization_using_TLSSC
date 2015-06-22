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

[SrcSignalVec, Fs]= wavread('LDC93S1.wav');
M=16;
amp_rate= 90.0;

mk_ISM_RIRs(Fs);
mk_dir;
wav_length= size(SrcSignalVec,1);
RIRlist= ld_RIRlist();
nRIR= size(RIRlist,1);
for i=1:nRIR
    RIRfn= RIRlist{i};
    fprintf('%s\n',RIRfn);
    AuData= ISM_AudioData(RIRfn,SrcSignalVec);
    for j=1:M
        str= sprintf('out%02d.wav',j-1);
        wavwrite(AuData(1:wav_length,j)*amp_rate + 0.001*randn(wav_length,1),Fs,str);
        direction= RIRfn(12:14);
        distance= RIRfn(16:17);
        height= RIRfn(19:23);
        reverberation= RIRfn(25:33);
        destination= ['./TL-SSC_simul_data/' direction '/' distance '/' height '/' reverberation];
        movefile(['./' str],destination);
    end
end