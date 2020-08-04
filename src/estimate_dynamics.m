function [pmus, ptotal, ptotal_hat, ers, rrs] = estimate_dynamics(pes, paw, ccw, flow, vol)
    ecw = 1/ccw;
    pmus = pes - ecw * vol;
    pmus = pmus - median(pmus(end-10:end));
    
    ptotal = paw - pmus;
    %Ptotal = Flow * Rrs + Volume * Ers
    %Ptotal = [Flow Volume] * [Rrs; Ers]
    A = [flow vol];
    
    % Least Squares
    h = (A'*A)\A'*ptotal;

    rrs = h(1);
    ers = h(2);

    ptotal_hat = A*h;
end