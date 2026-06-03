function out = hp_model(t,v,params)
%HP_MODEL Simulates the HP linear ion-drift memristor model.
%
% Inputs:
%   t      - time vector [s]
%   v      - voltage input [V]
%   params - structure containing Ron, Roff, uv, D and x0
%
% Outputs:
%   out.i   - terminal current [A]
%   out.x   - normalised state variable w/D
%   out.M   - memristance [ohm]
%   out.G   - conductance [S]
%   out.q   - charge [C]
%   out.phi - flux [Wb]

Ron = params.Ron;
Roff = params.Roff;
uv = params.uv;
D = params.D;
x0 = params.x0;

N = length(t);
dt = t(2)-t(1);

x = zeros(1,N);
M = zeros(1,N);
G = zeros(1,N);
i = zeros(1,N);

x(1) = x0;

for k = 1:N-1

    % HP memristance equation
    M(k) = Ron*x(k) + Roff*(1-x(k));

    % Terminal current from v = M i
    i(k) = v(k)/M(k);

    % HP linear ion-drift state equation
    dxdt = (uv*Ron/D^2)*i(k);

    % Euler state update
    x(k+1) = x(k) + dxdt*(t(k+1)-t(k));

    % Physical boundary condition
    x(k+1) = min(max(x(k+1),0),1);
end

% Final sample
M(N) = Ron*x(N) + Roff*(1-x(N));
i(N) = v(N)/M(N);

% Conductance
G = 1./M;

% Numerical charge and flux
q = cumtrapz(t,i);
phi = cumtrapz(t,v);

out.i = i;
out.x = x;
out.M = M;
out.G = G;
out.q = q;
out.phi = phi;
end
