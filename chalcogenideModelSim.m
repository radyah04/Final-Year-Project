%% Mean Metastable Switch Model - Initial simulations of chalcogenide-based model
% Takes 3.6mins
clear,clc,close all;
tic

%Constants and parameters
Roff=1500;
Ron=500;
Rinit=500;
%Computing the initial condition
Xic=Ron*(Rinit-Roff)/(Rinit*(Ron-Roff));
%---------------------------Guide to Figures-------------------------------
%Figure 1: I, V, M and X waveforms for sine waves with different f
%Figure 2: I, V, M and X waveforms for sine wave with different A
%Figure 3: I-V characteristic for sine waves with different f and A
%Figure 4: I, V, M and X waveforms for square wave with different dc offset
%Figure 5: I, V, M and X waveforms for sine waves with different dc offset
%Figure 6: I, V, M and X waveforms for triangular waves with different dc offset
%Figure 7: I, V, M and X waveforms for sine wave input to in-series/in-parallel configuration
%------------------------------SINE INPUT----------------------------------
%Setting the frequency of the input signal
f=100;

%Setting a sinusoidal input voltage source
time_vect=[0:1/10000:(1-1/10000)]; %Generate t for V
V=0.5*sin(2*pi*f*time_vect); %Generate input voltage waveform V(t)
figure(1),subplot(3,5,1);
plot(time_vect,V);
title('V(t) ({\itf} = 100Hz)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.04]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(1),subplot(3,5,2);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.04])

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%Obtaining the current as I = GV
I=G.*V';
figure(1),subplot(3,5,3);
plot(time_vect,I);
title('I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.04]);

%Plotting the variation of the memristance with time
M=V./(I');
figure(1),subplot(3,5,4);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.04]);

%Plotting the I-V characteristic
figure(1),subplot(3,5,5);
plot(V,I),hold on;
plot(V(1),I(1),'r*');
title('I - V response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
figure(3),subplot(1,2,1);
plot(V,I),hold on;
title({['I - V Response of Chalcogenide-based'] ['Memristor for Variable {\itf}']},'Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
figure(3),subplot(1,2,2);
plot(V,I),hold on;
title({['I - V Response of Chalcogenide-based'] ['Memristor for Variable {\itf} & {\itA}']},'Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);

f=500;
time_vect=[0:1/20000:(1-1/20000)]; %Generate t for V
V=0.5*sin(2*pi*f*time_vect); %Generate input voltage waveform V(t)

figure(1),subplot(3,5,6);
plot(time_vect,V);
title('V(t) ({\itf} = 500Hz)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.008]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(1),subplot(3,5,7);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.008])

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%Obtaining the current as I = GV
I=G.*V';
figure(1),subplot(3,5,8);
plot(time_vect,I);
title('I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.008]);

%Plotting the variation of the memristance with time
M=V./(I');
figure(1),subplot(3,5,9);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.008]);

%Plotting the I-V characteristic
figure(1),subplot(3,5,10);
plot(V,I),hold on;
plot(V(1),I(1),'r*');
title('I - V response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
figure(3),subplot(1,2,1);
plot(V,I);
figure(3),subplot(1,2,2);
plot(V,I);

f=2000;
time_vect=[0:1/200000:(1-1/200000)]; %Generate t for V
V=0.5*sin(2*pi*f*time_vect); %Generate input voltage waveform V(t)

figure(1),subplot(3,5,11);
plot(time_vect,V);
title('V(t) ({\itf} = 2000Hz)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.002]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(1),subplot(3,5,12);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.002])

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%Obtaining the current as I = GV
I=G.*V';
figure(1),subplot(3,5,13);
plot(time_vect,I);
title('I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.002]);

%Plotting the variation of the memristance with time
M=V./(I');
figure(1),subplot(3,5,14);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.002]);

%Plotting the I-V characteristic
figure(1),subplot(3,5,15);
plot(V,I),hold on;
plot(V(1),I(1),'r*');
title('I - V response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
figure(3),subplot(1,2,1);
plot(V,I);
plot(V(1),I(1),'r*');
legend('{\itf} = 100Hz','{\itf} = 500Hz','{\itf} = 2kHz','Fontsize',14);
figure(3),subplot(1,2,2);
plot(V,I);
%--------------------------Effect of Amplitude-----------------------------
f=500;
time_vect=[0:1/20000:(1-1/20000)]; %Generate t for V
V=2*sin(2*pi*f*time_vect); %Generate input voltage waveform V(t)

figure(2),subplot(1,5,1);
plot(time_vect,V);
title('V(t) ({\itf} = 500Hz)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.008]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(2),subplot(1,5,2);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.008])

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%Obtaining the current as I = GV
I=G.*V';
figure(2),subplot(1,5,3);
plot(time_vect,I);
title('I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.008]);

%Plotting the variation of the memristance with time
M=V./(I');
figure(2),subplot(1,5,4);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.008]);

%Plotting the I-V characteristic
figure(2),subplot(1,5,5);
plot(V,I),hold on;
plot(V(1),I(1),'r*');
title('I - V response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
figure(3),subplot(1,2,2);
plot(V,I);
plot(V(1),I(1),'r*');
legend('{\itA} = 0.5, {\itf} = 100Hz','{\itA} = 0.5, {\itf} = 500Hz','{\itA} = 0.5, {\itf} = 2kHz','{\itA} = 2, {\itf} = 100Hz','Fontsize',14);
%------------------------------SQUARE INPUT------------------------------
f=100;
time_vect=[0:1/10000:(1-1/10000)]; %Generate t for V
V=0.5*square(2*pi*f*time_vect); %Generate input voltage waveform V(t)
figure(4),subplot(3,5,1);
plot(time_vect,V);
title('V(t) ({\itf} = 100Hz)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.04]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(4),subplot(3,5,2);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.04])

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%Obtaining the current as I = GV
I=G.*V';
figure(4),subplot(3,5,3);
plot(time_vect,I);
title('I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.04]);

%Plotting the variation of the memristance with time
M=V./(I');
figure(4),subplot(3,5,4);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.04]);

%Plotting the I-V characteristic
figure(4),subplot(3,5,5);
plot(V,I);
title('I - V response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);

f=100;
time_vect=[0:1/10000:(1-1/10000)]; %Generate t for V
V=-0.2+0.5*square(2*pi*f*time_vect); %Generate input voltage waveform V(t)
figure(4),subplot(3,5,6);
plot(time_vect,V);
title('V(t) (offset = -0.2V)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.04]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(4),subplot(3,5,7);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.04]);

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%Obtaining the current as I = GV
I=G.*V';
figure(4),subplot(3,5,8);
plot(time_vect,I);
title('I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.04]);

%Plotting the variation of the memristance with time
M=V./(I');
figure(4),subplot(3,5,9);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.04]);

%Plotting the I-V characteristic
figure(4),subplot(3,5,10);
plot(V,I);
title('I - V response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);

f=100;
time_vect=[0:1/10000:(1-1/10000)]; %Generate t for V
V=0.4+0.5*square(2*pi*f*time_vect); %Generate input voltage waveform V(t)
figure(4),subplot(3,5,11);
plot(time_vect,V);
title('V(t) (offset = 0.4V)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.04]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(4),subplot(3,5,12);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.04])

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%Obtaining the current as I = GV
I=G.*V';
figure(4),subplot(3,5,13);
plot(time_vect,I);
title('I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.04]);

%Plotting the variation of the memristance with time
M=V./(I');
figure(4),subplot(3,5,14);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.04]);

%Plotting the I-V characteristic
figure(4),subplot(3,5,15);
plot(V,I);
title('I - V response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
%--------------------------Effect of DC Offset-----------------------------
%Increasing the offset of the square pulses from 0V to 0.5 and 1V
%Setting the frequency of the input signal
f=100;

%Setting a sinusoidal input voltage source
time_vect=[0:1/10000:(1-1/10000)]; %Generate t for V
V=0.5*sin(2*pi*f*time_vect); %Generate input voltage waveform V(t)
figure(5),subplot(4,5,1);
plot(time_vect,V);
title('V(t) (offset = 0V)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.04]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(5),subplot(4,5,2);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.04])

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%Obtaining the current as I = GV
I=G.*V';
figure(5),subplot(4,5,3);
plot(time_vect,I);
title('I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.04]);

%Plotting the variation of the memristance with time
M=V./(I');
figure(5),subplot(4,5,4);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.04]);

%Plotting the I-V characteristic
figure(5),subplot(4,5,5);
plot(V,I),hold on;
plot(V(1),I(1),'r*');
title('I - V response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);

offset=0.29;
V=offset+0.5*sin(2*pi*f*time_vect); %Generate input voltage waveform V(t)
figure(5),subplot(4,5,6);
plot(time_vect,V);
title({["V(t)"] ["(offset = 0.29)"]},'Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.04]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(5),subplot(4,5,7);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.04])

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%Obtaining the current as I = GV
I=G.*V';
figure(5),subplot(4,5,8);
plot(time_vect,I);
title('I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.04]);

%Plotting the variation of the memristance with time
M=V./(I');
figure(5),subplot(4,5,9);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.04]);

%Plotting the I-V characteristic
figure(5),subplot(4,5,10);
plot(V,I),hold on;
plot(V(1191),I(1191),'r*');
title('I - V response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);

offset=-0.29;
V=offset+0.5*sin(2*pi*f*time_vect); %Generate input voltage waveform V(t)
figure(5),subplot(4,5,11);
plot(time_vect,V);
title({["V(t)"] ["(offset = -0.29)"]},'Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.04]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(5),subplot(4,5,12);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.04])

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%Obtaining the current as I = GV
I=G.*V';
figure(5),subplot(4,5,13);
plot(time_vect,I);
title('I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.04]);

%Plotting the variation of the memristance with time
M=V./(I');
figure(5),subplot(4,5,14);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.04]);

%Plotting the I-V characteristic
figure(5),subplot(4,5,15);
plot(V,I),hold on;
plot(V(411),I(411),'r*');
title('I - V response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);

V=1+0.5*sin(2*pi*f*time_vect); %Generate input voltage waveform V(t)
figure(5),subplot(4,5,16);
plot(time_vect,V);
title({['V(t)'] ['(offset = 1V)']},'Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.04]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(5),subplot(4,5,17);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.04]);

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%Obtaining the current as I = GV
I=G.*V';
figure(5),subplot(4,5,18);
plot(time_vect,I);
title('I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.04]);

%Plotting the variation of the memristance with time
M=V./(I');
figure(5),subplot(4,5,19);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.04]);

%Plotting the I-V characteristic
figure(5),subplot(4,5,20);
plot(V,I),hold on;
title('I - V response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
%----------------------------TRIANGULAR INPUT------------------------------
f=100;

%Setting a triangular input voltage source
time_vect=[0:1/20000:(1-1/20000)]; %Generate t for V
V=0.5*sawtooth(2*pi*f*time_vect,0.5); %Generate input voltage waveform V(t)
figure(6),subplot(3,5,1)
plot(time_vect,V);
title({['V(t)'] ['({\itf} = 100Hz)']},'Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.04]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(6),subplot(3,5,2);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.04]);

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%Obtaining the current as I = GV
I=G.*V';
figure(6),subplot(3,5,3);
plot(time_vect,I);
title('I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.04]);

%Plotting the variation of the memristance with time
M=V./(I');
figure(6),subplot(3,5,4);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.04]);

%Plotting the I-V characteristic
figure(6),subplot(3,5,5);
plot(V,I),hold on;
plot(V(1251),I(1251),'r*');
title('I - V response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);

V=-0.2+0.5*sawtooth(2*pi*f*time_vect,0.5); %Generate input voltage waveform V(t)
figure(6),subplot(3,5,6)
plot(time_vect,V);
title({['V(t)'] ['(dc offset = -0.2)']},'Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.04]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(6),subplot(3,5,7);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.04]);

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%Obtaining the current as I = GV
I=G.*V';
figure(6),subplot(3,5,8);
plot(time_vect,I);
title('I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.04]);

%Plotting the variation of the memristance with time
M=V./(I');
figure(6),subplot(3,5,9);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.04]);

%Plotting the I-V characteristic
figure(6),subplot(3,5,10);
plot(V,I),hold on;
plot(V(331),I(331),'r*');
title('I - V response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);

V=0.29+0.5*sawtooth(2*pi*f*time_vect,0.5); %Generate input voltage waveform V(t)
figure(6),subplot(3,5,11)
plot(time_vect,V);
title({['V(t)'] ['(dc offset = -0.29)']},'Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.04]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(6),subplot(3,5,12);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.04])

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%Obtaining the current as I = GV
I=G.*V';
figure(6),subplot(3,5,13);
plot(time_vect,I);
title('I(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.04]);

%Plotting the variation of the memristance with time
M=V./(I');
figure(6),subplot(3,5,14);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.04]);

%Plotting the I-V characteristic
figure(6),subplot(3,5,15);
plot(V,I),hold on;
plot(V(1380),I(1380),'r*');
title('I - V response','Fontsize',18);
xlabel('{\itV} (V)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
%--------------------------IN SERIES/IN PARALLEL---------------------------
f=100;

%In-parallel
%Setting a sinusoidal input voltage source
time_vect=[0:1/10000:(1-1/10000)]; %Generate t for V
V=0.5*sin(2*pi*f*time_vect); %Generate input voltage waveform V(t)
figure(7),subplot(2,5,1);
plot(time_vect,V);
title({['V_{in}(t)']},'Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.04]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(7),subplot(2,5,2);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.04]);

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%This is the conductance of an individual memristor
%Thus, when in parallel, the total conductance will be double

%Obtaining the current as I = ΣGV
I=G.*V';
Iin=2*I;
figure(7),subplot(2,5,3);
plot(time_vect,Iin);
title('I_{in}(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.04]);

%Plotting the variation of the memristance with time
M=V./(Iin');
figure(7),subplot(2,5,4);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.04]);

%Plotting the I-V characteristic
figure(7),subplot(2,5,5);
plot(V,Iin),hold on;
plot(V,I);
plot(V(1),I(1),'r*');
title('I - V response','Fontsize',18);
ylabel('{\itI} (A)','Fontsize',16);
xlabel('{\itV} (V)','Fontsize',16);
legend('In-parallel','Single memristor');

%In-series
%Setting a sinusoidal input voltage source
time_vect=[0:1/10000:(1-1/10000)]; %Generate t for V
Vin=0.5*sin(2*pi*f*time_vect); %Generate input voltage waveform V(t)
V=0.5*Vin; %Voltage across each memristor
figure(7),subplot(2,5,6);
plot(time_vect,Vin);
title({['V_{in}(t)']},'Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itV} (V)','Fontsize',16);
xlim([0 0.04]);

%Solving the ODE to obtain the state variable X(t)
[t X]=ode45(@(t,X) fODE(t,X,V,time_vect),time_vect,Xic);

figure(7),subplot(2,5,7);
plot(t,X);
title('X(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itX}(t)','Fontsize',16);
xlim([0 0.04])

%Obtaining the conductance G as a function of X(t)
G=X/Ron+(1-X)/Roff;

%This is the conductance of an individual memristor

%Obtaining the current as I = ΣGV
I=G.*V'; %Current through the in-series combination
figure(7),subplot(2,5,8);
plot(time_vect,I);
title('I_{in}(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itI} (A)','Fontsize',16);
xlim([0 0.04]);

%Plotting the variation of the memristance with time
M=Vin./(I');
figure(7),subplot(2,5,9);
plot(time_vect,M);
title('M(t)','Fontsize',18);
xlabel('Time{\it t} (s)','Fontsize',16);
ylabel('{\itM} (Ω)','Fontsize',16);
xlim([0 0.04]);

%Plotting the I-V characteristic
figure(7),subplot(2,5,10);
plot(Vin,I),hold on;
plot(V,I);
plot(V(1),I(1),'r*');
title('I - V response','Fontsize',18);
ylabel('{\itI} (A)','Fontsize',16);
xlabel('{\itV} (V)','Fontsize',16);
legend('In-series','Single memristor');

toc
%------------------------------ODE Function--------------------------------
%Non-updated initial version: did not use one function block with a nested function
function dXdt=fODE(t,X,V,time_vect)
    %Defining the constants
    beta_var=1/0.026; %Inverse of the thermal voltage VT
    Von=0.27;
    Voff=0.27;
    tau=.0001;
    
    V_interp=interp1(time_vect,V,t); %Interpolating the data set (Vt,V) at times t
    
    %Evaluating the ODE at times t
    dXdt=1/tau*[1./(1+exp(-beta_var.*(V_interp-Von))).*(1-X)-(1-1./(1+exp(-beta_var.*(V_interp+Voff)))).*X];
end

%Updated version using a nested function
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
