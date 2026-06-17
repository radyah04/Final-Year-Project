function [I, G] = HPmodel(Ron, Roff, mu, D, V, time_vect, timestep)
% INPUTS to MODEL:
% ON resistance
% OFF resistance
% mu: average vacancy mobility of linear ionic drift
% Thickness D of the memristor (with high and low dopant concentration)
% Voltage V at times time_vect

% OUTPUTS of MODEL:
% Current I at times t
% Memristance M at times t

    % Defining the constants k2 and k3
    k2 = (Ron - Roff) * mu * Ron/(D^2);
    k3 = Roff/10;
   
    I = zeros(1, length(time_vect));
    G = zeros(1, length(time_vect));
   
    for t = 1:length(time_vect)
       
        % Obtaining the current I as a function of time t
        V_time = V(1:t);
        I(t) = V(t)/((k3 - 2 * k2 * 1/timestep * trapz(V_time))^(1/2));
   
        % Obtaining the variation of the memristance with time
        G(t) = 1/(V(t)/(I(t))');
    end
end