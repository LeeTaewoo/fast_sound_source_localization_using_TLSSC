% function []=main(dataset_dir,tdoa_table_dir)
% Input: dataset_dir,
%        tdoa_table_dir (in which there are TDOA_table.mat, 
%        cartCoords.mat, inverse_map.mat, micPair_min_max_table.mat,
%        TDOA_table_SSC.mat, SSC_centroids.mat, SSC.mat,
%        TDOA_table_SSC2.mat, SSC2_centroids.mat, SSC2.mat.)
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
dataset_dir= '../1_gen_simul_data/TL-SSC_simul_data';
tdoa_table_dir= '../3_gen_TLSSC_TDOA_table';
tolerance.theta= 10.001;  % degree
tolerance.phi= 5.001;     % degree

SSL_1_full_search(dataset_dir,tdoa_table_dir,tolerance)
SSL_2_inverse_map_run(dataset_dir,tdoa_table_dir,tolerance)
SSL_3_SSC(dataset_dir,tdoa_table_dir,tolerance)
SSL_4_SSC2_run(dataset_dir,tdoa_table_dir,tolerance)
