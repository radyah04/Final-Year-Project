function out = HPmodel_state_v2(t,V,params)
%HPMODEL_STATE_V2 Explicit state-update HP linear ion-drift model.
%
% State variable:
%   x = w/D, where 0 <= x <= 1
%
% HP memristance:
%   M(x) = Ron*x + Roff*(1-x)
%
% Terminal equation:
%   V(t) = M(x) I(t)
%
% State equation:
%   dx/dt = eta*(mu*Ron/D^2)*I(t)
%
% eta controls polarity/sign convention.

Ron = params.Ron;
Roff = params.Roff;
mu = params.mu;
D = params.D;
x0 = params.x0;
eta = params.eta;

N = length(t);
dt = t(2)-t(1);

x = zeros(1,N);
M = zeros(1,N);
G = zeros(1,N);
I = zeros(1,N);

x(1) = x0;

for k = 1:N-1

    % Memristance from current state
    M(k) = Ron*x(k) + Roff*(1-x(k));

    % Current from terminal relation V = M I
    I(k) = V(k)/M(k);

    % Linear ion drift state update
    dxdt = eta*(mu*Ron/D^2)*I(k);

    % Euler update
    x(k+1) = x(k) + dxdt*dt;

    % Physical bounds
    if x(k+1) > 1
        x(k+1) = 1;
    elseif x(k+1) < 0
        x(k+1) = 0;
    end
end

% Final point
M(N) = Ron*x(N) + Roff*(1-x(N));
I(N) = V(N)/M(N);

G = 1./M;

q = cumtrapz(t,I);
phi = cumtrapz(t,V);

out.I = I;
out.M = M;
out.G = G;
out.x = x;
out.q = q;
out.phi = phi;
end
