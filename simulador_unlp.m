%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Inicialización
clear global
clear
clc
dir = fileparts(which('simulador_unlp'));
cd(dir)
addpath(genpath(cd))

global ctrl
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plataforma de simulación  
plataforma = 'plataforma_unlp';
 
auto = 0;
switch auto    
case 1
    % Configuración de simulación
    settings = struct(...                                                
        'escenario',{'prueba'},...
        'paso',1,'ti',0,'tf',30,...
        'narchi',{'sim'},...
        'varsen',0,'visentin',0,'mix',0,...
        'lazo',{'Lazo abierto'},...
        'bomba',0,'sensor',1,'ruido',0,...
        'nombrebomba',{'insulet.pmp'},'nombresensor',{'dexcom50.scs'},...        
        'excel',0);
    
    % Pacientes
    %sujeto = ({'adult#001'});
    %***Adultos***
    %sujeto = ({'adult#001','adult#002','adult#003','adult#004','adult#005','adult#006','adult#007','adult#008','adult#009','adult#010','adult#average'});
    %***Pibes***
    %sujeto = ({'child#001','child#002','child#003','child#004','child#005','child#006','child#007','child#008','child#009','child#010','child#average'});
    %***Adolescentes***
    %sujeto = ({'adolescent#001','adolescent#002','adolescent#003','adolescent#004','adolescent#005','adolescent#006','adolescent#007','adolescent#008','adolescent#009','adolescent#010','adolescent#average'});       
    %***Todes***
    sujeto = ({'child#001','child#002','child#003','child#004','child#005','child#006','child#007','child#008','child#009','child#010','child#average',...
               'adolescent#001','adolescent#002','adolescent#003','adolescent#004','adolescent#005','adolescent#006','adolescent#007','adolescent#008','adolescent#009','adolescent#010','adolescent#average',...
               'adult#001','adult#002','adult#003','adult#004','adult#005','adult#006','adult#007','adult#008','adult#009','adult#010','adult#average'});

case 0        
    %Carga de los sujetos a simular
    [sujeto, bombas, sensores, s] = subj_disp_loader();    %arrelgo de cadenas que contienem los sujetosy dispositivos disponibles
    if s==0                     %en caso de cancelar la selección se cierra el programa
        clear
        return;
    end    

    %Ventana de carga de datos
    [settings, boton] = settingsdlg(...                                                 %esta función fue desarrollada por Rody Oldenhuis
        'Description', 'Configuración de diferentes aspectos de la simulación',...
        'title'      , 'Simulador UNLP',...
        'separator'  , 'Configuración',...
        {'Nombre escenario';'escenario'},'prueba',...
        {'Paso de simulación (en minutos)';'paso'},1,...
        {'Inicio (hs a partir 00hs)';'ti'},6,...
        {'Fin de la simulación (hs a partir 00hs)';'tf'},24,...
        'separator'  , 'Modelo sensor',...
        {'Modelo sensor';'sensor'},[false, true],...
        {'Sensores disponibles';'nombresensor'},{sensores},...
        {'Ruido';'ruido'},false,...
        'separator'  , 'Modelo bomba',...
        {'Modelo bomba';'bomba'},[false, true],...
        {'Bombas disponibles';'nombrebomba'},{bombas},...
        'separator'  , 'Variación intra-paciente',...    
        {'Variación Herrero 2012','varsen'},false,... 
        {'Variación Visentin 2015','visentin'},false,...
        'separator'  , 'Comidas mixtas',...
        {'Agregar comidas mixtas';'mix'},false,...
        'separator'  , 'Rango de normoglucemia',...
        {'Límite de hipoglucemia (mg/dl)';'rango1'},70,...
        {'Límite de hiperglucemia (mg/dl)';'rango2'},180,...
        'separator'  ,'Tipo de tratamiento',...
        {'Tratamiento';'lazo'},{'Lazo abierto','Lazo cerrado','Lazo híbrido'},...
        'separator' ,'Archivos de salida',...
        {'Nombre del archivo de guardado';'narchi'},'sim',...
        {'¿Archivo Excel?';'excel'},false);

    if ~strcmp(boton,'OK')              %en caso de cancelar se sale del programa
        clear
        return;
    end
end 

