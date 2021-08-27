%% ------- Inicializacion
clear global
clear
clc
dir = fileparts(which('testSimulador'));
cd(dir)
addpath(genpath(cd))

global ctrl

%% ------- Plataforma de simulacion
plataforma = 'plataforma_unlp';

auto = 0; % para usar interfaz grafica o no
switch auto
    case 1
        % Configuracion de simulacion
        settings = struct(...
            'escenario',{'prueba'},...
            'paso',1,'ti',0,'tf',30,...
            'narchi',{'sim'},...
            'varsen',0,'visentin',0,'mix',0,...
            'lazo',{'Lazo abierto'},...
            'bomba',0,'sensor',1,'ruido',0,...
            'nombrebomba',{'insulet.pmp'},'nombresensor',{'dexcom50.scs'},...
            'excel',0);
        
        sujeto = ({'child#001','child#002','child#003','child#004','child#005','child#006','child#007','child#008','child#009','child#010','child#average',...
            'adolescent#001','adolescent#002','adolescent#003','adolescent#004','adolescent#005','adolescent#006','adolescent#007','adolescent#008','adolescent#009','adolescent#010','adolescent#average',...
            'adult#001','adult#002','adult#003','adult#004','adult#005','adult#006','adult#007','adult#008','adult#009','adult#010','adult#average'});
        
    case 0
        %Carga de los sujetos a simular
        [sujeto, bombas, sensores, s] = subj_disp_loader();    %arreglo de cadenas que contienem los sujetosy dispositivos disponibles
        if s==0                     %en caso de cancelar la selecci�n se cierra el programa
            clear
            return;
        end
        
        %% ---- Ventana de carga de datos
        [settings, boton] = settingsdlg(...                                                 %esta funci�n fue desarrollada por Rody Oldenhuis
            'Description', 'Configuracion de diferentes aspectos de la simulacion',...
            'title'      , 'Simulador UNLP',...
            'separator'  , 'Configuracion',...
            {'Nombre escenario';'escenario'},'prueba',...
            {'Paso de simulacion (en minutos)';'paso'},1,...
            {'Inicio (hs a partir 00hs)';'ti'},6,...
            {'Fin de la simulacion (hs a partir 00hs)';'tf'},24,...
            'separator'  , 'Modelo sensor',...parametros.ruido
            {'Modelo sensor';'sensor'},[false, true],...
            {'Sensores disponibles';'nombresensor'},{sensores},...
            {'Ruido';'ruido'},false,...
            'separator'  , 'Modelo bomba',...
            {'Modelo bomba';'bomba'},[false, true],...
            {'Bombas disponibles';'nombrebomba'},{bombas},...
            'separator'  , 'Variacion intra-paciente',...
            {'Variacion Herrero 2012','varsen'},false,...
            {'Variacion Visentin 2015','visentin'},false,...
            'separator'  , 'Comidas mixtas',...
            {'Agregar comidas mixtas';'mix'},false,...
            'separator'  , 'Rango de normoglucemia',...
            {'Limite de hipoglucemia (mg/dl)';'rango1'},70,...
            {'Limite de hiperglucemia (mg/dl)';'rango2'},180,...
            'separator'  ,'Tipo de tratamiento',...
            {'Tratamiento';'lazo'},{'Lazo abierto','Lazo cerrado','Lazo hibrido'},...
            'separator' ,'Archivos de salida',...
            {'Nombre del archivo de guardado';'narchi'},'sim',...
            {'Archivo Excel?';'excel'},false);
        
        if ~strcmp(boton,'OK')              %en caso de cancelar se sale del programa
            clear
            return;
        end
end

%Creacion de las estructuras de salida
[data,parametros,escenario,ctrl,hardware] = creacion_struc(length(sujeto));

%% ------- Ventana de variacion intra-paciente senoidal
if settings.varsen
    [parametros.variacion,boton] = settingsdlg(...
        'separator' ,'Variacion senoidal',...
        {'Sens. ins.: Periodo (hs)';'periodovmx'},24,...
        {'Sens. ins.: Amplitud (%)';'ampvmx'},0,...
        {'Sens. ins.: Fase (hs)';'fasevmx'},0,...
        {'Sens. ins. hepatica: Periodo (hs)';'periodokp3'},24,...
        {'Sens. ins. hepatica: Amplitud (%)';'ampkp3'},0,...
        {'Sens. ins. hepatica: Fase (hs)';'fasekp3'},0,...
        {'Dinamica ins. sc.: Periodo (hs)';'periodoisc'},24,...
        {'Dinamica ins. sc: Amplitud (%)';'ampisc'},0,...
        {'Dinamica ins. sc: Fase (hs)';'faseisc'},0);
    if ~strcmp(boton,'OK')
        settings.varsen = 0;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('**Inicializando simulador**')

escenario.nombre = [char(settings.escenario) '.scn'];       %nombre del escenario especificado
if ~max(strcmp(escenario.nombre,cellstr(ls('Escenarios'))))
    disp('Nombre de escenario erroneo');
    clear
    return;
end
escenario.ti                = settings.ti*60;             %tiempo de inicio de la simulacion en minutos a partir de las 0hs
escenario.tf                = settings.tf*60;             %duracion de la simulacion
escenario.paso              = settings.paso;              %paso de simulacion en minutos

