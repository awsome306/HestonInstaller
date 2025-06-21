%% Plotspc.m
% This script plots the time series and spectra of pressure data from a
% Kulite and PCB pressure transducer. The data is read from a text file
% and processed to compute the pressure in psi. The script also computes
% the root mean square (RMS) and mean values for both no-flow and flow
% conditions, and plots the power spectral density (PSD) for both cases.
%
% * Author: Eric Matlis
% * Edits by: Joseph Heston
% * Date: 06/18/2025

% Clear workspace and set default parameters
close all; clear all; clc; %#ok<CLALL>
set(0,'DefaultAxesFontSize',18);
set(0,'DefaultLineLineWidth',1.75);
set(0,'DefaultAxesLineWidth',1.75);
format long;

% 
% pkg load signal;

%% User Inputs (Change each time)
% Change either everytime or at least daily.

% CHANGE 
% File to Read:
% filename = 'Waveform-MM-DD-hh-mm-2025.txt'; % <Stagnation Pressure>,<Nozzle Temp>
% filename = 'Waveform-06-18-11-24-2025.txt'; % <Stagnation Pressure>,<Nozzle Temp>
filename = 'Waveform-06-19-15-35-2025.txt';
% CHANGE DAILY:
% 1 if the Kulite has been calibrated (slope found empirically).
% 0 if otherwise (rely on spec sheet value)
isKuliteCalibrated = 0;
% When the KSC-2 Signal Conditioner is Auto-balanced:
pressNulled  = 0.90;   % Test Section Pressure [psi]
voltNulled   = 150E-9; % Kulite Voltage [V]
% Plot Spectra (yes/no --> true/false)
isSpectra = 0;


%% Input Parameters:
% 0. Constants
% 1. Kulite Calibration Parameters
% 2. Signal Conditioner Gain
% 3. Filename of the data file



% 0. Constants
MBAR2PSI    =1/68.948; % mbar to psi
KULITE_SLOPE= 1/.00409; % [psi/V] (from spec sheet. Do not change.)
PCB_SLOPE   = 1/.10016; % [psi/V] (from spec sheet. Do not change.)

% 1. Kulite Calibration Parameters (Parts A and B)

if isKuliteCalibrated
  kuliteSlope = (pressure2 - pressure1)./(voltage2-voltage1); %#ok<UNRCH>
else
  kuliteSlope = KULITE_SLOPE; %#ok<UNRCH>
end

% Solve for the Kulite Voltage at true vaccuum (0psi):
kuliteIntercept=pressNulled-kuliteSlope*voltNulled;





sampleFreq=1.25e6;

nfft_noflow=2^16;
nfft_flow=2^14;

freqLimitKHz=12; % freq limit in kHz for spectra graphs


%% Get Inputs from Signal Conditioner
% Gain through SRS SR650 filter/gain unit which is in dB

% Gain of each channel in deciBels:
channelGainDB = [0 0 20 0]; % dB

% Convert gains from dB
channelGain = 10.^(channelGainDB/20); % linear gain

%% Begin Main Program

%% Import Data File
%{
Ch1= Kulite DC coupled
Ch2= Kulite AC coupled
Ch3= PCB Filtered
Ch4= PCB Unfiltered
%}
fprintf('\n*************************************')
fprintf('\nStarting Program plotspc.m\n')
fprintf('*************************************\n')

fprintf('\nLoading Data... Please Wait.\n')
data=load(filename);
t=data(:,1);
channelVoltages = data(:,2:end);
% Ch1=data(:,2); % Kulite DC coupled
% Ch2=data(:,3); % Kulite AC coupled
% Ch3=data(:,4); % PCB Filtered
% Ch4=data(:,5); % PCB Unfiltered
fprintf('\nData loaded from file: %s\n',filename)

%% Process Data
order=3;
%[B,A]=butter(order,(100/(sampleFreq/2)),'high');
%Ch1=filtfilt(B,A,Ch1);
%Ch1(1)

% Correct for gain
channelData = channelVoltages./ channelGain;
% Calibration to psi
channelPressure(:,1) = kuliteSlope*channelData(:,1) + kuliteIntercept; % [psi]
channelPressure(:,2) = kuliteSlope*channelData(:,2) + kuliteIntercept; % [psi]
Ch1=m_kulite*Ch1+b_kulite;
Ch2=m_kulite*Ch2+b_kulite;
Ch3=m_pcb*Ch3;
Ch4=m_pcb*Ch4;

