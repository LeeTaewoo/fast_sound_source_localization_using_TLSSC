function []=mk_tdoa_table_tlssc(tdoa_table_filename, ...
                                tdoa_table_SSC_filename, ...
                                ssc_centroids_filename,mic,Fs,c)
% In : TDOA_table_SSC.mat, SSC_centroids.mat
% Out: TDOA_table_SSC2.mat, SSC2_centroids.mat
%
% Reference:
% Dongsuk Yook, Taewoo Lee, and Youngkyu Cho, 
% "Fast Sound Source Localization Using Two-Level Search Space Clustering,"
% IEEE Transactions on Cybernetics, In Press, Feb. 2015.
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

threshold= round((1/5) * (55/c) * Fs);
load(tdoa_table_filename);
load(tdoa_table_SSC_filename);

% Theta is determined by the equation (7) in the reference paper.
% For all microphone pairs, the coordinates within the range of a same TDOA 
% -theta to +theta are annotated as a same cluster ID. Then, it is saved
% into the CoordClusterTable.
fprintf('Two-Level Search Space Clustering ...\n');
clusterID= 0;
nCoord= size(TDOA_table_SSC,1);
CoordClusterTable= zeros(nCoord,1);
for i=1:nCoord-1
    fprintf('Processing ... clutser %d/%d\n',i,nCoord);
    if (CoordClusterTable(i,1)~=0)
        continue;
    end
    
    clusterID= clusterID+1;
    coordCnt=1;
    CoordClusterTable(i,1)= clusterID;
    for j=i+1:nCoord
        diffVec= abs(TDOA_table_SSC(i,:) - TDOA_table_SSC(j,:));
        if (max(diffVec) <= threshold)
            CoordClusterTable(j,1)= clusterID;
        end
    end
end
if (CoordClusterTable(nCoord,1)==0)
    clusterID= clusterID+1;
    CoordClusterTable(nCoord,1)= clusterID;
end

% Gathering coordinates with a same cluster ID, then save it in SSC.
nCluster= max(CoordClusterTable);
SSC2= cell(nCluster,1);
for clusterID=1:nCluster
    SSC2{clusterID}= find(CoordClusterTable==clusterID);
end
save('SSC2.mat','SSC2');

% Extracting representative coordinates in each cluster. Then, it is saved 
% in TDOA_table_SSC2. The representative coordinates is determined as
% the centroid in each cluster.
load(ssc_centroids_filename);
M= size(mic,1);
N= M*(M-1)/2;
nCluster= size(SSC2,1);
TDOA_table_SSC2= zeros(nCluster,N);
SSC2_centroids= zeros(nCluster,3);
for i=1:nCluster
    centroid= zeros(1,3);
    nCoord= size(SSC2{i,1},1);
    for j=1:nCoord
        coordIdx= SSC2{i,1}(j,1);
        centroid= centroid + SSC_centroids(coordIdx,:);
    end
    centroid= centroid ./ nCoord;
    SSC2_centroids(i,:)= centroid;

    % Re-calculate the TDOA of the centroid -> save to TDOA_table_SSC2.mat
    micPairCnt= 0;
    for m1=1:M-1
        for m2=m1+1:M
            d1= norm(mic(m1,:)-centroid(1,:),2);
            d2= norm(mic(m2,:)-centroid(1,:),2);
            dd= d1-d2;
            sd= round((dd/c)*Fs);
            micPairCnt= micPairCnt+1;
            TDOA_table_SSC2(i,micPairCnt)= sd;
        end
    end
end
save ('TDOA_table_SSC2.mat','TDOA_table_SSC2');
save ('SSC2_centroids.mat','SSC2_centroids');
