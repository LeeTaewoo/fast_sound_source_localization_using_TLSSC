% Voice Activity Detector (VAD)
%   with MMSE a posteriori noise estimation and Decision-Directed SNR estimation
%
% Usage:
%   results = VAD(wav_file, threshold, win_dur, hop_dur, num_noise, argin)
%
% Input arguments with typical values:   
%   wav_file = 'speech.wav'  % Your speech file in WAV format
%   threshold = 0.1; % Decision threshold of the likelihood ratio test
%   win_dur = 0.05;  % Window duration in seconds
%   hop_dur = 0.025; % Hop duration in seconds
%   num_noise = 20;  % Number of noise frames at the beginning of file
%   argin = 1;       % Noise estimation (1: enable, 0: disable)
%
% Output:
%   results % A vector with elements indicating either active speech (1)
%           %   or noise (0) for each one of the frames
% 
% This method is based on the noise estimation algorithm proposed by
% 
%   Bowon Lee and Mark Hasegawa-Johnson,
%   "Minimum Mean Squared Error a posteriori Estimation of High Variance Vehicular Noise,"
%   in Proc. Biennial on DSP for In-Vehicle and Mobile Systems, June 2007, Istanbul, Turkey. 
% 
% and the spectrum-based likelihood ratio test proposed by
%
%   J. Sohn, N.-S. Kim, and W. Sung,
%   "A statistical model based voice activity detection,"
%   IEEE Signal Process. Letters, vol. 6, no. 1, pp. 1-3, 1999.
%
% Written by Bowon Lee (bowon.lee@ieee.org) 

function results = VAD(wav_file, threshold, win_dur, hop_dur, num_noise, argin)

DEBUG = 1;

% Markov parameters for hangover scheme
a01 = 0.5;
a10 = 0.1;
a00 = 1 - a01;
a11 = 1 - a10;

% Coefficient for decision-directed SNR estimation
alpha = 0.99;

audio_filename = wav_file;
fprintf(sprintf('Loading audio file %s...\n',audio_filename));
[audio,Fs] = wavread(audio_filename);
audio_length = length(audio);            
win_size = Fs * win_dur;
hop_size = Fs * hop_dur;

N_FFT = win_size;

hamming_win = hamming(win_size);
num_frames = floor((audio_length-win_size)/hop_size);
results = zeros(num_frames,1);

noise_var_temp = zeros(N_FFT,1)';

for n = 1:num_noise   
    audio_frame = hamming_win.*audio(((n-1)*hop_size+1):((n-1)*hop_size+win_size),:); 
  	audio_frame_fft = fft(audio_frame,N_FFT)';
    noise_var_temp = noise_var_temp + real(conj(audio_frame_fft).*audio_frame_fft);
    results(n) = 0;
end

noise_var_orig = noise_var_temp' / num_noise;
noise_var_old = noise_var_orig;

G_old = 1;
A_MMSE = zeros(N_FFT,1);
G_MMSE = zeros(N_FFT,1);

outfile = sprintf('%s_VAD',audio_filename(1:end-4));
VADOUT = fopen(outfile,'w');

cumulative_Lambda = zeros(num_frames,1);

for n = 1:num_frames    

    dur = [((n-1)*hop_size+1):((n-1)*hop_size+win_size)];
    audio_frame = hamming_win.*audio(dur);     
 	audio_frame_fft = fft(audio_frame,N_FFT)';
    frame_var = real(conj(audio_frame_fft).*audio_frame_fft)';
	noise_var = noise_var_orig;

    if (argin) % for noise estimation, set argin = 1, otherwise 0.
        % Begin iteration
        nn = 1;
        noise_var_prev = noise_var_orig;
        while (nn <= 10)
            gamma = (frame_var./noise_var);

            Y_mag = abs(audio_frame_fft);	

            if (n == 1)
                xi = alpha + (1-alpha) * max(gamma-1, 0);
            else	
                xi = alpha * ( (A_MMSE(:,n-1).^2) ./ noise_var_old ) ...
                    + (1-alpha) * max(gamma-1, 0);
            end

            v = (xi .* gamma) ./ ( 1 + xi);

            G_MMSE(:,n) = (sqrt(pi)/2) * (sqrt(v)./gamma) .* exp(v/-2) .* ...
                 ((1+v) .* besseli(0,v/2) + v .* besseli(1,v/2));

            G_MMSE(find(isnan(G_MMSE(:,n))),n) = 1;
            G_MMSE(find(isinf(G_MMSE(:,n))),n) = 1;

            A_MMSE(:,n) = G_MMSE(:,n) .* Y_mag' ;

            Lambda = zeros(N_FFT,1);
            for k = 1:N_FFT
                Lambda(k) = 1/(1+xi(k)) + exp(gamma(k)*xi(k)/(1+xi(k)));
            end

            Lambda_mean = sum(Lambda)/N_FFT;   
            weight = Lambda_mean / (1 + Lambda_mean);
            if(isnan(weight))
                weight = 1;
            end
            noise_var = weight*noise_var_orig + (1-weight)*frame_var;

            diff = abs(sum(noise_var - noise_var_prev));

            if (diff < 0.000001)
              nn = 10;
            end

            nn = nn + 1;
            noise_var_prev = noise_var;
        end % while(nn < 10)
    end % if (argin)
        
	gamma = (frame_var./noise_var);

	Y_mag = abs(audio_frame_fft);	

	if (n == 1)
	    xi = alpha + (1-alpha) * max(gamma-1, 0);
	else	
	    xi = alpha * ( (A_MMSE(:,n-1).^2) ./ noise_var_old ) ...
			+ (1-alpha) * max(gamma-1, 0);
	end

	v = (xi .* gamma) ./ ( 1 + xi );

	G_MMSE(:,n) = (sqrt(pi)/2) * (sqrt(v)./gamma) .* exp(v/-2) .* ...
		 ((1+v) .* besseli(0,v/2) + v .* besseli(1,v/2));

	G_MMSE(find(isnan(G_MMSE(:,n))),n) = 1;
	G_MMSE(find(isinf(G_MMSE(:,n))),n) = 1;

	A_MMSE(:,n) = G_MMSE(:,n) .* Y_mag' ;

    Lambda = zeros(N_FFT,1);
    for k = 1:N_FFT
        Lambda(k) = log(1/(1+xi(k))) + gamma(k)*xi(k)/(1+xi(k));
    end

    Lambda_mean = sum(Lambda)/N_FFT;   

    G = (a01+a11*G_old)/(a00+a10*G_old) * Lambda_mean; 

    L_ML = (1/N_FFT)*sum(gamma-log(gamma)-1);

if(DEBUG)
%     fprintf(sprintf('Frame %04d: ', n));
    if ( (G < threshold) || (n < num_noise) )
        results(n) = 0;
%         fprintf('NOISE  ');
    else
        results(n) = 1;
%         fprintf('SPEECH ');
    end        
%     fprintf(sprintf('(Lambda = %f, G = %f)\n', Lambda_mean, G));    
    assert(isnan(Lambda_mean)==0);
end % if(DEBUG)
    cumulative_Lambda(n) = Lambda_mean;
	G_old = G;
	noise_var_old = noise_var;
    fprintf(VADOUT, '%d\n', results(n));    
end

% if(DEBUG)
% figure(1); hold on;
% plot(cumulative_Lambda,'b.'); plot(results,'r');
% axis([1 num_frames 0 2]);
% wavData= wavread(wav_file);
% plot(wavData*100+1.0);
% hold off;
% end % if(DEBUG)

fclose(VADOUT);