% Time series plot
ifig=0;
ifig=ifig+1;
str1='Kulite DC coupled ';
str2=strcat(str1,filename);

figure(ifig)
subplot(4,1,1); plot(t*1000, Ch1); ylabel('Pressure (psi)'); title(str2);xlim([0 2000]); ylim([-2 8]);
subplot(4,1,2); plot(t*1000, Ch2); ylabel('Pressure (psi)'); title('Kulite AC coupled');xlim([0 2000]); %ylim([-.01 .01]);
subplot(4,1,3); plot(t*1000, Ch3); ylabel('Pressure (psi)'); title('PCB Filtered');xlim([0 2000]);ylim([-.25 .25])%ylim([-2 3]);
subplot(4,1,4); plot(t*1000, Ch4); ylabel('Pressure (psi)'); title('PCB Unfiltered');xlim([0 2000]);%xlim([.99 .993]);ylim([-.06 .06]);

%subplot(4,1,1); plot(t*1000, Ch1); ylabel('Amplitude (V)'); title('Kulite DC coupled');xlim([0 2000]); %ylim([-.03 .03]);
%subplot(4,1,2); plot(t*1000, Ch2); ylabel('Amplitude (V)'); title('Kulite AC coupled');xlim([0 2000]); %ylim([-.01 .01]);
%subplot(4,1,3); plot(t*1000, Ch3); ylabel('Amplitude (V)'); title('PCB Filtered');xlim([0 2000])%xlim([.99 .993]);ylim([-6 6]);
%subplot(4,1,4); plot(t*1000, Ch4); ylabel('Amplitude (V)'); title('PCB Unfiltered');xlim([0 2000]);%xlim([.99 .993]);ylim([-.06 .06]);
box on
xlabel('time (ms)')


x=[654 1079 1205];
x=[745 1000 1250]; % Waveform-12-30-14-39-2024.txt
x=[703 803 926 ]; % Waveform-12-30-14-54-2024.txt

% Grab points using mouse cursor
fprintf('\nSelect 3 points on graph, then hit enter (while cursor is still on plot) to finish.\n')
[x,y]=ginput();

ttime=x/1000; % [s] (plots are shown in units of msec)

time_offset=17e-3+30e-3; %[s] valve open time plus disturbed flow
ttime(2)=ttime(2)+time_offset;

for i=1:length(x)
  [~,idx(i)]=min(abs(t-ttime(i)));
end

% No-flow data before valve opens
Ch1_noflow=Ch1(1:idx(1)); t_noflow=t(1:idx(1));
Ch2_noflow=Ch2(1:idx(1));
Ch3_noflow=Ch3(1:idx(1));
Ch4_noflow=Ch4(1:idx(1));

% Flow data while valve is open
Ch1_flow=Ch1(idx(2):idx(3)); t_flow=t(idx(2):idx(3));
Ch2_flow=Ch2(idx(2):idx(3));
Ch3_flow=Ch3(idx(2):idx(3));
Ch4_flow=Ch4(idx(2):idx(3));

% Compute RMS/Means No Flow
num_pnts_noflow=length(t_noflow);
Ch1_noflow_mean=mean(Ch1_noflow)
Ch1_noflow_rms=sqrt(1/num_pnts_noflow*sum((Ch1_noflow-Ch1_noflow_mean).^2))
Ch2_noflow_mean=mean(Ch2_noflow)
Ch2_noflow_rms=sqrt(1/num_pnts_noflow*sum((Ch2_noflow-Ch2_noflow_mean).^2))
Ch3_noflow_mean=mean(Ch3_noflow)
Ch3_noflow_rms=sqrt(1/num_pnts_noflow*sum((Ch3_noflow-Ch3_noflow_mean).^2))
Ch4_noflow_mean=mean(Ch4_noflow)
Ch4_noflow_rms=sqrt(1/num_pnts_noflow*sum((Ch4_noflow-Ch4_noflow_mean).^2))

% Compute RMS/Means Flow found errors in calc of mean (used noflow instead of flow)
num_pnts_flow=length(t_flow);
Ch1_flow_mean=mean(Ch1_flow)
Ch1_flow_rms=sqrt(1/num_pnts_flow*sum((Ch1_flow-Ch1_flow_mean).^2))
Ch2_flow_mean=mean(Ch2_flow)
Ch2_flow_rms=sqrt(1/num_pnts_flow*sum((Ch2_flow-Ch2_flow_mean).^2))
Ch3_flow_mean=mean(Ch3_flow)
Ch3_flow_rms=sqrt(1/num_pnts_flow*sum((Ch3_flow-Ch3_flow_mean).^2))
Ch4_flow_mean=mean(Ch4_flow)
Ch4_flow_rms=sqrt(1/num_pnts_flow*sum((Ch4_flow-Ch4_flow_mean).^2))

