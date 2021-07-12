%=======================================================================
% carga_hardware
%
%   @Description:
%               Funcion encargada de generar una estructura de datos que
%               representa el hardware a implementar en la simulacion.
%
%   @param:     -nombre_bomba:          string
%               -nombre_sensor:         string
%               -hardware:              struct(string,number)
%               -bomba:
%               -sensor:
%
%   @return:    -hardware:            	struct(string,number)
%==========================================================================
function hardware = cargar_hardware(nombre_bomba,nombre_sensor,hardware,bomba,sensor)
if bomba
    content = textread(['Hardware\' nombre_bomba],'%s','delimiter','\n');
    n       = length(content);
    if n~=0
        for i=1:n
            line=content{i};
            if ~isempty(line)
                if strcmp(line(1),'%')
                    line=line(2:end);
                    if strfind(line,'minbolus')
                        p=strfind(line,'minbolus');
                        p2=1+strfind(line(p:end),'=');
                        hardware.pump_bolus_min=str2double(line(p-1+p2:end))*6000;
                    elseif strfind(line,'maxbolus')
                        p=strfind(line,'maxbolus');
                        p2=1+strfind(line(p:end),'=');
                        hardware.pump_bolus_max=str2double(line(p-1+p2:end))*6000;
                    elseif strfind(line,'incbolus')
                        p=strfind(line,'incbolus');
                        p2=1+strfind(line(p:end),'=');
                        hardware.pump_bolus_inc=str2double(line(p-1+p2:end))*6000;
                    elseif strfind(line,'minbasal')
                        p=strfind(line,'minbasal');
                        p2=1+strfind(line(p:end),'=');
                        hardware.pump_basal_min=str2double(line(p-1+p2:end))*100;
                    elseif strfind(line,'maxbasal')
                        p=strfind(line,'maxbasal');
                        p2=1+strfind(line(p:end),'=');
                        hardware.pump_basal_max=str2double(line(p-1+p2:end))*100;
                    elseif strfind(line,'incbasal')
                        p=strfind(line,'incbasal');
                        p2=1+strfind(line(p:end),'=');
                        hardware.pump_basal_inc=str2double(line(p-1+p2:end))*100;
                    elseif strfind(line,'sampling')
                        p=strfind(line,'sampling');
                        p2=1+strfind(line(p:end),'=');
                        hardware.pump_sampling=str2double(line(p-1+p2:end));
                    elseif strfind(line,'bolus_mean')
                        p=strfind(line,'bolus_mean');
                        p2=1+strfind(line(p:end),'=');
                        hardware.pump_bolus_mean=str2num(str2mat(line(p-1+p2:end)));
                    elseif strfind(line,'bolus_std2')
                        p=strfind(line,'bolus_std2');
                        p2=1+strfind(line(p:end),'=');
                        hardware.pump_bolus_std2=str2num(str2mat(line(p-1+p2:end)));
                    elseif strfind(line,'accuracy_bolus_amount')
                        p=strfind(line,'accuracy_bolus_amount');
                        p2=1+strfind(line(p:end),'=');
                        hardware.pump_accuracy_bolus_amount=str2num(str2mat(line(p-1+p2:end)));
                    elseif strfind(line,'pump_noise')
                        p=strfind(line,'pump_noise');
                        p2=1+strfind(line(p:end),'=');
                        hardware.pump_noise=str2double(line(p-1+p2:end));
                    elseif strfind(line,'pump_char')
                        p=strfind(line,'pump_char');
                        p2=1+strfind(line(p:end),'=');
                        hardware.pump_char=str2double(line(p-1+p2:end));
                    end
                end
            end
        end
    end
end
if sensor
    content = textread(['Hardware\' nombre_sensor],'%s','delimiter','\n');
    n       = length(content);
    if n~=0
        for i=1:n
            line=content{i};
            if ~isempty(line)
                if strcmp(line(1),'%')
                    line=line(2:end);
                    if strfind(line,'PACF')
                        p=strfind(line,'PACF');
                        p2=1+strfind(line(p:end),'=');
                        hardware.sensor_PACF=str2double(line(p-1+p2:end));
                    elseif strfind(line,'type')
                        p=strfind(line,'type');
                        p2=1+strfind(line(p:end),'=');
                        hardware.sensor_type=(line(p-1+p2:end));
                    elseif strfind(line,'delta')
                        p=strfind(line,'delta');
                        p2=1+strfind(line(p:end),'=');
                        hardware.sensor_delta=str2double(line(p-1+p2:end));
                    elseif strfind(line,'gamma')
                        p=strfind(line,'gamma');
                        p2=1+strfind(line(p:end),'=');
                        hardware.sensor_gamma=str2double(line(p-1+p2:end));
                    elseif strfind(line,'xi')
                        p=strfind(line,'xi');
                        p2=1+strfind(line(p:end),'=');
                        hardware.sensor_xi=str2double(line(p-1+p2:end));
                    elseif strfind(line,'lambda')
                        p=strfind(line,'lambda');
                        p2=1+strfind(line(p:end),'=');
                        hardware.sensor_lambda=str2double(line(p-1+p2:end));
                    elseif strfind(line,'min')
                        p=strfind(line,'min');
                        p2=1+strfind(line(p:end),'=');
                        hardware.sensor_min=str2double(line(p-1+p2:end));
                    elseif strfind(line,'max')
                        p=strfind(line,'max');
                        p2=1+strfind(line(p:end),'=');
                        hardware.sensor_max=str2double(line(p-1+p2:end));
                    elseif strfind(line,'sampling')
                        p=strfind(line,'sampling');
                        p2=1+strfind(line(p:end),'=');
                        hardware.sensor_sampling=str2double(line(p-1+p2:end));
                    end
                end
            end
        end
    end
end