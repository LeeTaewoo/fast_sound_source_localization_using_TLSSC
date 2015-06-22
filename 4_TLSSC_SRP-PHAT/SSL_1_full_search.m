function []=SSL_1_full_search(dataset_dir,tdoa_table_dir,tolerance)
% Input: cartCoords.mat, TDOA_table.mat, ~/VADed_data.mat
% Output: ./log/full_search.txt
%
% Reference:
% J. Dmochowski, J. Benesty, and S. Affes, "A generalized steered response 
% power method for computationally viable source localization," 
% IEEE Transactions on Audio, Speech, and Language Processing, vol. 15, 
% pp. 2510-2526, 2007.
%
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

DEBUG= 1;
error_tolerance= tolerance.theta;    %degree
error_tolerance_phi= tolerance.phi;  %degree
load([tdoa_table_dir '/cartCoords.mat']);
load([tdoa_table_dir '/TDOA_table.mat']);
TDOA_table= TDOA_table'; % For improving memory access pattern.
filelist= ld_vadlist(dataset_dir);
nfile= size(filelist,1);

diary('off');
delete('./log/full_search.txt');
if exist('./log','dir')
    rmdir('./log','s');
end
mkdir('./log');
diary('./log/full_search.txt');
disp('Full-search (forward mapping SRP-PHAT)');
time= clock;
fprintf('%s, %d:%d\n',date,time(4),time(5));

for i=1:nfile  
    filename= filelist{i,1};
    fnlen= size(filename,2);
    disp(filename);
    vadframe_filename= [filename(1:fnlen-9) 'VADed_data.mat'];
    load(vadframe_filename);
    
    ans_r= str2num(vadframe_filename(43)) * 1000;
    ans_height= 1700 - 400;
    ans_phi= (rad2deg(atan2(ans_height,ans_r)));
    ans_theta= str2num(vadframe_filename(39:41));
    if (DEBUG==1)
        fprintf('ans_theta=%d, ans_phi=%.2f, ans_r=%d\n', ...
                 ans_theta,ans_phi,ans_r);
    end
    
    M= size(f2,1);
    nFrame= size(f2{1,1},1);
    T= size(f2{1,1},2);
    
    nCorrectFrame_theta= 0; 
    nCorrectFrame_phi= 0; 
    nCorrectFrame= 0;
    t1= clock;
    for f=1:nFrame
        input_frames= zeros(M,T);
        for m=1:M
            input_frames(m,:)= f2{m,1}(f,:);
        end
        
        % Search (SRP-PHAT forward mapping)
        I= srp_phat_forward_map(input_frames,TDOA_table);
        
        [t,p,r]= cart2sph(cartCoords(I,1),cartCoords(I,2),cartCoords(I,3));
        theta= floor(abs(rad2deg(t)));
        phi= floor(abs(rad2deg(p)));
        
        % Error count
        error_theta= abs(ans_theta-theta);
        error_phi= abs(ans_phi-phi);
        if (error_theta<=error_tolerance)
            nCorrectFrame_theta= nCorrectFrame_theta+1;
        end
        if (error_phi<=error_tolerance_phi)
            nCorrectFrame_phi= nCorrectFrame_phi+1;
        end
        if ((error_theta<=error_tolerance) && (error_phi<=error_tolerance_phi))
            nCorrectFrame= nCorrectFrame+1;
        end
        
        if (DEBUG==1)
            fprintf('%d:[%d/%d] ',i,f,nFrame);
            fprintf('theta=%03.2f, phi=%03.2f, r=%03.2f \n',theta,phi,r);
        end
    end    
    exec_time= etime(clock,t1);
    
    fprintf('Execution time (total) = %f (sec)\n',exec_time);
    fprintf('Execution time per frame = %f (sec)\n',exec_time/nFrame);
    fprintf('Theta accuracy= %d/%d, (%.2f%%)\n', ...
        nCorrectFrame_theta,nFrame,nCorrectFrame_theta/nFrame*100);
    fprintf('Phi accuracy= %d/%d, (%.2f%%)\n', ...
        nCorrectFrame_phi,nFrame,nCorrectFrame_phi/nFrame*100);
    fprintf('Theta/phi accuracy= %d/%d, (%.2f%%)\n', ...
        nCorrectFrame,nFrame,nCorrectFrame/nFrame*100); 
    fprintf('\n');
end
diary('off');