%Ch1_noflow_rms=rms(detrend(Ch1_noflow))


Ch11_noise=100*(Ch1_flow_rms-Ch1_noflow_rms)/Ch1_flow_mean
Ch13_noise=100*(Ch3_flow_rms-Ch3_noflow_rms)/Ch1_flow_mean

% No Flow Time series plot
ifig=ifig+1;
figure(ifig)
subplot(4,1,1); plot(t_noflow*1000, Ch1_noflow); ylabel('Pressure (psi)'); title('Kulite DC coupled No Flow');xlim([0 2000]); %ylim([-.03 .03]);
subplot(4,1,2); plot(t_noflow*1000, Ch2_noflow); ylabel('Pressure (psi)'); title('Kulite AC coupled No Flow');xlim([0 2000]); %ylim([-.01 .01]);
subplot(4,1,3); plot(t_noflow*1000, Ch3_noflow); ylabel('Pressure (psi)'); title('PCB Filtered No Flow');xlim([0 2000])%xlim([.99 .993]);ylim([-6 6]);
subplot(4,1,4); plot(t_noflow*1000, Ch4_noflow); ylabel('Pressure (psi)'); title('PCB Unfiltered No Flow');xlim([0 2000]);%xlim([.99 .993]);ylim([-.06 .06]);


% Flow Time series plot
ifig=ifig+1;
figure(ifig)
subplot(4,1,1); plot(t_flow*1000, Ch1_flow); ylabel('Pressure (psi)'); title('Kulite DC coupled Flow');xlim([0 2000]); %ylim([-.03 .03]);
subplot(4,1,2); plot(t_flow*1000, Ch2_flow); ylabel('Pressure (psi)'); title('Kulite AC coupled Flow');xlim([0 2000]); %ylim([-.01 .01]);
subplot(4,1,3); plot(t_flow*1000, Ch3_flow); ylabel('Pressure (psi)'); title('PCB Filtered Flow');xlim([0 2000])%xlim([.99 .993]);ylim([-6 6]);
subplot(4,1,4); plot(t_flow*1000, Ch4_flow); ylabel('Pressure (psi)'); title('PCB Unfiltered Flow');xlim([0 2000]);%xlim([.99 .993]);ylim([-.06 .06]);


