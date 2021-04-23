function [parametros_simu] = config_sim()

%Configuración de la simulación de simulink
parametros_simu.SimulationMode = 'normal';
parametros_simu.SaveState      = 'on';
parametros_simu.StateSaveName  = 'estados';
parametros_simu.SaveOutput     = 'on';
parametros_simu.OutputSaveName = 'salidas';
parametros_simu.StartTime      = 'escenario.ti';
parametros_simu.StopTime       = 'escenario.tf';
parametros_simu.SaveTime       = 'on';
parametros_simu.TimeSaveName   = 'tout';
parametros_simu.SolverType     = 'Fixed-step';
parametros_simu.Solver         = 'ode1';
parametros_simu.Fixedstep      = 'escenario.paso';
parametros_simu.LimitDataPoints = 'off';

end

%Solvers de paso fijo
%   ode3 (Bogacki-Shampine)
%   ode8 (Dormand-Prince RK8(7))
%   ode5 (Dormand-Prince)
%   ode4 (Runge-Kutta)
%   ode2 (Heun)
%   ode1 (Euler)
%   ode14x (extrapolation)

%Para mas información ver:
%                         http://www.mathworks.com/help/simulink/gui/solver-pane.html#bq7cmsp-1_1
