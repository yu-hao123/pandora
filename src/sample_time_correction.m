%% Corrects waveforms with a constant sample time
clear variables;

filename = "../data/signals/occl_1921.mat";
load(filename);

table = occl_1921;
timestamp = table.Stamp;
paw = table.Paw;
pes = table.Pes;
flow = table.Flow;
vol = table.Vol;

% Matching a constant sample time
start = timestamp(1);
regular_timestamp = zeros(size(timestamp, 1), 1);
block_counter = 0;
for i = 1:size(timestamp, 1)
    regular_timestamp(i) = timestamp(i) + block_counter * 1000;
    if i == size(timestamp, 1)
        continue
    end
    if (timestamp(i+1) < timestamp(i)) 
        block_counter = block_counter + 1;
    end
end

corrected_timestamp = regular_timestamp - start;

sample_t = ...
    round(mean(corrected_timestamp((2:end)) - ...
    corrected_timestamp((1:end-1))));

t = (0:sample_t:((size(timestamp, 1)-1)*sample_t))';

c_paw = interp1(corrected_timestamp,paw,t,'spline');
c_pes = interp1(corrected_timestamp,pes,t,'spline');
c_vol = interp1(corrected_timestamp,vol,t,'spline');
c_flow = interp1(corrected_timestamp,flow,t,'spline');
Ts = sample_t;

save("../data/signals/corrected_occl_1921.mat",...
    'c_paw','c_pes', 'c_vol', 'c_flow', 't', 'Ts');