if(isSpectra==1)
  % No Flow number of points
  spectral_resolution_noflow=sampleFreq/nfft_noflow;
  fprintf('The no-flow spectral resolution is %f Hz\n',spectral_resolution_noflow)
  num_avgs_noflow=floor(num_pnts_noflow/nfft_noflow)
  num_pnts_noflow=nfft_noflow*num_avgs_noflow; % get number of points for integer number of records
  fprintf('The total number of points used for no flow case is %d\n\n',num_pnts_noflow)

  % Flow number of points
  spectral_resolution_flow=sampleFreq/nfft_flow;
  fprintf('The flow-on spectral resolution is %f Hz\n',spectral_resolution_flow)
  num_avgs_flow=floor(num_pnts_flow/nfft_flow)
  num_pnts_flow=nfft_flow*num_avgs_flow; % get number of points for integer number of records
  fprintf('The total number of points used for flow case is %d\n',num_pnts_flow)

  noverlap=0;
  % Compute PSD for No Flow case
  [Ch1Pxx_noflow,f_noflow]=pwelch(detrend(Ch1_noflow),hanning(nfft_noflow),noverlap,nfft_noflow,sampleFreq);
  [Ch2Pxx_noflow,f]=pwelch(Ch2_noflow,hanning(nfft_noflow),noverlap,nfft_noflow,sampleFreq);
  [Ch3Pxx_noflow,f]=pwelch(Ch3_noflow,hanning(nfft_noflow),noverlap,nfft_noflow,Fs);
  [Ch4Pxx_noflow,f]=pwelch(Ch4_noflow,hanning(nfft_noflow),noverlap,nfft_noflow,Fs);

  % Compute PSD for Flow on case
  [Ch1Pxx_flow,f_flow]=pwelch(detrend(Ch1_flow),hanning(nfft_flow),noverlap,nfft_flow,Fs);
  [Ch2Pxx_flow,f]=pwelch(Ch2_flow,hanning(nfft_flow),noverlap,nfft_flow,Fs);
  [Ch3Pxx_flow,f]=pwelch(Ch3_flow,hanning(nfft_flow),noverlap,nfft_flow,Fs);
  [Ch4Pxx_flow,f]=pwelch(Ch4_flow,hanning(nfft_flow),noverlap,nfft_flow,Fs);

  % Convert to dB noflow
  Ch1Pxxdb_noflow=10*log10(Ch1Pxx_noflow);
  Ch2Pxxdb_noflow=10*log10(Ch2Pxx_noflow);
  Ch3Pxxdb_noflow=10*log10(Ch3Pxx_noflow);
  Ch4Pxxdb_noflow=10*log10(Ch4Pxx_noflow);

  % Convert to dB flow
  Ch1Pxxdb_flow=10*log10(Ch1Pxx_flow);
  Ch2Pxxdb_flow=10*log10(Ch2Pxx_flow);
  Ch3Pxxdb_flow=10*log10(Ch3Pxx_flow);
  Ch4Pxxdb_flow=10*log10(Ch4Pxx_flow);

  % No Flow PSD plot
  f=f_noflow;
  ifig=ifig+1;
  figure(ifig)
  subplot(4,1,1); plot(f/1000, Ch1Pxx_noflow); ylabel('PSI^{2}/Hz'); xlim([0 flim]);title('Kulite DC coupled No Flow');
  subplot(4,1,2); plot(f/1000, Ch2Pxx_noflow); ylabel('PSI^{2}/Hz'); xlim([0 flim]);title('Kulite AC coupled No Flow');
  subplot(4,1,3); plot(f/1000, Ch3Pxx_noflow); ylabel('PSI^{2}/Hz'); xlim([0 flim]);title('PCB Filtered No Flow');
  subplot(4,1,4); plot(f/1000, Ch4Pxx_noflow); ylabel('PSI^{2}/Hz'); xlim([0 flim]);xlabel('Freq (kHz)'); title('PCB Unfiltered No Flow');


  % Flow PSD plot
  f=f_flow;
  ifig=ifig+1;
  figure(ifig)
  subplot(4,1,1); plot(f, Ch1Pxx_flow); ylabel('PSI^{2}/Hz');title('Kulite DC coupled Flow'); %xlim([0 flim]);
  subplot(4,1,2); plot(f, Ch2Pxx_flow); ylabel('PSI^{2}/Hz');title('Kulite AC coupled Flow');%xlim([0 flim]);
  %subplot(4,1,1); loglog(f, Ch1Pxx_flow); ylabel('PSI^{2}/Hz');title('Kulite DC coupled Flow'); %xlim([0 flim]);
  %subplot(4,1,2); loglog(f, Ch2Pxx_flow); ylabel('PSI^{2}/Hz');title('Kulite AC coupled Flow');%xlim([0 flim]);
  %subplot(4,1,1); plot(f/1000, Ch1Pxx_flow); ylabel('PSI^{2}/Hz');title('Kulite DC coupled Flow'); %xlim([0 flim]);
  %subplot(4,1,2); plot(f/1000, Ch2Pxx_flow); ylabel('PSI^{2}/Hz');title('Kulite AC coupled Flow');%xlim([0 flim]);
  subplot(4,1,3); plot(f/1000, Ch3Pxx_flow); ylabel('PSI^{2}/Hz'); xlim([0 flim]);title('PCB Filtered Flow');
  subplot(4,1,4); plot(f/1000, Ch4Pxx_flow); ylabel('PSI^{2}/Hz'); xlim([0 flim]);xlabel('Freq (kHz)'); title('PCB Unfiltered Flow');

  % Flow PSD plot (dB)
  f=f_flow;
  ifig=ifig+1;
  figure(ifig)
  subplot(4,1,1); semilogx(f(2:end), Ch1Pxxdb_flow(2:end)); ylabel('PSI^{2}/Hz'); title('dB Kulite DC coupled Flow');%xlim([0 flim]);
  subplot(4,1,2); semilogx(f(2:end), Ch2Pxxdb_flow(2:end)); ylabel('PSI^{2}/Hz'); title('dB Kulite AC coupled Flow');%xlim([0 flim]);
  %subplot(4,1,1); plot(log10(f), Ch1Pxxdb_flow); ylabel('PSI^{2}/Hz'); title('dB Kulite DC coupled Flow');%xlim([0 flim]);
  %subplot(4,1,2); plot(log10(f), Ch2Pxxdb_flow); ylabel('PSI^{2}/Hz'); title('dB Kulite AC coupled Flow');%xlim([0 flim]);
  %subplot(4,1,1); plot(f/1000, Ch1Pxxdb_flow); ylabel('PSI^{2}/Hz'); title('dB Kulite DC coupled Flow');%xlim([0 flim]);
  %subplot(4,1,2); plot(f/1000, Ch2Pxxdb_flow); ylabel('PSI^{2}/Hz'); title('dB Kulite AC coupled Flow');%xlim([0 flim]);
  subplot(4,1,3); plot(f/1000, Ch3Pxxdb_flow); ylabel('PSI^{2}/Hz'); xlim([0 flim]);title('dB PCB Filtered Flow');
  subplot(4,1,4); plot(f/1000, Ch4Pxxdb_flow); ylabel('PSI^{2}/Hz'); xlim([0 flim]);xlabel('Freq (kHz)'); title('dB PCB Unfiltered Flow');


