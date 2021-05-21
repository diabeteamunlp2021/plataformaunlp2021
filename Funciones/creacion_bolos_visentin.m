%=======================================================================
% **creacion_bolos_visentin**
%
%   @Description:
%               Funcion encargada de generar vector de insulina basado en
%               en el modelo de Visentin.
%               Este modelo permite tener en cuenta una variacion mas 
%               realista y versatil, se considero la variabilidad diurna 
%               de los parametros del sistema que describe la sensibilidad 
%               a la insulina.
%               
%
%   @param:     -parametros:            struct(string,array)
%               -escenario:             struct(string,array)
%               -t:                     array(number)
%               -sujeto:                struct(string,array)
%               -mix:                   boolean
%
%   @return:    -parametros:            struct(string,array)
%               -escenario:             struct(string,array) 
%=======================================================================
function [parametros,escenario] = creacion_bolos_visentin(parametros,escenario,t,sujeto,mix)

SI_profile = ones(1,length(t));

%Asignación aletaoria de clase   
%r tiene una distribución uniforme continua entre 0 y 1  
%a partir de la misma creo mi distribución de clases

r = rand;
if      r<=.1
    class = 1;
elseif  r>.1 && r<=.15
    class = 2;
elseif  r>.15 && r<=.2
    class = 3;
elseif  r>.2 && r<=.3
    class = 4;
elseif  r>.3 && r<=.5
    class = 5;
elseif  r>.5 && r<=.7
    class = 6;
else
    class = 7;
end

%Asignación predifinida de clase
% load Vclass
% for j=1:size(Vclass,2)
%     if strcmp(sujeto,Vclass(j).names)
%        class = Vclass(j).values;
%     end
% end  

%Asigno los valores de h y l
high    = 1;
low     = 0.6;
TBR     = [4 11 17];    %hora de cambios de insulina basal
CR_low  = 0.6;
sigma   = 0;            %desviación estandard del ruido de SI
class   = 3;            %me cago en la selección aleatoria

%Factores de sensibilidad sobre la relación I:CHO
switch class
    case 1
        SI_factor = [1 1 1];
    case 2
        SI_factor = [1 1 CR_low];
    case 3
        SI_factor = [1 CR_low 1];
    case 4
        SI_factor = [1 CR_low CR_low];
    case 5
        SI_factor = [CR_low 1 1];
    case 6
        SI_factor = [CR_low 1 CR_low];
    case 7
        SI_factor = [CR_low CR_low 1];
end
%Creo los vectores de insulina
insulina    = zeros(2,size(t,2));
durinsulina = 1;

if ~strcmp(escenario.LAoptimo,'on')
%Bolos por escenario    
    for j=1:size(escenario.Tbolos,2)
        aux = floor(escenario.Tbolos(1,j)/escenario.paso)+1;
        aux2 = floor(durinsulina/escenario.paso);
        if aux<size(t,2)
            if aux2==0
               insulina(1,aux) = 6000*escenario.bolos(1,j);
            else
               for k=0:aux2-1
                   insulina(1,aux+k) = 6000*escenario.bolos(1,j)/durinsulina;
                end
            end
        else
            break
        end
    end  
else
    %Bolos optimos
    if mix
        escenario.Tcomida        = [escenario.Tcomida escenario.Tcomix];
        escenario.comida         = [escenario.comida escenario.Acomix];
        [escenario.Tcomida,ind]  = sort(escenario.Tcomida);
        escenario.comida         = escenario.comida(ind);
    end 
    escenario.Tbolos = escenario.Tcomida-escenario.deltat;
    if isempty(escenario.sensibilidad)
        escenario.sensibilidad = parametros.paciente.CR*1000;
