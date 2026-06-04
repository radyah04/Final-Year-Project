function mem = HPmemristor_Pierre(Ron, Roff, z0)
%HPMEMRISTOR_PIERRE Initialises Pierre-style charge-controlled HP memristor.
%
% Inputs:
%   Ron  - ON resistance [ohm]
%   Roff - OFF resistance [ohm]
%   z0   - initial internal state, 0 <= z0 <= 1
%
% Outputs:
%   mem - structure containing model constants

% Constants used in Pierre's appendix
uv = 1e-14;      % vacancy mobility [m^2/(V s)]
D = 1e-9;        % device length [m]

% Initial memristance from HP weighted resistance
R0 = Ron*z0 + Roff*(1-z0);

% Charge coefficient
% Pierre uses a charge-controlled form related to M(q)=R0-kq
k = Ron*uv*(Roff - Ron)/(D^2);

% Maximum charge for full state transition
qmax = D^2/(uv*Ron);

% Initial charge corresponding to z0
q0 = z0*qmax;

% Initial flux from integrating M(q)
phi0 = R0*q0 - 0.5*k*q0^2;

% Maximum flux
phimax = Ron*qmax + 0.5*(Roff - Ron)*qmax;

% Store constants
mem.Ron = Ron;
mem.Roff = Roff;
mem.z0 = z0;
mem.R0 = R0;
mem.k = k;
mem.q0 = q0;
mem.phi0 = phi0;
mem.qmax = qmax;
mem.phimax = phimax;
mem.uv = uv;
mem.D = D;

end