end


if(isSpectra==2)
% Compute PSD
orig_num_pnts=length(t);
fprintf('The total number of available points = %d\n',orig_num_pnts)
%num_pow2=pow2(floor(log2(orig_num_pnts)));
%num_pnts=num_pow2

fprintf('The fft size is %d\n',nfft)
num_avgs=floor(orig_num_pnts/nfft);
num_pnts=nfft*num_avgs;
fprintf('The number of points used is %d\n',num_pnts)
%fprintf('The number of fft record averages is %d\n',num_avgs)

Ch1=Ch1(1:num_pnts);
Ch2=Ch2(1:num_pnts);
Ch3=Ch3(1:num_pnts);
Ch4=Ch4(1:num_pnts);

%nfft=num_pnts;
order=5;
noverlap=0;
spectral_resolution=Fs/nfft;
fprintf('The number of fft avgs = %4.1f\n',num_avgs)
fprintf('the spectral resolution is %4.1f Hz\n',spectral_resolution)

%[z,p,k]=butter(order,(480/(Fs/2)),'high');
%Ch2_filt=filtfilt(z,p,Ch2);
%Ch3_filt=filtfilt(z,p,Ch3);
[B,A]=butter(order,(480/(Fs/2)),'high');
%[B,A]=butter(order,(2000/(Fs/2)),'high');

%Ch1_filt=filtfilt(B,A,Ch1);
Ch2_filt=filtfilt(B,A,Ch2);
Ch3_filt=filtfilt(B,A,Ch3);
%Ch4_filt=filtfilt(B,A,Ch4);

xx=Ch2_filt(1);
fprintf('First data point after filter = %f\n',xx)

[Ch2Pxx,f]=pwelch(Ch2,hanning(nfft),noverlap,nfft,Fs);
[Ch3Pxx,f]=pwelch(Ch3,hanning(nfft),noverlap,nfft,Fs);
[Ch2Pxx_filt,f]=pwelch(Ch2_filt,hanning(nfft),noverlap,nfft,Fs);
[Ch3Pxx_filt,f]=pwelch(Ch3_filt,hanning(nfft),noverlap,nfft,Fs);
%      [pxx,f]= pwelch(x,window,0,nfft,fs);    % W/Hz power spectral density

Ch2Pxxdb=10*log10(Ch2Pxx);
Ch2Pxxdb_filt=10*log10(Ch2Pxx_filt);
Ch3Pxxdb=10*log10(Ch3Pxx);
Ch3Pxxdb_filt=10*log10(Ch3Pxx_filt);

ifig=ifig+1;
figure(ifig)
plot(f/1000,Ch2Pxx_filt)
xlabel('Freq (kHz)')
ylabel('PSD (V^{2}/Hz)')
xlim([0 flim])
title('Kulite 60Hz High Pass Filtered')

ifig=ifig+1;
figure(ifig)
plot(f/1000,Ch2Pxxdb_filt)
xlabel('Freq (kHz)')
ylabel('dB (V^{2}/Hz)')
xlim([0 flim])
ylim([-120 0])
title('Kulite 60Hz High Pass Filtered')

ifig=ifig+1;
figure(ifig)
plot(f/1000,Ch3Pxx_filt)
xlabel('Freq (kHz)')
ylabel('PSD (V^{2}/Hz)')
xlim([0 flim])
title('PCB 60Hz High Pass Filtered')

ifig=ifig+1;
figure(ifig)
plot(f/1000,Ch3Pxxdb_filt)
xlabel('Freq (kHz)')
ylabel('dB PSD (V^{2}/Hz)')
xlim([0 flim])
ylim([-120 0])
title('PCB 60Hz High Pass Filtered')

end
