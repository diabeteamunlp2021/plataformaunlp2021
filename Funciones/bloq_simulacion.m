function [data] = bloq_simulacion(data,v,item,parametros,hardware,escenario,settings,ctrl)

x0 = parametros.paciente.x0;
tsimu = escenario.ti:escenario.paso:escenario.tf;
hardware.pump_char = 0;

mix_meals = (1/parametros.paciente.BW).*parametros.ra_comidas_mixtas; % **

for t=tsimu
    %% Bloque LA/LC
    switch settings.lazo
        case 'Lazo abierto'
            bolus_lalc1 = parametros.insulina(1,(t/escenario.paso)+1);
            basal_lalc1 = parametros.insulina(2,(t/escenario.paso)+1); %Basal LA + Bolo LA
        case 'Lazo cerrado'
            bolus_lalc1 = 1;
            basal_lalc1 = 1;
        case 'Lazo hibrido'
            bolus_lalc22 = 0;
            basal_lalc22 = 0;
    end
    bolus_lalc2 = 0;
    basal_lalc2 = 0;
    ubolus = bolus_lalc1 + bolus_lalc2;
    ubasal = basal_lalc1 + basal_lalc2;
    
    %% Pump Block
    [ubolus_ins,ubasal_ins]  = pump(ubolus,ubasal,hardware,parametros.paciente.BW); %Insulina
    %[ubolus_glu,ubasal_glu] = pump(ubolus,ubasal,hardware,parametros.paciente.BW);   %Glucagon
    
    %% Paciente Block
    sq_insulin = ubolus_ins + ubasal_ins;
    sq_glucagon = 0; %siempre en 0 para Lazo Abierto
    
    u = [parametros.comidas(1,t) sq_insulin sq_glucagon parametros.iv(2,t) parametros.iv(1,t) mix_meals(t)];
    
    % Se guardan los estados
    estados(:,item) = x0;
    
    gluc_p = x0(4)/parametros.paciente.Vg; %% x0(4) = x0(13) ?
    
    IOB_est = x0(11)+x0(12);    %IOB estimada
    
    glucosa(item) = gluc_p;   
    
    % Se suma ruido, 0 según lo especificado en settings.
    CGM = (x0(13)/parametros.paciente.Vg) + parametros.ruido(t,2);
    
    salidas(:,item) = [gluc_p CGM sq_insulin ubasal ubolus IOB_est];
    
    [~,X] = ode45(@(t,x) t1dm_unlp_v2(t,x,u,parametros,escenario),[t t+escenario.paso],x0);
    
    x0 = X(end,:); %Next iteration
    
    item = item + 1;
    
end %Fin Loop vector tiempo de Paciente(v)

[data] = guardar(data,v,glucosa,parametros,salidas,estados,escenario,tsimu,ctrl,settings.narchi);

end