% vector de tiempo de simulacion
t                           = linspace(0,escenario.tf,escenario.tf/escenario.paso+1);  %creacion del vector de tiempo de simulacion
escenario.nombre_bomba      = char(settings.nombrebomba);           %bomba seleccionada
escenario.nombre_sensor     = char(settings.nombresensor);          %sensor seleccionada

 parametros.variacion.visentin   = settings.visentin;
 parametros.variacion.varsen     = settings.varsen;

switch settings.lazo
    case 'Lazo abierto'
        lazo=1;lazoh=-1;
    case 'Lazo cerrado'
        lazo=-1;lazoh=-1;
    case 'Lazo hibrido'
        lazo=1;lazoh=1;
end

%Parametros generales de simulacion
disp('**Cargando parametros**')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Carga del escenario
[escenario] = cargar_escenario(escenario);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Creacion del vector de comidas
parametros.comidas = creacion_comidas(escenario,t);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Creacion del vector de suministros intravenosos
parametros.iv = creacion_IV(escenario,t);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Carga del hardware
hardware = cargar_hardware(escenario.nombre_bomba,escenario.nombre_sensor,hardware,settings.bomba,settings.sensor);

%% ------ Configuracion SIMULINK y ventana de progreso
% paramNameValStruct = config_sim();
% h = waitbar(0,'Simulando pacientes, por favor espere...','windowstyle', 'modal');


%Bucle principal de simulacion
for v=1:length(sujeto)
    
    %Carga de parametros de sujeto
    parametros = cargar_sujeto(char(sujeto(v)),parametros);
    
    %Creacion de comidas mixtas
    if settings.mix
        [parametros.ra_comidas_mixtas, escenario.Tcomix, escenario.Acomix] = creacion_comidas_mixtasv3(escenario,t,char(sujeto(v)));
    else
        parametros.ra_comidas_mixtas = zeros(1,size(t,2));
    end
    
    %Creacion vector de insulina
    if parametros.variacion.visentin
        [parametros,escenario] = creacion_bolos_visentin(parametros,escenario,t,char(sujeto(v)),settings.mix);
    else
        [parametros.insulina,escenario] = creacion_bolos(parametros,escenario,t,char(sujeto(v)),settings.mix);
    end
    
    %Vectores de variacion intra-paciente
    if parametros.variacion.varsen||parametros.variacion.visentin
        [parametros] = variacion_intrapaciente_v3(parametros,t,escenario.paso);
    end
    
    %Condicines iniciales del modelo T1DM
    parametros.paciente.x0 = condiciones_iniciales(parametros,escenario);
    
    %Configuracion de los parametros del controlador
%     control_param;
    
    %Creacion del vector de ruido de CGM
     if settings.ruido
         parametros.ruido = creacion_CGMnoise(hardware,escenario,t);
     else
         parametros.ruido = [t' zeros(size((t)'))];
     end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Simulacion Bloque_Simulink
       
    tsimul = [escenario.deltat]*60*24;
    
    ts = 0:escenario.deltat:tsimul-escenario.deltat;
    
    x0 = parametros.paciente.x0;
    
    item = 1;
    
    for k=1:length(ts)
        %% Bloque LA/LC
        switch settings.lazo
            case 'Lazo abierto'
                bolus_lalc1 = parametros.insulina(1,k);
                basal_lalc1 = parametros.insulina(2,k); %Basal LA + Bolo LA
            case 'Lazo cerrado'
                bolus_lalc1 = 1;
                basal_lalc1 = 1;
        end
        bolus_lalc2 = 0;
        basal_lalc2 = 0;
        ubolus = bolus_lalc1 + bolus_lalc2;
        ubasal = basal_lalc1 + basal_lalc2;
        
        %% Pump Block
        [ubolus_ins,ubasal_ins]  = pump(ubolus,ubasal,hardware,parametros.paciente.BW); %Insulina
        [ubolus_glu,ubasal_glu] = pump(ubolus,ubasal,hardware,parametros.paciente.BW);   %Glucagon
        
        %% Paciente Block
        ubolus_ins= (1/parametros.paciente.BW).*ubolus_ins;
        ubasal_ins = (1/parametros.paciente.BW).*ubasal_ins;
        sq_insulin = ubolus_ins + ubasal_ins;
        
        ubolus_glu = (1/parametros.paciente.BW).*ubolus_glu;
        ubasal_glu = (1/parametros.paciente.BW).*ubasal_glu;
        sq_glucagon = ubolus_glu + ubasal_glu;
        iv_insulin = parametros.iv(2,:);   %insulina
        iv_glucose = parametros.iv(1,:);   %glucosa 
        mix_meals = (1/parametros.paciente.BW).*parametros.ra_comidas_mixtas;
        
        u = [parametros.comidas(k); sq_insulin; sq_glucagon(k); iv_insulin(k); iv_glucose(k); mix_meals(k)];
        
        %
        
        [~,X] = ode45(@(k,x) t1dm_unlp_v2(k,x,u,parametros,escenario),[k k+escenario.deltat],x0);
        
        % Guardar estados 
        estados(item,:) = X;   
        
        x0 = X(end,:); %Next iteration       
        
        item = item + 1;
        
    end %Fin Loop vector tiempo de Paciente(v)
    salidas;
    
    [data] = guardar(data,v,sujeto,parametros,salidas,estados,escenario,ts,ctrl,settings.narchi);
    
end %Fin Loop Paciente
