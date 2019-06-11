classdef shuttleGUI_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        ManualModellingPanel            matlab.ui.container.Panel
        ModellingTimesLabel             matlab.ui.control.Label
        tmax                            matlab.ui.control.NumericEditField
        NumberofSpacialStepsLabel       matlab.ui.control.Label
        nx                              matlab.ui.control.NumericEditField
        TilethicknessmLabel             matlab.ui.control.Label
        xmax                            matlab.ui.control.NumericEditField
        NumberofTimeStepsLabel          matlab.ui.control.Label
        nt                              matlab.ui.control.NumericEditField
        ModelButton                     matlab.ui.control.Button
        MaxTempatRHSEditFieldLabel      matlab.ui.control.Label
        MaxTempatRHSEditField           matlab.ui.control.NumericEditField
        OptimumThicknessCalculationPanel  matlab.ui.container.Panel
        OptimalThicknessmmLabel         matlab.ui.control.Label
        thick                           matlab.ui.control.NumericEditField
        CalculateButton                 matlab.ui.control.Button
        MaximumShuttleWallTemperatureCLabel  matlab.ui.control.Label
        umax                            matlab.ui.control.NumericEditField
        NumberofShootingIterationsGaugeLabel  matlab.ui.control.Label
        NumberofShootingIterationsGauge  matlab.ui.control.SemicircularGauge
        GeneralInfoPanel                matlab.ui.container.Panel
        MaterialDropDownLabel           matlab.ui.control.Label
        material                        matlab.ui.control.DropDown
        NumericalMethodDropDownLabel    matlab.ui.control.Label
        method                          matlab.ui.control.DropDown
        TileDropDownLabel               matlab.ui.control.Label
        ntile                           matlab.ui.control.DropDown
        TabGroup                        matlab.ui.container.TabGroup
        TileTemperatureDistributionTab  matlab.ui.container.Tab
        UIAxes                          matlab.ui.control.UIAxes
        ShuttleWallTemperatureTab       matlab.ui.container.Tab
        UIAxes2                         matlab.ui.control.UIAxes
    end

    methods (Access = private)

        % Button pushed function: ModelButton
        function ModelButtonPushed(app, event)
           
            % Run shuttle command and plot heat distribution      
           
            doplot = false;
        
            
            [x,t,u] = shuttle(app.tmax.Value, app.nt.Value, app.xmax.Value,...
                app.nx.Value, app.method.Value, doplot, app.ntile.Value,app.material.Value);
            
            % Create a plot here.
            % contour plot
            surf(app.UIAxes,x,t,u)
            % comment out the next line to change the surface appearance
            shading(app.UIAxes,'interp')
            colorbar(app.UIAxes)
            
            % Rotate the view
            view(app.UIAxes,140,30)
            
            %label the axes
            xlabel(app.UIAxes,'\itx\rm - m')
            ylabel(app.UIAxes,'\itt\rm - s')
            zlabel(app.UIAxes,'\itu\rm - deg C')
            title(app.UIAxes,{['Temperature distribution across tile #' ...
                num2str(app.ntile.Value)], ...
                [' using the ' app.method.Value ' method']})
            
            app.MaxTempatRHSEditField.Value = max(u(:,1));
            
            %================================================================%
            
            plot(app.UIAxes2,t,u(:,1))
             
            %label the axes
            xlabel(app.UIAxes2,'\itt\rm - s')
            ylabel(app.UIAxes2,'\itu\rm - deg C')
            title(app.UIAxes2,{['Temperature distribution across tile #' ...
                num2str(app.ntile.Value)], [' of thickness ' num2str(app.xmax.Value) ' mm'], ...
                [' using the ' app.method.Value ' method']})
            
            
            
            
        end

        % Button pushed function: CalculateButton
        function CalculateButtonPushed(app, event)
            % Run shooting method for thickness calculation
            
            [optThick, iteration] = simpleShootingGUI(app.tmax.Value, app.nt.Value,...
                app.method.Value, app.umax.Value, app.ntile.Value, app.material.Value);
            
            app.thick.Value = optThick * 1000;
            
            doplot = false;
            
            % Run shuttle command using calculated thickness
            [x,t,u] = shuttle(app.tmax.Value, app.nt.Value, optThick,...
                app.nx.Value, app.method.Value, doplot, app.ntile.Value, app.material.Value);
            
            % Create a plot here.
            
            % contour plot
            surf(app.UIAxes,x,t,u)
            % comment out the next line to change the surface appearance
            shading(app.UIAxes,'interp')
            colorbar(app.UIAxes)
            
            % Rotate the view
            view(app.UIAxes,140,30)
            
            %label the axes
            xlabel(app.UIAxes,'\itx\rm - m')
            ylabel(app.UIAxes,'\itt\rm - s')
            zlabel(app.UIAxes,'\itu\rm - deg C')
            title(app.UIAxes,{['Temperature distribution across tile #' ...
                num2str(app.ntile.Value)], ...
                [' using the ' app.method.Value ' method']})
            
            app.MaxTempatRHSEditField.Value = max(u(:,1));
            app.NumberofShootingIterationsGauge.Value = iteration;
            
            plot(app.UIAxes2,t,u(:,1))
             
            %label the axes
            xlabel(app.UIAxes2,'\itt\rm - s')
            ylabel(app.UIAxes2,'\itu\rm - deg C')
            title(app.UIAxes2,{['Temperature distribution across tile #' ...
                num2str(app.ntile.Value)], [' of thickness ' num2str(app.thick.Value) ' mm'], ...
                [' using the ' app.method.Value ' method']})
            
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 1107 601];
            app.UIFigure.Name = 'UI Figure';

            % Create ManualModellingPanel
            app.ManualModellingPanel = uipanel(app.UIFigure);
            app.ManualModellingPanel.Title = 'Manual Modelling';
            app.ManualModellingPanel.Position = [804 200 296 257];

            % Create ModellingTimesLabel
            app.ModellingTimesLabel = uilabel(app.ManualModellingPanel);
            app.ModellingTimesLabel.HorizontalAlignment = 'right';
            app.ModellingTimesLabel.Position = [56 202 103 22];
            app.ModellingTimesLabel.Text = 'Modelling Time (s)';

            % Create tmax
            app.tmax = uieditfield(app.ManualModellingPanel, 'numeric');
            app.tmax.Position = [174 202 100 22];
            app.tmax.Value = 4000;

            % Create NumberofSpacialStepsLabel
            app.NumberofSpacialStepsLabel = uilabel(app.ManualModellingPanel);
            app.NumberofSpacialStepsLabel.HorizontalAlignment = 'right';
            app.NumberofSpacialStepsLabel.Position = [21 101 138 22];
            app.NumberofSpacialStepsLabel.Text = 'Number of Spacial Steps';

            % Create nx
            app.nx = uieditfield(app.ManualModellingPanel, 'numeric');
            app.nx.Position = [174 101 100 22];
            app.nx.Value = 21;

            % Create TilethicknessmLabel
            app.TilethicknessmLabel = uilabel(app.ManualModellingPanel);
            app.TilethicknessmLabel.HorizontalAlignment = 'right';
            app.TilethicknessmLabel.Position = [60 134 99 22];
            app.TilethicknessmLabel.Text = 'Tile thickness (m)';

            % Create xmax
            app.xmax = uieditfield(app.ManualModellingPanel, 'numeric');
            app.xmax.Position = [174 134 100 22];
            app.xmax.Value = 0.05;

            % Create NumberofTimeStepsLabel
            app.NumberofTimeStepsLabel = uilabel(app.ManualModellingPanel);
            app.NumberofTimeStepsLabel.HorizontalAlignment = 'right';
            app.NumberofTimeStepsLabel.Position = [34 168 125 22];
            app.NumberofTimeStepsLabel.Text = 'Number of Time Steps';

            % Create nt
            app.nt = uieditfield(app.ManualModellingPanel, 'numeric');
            app.nt.Position = [174 168 100 22];
            app.nt.Value = 501;

            % Create ModelButton
            app.ModelButton = uibutton(app.ManualModellingPanel, 'push');
            app.ModelButton.ButtonPushedFcn = createCallbackFcn(app, @ModelButtonPushed, true);
            app.ModelButton.Position = [94 62 100 22];
            app.ModelButton.Text = 'Model';

            % Create MaxTempatRHSEditFieldLabel
            app.MaxTempatRHSEditFieldLabel = uilabel(app.ManualModellingPanel);
            app.MaxTempatRHSEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxTempatRHSEditFieldLabel.Position = [95 32 103 22];
            app.MaxTempatRHSEditFieldLabel.Text = 'Max Temp at RHS';

            % Create MaxTempatRHSEditField
            app.MaxTempatRHSEditField = uieditfield(app.ManualModellingPanel, 'numeric');
            app.MaxTempatRHSEditField.Editable = 'off';
            app.MaxTempatRHSEditField.HorizontalAlignment = 'center';
            app.MaxTempatRHSEditField.Position = [96 11 100 22];

            % Create OptimumThicknessCalculationPanel
            app.OptimumThicknessCalculationPanel = uipanel(app.UIFigure);
            app.OptimumThicknessCalculationPanel.Title = 'Optimum Thickness Calculation';
            app.OptimumThicknessCalculationPanel.Position = [804 9 296 182];

            % Create OptimalThicknessmmLabel
            app.OptimalThicknessmmLabel = uilabel(app.OptimumThicknessCalculationPanel);
            app.OptimalThicknessmmLabel.HorizontalAlignment = 'right';
            app.OptimalThicknessmmLabel.Position = [9 33 135 22];
            app.OptimalThicknessmmLabel.Text = 'Optimal Thickness (mm)';

            % Create thick
            app.thick = uieditfield(app.OptimumThicknessCalculationPanel, 'numeric');
            app.thick.Editable = 'off';
            app.thick.HorizontalAlignment = 'center';
            app.thick.Position = [22 12 100 22];

            % Create CalculateButton
            app.CalculateButton = uibutton(app.OptimumThicknessCalculationPanel, 'push');
            app.CalculateButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateButtonPushed, true);
            app.CalculateButton.Position = [174 128 100 22];
            app.CalculateButton.Text = 'Calculate';

            % Create MaximumShuttleWallTemperatureCLabel
            app.MaximumShuttleWallTemperatureCLabel = uilabel(app.OptimumThicknessCalculationPanel);
            app.MaximumShuttleWallTemperatureCLabel.HorizontalAlignment = 'center';
            app.MaximumShuttleWallTemperatureCLabel.Position = [10 126 123 27];
            app.MaximumShuttleWallTemperatureCLabel.Text = {'Maximum Shuttle'; 'Wall Temperature (°C)'};

            % Create umax
            app.umax = uieditfield(app.OptimumThicknessCalculationPanel, 'numeric');
            app.umax.Position = [20 97 100 22];
            app.umax.Value = 175;

            % Create NumberofShootingIterationsGaugeLabel
            app.NumberofShootingIterationsGaugeLabel = uilabel(app.OptimumThicknessCalculationPanel);
            app.NumberofShootingIterationsGaugeLabel.HorizontalAlignment = 'center';
            app.NumberofShootingIterationsGaugeLabel.Position = [169 12 112 27];
            app.NumberofShootingIterationsGaugeLabel.Text = {'Number of Shooting'; 'Iterations'};

            % Create NumberofShootingIterationsGauge
            app.NumberofShootingIterationsGauge = uigauge(app.OptimumThicknessCalculationPanel, 'semicircular');
            app.NumberofShootingIterationsGauge.Limits = [0 16];
            app.NumberofShootingIterationsGauge.Position = [164 54 120 65];

            % Create GeneralInfoPanel
            app.GeneralInfoPanel = uipanel(app.UIFigure);
            app.GeneralInfoPanel.Title = 'General Info';
            app.GeneralInfoPanel.Position = [804 467 296 120];

            % Create MaterialDropDownLabel
            app.MaterialDropDownLabel = uilabel(app.GeneralInfoPanel);
            app.MaterialDropDownLabel.HorizontalAlignment = 'right';
            app.MaterialDropDownLabel.Position = [64 75 48 22];
            app.MaterialDropDownLabel.Text = 'Material';

            % Create material
            app.material = uidropdown(app.GeneralInfoPanel);
            app.material.Items = {'Given', 'LI-900', 'Avcoat-5026'};
            app.material.Position = [127 75 100 22];
            app.material.Value = 'Given';

            % Create NumericalMethodDropDownLabel
            app.NumericalMethodDropDownLabel = uilabel(app.GeneralInfoPanel);
            app.NumericalMethodDropDownLabel.HorizontalAlignment = 'right';
            app.NumericalMethodDropDownLabel.Position = [9 41 103 22];
            app.NumericalMethodDropDownLabel.Text = 'Numerical Method';

            % Create method
            app.method = uidropdown(app.GeneralInfoPanel);
            app.method.Items = {'crank-nicolson', 'forward', 'dufort-frankel', 'backward'};
            app.method.Position = [127 41 100 22];
            app.method.Value = 'crank-nicolson';

            % Create TileDropDownLabel
            app.TileDropDownLabel = uilabel(app.GeneralInfoPanel);
            app.TileDropDownLabel.HorizontalAlignment = 'right';
            app.TileDropDownLabel.Position = [87 8 25 22];
            app.TileDropDownLabel.Text = 'Tile';

            % Create ntile
            app.ntile = uidropdown(app.GeneralInfoPanel);
            app.ntile.Items = {'597', '468', '480', '502', '590', '711', '730', '850'};
            app.ntile.Position = [127 8 100 22];
            app.ntile.Value = '597';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [17 9 769 578];

            % Create TileTemperatureDistributionTab
            app.TileTemperatureDistributionTab = uitab(app.TabGroup);
            app.TileTemperatureDistributionTab.Title = 'Tile Temperature Distribution';

            % Create UIAxes
            app.UIAxes = uiaxes(app.TileTemperatureDistributionTab);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            app.UIAxes.Position = [1 1 767 552];

            % Create ShuttleWallTemperatureTab
            app.ShuttleWallTemperatureTab = uitab(app.TabGroup);
            app.ShuttleWallTemperatureTab.Title = 'Shuttle Wall Temperature';

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.ShuttleWallTemperatureTab);
            title(app.UIAxes2, 'Title')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            app.UIAxes2.Position = [1 1 767 552];
        end
    end

    methods (Access = public)

        % Construct app
        function app = shuttleGUI_exported

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end