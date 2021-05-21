%=======================================================================
% **creacion_struc**
%
%   @Description:
%               Funcion encarga de crear multiples estructuras de salida
%               (datos, hardware, escenario, parametros y control).
%
%   @param:     -n:             number (length)
%
%   @return:    -data:          struct(string,array)
%               -parametros:    struct(string,array)
%               -escenario:     struct(string,array)
%               -ctrl:          struct(string,array)
%               -hardware:      struct(string,number)
%=======================================================================
function [data,parametros,escenario,ctrl,hardware] = creacion_struc(n)

data(n)          = struct('glucosa',[],'t',[],'salidas',[],'estados',[],'parametros',[],'ctrl',[],'escenario',[]); 

hardware         = struct('pump_bolus_min',0,'pump_bolus_max',1000,'pump_bolus_inc',0.0001,'pump_basal_min',0,'pump_basal_max',inf,'pump_basal_inc',0.0001,'pump_sampling',1,'pump_accuracy_bolus_amount',[0 100],'pump_bolus_mean',[0 100],'pump_bolus_std2',[0 0],'pump_noise',0,'pump_char',0,...
                'sensor_sampling',1,'sensor_max',1000,'sensor_min',0);
        
escenario        = struct('ti',[],'tf',[],'paso',[],'Tcomida',[],'comida',[],'durcomida',[],'Tcomix',[],'Acomix',[],'comix',[],'Tbolos',[],'bolos',[],'basal',[],'Tivins',[],'ivins',[],'Tivd',[],'ivd',[]);   

parametros       = struct('insulina',[],'comidas',[],'ra_comidas_mixtas',[],'iv',[]);

                         
ctrl              = struct('paso',[],'CR',[],'CF',[],'ITDD',[],'KDIA',[],'Iee',[],'IOBlim',[]);


