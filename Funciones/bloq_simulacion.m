%=======================================================================
% bloq_simulacion
%
%   @Description:
%               Funcion encargada de calcular los parametros de entrada,  
%               salida y estados en la simulación principal. 
%
%   @param:     -data:          struct(string,array)
%               -v:             number
%               -item:          number
%               -parametros:    struct(string,array)
%               -hardware:      struct(string,number)
%               -escenario:     struct(string,array)
%               -settings:      struct(string,array)
%               -ctrl:
%
%   @return:    -data:          struct(string,array)
%=======================================================================
function [data] = bloq_simulacion(data,v,item,parametros,hardware,escenario,settings,ctrl)

x0 = parametros.paciente.x0;
tsimu = escenario.ti:escenario.paso:escenario.tf;
mix_meals = (1/parametros.paciente.BW).*parametros.ra_comidas_mixtas; % **

for t=tsimu
    %% LA/LC Block
    switch settings.lazo
        case 'Lazo abierto'
            bolus_input1 = parametros.insulina(1,(t/escenario.paso)+1);
            basal_input1 = parametros.insulina(2,(t/escenario.paso)+1);
        case 'Lazo cerrado'
            bolus_input1 = 1; %Valores NO finales (RANDOM)
            basal_input1 = 1; %Valores NO finales (RANDOM)
        case 'Lazo hibrido'
            %Falta implementación
            bolus_input3 = 0;
            basal_input3 = 0;
    end
    bolus_input2 = 0;
    basal_input2 = 0;
    ubolus = bolus_input1 + bolus_input2;   %pmol/kg
    ubasal = basal_input1 + basal_input2;   %pmol/kg
    
    %% Pump Block
    [ubolus_ins,ubasal_ins]  = pump_v2(ubolus,ubasal,hardware,settings.bomba,parametros.paciente.BW); %Insulina
    %[ubolus_ins,ubasal_ins]  = pump(ubolus,ubasal,hardware,parametros.paciente.BW); %Insulina
    %[ubolus_glu,ubasal_glu] = pump(ubolus,ubasal,hardware,settings.bomba,parametros.paciente.BW);   %Glucagon
    
    %% Patient Block
    sq_insulin = ubolus_ins + ubasal_ins;
    sq_glucagon = 0;    %Siempre en 0 para Lazo Abierto
    
    meal = parametros.comidas(1,(t/escenario.paso)+1);
    iv2 = parametros.iv(2,(t/escenario.paso)+1);
    iv1 = parametros.iv(1,(t/escenario.paso)+1);
    mix_meal = mix_meals((t/escenario.paso)+1);
    
    u = [meal sq_insulin sq_glucagon iv2 iv1 mix_meal];
    -
    % Se guardan los estados
    estados(:,item) = x0;
    
    gluc_p = x0(4)/parametros.paciente.Vg; 
    
    IOB_est = x0(11)+x0(12);    %IOB estimada
    
    glucosa(item) = gluc_p;
    
    % Se suma ruido, 0 según lo especificado en settings.
    CGM = (x0(13)/parametros.paciente.Vg) + parametros.ruido((t/escenario.paso)+1,2);
    
    salidas(:,item) = [gluc_p CGM sq_insulin ubasal ubolus IOB_est];
    
    [~,X] = ode45(@(t,x) t1dm_unlp_v2(t,x,u,parametros,escenario),[t (t+escenario.paso+1)],x0);
    
    x0 = X(end,:); %Next iteration
    
    item = item + 1;

end %Fin Loop vector tiempo de Paciente(v)

[data] = guardar(data,v,glucosa,parametros,salidas,estados,escenario,tsimu,ctrl,settings.narchi);

end