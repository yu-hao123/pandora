% Create the objects for modeling the occlusion maneuver
%% Dividing the dataset into fit and validation

close all;
clear variables;

load('../data/signals/corrected_occl_1921.mat');

delay = 20; % delay (samples)
gain = max(c_paw) - min(c_paw);

% remove delay
c_paw = c_paw(1:end-delay);
c_pes = c_pes(delay+1:end);

%remove offset
c_paw = c_paw - max(c_paw);
c_pes = c_pes - max(c_pes);


fit_ratio = 0.7; % fit to validation ratio
samples = size(c_paw, 1);
fit_idx = round(samples*fit_ratio);

fit_paw = c_paw(1:fit_idx);
fit_pes = c_pes(1:fit_idx);

val_paw = c_paw(fit_idx+1:end);
val_pes = c_pes(fit_idx+1:end);

total_paw = c_paw;
total_pes = c_pes;

fs = 1 / (Ts * 10^-3);

%% Data objects

fit_data = iddata(fit_paw, fit_pes, Ts * 10^-3);
fit_data.InputName = 'Esophageal Pressure';
fit_data.OutputName = 'Airway Pressure';
fit_data.InputUnit = 'cmH20';
fit_data.OutputUnit = 'cmH20';
fit_data.Tstart = 0.0;

val_data = iddata(val_paw, val_pes, Ts * 10^-3);
val_data.InputName = 'Esophageal Pressure';
val_data.OutputName = 'Airway Pressure';
val_data.InputUnit = 'cmH20';
val_data.OutputUnit = 'cmH20';
val_data.Tstart = (size(fit_data,1))* Ts * (10^-3);

total_data = iddata(total_paw, total_pes, Ts * 10^-3);
total_data.InputName = 'Esophageal Pressure';
total_data.OutputName = 'Airway Pressure';
total_data.InputUnit = 'cmH20';
total_data.OutputUnit = 'cmH20';
total_data.Tstart = 0.0;

save("../data/models/occl_1921_dataset.mat",...
    'total_data','val_data', 'fit_data');

figure;
plot(total_data);

%% Filtered Dataset

% Passband filter 25 rad/s?

smooth_paw = lowpass(c_paw, 0.3, fs);
smooth_pes = lowpass(c_pes, 0.3, fs);
one_percent = round(samples/200);
smooth_paw = smooth_paw(one_percent:samples-one_percent);
smooth_pes = smooth_pes(one_percent:samples-one_percent);
fit_idx = round(size(smooth_paw, 1) * fit_ratio);

smooth_fit_paw = smooth_paw(1:fit_idx);
smooth_fit_pes = smooth_pes(1:fit_idx);

smooth_val_paw = smooth_paw(fit_idx+1:end);
smooth_val_pes = smooth_pes(fit_idx+1:end);

smooth_total_paw = smooth_paw;
smooth_total_pes = smooth_pes;

fit_data = iddata(smooth_fit_paw, smooth_fit_pes, Ts * 10^-3);
fit_data.InputName = 'Esophageal Pressure';
fit_data.OutputName = 'Airway Pressure';
fit_data.InputUnit = 'cmH20';
fit_data.OutputUnit = 'cmH20';
fit_data.Tstart = 0.0;

val_data = iddata(smooth_val_paw, smooth_val_pes, Ts * 10^-3);
val_data.InputName = 'Esophageal Pressure';
val_data.OutputName = 'Airway Pressure';
val_data.InputUnit = 'cmH20';
val_data.OutputUnit = 'cmH20';
val_data.Tstart = (size(fit_data,1))*Ts*(10^-3);

total_data = iddata(smooth_total_paw, smooth_total_pes, Ts * 10^-3);
total_data.InputName = 'Esophageal Pressure';
total_data.OutputName = 'Airway Pressure';
total_data.InputUnit = 'cmH20';
total_data.OutputUnit = 'cmH20';
total_data.Tstart = 0.0;

save("../data/models/smooth_occl_1921_dataset.mat",...
    'total_data','val_data', 'fit_data');

figure;
plot(total_data);
