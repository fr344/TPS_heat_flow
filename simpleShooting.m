%fullShooting    Solves the boundary value problem (BVP) for the tile
%   thickness.
%
%   fullShooting calculates the optimal DT and DX value for computing
%   shuttle, considers the maximum temperature UMAX 
%   allowed at the inner surface of the desired space shuttle tile NTILE 
%   and calculates the necessary tile thickness using the Shooting Method
%   technique.
%
% Frederico Rodrigues
% University of Bath

%% Stating initial variables for ivpSolver

% Prompt for faster debugging
prompt = {'Simulation Time','Method',...
    'Max Shuttle Wall Temperature','Tile Number','Material'};
title = 'Input';
dims = [1 35];
definput = {'4000','crank-nicolson','60','597','Given'};
answer = inputdlg(prompt,title,dims,definput);

tmax = str2double(answer{1});
method = answer{2};
umax = str2double(answer{3});
ntile = str2double(answer{4});
material = answer{5};
doplot = false;

% DEBUGGING: Setting optimal dx to be kept constant during iterations
%dx = 0.006;

% Calculating optimal dx and nt to ensure Shooting Method stability
[dx,~,~,nt] = stabilitySpaceTime(material,false);


% Tile thickness guesses for shooting method initiation
thick1 = 0.01;
thick2 = 0.1;

% Computing nx to mantain dx = 0.006 constant
nx1 = round(thick1/dx + 1,0); % Integer required
nx2 = round(thick2/dx + 1,0);

%% Computing initial guesses and boundary value error
% Calling shuttle for each guess

[~,~,u1] = shuttle(tmax, nt, thick1, nx1, method, doplot, ...
    ntile, material); 
[~,~,u2] = shuttle(tmax, nt, thick2, nx2, method, doplot, ...
    ntile, material); 
z1 = max(u1(:,1));
z2 = max(u2(:,1));

% Evaluating error for boundary conditions
% Finds the maximum temperature along the RHS of the tile
e1 = z1 - umax;
e2 = z2 - umax;

%% Looping through guesses until error is minimised

en = 1; % Initializing final error
while abs(en) > 1e-7
    
    % Computing next guess
    thick = thick2 - e2*((thick2-thick1)/(e2-e1));
    nx = round(thick/dx + 1,0);
    
    % Calling shuttle for 3rd thickness guess
    [~,~,u3] = shuttle(tmax, nt, thick, nx, method, doplot, ...
        ntile, material); 
    z3 = max(u3(:,1));
    en = z3 - umax;
    
    % Updating previous values for loop
    thick1 = thick2;
    thick2 = thick;
    e1 = e2;
    e2 = en;
    
end

% Displays minimum thickness
disp(['Mimimum thickness: ' num2str(thick*1000) ' mm'])

