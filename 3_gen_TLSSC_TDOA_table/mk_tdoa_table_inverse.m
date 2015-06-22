function []=mk_tdoa_table_inverse(tdoa_table_filename)
% In : TDOA_table.mat
% Out: micPair_min_max_table.mat
%      inverse_map.mat
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

fprintf('TDOA Table Generation for Inverse Map\n');
load(tdoa_table_filename);
N= size(TDOA_table,2);

% Search max and min for each microphone pair in TDOA_table
micPair_min_max_table= zeros(N,2);
for i=1:N
    max_TDOA_value= -inf;
    min_TDOA_value= inf;
    tmpMax= max(TDOA_table(:,i));
    if (tmpMax > max_TDOA_value)
        max_TDOA_value= tmpMax;
    end
    tmpMin= min(TDOA_table(:,i));
    if (tmpMin < min_TDOA_value)
        min_TDOA_value= tmpMin;
    end
    micPair_min_max_table(i,1)= min_TDOA_value;
    micPair_min_max_table(i,2)= max_TDOA_value;
    micPair_min_max_table(i,3)= size([min_TDOA_value:max_TDOA_value],2);
end

% The creation of inverse map data structure
inverse_map= cell(N,1);
for i=1:N
    num_TDOA_range= micPair_min_max_table(i,3);
    inverse_map{i,1}= cell(num_TDOA_range,1);
end

% Allocating the coordinates into the inverse map
for i=1:N
    min_TDOA= micPair_min_max_table(i,1);
    max_TDOA= micPair_min_max_table(i,2);
    nTDOA= micPair_min_max_table(i,3);
    TDOA_range= [min_TDOA:max_TDOA];
    for j=1:nTDOA
        target_TDOA= TDOA_range(j);
        inverse_map{i,1}{j,1}= find(TDOA_table(:,i)==target_TDOA);
    end
end
save('inverse_map.mat','inverse_map');
save('micPair_min_max_table.mat','micPair_min_max_table');
