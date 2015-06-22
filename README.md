# Fast Sound Source Localization Using Two-Level Search Space Clustering
Simple demonstration using simulated data

### Execution
On Windows and MATLAB, (the codes were tested on Windows7 64-bit and MATLAB2009b).
 1. Download `LDC93S1.wav` file from [here](https://www.google.com/url?q=https%3A%2F%2Fcatalog.ldc.upenn.edu%2Fdesc%2Faddenda%2FLDC93S1.wav&sa=D&sntz=1&usg=AFQjCNE1QtQownD3lvimnRxuWBXkutWotg). Copy the file into `1_gen_simul_data` folder.
 2. Execute `./1_gen_simul_data/main.m`.
 3. Execute `./2_data_preprocessing/main.m`.
 4. Execute `./3_gen_TLSSC_TDOA_table/main.m`.
 5. Execute `./4_TLSSC_SRP-PHAT/main.m`.

Experiment result log files are saved in `./4_TLSSC_SRP-PHAT/log`. For more detailed explanation, please refer to the paper below.

### Reference
Dongsuk Yook, Taewoo Lee, and Youngkyu Cho, ["Fast Sound Source Localization Using Two-Level Search Space Clustering,"](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=7039285&sortType=asc_p_Sequence&filter=AND(p_IS_Number:6352949)) IEEE Transactions on Cybernetics, In Press, Feb. 2015
