clear all
clc

% pre processing stage 
N_x = 121; % grid point in x direction 
N_y = 81; % grid points in y direction 
X_min = 0; % X initial poistion of domain in meter
X_max = 0.06; % X end poistion of domain in meter
Y_min = 0; % Y initial poistion of domain in meter
Y_max = 0.04; % Y end poistion of domain in meter
SF_1 = 0.01; % stream function in boundry top, left, bottom left in meter square per second 
SF_2 = 0.00; % stream function in boundry bottom right in meter square per second 
BLT = 0.01; % bottom left thickness
ILT = 0.002; % inlet thickness at the bottom
l=3; %1 for jacobi, 2 for GS method, 3 for relaxation method
w = 1.8; %relaxation parameter with increment of 0.1

%u = size(w);

delta_X = (X_max - X_min) / (N_x-1); % grid thickness value in X direction  
delta_Y = (Y_max - Y_min) / (N_y-1); % grid thickness value in Y direction 

BL = BLT / delta_X; %bottom left boundary
IL = ILT / delta_X; %Inlet interval thickness 

INV = BL + IL; % inlet end point 

% strema function 

Psi = zeros(N_x , N_y);

% boundary condition 
for i = 1 : N_x  % top boundary 
    Psi(i , N_y) = SF_1;
end
for i = 1 : N_y  % left boundary
    Psi(1 , i) = SF_1;
end
for i = 1 : BL+1  % bottom left bounday
    Psi ( i , 1 ) = SF_1;
end


Beta = delta_X.^2/(delta_Y.^2);

%delta_abs = 1; % intialiazation guess for residual
delta_abs = 1;
Psi_new= Psi ;
k=0;
switch l
    case 1                          %Jacobi function 
    while delta_abs > 0.00001  %limiting thrush hold value for error
    k=k+1;  %count of number of iteration 
    for j = 2 : N_y-1
        for i = 2 : N_x -1
            Psi_new(i,j) = (Psi(i+1,j)+Psi(i-1,j)+Beta*(Psi(i,j+1)+Psi(i,j-1)))*(1/(2*(1+Beta))); %jacobi function 
        end %end of loop i
     end %end of loop j
      Psi_new(N_x ,:) = Psi_new(N_x-1 ,:); % outer boundary condition
      delta_abs = max (max(abs( Psi_new - Psi))); %residual computaion
      delta_rel = max (max(abs((Psi_new - Psi)./(abs(Psi)+eps)))); % relative computation
     Psi = Psi_new;
     a(k,1) = delta_abs;
    end %end of itteration 
    case 2                          % GS function
    while delta_abs > 0.00001   %limiting thrush hold value for error
    k=k+1; %count of number of iteration 
    for j = 2 : N_y-1
        for i = 2 : N_x -1
            Psi_new(i,j) = (Psi(i+1,j)+Psi_new(i-1,j)+Beta*(Psi(i,j+1)+Psi_new(i,j-1)))*(1/(2*(1+Beta))); %GS function 
        end %end of loop i
     end %end of loop j
      Psi_new(N_x ,:) = Psi_new(N_x-1 ,:); % outer boundary condition
      delta_abs = max (max(abs( Psi_new - Psi))); %residual computaion
      delta_rel = max (max(abs((Psi_new - Psi)./(abs(Psi)+eps)))); % relative computation
     Psi = Psi_new;
     a(k,1) = delta_abs;
    end %end of itteration 
    otherwise                       %relaxation function
     while delta_abs > 0.00001 %limiting thrush hold value for error
    k=k+1; %count of number of iteration 
    for j = 2 : N_y-1
        for i = 2 : N_x -1
            Psi_new(i,j) = (1-w)*Psi(i,j)+w*((Psi(i+1,j)+Psi_new(i-1,j)+Beta*(Psi(i,j+1)+Psi_new(i,j-1)))*(1/(2*(1+Beta))));% relaxation function 
        end %end of loop i
     end %end of loop j
      Psi_new(N_x ,:) = Psi_new(N_x-1 ,:); % outer boundary condition
      delta_abs = max (max(abs( Psi_new - Psi))); %residual computaion
      delta_rel = max (max(abs((Psi_new - Psi)./(abs(Psi)+eps)))); % relative computation
     Psi = Psi_new;
     a(k,1) = delta_abs;
    end %end of itteration 
end

[u,v] = gradient(Psi_new, delta_X, delta_Y); %calculation of velocity distribution in u and v direction 
v=-v; % v= -d(Psi)/dx
quiver(u',v',10) % drawing a velocity profile in vector form with the scale of 10 
TV=0;
for i=1:N_y
    delta_V = u(N_x,i)*delta_Y; % volume flow rate at eact delta y value at the exit 
V(i,1) = delta_V; %storage of delata_V  in a martix
TV=TV+delta_V; % method 1 of calculation total volume flow rate with addition of each delta V value 
end
TV
total_Volume_flow_rate = sum(V) %total volume flow rate 

for i = BL+1 : INV
    Inlet_V = v(i,1) * delta_X; %inlet flow at each delta x value at the entrance
    IV(i,1) = Inlet_V;
end
total_inlet_flow = sum(IV) %total inflow volume flow rate
