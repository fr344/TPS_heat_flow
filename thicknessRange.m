%thicknessRange      Plots the inner surface temperature distribution 

% Initialise variables
tmax = 4000;
nt = 161; % From optimised data
xmax = 0.05; 
nx = 19; % From optimised data
method = 'crank-nicolson';
doplot = false;
ntile = 597;
%material = 'given';

% Menu for selected material
material = menu('Material Selection','Given', 'LI-900', 'Avcoat-5026');

% Switches numerical response to corresponding string
switch material
    case 1
        material = 'given';
    case 2
        material = 'li-900';
    case 3
        material = 'avcoat-5026';
end
% Loops through range of thickness and plots solution

for xmax = 0.03:0.01:0.08
    
% Computes shuttle temperature distribution for range of thicknesses
[x, t, u] = shuttle(tmax, nt, xmax, nx, method, doplot,...
    ntile, material); 


plot(t, u(:,1));
xlabel('\itt\rm - s')
ylabel('\itu\rm - deg C')
hold on

end

legend('0.03m', '0.04m', '0.05m', '0.06m', '0.07m', '0.08m')
hold off