%         if strcmp(sujeto,'adult#009')
%             escenario.sensibilidad = parametros.paciente.CR*1000*1; %el 9 es un HDP, se sugiere 1.2
%         end
    end    
    if ~isempty(escenario.Tcomida)            
        for j=1:size(escenario.Tbolos,2)
            hora_bolo = mod(escenario.Tbolos(1,j),1440);
            if hora_bolo>=TBR(1)*60&&hora_bolo<TBR(2)*60
                escenario.bolos(1,j) = escenario.comida(1,j)/(escenario.sensibilidad*SI_factor(1));
            elseif hora_bolo>=TBR(2)*60&&hora_bolo<TBR(3)*60
                escenario.bolos(1,j) = escenario.comida(1,j)/(escenario.sensibilidad*SI_factor(2));
            else
                escenario.bolos(1,j) = escenario.comida(1,j)/(escenario.sensibilidad*SI_factor(3));
            end                
            aux = floor(escenario.Tbolos(1,j)/escenario.paso)+1;
            aux2 = floor(durinsulina/escenario.paso);
            if aux<size(t,2)
                if aux2==0
                   insulina(1,aux)=6000*escenario.bolos(1,j)+insulina(1,aux);
                else
                   for k=0:aux2-1
                       insulina(1,aux+k)=6000*escenario.bolos(1,j)/durinsulina+insulina(1,aux+k);
                    end
                end
            else
                break
            end
        end
    end
end

%Insulina basal

if isempty(escenario.Gtarget)
    escenario.Gtarget = parametros.paciente.x0(4)/parametros.paciente.Vg;
end

