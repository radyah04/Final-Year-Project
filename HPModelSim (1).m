%% HP Memristor Model Simulation
clear,clc,close all;

%---------------------------Guide to Figures-------------------------------
%Figure 1: V, I, M waveforms and I-V response for input sine wave
%Figure 2: I-V response for input sine wave for varying film thickness D
%------------------------------SINE INPUT----------------------------------
%Setting the frequency of the input signal
f=100;

%Setting a sinusoidal input voltage source
time_vect=[0:1/10000:(1-1/10000)]; %Generate t for V
V=0.5*sin(2*pi*f*time_vect); %Generate input voltage waveform V(t)

%Plotting the variation of the input voltage with time
figure(1),subplot(1,4,1);
plot(time_vect,V);
title('Input V(t) ({\itf} = 100Hz)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 .04]);

Xic=1;
Ron=100;
Roff=30000;
mu=10^(-10)*10^(-4);
D=6*10^(-9);

[I,M]=HPmodel(Ron,Roff,mu,D,V,time_vect);

%Plotting the variation of the output current with time
figure(1),subplot(1,4,2);
plot(time_vect,I);
title('Output I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.04]);

%Plotting the variation of the memristance with time
figure(1),subplot(1,4,3);
plot(time_vect,M);
title('Memristance M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.04]);

%Plotting the I-V characteristic
figure(1),subplot(1,4,4);
plot(V,I),hold on;
plot(V(1),I(1),'r*');
title('I - V Response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
figure(2);
plot(V,I,'Linewidth',1.6),hold on;
title('I - V Response of HP Memristor for Variable Film Thickness{\it D}','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);

D=7*10^(-9);
[I,~]=HPmodel(Ron,Roff,mu,D,V,time_vect);
plot(V,I,'Linewidth',1.6);

D=8*10^(-9);
[I,~]=HPmodel(Ron,Roff,mu,D,V,time_vect);
plot(V,I,'Linewidth',1.6);
plot(V(1),I(1),'r*');
legend('D = 6nm','D = 7nm','D = 8nm','Zero-crossing','Fontsize',14,'Location','southeast');

function [I,M]=HPmodel(Ron,Roff,mu,D,V,time_vect)
%INPUTS to MODEL:
%ON resistance
%OFF resistance
%μ: average vacancy mobility of linear ionic drift
%Thickness D of the memristor (with high and low dopant concentration)
%Voltage V at times time_vect

%OUTPUTS of MODEL:
%Current I at times t
%Memristance M at times t

    %Defining the constants k2 and k3
    k2=(Ron-Roff)*mu*Ron/(D^2);
    k3=Roff/10;
    
    I=zeros(1,length(time_vect));
    M=zeros(1,length(time_vect));
    
    for t=1:length(time_vect)
       
        %Obtaining the current I as a function of time t
        %I(t)=V(t)/((k3-2*k2*integral(V_time,0,time_vect(t)))^(1/2));
        
        V_time = V(1:t);
        
        I(t)=V(t)/((k3-2*k2*1/10000*trapz(V_time))^(1/2));
    
        %Obtaining the variation of the memristance with time
        M(t)=V(t)/(I(t))';
    end
end