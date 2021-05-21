%=======================================================================
%   **variacion_intrapaciente_v3**
%   
%   @Description:
%               Funcion encargada de generar una variacion senoidal para 
%               asi obtener una simulacion mas realista de las variaciones
%               de los parmetros de los pacientes.
%
%               Modelo: p(t)=p0 +p0 *K(t) sin [(2PI/(P*60))+2PI*F]
%
%               -p(t):          Parametro a variar en el tiempo
%
%               -p0:            Valor inicial/por defecto del parametro
%               -K(t):          Amplitud que puede variar o no en el tiempo
%                               dependiendo de p0
%               -P:             Periodo de la variacion (24hrs)
%               -F:             Ajuste de fase
%
%   @param:     -parametros:    struct(string,array)
%               -t:             array(number)
%               -paso:          number(paso de simulacion)
%               
%   
%   @return:    -parametros:    struct(string,array)
%=======================================================================
%%
function[parametros] = variacion_intrapaciente_v3(parametros,t,paso)

%En base a la interfaz grafica que se muestra al inicio de simulacion la
%cual permite seleccionar o variacion varsen o visentin

if parametros.variacion.varsen
    parametros.paciente.Vmx  = parametros.paciente.Vmx*(1+parametros.variacion.ampvmx/100*sin(2*pi/parametros.variacion.periodovmx/60*(t+parametros.variacion.fasevmx*60)));
    parametros.paciente.kp3  = parametros.paciente.kp3*(1+parametros.variacion.ampkp3/100*sin(2*pi/parametros.variacion.periodokp3/60*(t+parametros.variacion.fasekp3*60)));
    parametros.paciente.ka1  = parametros.paciente.ka1*(1+parametros.variacion.ampisc/100*sin(2*pi/parametros.variacion.periodoisc/60*(t+parametros.variacion.faseisc*60)));
    parametros.paciente.ka2  = parametros.paciente.ka2*(1+parametros.variacion.ampisc/100*sin(2*pi/parametros.variacion.periodoisc/60*(t+parametros.variacion.faseisc*60)));
    parametros.paciente.kd   = parametros.paciente.kd*(1+parametros.variacion.ampisc/100*sin(2*pi/parametros.variacion.periodoisc/60*(t+parametros.variacion.faseisc*60)));
    parametros.paciente.kmax = parametros.paciente.kmax*ones(1,length(t));
    parametros.paciente.kmin = parametros.paciente.kmin*ones(1,length(t));
    parametros.paciente.kabs = parametros.paciente.kabs*ones(1,length(t));
end

if parametros.variacion.visentin
    
    parametros.paciente.Vmx = parametros.paciente.Vmx*parametros.variacion.SI_profile(1,:);
    parametros.paciente.kp3 = parametros.paciente.kp3*parametros.variacion.SI_profile(2,:);    
    kgut = [parametros.paciente.kmax parametros.paciente.kmin parametros.paciente.kabs];
    
    %Creación de los vectores aleatorios para cada parametro de abs.
    for jj=1:3
        noise = 0.044.*randn(1,3)+.059;
        %noise = zeros(1,3);
        D = kgut(jj)*(1+((rand>0.5)*2-1)*noise(jj));        
        L = kgut(jj)*(1+((rand>0.5)*2-1)*noise(jj));        
        B = kgut(jj)*(1+((rand>0.5)*2-1)*noise(jj));       
        aux(jj,:) = [D,(D+(B-D)*sigmf(1:450/paso,[.05*paso 240/paso])),(B+(L-B)*sigmf(1:390/paso,[.05*paso 240/paso])),(L+(D-L)*sigmf(1:600/paso,[.05*paso 240/paso]))];
    end
    for i=1:length(t)
            parametros.paciente.kmax(i) = aux(1,mod(i,1440/paso)+1); 
            parametros.paciente.kmin(i) = aux(2,mod(i,1440/paso)+1);
            parametros.paciente.kabs(i) = aux(3,mod(i,1440/paso)+1);
    end
    
    if ~parametros.variacion.varsen        
        parametros.paciente.ka1 = parametros.paciente.ka1*ones(1,length(t));
        parametros.paciente.ka2 = parametros.paciente.ka2*ones(1,length(t));
        parametros.paciente.kd = parametros.paciente.kd*ones(1,length(t));
    end
end