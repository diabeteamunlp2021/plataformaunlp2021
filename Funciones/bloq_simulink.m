function [glucose_plasma, CGM, u_pumped, ubasal, ubolus,IOB_est ] = bloq_simulink (parametros, hardware)
% For cada paciente
%   k=1     // paciente
%   controlador(k) --> controller();
%   for Simulink
%       bloque_la_lc(k);
%       bloque_bomba(k) --> pump()--> [in: ubolus,ubasal,hardware,BW;
%                        out: ubolus_pumped,ubasal_pumped, senal*]
%       bloque_paciente(k) --> t1dm_unlp.m
%       bloque_sensor(k) --> sensor() --> [in: IG; out: CGM)
%       bloque_controlador(k)--> controlador() --> [in: CGM_sensor, parametros.comidas, Ins_LA(inyeccion insulina bomba*);
%                                 out: basal_cont, bolo_cont]
%   end Simulink
% end Paciente

% initialize controller  UVA 
% myController(idx_subject) = init_controller(controllerpath,Quest);
% cd Controladores\
% [b_controller(1)] = controller(CGM, parametros.comidas(k),ubolus_pumped,ubasal_pumped);
% cd ..
for k=1:length(insulina)
    %% Bloque LA/LC
    %Control LA/LC
    if (lazo >= 0) 
        out_lalc1 = parametros.insulina(k); %Basal LA + Bolo LA
    else
        out_lalc1 = b_controller(k); %Basal LC + Bolo LC
    end
    
    %Control LH    
    if (lazoh >= 0) 
        out_lalc2 = b_controller(k);
    else
        out_lalc2 = zeros(1,size(length(parametros.insulina),2));
    end
    out_lazo = out_lalc1 + out_lalc2;
    ubolus = out_lazo(1);
    ubasal = out_lazo(2);
    
    %% Bloque Bomba
    [ubolus_pumped,ubasal_pumped]  = pump(ubolus,ubasal,hardware,parametros.paciente.BW);
    %IOB_est -> State-Space
        %A = [ctrl.KDIA;ctrl.KDIA -ctrl.KDIA];
        %B = [1/6000;0];
        %C = [1 1];
        %t0 = [ctrl.Iee/ctrl.KDIA/6000;ctrl.Iee/ctrl.KDIA/6000];
        %IOB_est = ss(A,B,C,0) %D = 0
        %IOB_est o tf
        
    %% Bloque Paciente
    ubolus_pumped = (1/parametros.paciente.BW).*ubolus_pumped;
    ubasal_pumped = (1/parametros.paciente.BW).*ubasal_pumped;
    % iv(2,:) insulina ? 
    % iv(1,:) glucosa ? 
    iv(k) = (1/parametros.paciente.BW).*parametros.iv(k);
    comidas_mixtas(k) = (1/parametros.paciente.BW).*parametros.ra_comidas_mixtas(k);
    
    %IG = glucose_subc_out_model_pacient; parametros.paciente.Vg ? 
    
    %% Bloque Sensor
    KC = 1; %Ganancia de calibracion
    Offset = 0; %Offset de calibracion o vector de ceros? 
    ig1 = KC.*IG;
    ig2 = ig1+Offset;
    KR = 1; %Ganancia de ruido
    ruido = K.*parametros.ruido;
    gscn = ig2 + ruido;
    %Zero Order Hold
    %Saturation
    %NL = saturation('LinearInterval',[hardware.sensor_min, hardware.sensor_max]
    %Rate Transition
    %Switch
    if settings.sensor
        CGM = out_rate_transition;
    else
        CGM = IG;
        
    %% Bloque Controlador
    cd Controladores\
    [b_controller] = controller(CGM, parametros.comidas(k),ubolus_pumped,ubasal_pumped);
    cd ..
end

return




        