if isempty(escenario.basal)    
    %Calculo de la ins basal para Gtarget en caso low y high ideales
    if escenario.Gtarget<parametros.paciente.Gb && escenario.Gtarget>parametros.paciente.Gth
        fGp  = log(escenario.Gtarget/parametros.paciente.Gb)^parametros.paciente.r2;
        risk = 10*fGp^2;
    elseif escenario.Gtarget<parametros.paciente.Gth
        fGp  = log(parametros.paciente.Gth/parametros.paciente.Gb)^parametros.paciente.r2;
        risk = 10*fGp^2;
    else
        risk = 0;
    end
    if escenario.Gtarget*parametros.paciente.Vg>parametros.paciente.ke2
        Et = parametros.paciente.ke1*(escenario.BGinit*parametros.paciente.Vg-parametros.paciente.ke2);
    else
        Et = 0;
    end
    Gpop    = escenario.Gtarget*parametros.paciente.Vg;
    GGta    = -parametros.paciente.k2-parametros.paciente.Vmx*(1+parametros.paciente.r3*risk)*parametros.paciente.k2/parametros.paciente.kp3;
    GGtb    = parametros.paciente.k1*Gpop-parametros.paciente.k2*parametros.paciente.Km0-parametros.paciente.Vm0+parametros.paciente.Vmx*(1+parametros.paciente.r3*risk)*parametros.paciente.Ib+...
              (parametros.paciente.Vmx*(1+parametros.paciente.r3*risk)*(parametros.paciente.k1+parametros.paciente.kp2)*Gpop-parametros.paciente.Vmx*(1+parametros.paciente.r3*risk)*parametros.paciente.kp1+parametros.paciente.Vmx*(1+parametros.paciente.r3*risk)*(parametros.paciente.Fsnc+Et))/parametros.paciente.kp3;
    GGtc    = parametros.paciente.k1*Gpop*parametros.paciente.Km0;
    Gtop    = (-GGtb-sqrt(GGtb^2-4*GGta*GGtc))/(2*GGta);
    Idop    = max([0 (-(parametros.paciente.k1+parametros.paciente.kp2)*Gpop+parametros.paciente.k2*Gtop+parametros.paciente.kp1-(parametros.paciente.Fsnc+Et))/parametros.paciente.kp3]);
    Ipop    = Idop*parametros.paciente.Vi;
    ILop    = parametros.paciente.m2*Ipop/(parametros.paciente.m1+parametros.paciente.m30);
    Ib_high = parametros.paciente.BW*((parametros.paciente.m2+parametros.paciente.m4)*Ipop-parametros.paciente.m1*ILop);

    Gpop    = escenario.Gtarget*parametros.paciente.Vg;
    GGta    = -parametros.paciente.k2-parametros.paciente.Vmx*low*(1+parametros.paciente.r3*risk)*parametros.paciente.k2/(parametros.paciente.kp3*low);
    GGtb    = parametros.paciente.k1*Gpop-parametros.paciente.k2*parametros.paciente.Km0-parametros.paciente.Vm0+parametros.paciente.Vmx*low*(1+parametros.paciente.r3*risk)*parametros.paciente.Ib+...
              (parametros.paciente.Vmx*low*(1+parametros.paciente.r3*risk)*(parametros.paciente.k1+parametros.paciente.kp2)*Gpop-parametros.paciente.Vmx*low*(1+parametros.paciente.r3*risk)*parametros.paciente.kp1+parametros.paciente.Vmx*low*(1+parametros.paciente.r3*risk)*(parametros.paciente.Fsnc+Et))/(parametros.paciente.kp3*low);
    GGtc    = parametros.paciente.k1*Gpop*parametros.paciente.Km0;
    Gtop    = (-GGtb-sqrt(GGtb^2-4*GGta*GGtc))/(2*GGta);
    Idop    = max([0 (-(parametros.paciente.k1+parametros.paciente.kp2)*Gpop+parametros.paciente.k2*Gtop+parametros.paciente.kp1-(parametros.paciente.Fsnc+Et))/(parametros.paciente.kp3*low)]);
    Ipop    = Idop*parametros.paciente.Vi;
    ILop    = parametros.paciente.m2*Ipop/(parametros.paciente.m1+parametros.paciente.m30);
    Ib_low = parametros.paciente.BW*((parametros.paciente.m2+parametros.paciente.m4)*Ipop-parametros.paciente.m1*ILop);

    %Creación del perfil de basal y de variación de parametros
    TBR = TBR-2;
    switch class
        case 1
            basal(1,1:floor(TBR(1)*60/escenario.paso)+1)                                    = Ib_high;
            basal(1,floor(TBR(1)*60/escenario.paso)+2:floor(TBR(2)*60/escenario.paso)+1)    = Ib_high;
            basal(1,floor(TBR(2)*60/escenario.paso)+2:floor(TBR(3)*60/escenario.paso)+1)    = Ib_high;
            basal(1,floor(TBR(3)*60/escenario.paso)+2:floor(24*60/escenario.paso)+1)        = Ib_high;     
            noise = sigma.*randn(3,2)+1;
            B = high*noise(1,:); %breakfast            
            L = high*noise(2,:); %lunch            
            D = high*noise(3,:); %dinner
        case 2
            basal(1,1:floor(TBR(1)*60/escenario.paso)+1)                                    = Ib_low;
            basal(1,floor(TBR(1)*60/escenario.paso)+2:floor(TBR(2)*60/escenario.paso)+1)    = Ib_high;
            basal(1,floor(TBR(2)*60/escenario.paso)+2:floor(TBR(3)*60/escenario.paso)+1)    = Ib_high;
            basal(1,floor(TBR(3)*60/escenario.paso)+2:floor(24*60/escenario.paso)+1)        = Ib_low;
            noise = sigma.*randn(3,2)+1;
            B = high*noise(1,:); %breakfast            
            L = high*noise(2,:); %lunch            
            D = low*noise(3,:); %dinner
        case 3
            basal(1,1:floor(TBR(1)*60/escenario.paso)+1)                                    = Ib_high;
            basal(1,floor(TBR(1)*60/escenario.paso)+2:floor(TBR(2)*60/escenario.paso)+1)    = Ib_high;
            basal(1,floor(TBR(2)*60/escenario.paso)+2:floor(TBR(3)*60/escenario.paso)+1)    = Ib_low;
            basal(1,floor(TBR(3)*60/escenario.paso)+2:floor(24*60/escenario.paso)+1)        = Ib_high;
            noise = sigma.*randn(3,2)+1;
            B = high*noise(1,:); %breakfast            
            L = low*noise(2,:); %lunch            
            D = high*noise(3,:); %dinner
        case 4
            basal(1,1:floor(TBR(1)*60/escenario.paso)+1)                                    = Ib_low;
            basal(1,floor(TBR(1)*60/escenario.paso)+2:floor(TBR(2)*60/escenario.paso)+1)    = Ib_high;
            basal(1,floor(TBR(2)*60/escenario.paso)+2:floor(TBR(3)*60/escenario.paso)+1)    = Ib_low;
            basal(1,floor(TBR(3)*60/escenario.paso)+2:floor(24*60/escenario.paso)+1)        = Ib_low;
            noise = sigma.*randn(3,2)+1;
            B = high*noise(1,:); %breakfast            
            L = low*noise(2,:); %lunch            
            D = low*noise(3,:); %dinner
        case 5
            basal(1,1:floor(TBR(1)*60/escenario.paso)+1)                                    = Ib_high;
            basal(1,floor(TBR(1)*60/escenario.paso)+2:floor(TBR(2)*60/escenario.paso)+1)    = Ib_low;
            basal(1,floor(TBR(2)*60/escenario.paso)+2:floor(TBR(3)*60/escenario.paso)+1)    = Ib_high;
            basal(1,floor(TBR(3)*60/escenario.paso)+2:floor(24*60/escenario.paso)+1)        = Ib_high;
            noise = sigma.*randn(3,2)+1;
            B = low*noise(1,:); %breakfast            
            L = high*noise(2,:); %lunch            
            D = high*noise(3,:); %dinner
        case 6
            basal(1,1:floor(TBR(1)*60/escenario.paso)+1)                                    = Ib_low;
            basal(1,floor(TBR(1)*60/escenario.paso)+2:floor(TBR(2)*60/escenario.paso)+1)    = Ib_low;
            basal(1,floor(TBR(2)*60/escenario.paso)+2:floor(TBR(3)*60/escenario.paso)+1)    = Ib_high;
            basal(1,floor(TBR(3)*60/escenario.paso)+2:floor(24*60/escenario.paso)+1)        = Ib_low;               
            noise = sigma.*randn(3,2)+1;
            B = low*noise(1,:); %breakfast            
            L = high*noise(2,:); %lunch            
            D = low*noise(3,:); %dinner
        case 7
            basal(1,1:floor(TBR(1)*60/escenario.paso)+1)                                    = Ib_high;
            basal(1,floor(TBR(1)*60/escenario.paso)+2:floor(TBR(2)*60/escenario.paso)+1)    = Ib_low;
            basal(1,floor(TBR(2)*60/escenario.paso)+2:floor(TBR(3)*60/escenario.paso)+1)    = Ib_low;
            basal(1,floor(TBR(3)*60/escenario.paso)+2:floor(24*60/escenario.paso)+1)        = Ib_high;
            noise = sigma.*randn(3,2)+1;
            B = low*noise(1,:); %breakfast            
            L = low*noise(2,:); %lunch            
            D = high*noise(3,:); %dinner
    end 
    Vvmx = [D(1),(D(1)+(B(1)-D(1))*sigmf(1:450/escenario.paso,[.05*escenario.paso 240/escenario.paso])),(B(1)+(L(1)-B(1))*sigmf(1:390/escenario.paso,[.05*escenario.paso 240/escenario.paso])),(L(1)+(D(1)-L(1))*sigmf(1:600/escenario.paso,[.05*escenario.paso 240/escenario.paso]))];
    Vkp3 = [D(2),(D(2)+(B(2)-D(2))*sigmf(1:450/escenario.paso,[.05*escenario.paso 240/escenario.paso])),(B(2)+(L(2)-B(2))*sigmf(1:390/escenario.paso,[.05*escenario.paso 240/escenario.paso])),(L(2)+(D(2)-L(2))*sigmf(1:600/escenario.paso,[.05*escenario.paso 240/escenario.paso]))];
    for i=1:length(t)
        SI_profile(1,i) = Vvmx(1,mod(i,1440/escenario.paso)+1);        
        %SI_profile(2,i) = Vkp3(1,mod(i,1440/escenario.paso)+1);
        SI_profile(2,i) = Vvmx(1,mod(i,1440/escenario.paso)+1); %en caso desear el mismo perfil de variación para vmx y kp3
        insulina(2,i)   = basal(1,mod(i,1440/escenario.paso)+1);  
        %insulina(2,i)   = Ib_high; %basal cte
    end  
else
    insulina(2,:) = 100*escenario.basal;
end

parametros.insulina             = insulina;
parametros.variacion.SI_profile = SI_profile;
parametros.variacion.high       = high;  
parametros.variacion.low        = low;
parametros.variacion.TBR        = TBR;
parametros.variacion.sigma      = sigma;
parametros.variacion.CR_low     = CR_low;
parametros.variacion.class      = class;