%Creación de las estructuras de salida  
[data,parametros,escenario,ctrl,hardware] = creacion_struc(length(sujeto));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Ventana de variación intra-paciente senoidal
if settings.varsen
   [parametros.variacion,boton] = settingsdlg(...                   
    'separator' ,'Variacion senoidal',...    
    {'Sens. ins.: Periodo (hs)';'periodovmx'},24,...
    {'Sens. ins.: Amplitud (%)';'ampvmx'},0,...
    {'Sens. ins.: Fase (hs)';'fasevmx'},0,...
    {'Sens. ins. hepática: Periodo (hs)';'periodokp3'},24,...
    {'Sens. ins. hepática: Amplitud (%)';'ampkp3'},0,...
    {'Sens. ins. hepática: Fase (hs)';'fasekp3'},0,...
    {'Dinámica ins. sc.: Periodo (hs)';'periodoisc'},24,...
    {'Dinámica ins. sc: Amplitud (%)';'ampisc'},0,...
    {'Dinámica ins. sc: Fase (hs)';'faseisc'},0);
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
escenario.ti                = settings.ti*60;             %tiempo de inicio de la simulación en minutos a partir de las 0hs
escenario.tf                = settings.tf*60;             %duración de la simulación
escenario.paso              = settings.paso;              %paso de simulación en minutos
t                           = linspace(0,escenario.tf,escenario.tf/escenario.paso+1);  %creación del vector de tiempo de simulación  
escenario.nombre_bomba      = char(settings.nombrebomba);           %bomba seleccionada
escenario.nombre_sensor     = char(settings.nombresensor);          %sensor seleccionada

parametros.variacion.visentin   = settings.visentin;
parametros.variacion.varsen     = settings.varsen;

switch settings.lazo
    case 'Lazo abierto'
        lazo=1;lazoh=-1;
    case 'Lazo cerrado'
        lazo=-1;lazoh=-1;
    case 'Lazo híbrido'
        lazo=1;lazoh=1;
end

%Parametros generales de simulación
disp('**Cargando parámetros**')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Carga del escenario
[escenario] = cargar_escenario(escenario);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Creación del vector de comidas
parametros.comidas = creacion_comidas(escenario,t);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Creación del vector de suministros intravenosos
parametros.iv = creacion_IV(escenario,t);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Carga del hardware
hardware = cargar_hardware(escenario.nombre_bomba,escenario.nombre_sensor,hardware,settings.bomba,settings.sensor); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Configuración SIMULINK y ventana de progreso
paramNameValStruct = config_sim();
h = waitbar(0,'Simulando pacientes, por favor espere...','windowstyle', 'modal');

%Bucle principal de simulación
for v=1:length(sujeto)
    
    %Carga de parámetros de sujeto
    parametros = cargar_sujeto(char(sujeto(v)),parametros);

    %Creación de comidas mixtas
    if settings.mix
        [parametros.ra_comidas_mixtas, escenario.Tcomix, escenario.Acomix] = creacion_comidas_mixtasv3(escenario,t,char(sujeto(v)));
    else
        parametros.ra_comidas_mixtas = zeros(1,size(t,2));
    end

    %Creación vector de insulina 
    if parametros.variacion.visentin
        [parametros,escenario] = creacion_bolos_visentin(parametros,escenario,t,char(sujeto(v)),settings.mix);
    else
        [parametros.insulina,escenario] = creacion_bolos(parametros,escenario,t,char(sujeto(v)),settings.mix);
    end

    %Vectores de variación intra-paciente
    if parametros.variacion.varsen||parametros.variacion.visentin
        [parametros] = variacion_intrapaciente_v3(parametros,t,escenario.paso);
    end

    %Condicines iniciales del modelo T1DM
    parametros.paciente.x0 = condiciones_iniciales(parametros,escenario);

    %Configuración de los parámetros del controlador
    control_param;
    
    %Creación del vector de ruido de CGM
    if settings.ruido
        parametros.ruido = creacion_CGMnoise(hardware,escenario,t);
    else
        parametros.ruido = [t' zeros(size((t)'))];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Simulación
    cd Plataformas\
    simOut = sim(plataforma,paramNameValStruct);
    cd ..
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Guardado de variables de salida de la simulación
    salidas = simOut.get('salidas');
    estados = simOut.get('estados');
    ts      = simOut.get('tout');
    
    waitbar(v/length(sujeto));
    if v==length(sujeto)
        close(h);        
    end    

    [data] = guardar(data,v,sujeto,parametros,salidas,estados,escenario,ts,ctrl,settings.narchi);
    
end
disp(['**Guardado "',settings.narchi,'"**'])
disp('**Simulación finalizada**')
disp(datetime('now'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Gráficos y planilla de resultados
if auto == 0
    graficos(settings.narchi);
end
if settings.excel
    excel_maker(['resultados_' settings.narchi]);
end

%rmpath(genpath(dir))

clearvars -except data 



    