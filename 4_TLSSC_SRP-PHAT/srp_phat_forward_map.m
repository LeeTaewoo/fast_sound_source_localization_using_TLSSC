function [max_srp_index]= srp_phat_forward_map(f, ...   % M by T matrix
                                               TDOA_table)
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
Q= size(TDOA_table,2);

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

% SRP (full search or forward map)
center= T/2;
srp_global= zeros(Q,1);
for q=1:Q
    srp_local= 0;
    for p=1:N
        tau_qp= TDOA_table(p,q) + center;
        srp_local= srp_local + R(p,tau_qp);
    end
    srp_global(q,1)= srp_local;
end

[~,max_srp_index]= max(srp_global);