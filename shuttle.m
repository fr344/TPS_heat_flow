function [x, t, u] = shuttle(tmax, nt, xmax, nx, method, doplot, ntile, material)
% Function for modelling temperature in a space shuttle tile
%
% Made by: D N Johnston  30/1/19
% Modified by: Frederico Rodrigues, 10921
% University of Bath

% Input arguments:
% tmax     - maximum time
% nt       - number of timesteps
% xmax     - total thickness
% nx       - number of spatial steps
% method   - solution method ('forward', 'backward', 'dufort-frankel',
%            'crank-nicolson')
% doplot   - true to plot graph; false to suppress graph.
% ntile    - number code for the desired tile
% material - tile material
%
% Return arguments:
% x      - distance vector
% t      - time vector
% u      - temperature matrix
%
% For example, to perform a  simulation with 501 time steps
%  [x, t, u] = shuttle(4000, 501, 0.05, 21, 'forward', true, 597, 'given');

% Set tile properties
switch lower(material)
    case 'given'
        thermcon = 0.141; % W/(m K)
        density  = 351;   % 22 lb/ft^3
        specheat = 1259;  % ~0.3 Btu/lb/F at 500F
        
    case 'li-900'
        thermcon = 0.05; % W/(m K)
        density  = 144.2;   % kg/m3
        specheat = 900;  % J/(Kg K)
        
    case 'avcoat-5026'
        thermcon = 0.164; % W/(m K)
        density  = 512;   % kg/m3
        specheat = 1675;  % J/(Kg K)
end

% Some crude data to get you started:
% timedata = [0  60 500 1000 1500 1750 4000]; % s
% tempdata = [16 16 820 760  440  16   16];   % degrees C

% Import NASA data for desired tile
plottemp(ntile,false) % Reads NASA image file
S = load(['temp' num2str(ntile) '.mat']);
timedata = S.timedata;
tempdata = S.tempdata;

% Better to load surface temperature data from file.
% (you need to have modified and run plottemp.m to create the file first.)
% Uncomment the following line.
% load tempdata.mat

% Initialise everything.
dt = tmax / (nt-1);
t = (0:nt-1) * dt;
dx = xmax / (nx-1);
x = (0:nx-1) * dx;
u = zeros(nt, nx);

% Initialising p constant for numerical methods
alpha = thermcon/(density * specheat); % Thermal diffusivity, m^2/s
p = alpha * dt / dx^2;

% Optional for debugging
% % create dialog box for entering value of p
% answer = inputdlg('Enter the value of p/alpha');
% % convert from string to number
% p = alpha*str2double(answer{1});

% set initial conditions to 16C throughout.
% Do this for first two timesteps.
u([1 2], :) = 16;

ivec = 2:nx-1; % set up index vector

% Main timestepping loop.
for n = 2:nt - 1
    
    % RHS boundary condition: outer surface.
    % Use interpolation to get temperature R at time t(n+1).
    RF = interp1(timedata, tempdata, t(n+1), 'linear', ...
        'extrap'); % In Farenheit
    R = (5/9) * (RF - 32); % Farenheit to Celsius Conversion of RHS
    
    % Select method.
    switch method
        case 'forward'
            
            % LHS Neumann boundary condition
            u(n+1,1) = (1 - 2*p) * u(n,1) + 2*p*u(n,2);
            % RHS Dirichlet boundary condition
            u(n+1, nx) = R;
            
            % Calculate internal values using forward differencing
            u(n+1,ivec) = (1 - 2 * p) * u(n,ivec) + p * (u(n,ivec-1) + ...
                u(n,ivec+1));
            
        case 'dufort-frankel'
            
            % LHS Neumann boundary condition
            u(n+1,1) = ((1 - 2*p) * u(n-1,1) + 4*p*u(n,2)) / (1 + 2*p);
            % RHS Dirichlet boundary condition
            u(n+1, nx) = R;
            
            % calculate internal values using Dufort-Frankel method
            u(n+1,ivec) = ((1 - 2*p) * u(n-1,ivec) + 2*p * ...
                (u(n,ivec-1) + u(n,ivec+1))) / (1 + 2*p);
            
        case 'backward'
            
            % LHS Neumann boundary condition
            b(1)    = 1 + 2*p;
            c(1)    = -2*p;
            d(1)    = u(n,1);
            
            %calculate internal values using backward differencing
            a(ivec) = -p;
            b(ivec) = 1 + 2*p;
            c(ivec) = -p;
            d(ivec) = u(n, ivec);
            
            % RHS Dirichlet boundary condition
            a(nx)   = 0;
            b(nx)   = 1;
            d(nx)   = R;
            
            u(n+1,:) = tdm(a,b,c,d);
            
        case 'crank-nicolson'
            
            % LHS Neumann boundary condition
            b(1)    = 1 + p;
            c(1)    = -p;
            d(1)    = (1 - p)*u(n,1) + p*u(n,2);
            
            %calculate internal values using backward differencing
            a(ivec) = -p/2;
            b(ivec) = 1 + p;
            c(ivec) = -p/2;
            d(ivec) = p/2*u(n, ivec-1) + (1 - p)*u(n,ivec) + ...
                p/2*u(n,ivec+1);
            
            % RHS Dirichlet boundary condition
            a(nx)     = 0;
            b(nx)     = 1;
            d(nx)     = R;
            
            u(n+1,:) = tdm(a,b,c,d);
            
        otherwise
            error (['Undefined method: ' method])
            return
    end   
    
end

% Surface Plotting
if doplot
    % Create a plot here.
    % contour plot
    surf(x,t,u)
    % comment out the next line to change the surface appearance
    shading interp
    
    % Rotate the view
    % view(140,30)
    
    %label the axes
    xlabel('\itx\rm - m')
    ylabel('\itt\rm - s')
    zlabel('\itu\rm - deg C')
    title({['Temperature distribution across tile #' num2str(ntile)], ...
        [' using the ' method ' method']})
end

% End of shuttle function

%=========================================================================%
% Tri-diagonal matrix solution function
function x = tdm(a,b,c,d)
%TDM The tri-diagonal matrix solution method
%   Takes inputs a, b, c and d for the tri diagonal matrix structure and
%   solves for the x vector.

n = length(b);

% Eliminate a terms
for i = 2:n
    factor = a(i) / b(i-1);
    b(i) = b(i) - factor * c(i-1);
    d(i) = d(i) - factor * d(i-1);
end

x(n) = d(n) / b(n);

% Loop backwards to find other x values by back-substitution
for i = n-1:-1:1
    x(i) = (d(i) - c(i) * x(i+1)) / b(i);
end
%=========================================================================%


