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

%% Clear Workspace
% Clear workspace and set default parameters
clear; clc; close all;
set(0,'DefaultAxesFontSize',18); set(0,'DefaultAxesLineWidth',1.75);
set(0,'DefaultLineLineWidth',1.75);

format longeng;
%pkg load signal; % Load signal processing package for Octave

%% User Inputs (CHANGE EACH TIME YOU RUN THIS SCRIPT)
% Change the following every time you run this script:
% Filename, spectra plot on/off, PCB Gain settings, Kulite calibration.

% File to Read:
% filename = 'Waveform-MM-DD-hh-mm-2025.txt'; % <Stagnation Pressure>,<Nozzle Temp>
filename = 'Waveform-06-19-15-35-2025.txt';

% Gain of each channel in decibels. 
% Be especially aware of the SRS SR650 filter/gain unit which is in dB!
SRSInputGainDB  = 10; % dB (SRS Input Gain)
SRSOutputGainDB = 10; % dB (SRS Output Gain)
ch3GainDB = SRSInputGainDB+SRSOutputGainDB; % dB (PCB Filtered)

channelGainDB   = [0, 0, ch3GainDB, 0]; % dB
clear SRSInputGainDB SRSOutputGainDB ch3GainDB; % Clear gain variables

% Plot Spectra? (yes/no --> true/false)
isSpectra = 0;
SPECTRA = isSpectra; % For compatibility with old scripts

% When the KSC-2 Signal Conditioner is Auto-balanced:
pressNulled  = 1.06;   % Test Section Pressure [psi]
voltNulled   = 150E-9; % Kulite Voltage [V]

% CHANGE DAILY:
% 1 if the Kulite has been calibrated (slope found empirically).
% 0 if otherwise (rely on spec sheet value)
isKuliteCalibrated = 0;
% Kulite Calibration:
pressure1 = 14.7; % [psi] (Test Section)
pressure2 = 0;    % [psi] (Test Section)
voltage1  = 0;    % [V] (from calibration)
voltage2  = -999; % [V] (from calibration)  

%% Input Parameters: (NO CHANGE NEEDED)
% This section defines the constants used in the script,
% along with performing relevant unit conversions.
% 
% 0. Constants
MBAR2PSI    =1/68.948; % mbar to psi
KULITE_SLOPE= 1/.00409; % [psi/V] (from spec sheet. Do not change.)
PCB_SLOPE   = 1/.10016; % [psi/V] (from spec sheet. Do not change.)
% 1a. Perform linear fit on Kulite calibration data to find slope and intercept
if isKuliteCalibrated
  kuliteSlope = (pressure2 - pressure1)./(voltage2-voltage1); %#ok<UNRCH>
else
  kuliteSlope = KULITE_SLOPE; %#ok<UNRCH>
end
% 1b. Solve for the Kulite Voltage at true vaccuum (0psi):
kuliteIntercept=pressNulled-kuliteSlope*voltNulled;

% 2. Sampling Frequency:
sampleFreq=1.25e6; % [Hz] (1.25 MHz)
nfft_noflow=2^16;  % Number of points for no-flow spectra
nfft_flow=2^14;    % Number of points for flow spectra

freqLimitKHz=12; % freq limit in kHz for spectra graphs


% Convert gains from dB
channelGain = 10.^(channelGainDB/20); % linear gain

clear pressure1 pressure2 voltage1 voltage2; % Clear calibration variables

%% Import Data File

% If channel names are not known, use generic names.
Ch1 = "Kulite DC coupled";
Ch2 = "Kulite AC coupled";
Ch3 = "PCB Filtered";
Ch4 = "PCB Unfiltered";
channelNames = [Ch1, Ch2, Ch3, Ch4]; % Channel names
% channelNames = {'Ch1', 'Ch2', 'Ch3', 'Ch4'}; % Generic channel names
clear Ch1 Ch2 Ch3 Ch4; % Clear individual channel name variables

fprintf('\n--------------------------------------')
fprintf('\nStarting Program plotspc.m')
fprintf('\n--------------------------------------\n')

fprintf('\nLoading Data... Please Wait.')
data=load(filename);
t=data(:,1);
channelVoltage = data(:,2:end);
fprintf('\nData loaded from file: %s',filename)

numChannels = size(channelVoltage,2); % Number of channels
fprintf('\nFound %i channels.',numChannels);

clear data; % Clear data variable to save memory
clear Ch1 Ch2 Ch3 Ch4; % Clear individual channel name variables

%% Process Data
order=3;
%[B,A]=butter(order,(100/(sampleFreq/2)),'high');
%Ch1=filtfilt(B,A,Ch1);
%Ch1(1)

% Correct for gain
channelData = channelVoltage./channelGain;
% Calibration to psi
channelPressure      = zeros(size(channelData));
channelPressure(:,1) = kuliteSlope*channelData(:,1) + kuliteIntercept; % [psi]
channelPressure(:,2) = kuliteSlope*channelData(:,2) + kuliteIntercept; % [psi]
channelPressure(:,3) =   PCB_SLOPE*channelData(:,3) + 0; % [psi]
channelPressure(:,4) =   PCB_SLOPE*channelData(:,4) + 0; % [psi]

%% Plot Raw Data

% Initialize figure counter
iFig=0;

% Plot time series data
iFig=iFig+1;

