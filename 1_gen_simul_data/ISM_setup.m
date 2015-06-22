function [SetupStruc] = ISM_setup(srcX, srcY, srcZ, reverb, Fs)
%ISM_setup  Environmental parameters for image-source method simulation
%
% [SetupStruc] = ISM_setup()  
%
% This function can be used as a template for the definition of the
% different parameters for an image-source method simulation, typically
% providing inputs to the functions 'ISM_RIR_bank.m' as well as
% 'fast_ISM_RIR_bank.m' (Lehmann & Johansson's ISM implementations). This
% function returns the structure 'SetupStruc' with the following fields:
%
%          Fs: sampling frequency in Hz.
%        room: 1-by-3 vector of enclosure dimensions (in m), 
%              [x_length y_length z_length].
%     mic_pos: N-by-3 matrix, [x1 y1 z1; x2 y2 z2; ...] positions of N
%              microphones in the environment (in m). 
%    src_traj: M-by-3 matrix, [x1 y1 z1; x2 y2 z2; ...] positions of M 
%              source trajectory points in the environment (in m).
%  T20 or T60: scalar value (in s), desired reverberation time.
%           c: (optional) sound velocity (in m/s).
% abs_weights: (optional) 1-by-6 vector of absorption coefficients weights, 
%              [w_x1 w_x2 w_y1 w_y2 w_z1 w_z2].
%
% The structure field 'c' is optional in the sense that the various
% functions developed in relation to Lehmann & Johansson's ISM
% implementation assume a sound velocity of 343 m/s by default. If defined
% in the function below, the field 'SetupStruc.c' will take precedence and
% override the default value with another setting.
%
% The field 'abs_weight' corresponds to the relative weights of each of the
% six absorption coefficients resulting from the desired reverberation time
% T60. For instance, defining 'abs_weights' as [0.8 0.8 1 1 0.6 0.6] will
% result in the absorption coefficients (alpha) for the walls in the
% x-dimension being 20% smaller compared to the y-dimension walls, whereas
% the floor and ceiling will end up with absorption coefficients 40%
% smaller (e.g., to simulate the effects of a concrete floor and ceiling).
% Note that setting some of the 'abs_weight' parameters to 1 does NOT mean
% that the corresponding walls will end up with a total absorption! If the
% field 'abs_weight' is omitted, the various functions developed in
% relation to Lehmann & Johansson's ISM implementation will set the
% 'abs_weight' parameter to [1 1 1 1 1 1], which will lead to uniform
% absorption coefficients for all room boundaries.
%
% The structure 'SetupStruc' may contain one of the two fields 'T60' or
% 'T20'. T60 corresponds to the time required by the impulse response to
% decay by 60dB, whereas T20 is defined as the time required for the
% impulse response to decay from -5 to -25dB. Simply define either one of
% these fields in the file below. Set this value to 0 for anechoic
% environments (direct path only).

SetupStruc.Fs = Fs;                 % sampling frequency in Hz

SetupStruc.c = 340;                   % (optional) propagation speed of acoustic waves in m/s

SetupStruc.room = [8 8 3];        % room dimensions in m
x= 4.0;
y= 4.0;
z= 0.6;

SetupStruc.mic_pos = [x+0.0000 y+0.1225 z+0.4380;   % 0
                      x+0.0866 y+0.0866 z+0.4380;   % 1
                      x+0.1225 y+0.0000 z+0.4380;   % 2
                      x+0.0866 y-0.0866 z+0.4380;   % 3
                      x+0.0000 y-0.1225 z+0.4380;   % 4
                      x-0.0866 y-0.0866 z+0.4380;   % 5
                      x-0.1225 y+0.0000 z+0.4380;   % 6
                      x-0.0866 y+0.0866 z+0.4380;   % 7
                      x+0.0000 y+0.1225 z+0.2000;   % 8
                      x+0.0866 y+0.0866 z+0.2000;   % 9
                      x+0.1225 y+0.0000 z+0.2000;   % 10
                      x+0.0866 y-0.0866 z+0.2000;   % 11
                      x+0.0000 y-0.1225 z+0.2000;   % 12
                      x-0.0866 y-0.0866 z+0.2000;   % 13
                      x-0.1225 y+0.0000 z+0.2000;   % 14
                      x-0.0866 y+0.0866 z+0.2000];  % 15
                 
%SetupStruc.src_traj = [linspace(1,2,101).'  ones(101,1)*3  ones(101,1)*1.7];   % [x y z] positions of source trajectory in m. 
SetupStruc.src_traj = [x+srcX y+srcY z+srcZ];   % [x y z] positions of source trajectory in m. 
%% defines a straight line in front of the mic array, with 101 source points along the trajectory (1cm distance increment).
                                    
SetupStruc.T60 = reverb;                 % reverberation time T60, or define a T20 field instead!
% SetupStruc.T20 = 0.15;                % reverberation time T20, or define a T60 field instead!

% SetupStruc.abs_weights = [0.6  0.7  0.5  0.6  0.7  0.7];    % (optional) weights for the resulting alpha coefficients.
%% simulates a carpeted floor, and sound-absorbing material on the ceiling and the second x-dimension wall.


%% Uncomment the following for a 3D plot of the above setup:
% plot3(SetupStruc.src_traj(:,1),SetupStruc.src_traj(:,2),SetupStruc.src_traj(:,3),'ro-','markersize',4); hold on;
% plot3(SetupStruc.mic_pos(:,1),SetupStruc.mic_pos(:,2),SetupStruc.mic_pos(:,3),'k.');
% axis equal; axis([0 SetupStruc.room(1) 0 SetupStruc.room(2) 0 SetupStruc.room(3)]);
% box on; xlabel('x-axis (m)'); ylabel('y-axis (m)'); zlabel('z-axis (m)');
