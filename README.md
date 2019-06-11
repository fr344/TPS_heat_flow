# Space Shuttle Thermal Protection System (TPS) 1D heat flow analysis

## Intro

The heat flow across the Thermal Protection System (TPS) tiles of the STS-96 space shuttle flight was modelled during re-entry conditions. A 1D model was made using Fourier's heat equation, and the solution was obtained through four different numerical methods: forward differencing, DuFort-Frankel, backward differencing and Crank-Nicolson. The stabilities of the different methods were evaluated in respect to the time step, ∆t and the spatial step, ∆x.

Full Report: [Numerical Modelling for the Space Shuttle Thermal ProtectionSystem](https://www.overleaf.com/read/jknnyfcvfvsm)

## Usage

1) Import .m files
2) Import .jpg temperature profiles
2) Initialise `shuttleGUI_exported.m`
3) Run script

## Index

- `plottemp.m`: Converts temp###.jpg to numerical data, in Celsius
- `shuttle.m`: Computes temperature profile data and solves numerically for zero heat-flow (Neumann) boundary conditions
- `simpleShooting.m`: Utilises the [shoothing method](https://en.wikipedia.org/wiki/Shooting_method) algorithm to solve for the tile thickness based on desired inner wall temperature
- `stabilitySpaceTime.m`: Iterates through numerical step sizes for stability analysis
- `shuttleGUI_exported.m`: Interactive GUI for tile thickness computation

