function [I, G, M, q, phi] = HPmodel_Athina(Ron, Roff, mu, D, V, time_vect, timestep)
%HPMODEL_ATHINA Voltage-driven HP memristor model adapted from Dendri.
%
% Inputs:
%   Ron       - ON resistance [ohm]
%   Roff      - OFF resistance [ohm]
%   mu        - average vacancy mobility [m^2/(V s)]
%   D         - memristor film thickness [m]
%   V         - voltage vector [V]
%   time_vect - time vector [s]
%   timestep  - time step [s]
%
% Outputs:
%   I    - current vector [A]
%   G    - conductance vector [S]
%   M    - memristance vector [ohm]
%   q    - charge vector [C]
%   phi  - flux vector [Wb]
%
% Note:
% This is adapted from Athina Dendri's HPmodel.m. The original function
% returns I and G. Here, M, q and phi are also calculated so the model can
% be compared using the same outputs as the rest of this project.

% Constants from the voltage-driven HP formulation
k2 = (Ron - Roff) * mu * Ron / (D^2);

% Athina used k3 = Roff/10 as an integration constant.
% This gives an initial memristance-like constant.
k3 = Roff/10;

% Preallocate outputs
N = length(time_vect);
I = zeros(1, N);
G = zeros(1, N);
M = zeros(1, N);

for idx = 1:N

    % Voltage history up to current time
    V_time = V(1:idx);

    % Integral of voltage history
    int_V = timestep * trapz(V_time);

    % Denominator from voltage-driven HP expression
    denom = sqrt(k3 - 2*k2*int_V);

    % Avoid division by zero or complex values
    if isreal(denom) && denom > 0
        I(idx) = V(idx)/denom;
    else
        I(idx) = NaN;
    end

    % Conductance and memristance
    if abs(V(idx)) > eps && ~isnan(I(idx))
        G(idx) = I(idx)/V(idx);
        M(idx) = V(idx)/I(idx);
    else
        G(idx) = NaN;
        M(idx) = NaN;
    end
end

% Charge and flux using trapezoidal integration
q = cumtrapz(time_vect, I);
phi = cumtrapz(time_vect, V);

end
