%% ------- Inicializacion
clear global
clear
clc
dir = fileparts(which('simulador_unlp'));
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
    if s==0                     %en caso de cancelar la selecci�n se cierra el programa
        clear
        return;
    end    

    %% ---- Ventana de carga de datos
    [settings, boton] = settingsdlg(...                                                 %esta funci�n fue desarrollada por Rody Oldenhuis
        'Description', 'Configuraci�n de diferentes aspectos de la simulaci�n',...
        'title'      , 'Simulador UNLP',...
        'separator'  , 'Configuraci�n',...
        {'Nombre escenario';'escenario'},'prueba',...
        {'Paso de simulaci�n (en minutos)';'paso'},1,...
        {'Inicio (hs a partir 00hs)';'ti'},6,...
        {'Fin de la simulaci�n (hs a partir 00hs)';'tf'},24,...
        'separator'  , 'Modelo sensor',...parametros.ruido
        {'Modelo sensor';'sensor'},[false, true],...
        {'Sensores disponibles';'nombresensor'},{sensores},...
        {'Ruido';'ruido'},false,...
        'separator'  , 'Modelo bomba',...
        {'Modelo bomba';'bomba'},[false, true],...
        {'Bombas disponibles';'nombrebomba'},{bombas},...
        'separator'  , 'Variaci�n intra-paciente',...    
        {'Variaci�n Herrero 2012','varsen'},false,... 
        {'Variaci�n Visentin 2015','visentin'},false,...
        'separator'  , 'Comidas mixtas',...
        {'Agregar comidas mixtas';'mix'},false,...
        'separator'  , 'Rango de normoglucemia',...
        {'L�mite de hipoglucemia (mg/dl)';'rango1'},70,...
        {'L�mite de hiperglucemia (mg/dl)';'rango2'},180,...
        'separator'  ,'Tipo de tratamiento',...
        {'Tratamiento';'lazo'},{'Lazo abierto','Lazo cerrado','Lazo h�brido'},...
        'separator' ,'Archivos de salida',...
        {'Nombre del archivo de guardado';'narchi'},'sim',...
        {'�Archivo Excel?';'excel'},false);

    if ~strcmp(boton,'OK')              %en caso de cancelar se sale del programa
        clear
        return;
    end
end 

%Creacion de las estructuras de salida  
[data,parametros,escenario,ctrl,hardware] = creacion_struc(length(sujeto));

%% ------- Ventana de variaci�n intra-paciente senoidal
if settings.varsen
   [parametros.variacion,boton] = settingsdlg(...                   
    'separator' ,'Variacion senoidal',...    
    {'Sens. ins.: Periodo (hs)';'periodovmx'},24,...
    {'Sens. ins.: Amplitud (%)';'ampvmx'},0,...
    {'Sens. ins.: Fase (hs)';'fasevmx'},0,...
    {'Sens. ins. hep�tica: Periodo (hs)';'periodokp3'},24,...
    {'Sens. ins. hep�tica: Amplitud (%)';'ampkp3'},0,...
    {'Sens. ins. hep�tica: Fase (hs)';'fasekp3'},0,...
    {'Din�mica ins. sc.: Periodo (hs)';'periodoisc'},24,...
    {'Din�mica ins. sc: Amplitud (%)';'ampisc'},0,...
    {'Din�mica ins. sc: Fase (hs)';'faseisc'},0);
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
escenario.ti                = settings.ti*60;             %tiempo de inicio de la simulaci�n en minutos a partir de las 0hs
escenario.tf                = settings.tf*60;             %duraci�n de la simulaci�n
escenario.paso              = settings.paso;              %paso de simulaci�n en minutos
t                           = linspace(0,escenario.tf,escenario.tf/escenario.paso+1);  %creaci�n del vector de tiempo de simulaci�n  
escenario.nombre_bomba      = char(settings.nombrebomba);           %bomba seleccionada
escenario.nombre_sensor     = char(settings.nombresensor);          %sensor seleccionada

parametros.variacion.visentin   = settings.visentin;
parametros.variacion.varsen     = settings.varsen;

switch settings.lazo
    case 'Lazo abierto'
        lazo=1;lazoh=-1;
    case 'Lazo cerrado'
        lazo=-1;lazoh=-1;
    case 'Lazo h�brido'
        lazo=1;lazoh=1;
end

%Parametros generales de simulaci�n
disp('**Cargando par�metros**')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Carga del escenario
[escenario] = cargar_escenario(escenario);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Creaci�n del vector de comidas
parametros.comidas = creacion_comidas(escenario,t);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Creaci�n del vector de suministros intravenosos
parametros.iv = creacion_IV(escenario,t);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Carga del hardware
hardware = cargar_hardware(escenario.nombre_bomba,escenario.nombre_sensor,hardware,settings.bomba,settings.sensor); 

%% ------ Configuraci�n SIMULINK y ventana de progreso
paramNameValStruct = config_sim();
h = waitbar(0,'Simulando pacientes, por favor espere...','windowstyle', 'modal');

%Bucle principal de simulaci�n
for v=1:length(sujeto)
    
    %Carga de par�metros de sujeto
    parametros = cargar_sujeto(char(sujeto(v)),parametros);

    %Creaci�n de comidas mixtas
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

    %Vectores de variaci�n intra-paciente
    if parametros.variacion.varsen||parametros.variacion.visentin
        [parametros] = variacion_intrapaciente_v3(parametros,t,escenario.paso);
    end

    %Condicines iniciales del modelo T1DM
    parametros.paciente.x0 = condiciones_iniciales(parametros,escenario);

    %Configuraci�n de los par�metros del controlador
    control_param;
    
    %Creaci�n del vector de ruido de CGM
    if settings.ruido
        parametros.ruido = creacion_CGMnoise(hardware,escenario,t);
    else
        parametros.ruido = [t' zeros(size((t)'))];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Simulacion REEMPLAZAR
    %[glucose_plasma, CGM, u_pumped, ubasal, ubolus,IOB_est ] = bloq_simulink (parametros, hardware);

    cd Plataformas\
    simOut = sim(plataforma,paramNameValStruct);
    cd ..
     
      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Guardado de variables de salida de la simulaci�n
    salidas = simOut.get('salidas');
    estados = simOut.get('estados');
    ts      = simOut.get('tout');
    
    waitbar(v/length(sujeto));
    if v==length(sujeto)
        close(h);        
    end    

    [data] = guardar(data,v,sujeto,parametros,salidas,estados,escenario,ts,ctrl,settings.narchi);
    
end
disp(['**Guardado "',settings.narchi,'"**']);
disp('**Simulaci�n finalizada**');
disp(datetime('now'));

%% --------- Gr�ficos y planilla de resultados
if auto == 0
    graficos(settings.narchi);
end
if settings.excel
    excel_maker(['resultados_' settings.narchi]);
end

%rmpath(genpath(dir))

clearvars -except data 



    