figure(iFig)
tits = channelNames; % Titles for each subplot
for i=1:numChannels
  subplot(numChannels,1,i);
  plot(t*1000, channelPressure(:,i)); % Convert time to milliseconds
  ylabel('Pressure (psi)');
  title(tits(i));
end
box on
sgtitle(filename)
xlabel('Time (ms)')

%% Get User Input (Replace with VITA)
% Grab points using mouse cursor
fprintf('\nSelect 3 points on graph, then hit Enter (while cursor is still on plot) to finish.\n')
[x,y]=ginput();

ttime=x/1000; % [s] (plots are shown in units of msec)

time_offset=17e-3+30e-3; %[s] valve open time plus disturbed flow
ttime(2)=ttime(2)+time_offset;

for i=1:length(x)
  [~,idx(i)]=min(abs(t-ttime(i)));
end

% flowStartIndex  = 
% flowEndIndex    = 

%% Extract Flow/No-Flow Regions
% No-flow data before valve opens; Flow data after valve opens and initial flow 
% has passed.
noFlowTimeSeries  = t(1:idx(1));
flowTimeSeries    = t(idx(2):idx(3));
noFlowData  = channelPressure(1:idx(1),:);
flowData    = channelPressure(idx(2):idx(3),:);

%%  Compute Statistics
% Computes mean and RMS

N_noFlow=length(noFlowTimeSeries); % Number of points in no-flow data
noFlowMean = mean(noFlowData,1); % mean across columns (channels)
noFlowRMS = sqrt(1/N_noFlow*sum((noFlowData-noFlowMean).^2));

N_flow = length(flowTimeSeries); % Number of points in flow data
flowMean = mean(flowData,1); % mean across columns (channels);
flowRMS = sqrt(1/N_flow*sum((flowData-flowMean).^2));

% Display Output in Table format
% Prepare data for table
T = table(channelNames', noFlowMean', flowMean', noFlowRMS', flowRMS', ...
    'VariableNames', {'Channel', 'NoFlow_Mean', 'Flow_Mean', 'NoFlow_RMS', 'Flow_RMS'});
fprintf('\n Units in PSI\n');
disp(T);

fprintf('\n---------------------------------------------------\n');
fprintf('\nNoise Percentages')
Ch11_noise=100*(Ch1_flow_rms-Ch1_noflow_rms)/Ch1_flow_mean
Ch13_noise=100*(Ch3_flow_rms-Ch3_noflow_rms)/Ch1_flow_mean

%% Plot

tits = channelNames; % Titles for each subplot

% No Flow Time series plot
iFig=iFig+1;
figure(iFig)
for i=1:numChannels
  subplot(numChannels,1,i); plot(noFlowTimeSeries*1000, noFlowData(:,i)); % Convert time to milliseconds
  xlim([0 2000]); ylabel('Pressure (psi)'); title(tits(i));
end
box on
xlabel('Time (ms)')
sgtitle(filename)

figure(iFig)
for i=1:numChannels
  subplot(numChannels,1,i); plot(flowTimeSeries*1000, flowData(:,i)); % Convert time to milliseconds
  xlim([0 2000]); ylabel('Pressure (psi)'); title(tits(i));
end
box on
xlabel('Time (ms)')
sgtitle(filename)

%% Frequency Domain Plots: 
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
  iFig=iFig+1;
  figure(iFig)
  subplot(4,1,1); plot(f/1000, Ch1Pxx_noflow); ylabel('PSI^{2}/Hz'); xlim([0 flim]);title('Kulite DC coupled No Flow');
  subplot(4,1,2); plot(f/1000, Ch2Pxx_noflow); ylabel('PSI^{2}/Hz'); xlim([0 flim]);title('Kulite AC coupled No Flow');
  subplot(4,1,3); plot(f/1000, Ch3Pxx_noflow); ylabel('PSI^{2}/Hz'); xlim([0 flim]);title('PCB Filtered No Flow');
  subplot(4,1,4); plot(f/1000, Ch4Pxx_noflow); ylabel('PSI^{2}/Hz'); xlim([0 flim]);xlabel('Freq (kHz)'); title('PCB Unfiltered No Flow');


  % Flow PSD plot
  f=f_flow;
  iFig=iFig+1;
  figure(iFig)
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
  iFig=iFig+1;
  figure(iFig)
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

  iFig=iFig+1;
  figure(iFig)
  plot(f/1000,Ch2Pxx_filt)
  xlabel('Freq (kHz)')
  ylabel('PSD (V^{2}/Hz)')
  xlim([0 flim])
  title('Kulite 60Hz High Pass Filtered')

  iFig=iFig+1;
  figure(iFig)
  plot(f/1000,Ch2Pxxdb_filt)
  xlabel('Freq (kHz)')
  ylabel('dB (V^{2}/Hz)')
  xlim([0 flim])
  ylim([-120 0])
  title('Kulite 60Hz High Pass Filtered')

  iFig=iFig+1;
  figure(iFig)
  plot(f/1000,Ch3Pxx_filt)
  xlabel('Freq (kHz)')
  ylabel('PSD (V^{2}/Hz)')
  xlim([0 flim])
  title('PCB 60Hz High Pass Filtered')

  iFig=iFig+1;
  figure(iFig)
  plot(f/1000,Ch3Pxxdb_filt)
  xlabel('Freq (kHz)')
  ylabel('dB PSD (V^{2}/Hz)')
  xlim([0 flim])
  ylim([-120 0])
  title('PCB 60Hz High Pass Filtered')
end
