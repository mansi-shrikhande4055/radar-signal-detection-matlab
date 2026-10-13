
clc;
clear;
close all;

%% 1. Radar Parameters
c = 3e8;                 % Speed of light (m/s)
Fs = 10e6;               % Sampling frequency (10 MHz)
Tp = 10e-6;              % Pulse duration (10 microseconds)
B = 2e6;                 % Chirp bandwidth (2 MHz)

% Target parameters
targetRange = 7500;      % Target range in metres
targetAmplitude = 0.7;

%% 2. Generate Transmitted LFM Pulse
tPulse = 0:1/Fs:Tp-1/Fs;
L = length(tPulse);

% Centered LFM chirp
tx = exp(1j*pi*(B/Tp)*(tPulse-Tp/2).^2);

%% 3. Simulate the Received Target Echo
targetDelay = 2*targetRange/c;
delaySamples = round(targetDelay*Fs);

N = 4096;
rxClean = zeros(1, N);

rxClean(delaySamples+(1:L)) = targetAmplitude*tx;

%% 3.5 Define Matched Filter
matchedFilter = conj(fliplr(tx));
%% 4. Test Different SNR Levels
snrValues = [-15, -10, -5, 0, 5];

signalPower = targetAmplitude^2;

figure;

for k = 1:length(snrValues)

    SNR_dB = snrValues(k);

    % Generate noise
    noisePower = signalPower / (10^(SNR_dB/10));

    noise = sqrt(noisePower/2) * ...
        (randn(1,N) + 1j*randn(1,N));

    % Received signal
    rx = rxClean + noise;

    % Apply matched filter
    mfOutput = conv(rx, matchedFilter, 'full');

    % Convert delay to range
    tDelay = ((0:length(mfOutput)-1) - (L-1))/Fs;
    rangeAxis = c*tDelay/2;

    % Search for the strongest peak in the range window
    valid = rangeAxis >= 0 & rangeAxis <= 15000;
    validIndices = find(valid);

    [peakValue, localIndex] = max(abs(mfOutput(valid)));
    peakIndex = validIndices(localIndex);

    estimatedRange = rangeAxis(peakIndex);
    rangeError = estimatedRange - targetRange;

    fprintf(['SNR = %3d dB | Estimated Range = %8.2f m | ' ...
        'Range Error = %8.2f m\n'], ...
        SNR_dB, estimatedRange, rangeError);

    % Plot matched-filter output
    subplot(length(snrValues),1,k);
    plot(rangeAxis(valid), abs(mfOutput(valid)));
    hold on;
    xline(targetRange, '--r', 'Actual Target');
    hold off;

    ylabel('Magnitude');
    title(sprintf('Matched Filter Output: SNR = %d dB', SNR_dB));
    grid on;
end

xlabel('Range (m)');
sgtitle('Radar Target Detection at Different SNR Levels');


%% 5. Matched Filter
matchedFilter = conj(fliplr(tx));

mfOutput = conv(rx, matchedFilter, 'full');

tDelay = ((0:length(mfOutput)-1) - (L-1))/Fs;
rangeAxis = c*tDelay/2;

%% 6. Estimate Target Range
[~, peakIndex] = max(abs(mfOutput));

estimatedRange = rangeAxis(peakIndex);

fprintf('Actual target range: %.2f m\n', targetRange);
fprintf('Estimated target range: %.2f m\n', estimatedRange);

%% 7. Plot Results
figure;

subplot(3,1,1);
plot(tPulse*1e6, real(tx));
xlabel('Time (microseconds)');
ylabel('Amplitude');
title('Transmitted LFM Radar Pulse');
grid on;

subplot(3,1,2);
plot((0:N-1)/Fs*1e6, real(rx));
xlabel('Time (microseconds)');
ylabel('Amplitude');
title('Received Signal with Noise');
grid on;

subplot(3,1,3);
plot(rangeAxis, abs(mfOutput));
xlabel('Range (m)');
ylabel('Magnitude');
title('Matched Filter Output');
xlim([0 15000]);
grid on;


%% 8. Radar Range Resolution

rangeResolution = c/(2*B);

fprintf('\n--- Radar Performance ---\n');
fprintf('Bandwidth: %.2f MHz\n', B/1e6);
fprintf('Sampling Frequency: %.2f MHz\n', Fs/1e6);
fprintf('Theoretical Range Resolution: %.2f m\n', ...
    rangeResolution);
fprintf('Actual Target Range: %.2f m\n', targetRange);


%% 9. Two-Target Detection

targetRanges = [6000, 7500];  % Target distances in metres
targetAmplitudes = [1.0, 0.8];

rxTwoTargets = zeros(1, N);

for k = 1:length(targetRanges)

    delay = 2*targetRanges(k)/c;
    delaySamples = round(delay*Fs);

    rxTwoTargets(delaySamples+(1:L)) = ...
        rxTwoTargets(delaySamples+(1:L)) + ...
        targetAmplitudes(k)*tx;
end

% Add noise at 0 dB SNR relative to total signal power
signalPower = mean(abs(rxTwoTargets).^2);
noisePower = signalPower;

noise = sqrt(noisePower/2) * ...
    (randn(1,N) + 1j*randn(1,N));

rxTwoTargets = rxTwoTargets + noise;

% Matched filtering
mfTwoTargets = conv(rxTwoTargets, matchedFilter, 'full');

tDelay = ((0:length(mfTwoTargets)-1) - (L-1))/Fs;
rangeAxis = c*tDelay/2;

% Plot positive range region
valid = rangeAxis >= 0 & rangeAxis <= 12000;

figure;
plot(rangeAxis(valid), abs(mfTwoTargets(valid)));
hold on;

xline(targetRanges(1), '--r', 'Target 1');
xline(targetRanges(2), '--g', 'Target 2');

xlabel('Range (m)');
ylabel('Magnitude');
title('Two-Target Detection Using Matched Filtering');
grid on;
hold off;

%% 10. Automatic Two-Target Range Estimation

% Search for peaks in the positive range region
valid = rangeAxis >= 0 & rangeAxis <= 12000;

rangePositive = rangeAxis(valid);
magnitudePositive = abs(mfTwoTargets(valid));

% Find prominent peaks
[pks, locs] = findpeaks(magnitudePositive, ...
    'MinPeakDistance', round(500/(c/(2*Fs))), ...
    'MinPeakProminence', 8);

% Sort peaks by magnitude and retain the two strongest
[~, order] = sort(pks, 'descend');
numDetected = min(2, length(order));
selected = order(1:numDetected);

detectedRanges = sort(rangePositive(locs(selected)));

fprintf('\n--- Automatic Target Detection ---\n');

for k = 1:length(detectedRanges)
    fprintf('Detected target %d: %.2f m\n', ...
        k, detectedRanges(k));
end

fprintf('Actual target ranges: %.2f m and %.2f m\n', ...
    targetRanges(1), targetRanges(2));

