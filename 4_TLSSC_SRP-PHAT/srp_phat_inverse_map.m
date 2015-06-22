function [max_srp_index]= srp_phat_inverse_map(...
                             f, ...                   % M by T matrix
                             inverse_map, ...
                             micPair_min_max_table, ...
                             pp, ...
                             Q)
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
                        
M= size(f,1);
N= M*(M-1)/2;
T= size(f,2);
max_tdoa= max(abs(micPair_min_max_table(:,1)));
max_tdoa= max(max_tdoa,max(abs(micPair_min_max_table(:,2))));

% GCC-PHAT
X= zeros(M,T);
for m=1:M
    X(m,:)= fft(f(m,:));
    X(m,:)= X(m,:)./abs(X(m,:));
end
Z= zeros(N,T);
p= 0;
for m1=1:M-1
    for m2=m1+1:M
        p= p+1;
        Z(p,:)= X(m1,:).*conj(X(m2,:));
    end
end
R= zeros(N,T);
for p=1:N
    R(p,:)= fftshift(real(ifft(Z(p,:))));
end
peaks= zeros(N,1);
for p=1:N
    center= T/2;
    [~,I]= max(R(p,center-max_tdoa:center+max_tdoa));
    peaks(p,1)= I-(max_tdoa+1);
end

% Search: SRP-PHAT inverse_map (p value of the paper is notated as pp 
%         to void cofusing with pair index p).
center= T/2;
srp_global= zeros(Q,1);
for p=1:N
    tdoa_start= max(peaks(p,1)-pp,micPair_min_max_table(p,1));
    tdoa_end= min(peaks(p,1)+pp,micPair_min_max_table(p,2));
    tdoa_range= tdoa_start:tdoa_end;
    n_tdoa= size(tdoa_range,2);
    for tdoa_idx=1:1:n_tdoa
        tdoa= tdoa_range(tdoa_idx);
        srp_local= R(p,tdoa+center);
        update_index= inverse_map{p,1}{tdoa_idx,1};
        srp_global(update_index)= srp_global(update_index) + ...
                                                        srp_local;
    end
end

[~,max_srp_index]= max(srp_global);
