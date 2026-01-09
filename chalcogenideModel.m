function [X, G, I, M] = chalcogenideModel(V, time_vect, Xic)
% INPUTS to MODEL:
% Voltage V at times time_vect
% Initial condition for state variable Xic

% OUTPUTS of MODEL:
% State variable X at times t
% Memductance G at times t
% Current I at times t
% Memristance M at times t

    % Solving the ODE
    [t X] = ode45(@(t, X) fODE(t, X, V, time_vect), time_vect, Xic);
    
    % Obtaining the conductance G as a function of X(t)
    Roff = 1500;
    Ron = 500;
    Rinit = 500;
    G = X/Ron + (1 - X)/Roff;
    
    % Obtaining the current I as a function of time t
    I = G .* V';
    
    % Obtaining the variation of the memristance with time
    M = V./(I');
    
    % Nested function which evaluates the ODE at each time instant
    function dXdt = fODE(t, X, V, time_vect)
        % Defining the constants
        beta_var = 1/0.026; %Inverse of the thermal voltage VT
        Von = 0.27;
        Voff = 0.27;
        tau = .0001;

        V_interp = interp1(time_vect, V, t); %Interpolating the data set (Vt,V) at times t

        % Evaluating the ODE at times t
        dXdt = 1/tau * [1./(1 + exp(-beta_var .* (V_interp - Von))) .* (1 - X)
            - (1 - 1./(1 + exp(-beta_var .* (V_interp + Voff)))) .* X];
    end
end