%=======================================================================
% **creacion_CGMnoise**
%
%   @Description:
%               Funcion encarga de simular el funcionamiento del sensor CGM
%               aplicando el ruido que este puede llegar a generar en las
%               mediciones para darle un toque mas realista en las lecturs.
%
%   @param:     -hardware:          struct(string,array)
%               -escenario:         struct(string,array)
%               -t:                 number
%
%   @return:    -ruido:             array
%=======================================================================
function [ruido] = creacion_CGMnoise(hardware,escenario,t)

ruido = [t' zeros(size((t)'))];

% create a normally distributed AR(1) time series with mean 0 and variance 1
v = randn(floor(escenario.tf/escenario.paso/15),1);
e(1) = v(1);
for i=2:escenario.tf/escenario.paso/15
    e(i) = hardware.sensor_PACF*v(i)+hardware.sensor_PACF*e(i-1);
end
% transform the standard normally distributed TS to obtain proper sensor
% ruido distribution using Johnson family of distributions.
JT           = Johnson_transform(hardware.sensor_type,hardware.sensor_gamma,hardware.sensor_delta,hardware.sensor_lambda,hardware.sensor_xi,e);
noise_interp = interp1(0:15:(length(e)-1)*15,JT,0:escenario.paso:escenario.tf,'linear','extrap');
ruido(:,2)   = smooth(noise_interp,15/escenario.paso); 

    
    
    