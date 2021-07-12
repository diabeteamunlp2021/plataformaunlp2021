%=======================================================================
%   creacion_bolos
%   
%   @Description:
%               Funcion encargada de crear los bolos de insulina necesario 
%               durante un periodo establecido de simulacion.
%
%   @param:     -parametros:            struct(string,array)
%               -escenario:             struct(string,array)
%               -t:                     array(number)
%               -sujeto:                struct(string,array)
%               -mix:                   boolean(comidas mixtas)
%
%   @return:    -insulina:              array
%               -escenario:             struct(string,array) 
%=======================================================================
function [insulina,escenario] = creacion_bolos(parametros,escenario,t,sujeto,mix)

insulina    = zeros(2,size(t,2));
durinsulina = 1;


if ~strcmp(escenario.LAoptimo,'on')
%Bolos por escenario    
    for j=1:size(escenario.Tbolos,2)
        aux = floor(escenario.Tbolos(1,j)/escenario.paso)+1;
        aux2 = floor(durinsulina/escenario.paso);
        if aux<size(t,2)
            if aux2==0
               insulina(1,aux)=6000*escenario.bolos(1,j);
            else
               for k=0:aux2-1
                   insulina(1,aux+k)=6000*escenario.bolos(1,j)/durinsulina;
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
        sensibilidad = parametros.paciente.CR*1000;
    else
        sensibilidad = escenario.sensibilidad;
    end
    if ~isempty(escenario.Tcomida)
        for i=1:size(escenario.comida,2)
            escenario.bolos(i) = escenario.comida(1,i)/sensibilidad; %6000 pasa unidades internacionales a pmol            
        end      
        for j=1:size(escenario.Tbolos,2)
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
if isempty(escenario.basal)
    if ~isempty(escenario.Gtarget)
        %Cálculo de la ins basal para Gtarget 
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
            Et = parametros.paciente.ke1*(escenario.Gtarget*parametros.paciente.Vg-parametros.paciente.ke2);
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
        insulina(2,:) = ones(1,length(insulina))*parametros.paciente.BW*((parametros.paciente.m2+parametros.paciente.m4)*Ipop-parametros.paciente.m1*ILop);
    else
        %Cálculo de la ins basal para la glucosa en ayunas
        insulina(2,:) = ones(1,length(insulina))*parametros.paciente.BW*((parametros.paciente.m2+parametros.paciente.m4)*parametros.paciente.x0(6)-parametros.paciente.m1*parametros.paciente.x0(10));
    end    
else
    insulina(2,:) = 100*escenario.basal;
end