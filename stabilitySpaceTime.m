function [dxOptimal, nxOptimal, dtOptimal, ntOptimal] = stabilitySpaceTime(material,doplot)
%stabilityTimeSpace    Calculates optimal DX and NX for numerical method use.
%
%   Iterates through different values of the spatial step DX
%   through shuttle for the specified tile MATERIAL, and calculates the 
%   maximum value for optimal speed and half degree accuracy. The function
%   considers the DTOPTIMAL found using stabilityTime to compute a stable
%   DX.
%
% Made by: D N Johnston  30/1/19
% Modified by: Frederico Rodrigues, 10921
% University of Bath


% Calls stabilityTime for optimal nt for speed
[dtOptimal, ntOptimal] = stabilityTime(material,false);

%% Computation of final temperature for varying DX

% Initialising Shuttle variables
i=0; 
thick = 0.05; 
tmax = 4000;
nt = ntOptimal;
ntile = 597;

% Initialising solution vectors for speed
loop = 3:1:51;
dx = zeros(size(loop));
uf = zeros(size(loop));
ub = zeros(size(loop));
ud = zeros(size(loop));
uc = zeros(size(loop));

for nx = 3:1:51
    
    i=i+1; 
    dx(i) = thick/(nx-1); 
    disp (['nx = ' num2str(nx) ', dx = ' num2str(dx(i)) ' s']) 
    
    % Obtaining final temperature using the forward diff. method
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'forward', false, ntile, 'given'); 
    uf(i) = u(end, 1);
    
    % Obtaining final temperature using the backward diff. method
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'backward', false, ntile,'given');
    ub(i) = u(end, 1); 
    
    % Obtaining final temperature using the dufort-frankel method
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'dufort-frankel', false, ntile, 'given');
    ud(i) = u(end, 1); 
    
    % Obtaining final temperature using the crank-nicolson method
    [~, ~, u] = shuttle(tmax, nt, thick, nx, 'crank-nicolson', false, ntile, 'given');
    uc(i) = u(end, 1); 
    
end

% Data plotting
if doplot
    
    plot(dx, [uf; ub; ud; uc])
    xlabel('Space Step size (dx), m')
    ylabel('Final Temperature Value, °C')
    ylim([138 148])
    legend ('Forward', 'Backward', 'Dufort-Frankel', 'Crank-Nicolson')
    
end

%% Finding optimal DX value using crank-nicolson

% Assume final temperature for initial values is 143°C
% Finding maximum dx for half-degree accuracy
a = find(uc<143.5 & uc>142.5);
dxMax = dx(a(1));

% Halving the maximum dx for greater accuracy
dxOptimal = dxMax / 2;
nxOptimal = (thick / dxOptimal) + 1;

disp(['Optimal nx = ' num2str(nxOptimal)])
disp(['Optimal dx = ' num2str(dxOptimal)])
disp(['Optimal nt = ' num2str(ntOptimal)])
disp(['Optimal dt = ' num2str(dtOptimal)])

end


