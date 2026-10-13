
# Radar Signal Detection and Range Estimation Using MATLAB

## Overview
This project simulates radar target detection in noisy signals using MATLAB. It explores Linear Frequency Modulated (LFM) pulses, matched filtering, signal-to-noise ratio (SNR), and target range estimation.

## Objectives
- Generate an LFM radar pulse.
- Simulate delayed target echoes in noisy conditions.
- Implement matched filtering to detect target echoes.
- Evaluate detection at different SNR levels.
- Estimate target ranges and calculate theoretical range resolution.
- Demonstrate automatic detection of two simulated targets.

## Tools and Concepts
- MATLAB
- Digital Signal Processing (DSP)
- LFM radar pulse simulation
- Matched filtering
- SNR analysis
- Peak detection
- Radar range estimation

## Simulation Parameters
| Parameter | Value |
|---|---:|
| Sampling frequency | 10 MHz |
| Pulse duration | 10 µs |
| Chirp bandwidth | 2 MHz |
| Theoretical range resolution | 75 m |
| Simulated target ranges | 6,000 m and 7,500 m |

## Results
The simulation successfully detected two simulated targets at 6 km and 7.5 km using matched filtering and automatic peak detection. The simulation also compared matched-filter outputs at SNR levels of −15, −10, −5, 0, and 5 dB.

## How to Run
1. Download or clone this repository.
2. Open `Radar.m` in MATLAB.
3. Run the script.
4. Observe the radar pulse, noisy received signal, matched-filter output, and two-target detection plots.

## Limitations
This is a software simulation with simplified target and noise models. Its results do not represent validation of a physical radar system.

## Author
Mansi Shrimant Shrikhande  
Electrical Engineering, NIT Kurukshetra
