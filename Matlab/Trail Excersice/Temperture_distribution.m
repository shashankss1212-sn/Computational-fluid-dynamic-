clc
clear all
N = 10; %number of node points
X = 0.5; %total lenght of the case
Ar = 0.01; % area of the case
K = 1000; %conductivity 
T_A = 373.15; %Temperature at the start
T_B = 773.15; %teperature at the end

delta_X = X / (N); %dividing entire domain into small segment

a = zeros(N); % Creating an inital matrix of N*N for the temparature profile 

for i = 2 : N-1
    a(i,i) = (2 * K * Ar )/delta_X ; %calculating stiffness matrix for the diagonal apart from end points
end
for i = 1 : N-1
    a(i,i+1) = -(K * Ar )/delta_X; %calculating stiffness matrix for the parallel to diagonal  and above points
end
for i = 1 : N-1
    a(i+1, i) = -(K * Ar )/delta_X;%calculating stiffness matrix for the parallel to diagonal  and below points
end
for i=1
    a(i,i) =  (3 * K * Ar )/delta_X ;%calculating stiffness matrix for the diagonal top point
end
for i = N
    a(i,i) =  (3 * K * Ar )/delta_X ; %calculating stiffness matrix for the diagonal bottom point
end
a;
s = zeros(N,1);
s(1) = (2 * K * Ar * T_A )/delta_X; %Boundary condition for the start point
s(N) = (2 * K * Ar * T_B )/delta_X; %Boundary condition for the end point 
s;
T = inv(a)* s %matrix muliplication for the tempertature distribution 

plot(T)
