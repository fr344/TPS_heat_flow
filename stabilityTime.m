function [dtOptimal, ntOptimal] = stabilityTime(material,doplot)
%stabilityTime    Calculates optimal DX and NX for numerical method use.
%
%   Iterates through different values of the time step dt
%   through shuttle for the specified tile MATERIAL, and calculates the 
%   maximum value for optimal speed and half degree accuracy.
%
% Made by: D N Johnston  30/1/19
% Modified by: Frederico Rodrigues, 10921
% University of Bath

%% Computation of final temperature for varying DT

% Initialising standard Shuttle variables
i=0; 
nx = 21; 
thick = 0.05; 
tmax = 4000;
ntile = 597;

% Initialising solution vectors for speed
loop = 41:20:1001;
dt = zeros(size(loop));
uf = zeros(size(loop));
ub = zeros(size(loop));
ud = zeros(size(loop));
uc = zeros(size(loop));

for nt = 41:20:1001
    
    i=i+1; 
    dt(i) = tmax/(nt-1); 
    disp (['nt = ' num2str(nt) ', dt = ' num2str(dt(i)) ' s']) 
    
    % Obtaining final temperature using the forward diff. method
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'forward', ...
        false, ntile, material); 
    uf(i) = u(end, 1);
    
    % Obtaining final temperature using the backward diff. method
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'backward', ...
        false, ntile, material); 
    ub(i) = u(end, 1); 
    
    % Obtaining final temperature using the dufort-frankel method
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'dufort-frankel', ...
        false, ntile, material); 
    ud(i) = u(end, 1); 
    
    % Obtaining final temperature using the crank-nicolson method
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'crank-nicolson', ...
        false, ntile, material); 
    uc(i) = u(end, 1); 
    
end 

% Data plotting
if doplot
    
plot(dt, [uf; ub; ud; uc])
xlabel('Time Step size (dt), s')
ylabel('Final Temperature Value, °C')
%ylim([142.5 143.5])
ylim([140 145])
legend ('Forward', 'Backward', 'Dufort-Frankel', 'Crank-Nicolson')

end

%% Finding optimal DT value using crank-nicolson

% Assume final temperature for initial values is 143°C
% Finding maximum dt for half-degree accuracy
a = find(uc<143.5 & uc>142.5);
dtMax = dt(a(1));

% Halving the maximum dt for greater accuracy
dtOptimal = dtMax / 2;
ntOptimal = (tmax / dtOptimal) + 1;

disp(['Optimal nt = ' num2str(ntOptimal)])

end