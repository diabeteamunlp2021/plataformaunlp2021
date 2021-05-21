%% Inf. clínica disponible de los pacientes 
ctrl.BW      = parametros.paciente.BW;
ctrl.TDI     = parametros.paciente.TDI;                 %Insulina total diaria                %Kdia
ctrl.CR      = parametros.paciente.CR;                   %Factor de correción
ctrl.CF      = parametros.paciente.CF;                   %CarbFactor - Relación I:CHO
ctrl.Ib_prof = parametros.insulina(2,:);
ctrl.Iee     = parametros.insulina(2,1);
ctrl.paso    = escenario.paso;
ctrl.bolos   = escenario.bolos;
ctrl.Tbolos  = escenario.Tbolos;
ctrl.comida  = escenario.comida;
ctrl.Tcomida = escenario.Tcomida;
ctrl.ti      = escenario.ti;
ctrl.tf      = escenario.tf;
ctrl.ITDD    = ctrl.Iee*60*24*2/6000;
ctrl.Ts      = 5;

if isfield(parametros.paciente,'KDIA')
    ctrl.KDIA = parametros.paciente.KDIA; 
else
    ctrl.KDIA = 16.3e-3; 
end


%% LH: Insulina basal = 0, debe ser suministrada por el controlador
if lazoh==1
    parametros.insulina(2,:) = zeros(1,size(parametros.insulina,2));
end