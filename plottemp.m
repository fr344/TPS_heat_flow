function plottemp(ntile,doplot)
%plottemp   Reads the temperature data from the image file of the desired
%shuttle tile.
%
% plottemp(NTILE,DOPLOT) considers the desired tile number NTILE and
% outputs the temperature profile across the surface of the tile provided
% by the NASA data. Available at:
% http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.26.1075&rep=rep1&type=pdf
%
% Made by: D N Johnston 30/01/19
% Modified by: Frederico Rodrigues
% University of Bath

name = ['temp' num2str(ntile)];
img=imread(['temp' num2str(ntile) '.jpg']);
a = size(img); % Initialising size matrix

% You can adapt the following code to enter data interactively or automatically.

%% Automatic Graph Data Conversion

% Initialise variables
timedata = [];
tempdata = [];

% Splits RGB Channels
red = img(:,:,1);
green = img(:,:,2);
blue = img(:,:,3);

% Initialising x-axis for speed
xaxis = zeros(size(a(2)));

% Locating x-axis
for n=1:a(2)
    
    % Searches for all black pixels in the image
    xaxis(n) = numel(find(red(:,n)<30 & green(:,n)<30 & blue(:,n)<30));
    
end

% Initialising y-axis for speed
yaxis = zeros(size(a(1)));

% Locating y-axis
for n=1:a(1)
    
    % Searches for all black pixels in the image
    yaxis(n) = numel(find(red(n,:)<30 & green(n,:)<30 & blue(n,:)<30));
    
end

% Magnitude of the axes
xsize = max(yaxis);
ysize = max(xaxis);

% Plot offset from figure origin
xo = find(xaxis==max(xaxis)); % Origin coordinate in x
yo = find(yaxis==max(yaxis)); % Origin coordinate in y
xend = xo + xsize;

% Initialising solution vectors
data = zeros(xsize);
timedata = [];
tempdata = [];


for n=xo:xend
    
    % Creates vector containing the y-coordinate of the red pixels
    data(n) = mean(find(red(:,n)>180 & green(:,n)<60 & blue(:,n)<60));
    
    % Removes NaN values
    if ~isnan(data(n))

        % Setting solution vectors with converted axes
        timedata = [timedata, (n-xo) / xsize * 2000];   % °F, Farenheit
        tempdata = [tempdata, (yo-data(n)) / ysize * 2000];   % s, seconds
    
    end

end

%% Manual Graph Data Conversion
%
% while 1 % infinite loop
%     [x, y, button] = ginput(1); % get one point using mouse
%     if button ~= 1 % break if anything except the left mouse button is pressed
%         break
%     end
%     plot(x, y, 'og') % 'og' means plot a green circle.
%
%     % Add data point to vectors. Note that x and y are pixel coordinates.
%     % You need to locate the pixel coordinates of the axes, interactively
%     % or otherwise, and scale the values into time (s) and temperature (F, C or K).
%     timedata = [timedata, x];
%     tempdata = [tempdata, y];
% end
% hold off

%% Updating Variables and Plotting

% Duplicate end value for constant temperature extrapolation
timedata = [timedata, timedata(end) + 1]; % Repeats value for the next second
tempdata = [tempdata, tempdata(end)];

% sort data and remove duplicate points.
[timedata, index] = unique(timedata);
tempdata = tempdata(index);

%save data to .mat file with same name as image file
save(name, 'timedata', 'tempdata')

% Plotting dataset for debugging
if doplot
    
    subplot(211);
    image(img);
    title(['Data figure for tile #' num2str(ntile)])
    
    subplot(212)
    plot(timedata,tempdata,'r')
    xlabel('Time, s')
    ylabel('Temperature, °F')
    title(['Temperature data for tile #' num2str(ntile)])
    
end

end
