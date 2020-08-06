% Apply estimated models in dynamic response 
%% Load models and filters data
close all;
clear variables;

load("../data/signals/corrected_analog_1921.mat");
load("../data/models/smooth_occl_1921_models_01.mat");
model = nlarx_tree;
model.Ts = Ts * 10^-3;
interval = 1:2000;
fs = 1 / model.Ts;
smooth_paw = lowpass(c_paw, 2, fs);
smooth_pes = lowpass(c_pes, 2, fs);
smooth_vol = lowpass(c_vol, 2, fs);
smooth_flow = lowpass(c_flow, 2, fs);

estimated_pes = sim(model, smooth_pes(interval));

% plot(smooth_paw(interval));
% hold on;
figure;
link_plot(1) = subplot(2,1,1);
plot(smooth_pes(interval)); grid on;
title('Original Esophageal Pressure');
link_plot(2) = subplot(2,1,2);
hold on;
plot(estimated_pes); grid on;
title('Corrected Esophageal Pressure');
linkaxes(link_plot,'x');

%% Respiratory parameters estimation
ins_marks = [60 350 570 720 910 1132 1438]; % hardcoded!!

orig_ptotal_hat = [];
orig_pes = [];
orig_ptotal = [];
orig_flow = [];
orig_pmus = [];
orig_paw = [];
orig_ers = []; 
orig_rrs = [];

eval_ptotal = [];
eval_ptotal_hat = [];
eval_pes = [];
eval_pmus = [];
eval_ers = [];
eval_rrs = [];

for i = 1:(size(ins_marks, 2)-1)
    
    cycle = ins_marks(i):(ins_marks(i+1)-1);
    
    paw = c_paw(cycle); % cmH2O
    flow = c_flow(cycle); % mL/s
    vol = c_vol(cycle); % mL
    pes_raw = c_pes(cycle); % cmH2O

    pes_hat = sim(model, pes_raw);
    pes = pes_raw;
    
    % remove offset
    paw = paw - median(paw(end-10:end));
    pes = pes - median(pes(end-10:end));
    pes_hat = pes_hat - median(pes_hat(end-10:end));

    ccw = 87.8; 
    
    % original respiratory dynamics (no correction)
    [pmus, ptotal, ptotal_hat, ers, rrs] = ...
    estimate_dynamics(pes, paw, ccw, flow, vol);
    
    orig_pes = [orig_pes; pes];
    orig_flow = [orig_flow; flow];
    orig_paw = [orig_paw; paw];
    
    orig_ptotal_hat = [orig_ptotal_hat; ptotal_hat];
    orig_ptotal = [orig_ptotal; ptotal];
    orig_pmus = [orig_pmus; pmus];
    orig_ers = [orig_ers; ers];
    orig_rrs = [orig_rrs; rrs];
    
    % corrected respiratory dynamics 
    [pmus, ptotal, ptotal_hat, ers, rrs] = ...
    estimate_dynamics(pes_hat, paw, ccw, flow, vol);
    
    eval_ptotal_hat = [eval_ptotal_hat; ptotal_hat];
    eval_ptotal = [eval_ptotal; ptotal];
    eval_pmus = [eval_pmus; pmus];
    eval_pes = [eval_pes; pes_hat];
    eval_ers = [eval_ers; ers];
    eval_rrs = [eval_rrs; rrs];
end

%% Plotting
% original response plot
figure;
link_plot(1) = subplot(2,1,1);

plot(orig_paw); hold on;
plot(orig_ptotal); hold on; plot(orig_ptotal_hat); hold on; 
plot(orig_pes); hold on; plot(orig_pmus); grid on;
legend('paw', 'ptotal', 'phat', 'pes-hat', 'pmus', 'location', 'best');
for i = 1:size(ins_marks, 2)
    xline(ins_marks(i)-ins_marks(1),'--r', 'HandleVisibility', 'off');
end
title('Pressures')
link_plot(2) = subplot(2,1,2);
plot(orig_flow); grid on;
for i = 1:size(ins_marks, 2)
    xline(ins_marks(i)-ins_marks(1),'--r');
end
title('Flow')
linkaxes(link_plot,'x');
sgtitle('Original dynamic response');

% evaluated response plot
figure;
link_plot(1) = subplot(2,1,1);

plot(orig_paw); hold on;
plot(eval_ptotal); hold on; plot(eval_ptotal_hat); hold on; 
plot(eval_pes); hold on; plot(eval_pmus); grid on;
legend('paw', 'ptotal', 'phat', 'pes-hat', 'pmus', 'location', 'best');
for i = 1:size(ins_marks, 2)
    xline(ins_marks(i)-ins_marks(1),'--r', 'HandleVisibility', 'off');
end
title('Pressures')
link_plot(2) = subplot(2,1,2);
plot(orig_flow); grid on;
for i = 1:size(ins_marks, 2)
    xline(ins_marks(i)-ins_marks(1),'--r');
end
title('Flow')
linkaxes(link_plot,'x');
sgtitle('Corrected dynamic response');

% Respiratory Parameters
actual_crs = 18.5 % mL/cmH20
actual_rrs = 0.0168 % cmH20/(mL/s)

eval_crs = 1./eval_ers;
orig_crs = 1./orig_ers;

figure;
link_plot(1) = subplot(2,1,1);
plot(eval_rrs, 'k-o'); hold on;
plot(orig_rrs, 'b-o'); hold on;
yline(actual_rrs, '--r');
legend('corrected', 'original', 'measured');
title('Respiratory system resistance');
link_plot(2) = subplot(2,1,2);
plot(eval_crs, 'k-o'); hold on;
plot(orig_crs, 'b-o'); hold on;
yline(actual_crs, '--r');
legend('corrected', 'original', 'measured');
title('Respiratory system compliance');
linkaxes(link_plot, 'x');







