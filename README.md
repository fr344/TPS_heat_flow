# matlab

%% Space Shuttle Thermal Protection System (TPS) 1D heat flow analysis

The heat flow across the Thermal Protection System (TPS) tiles of the STS-96 space shuttle flight was modelled during re-entry conditions. A 1D model was made using Fourier's heat equation, and the solution was obtained through four different numerical methods: forward differencing, DuFort-Frankel, backward differencing and Crank-Nicolson. The stabilities of the different methods were evaluated in respect to the time step, $\Delta t$ and the spatial step, $\Delta x$, and the Crank-Nicolson method was chosen as the most stable and accurate method for the model. The optimal time and spatial steps were found to be $25s$ and $0.0028\ mm$. The model was then assessed for several tile thickness using the shooting method algorithm, obtaining a final thickness of $54.29\ mm$ for tile \%597 assuming a maximum inner surface temperature of $175\degree C$. Data for other tile positions across the space shuttle were obtained.


%% GUI Initialisation

1) Import .m files
2) Import .jpg temperature profiles
2) Initialise shuttleGUI_exported.m
3) Run script
