%=======================================================================
%   creacion_comidas_mixtasv3
%
%   @Description:
%               Funcion encargada de generar vector de comidas mixtas con
%               la capacidad de generar el momento del dia en que se aplica 
%               y la cantidad de calorias en un momento dado.
%
%   @param:     -escneario:          struct(string,array)
%               -t:                  array(time)
%               -sujeto:             struct(string,array)
%
%   @return:    -comidas_mixtas:     array
%               -Tcomix:             array(time)
%               -Acomix:             array(calorias)
%=======================================================================
function [comidas_mixtas,Tcomix,Acomix] = creacion_comidas_mixtasv3(escenario,t,sujeto)

load('RaPoint')
load('CHOPoint')
comidas_mixtas = zeros(1,size(t,2));

if isempty(escenario.Tcomix)||isempty(escenario.comix)    
    %Manual
    load('Lista de comidas')
    flag = 1;
    j    = 1;
    while flag
    [k,v] = listdlg('ListString',Nombre,'SelectionMode','single','Name','Simulador UNLP','PromptString','Lista de comidas mixtas');
        if v~=0
            T  = str2num(char(inputdlg('Ingrese el horario de la comida (hs a partir de 00hs)','Comida mixta')))*60;
            ra = interp1(0:5:420,RaPoint(k,:),0:escenario.paso:420);
            f  = (ra(end)-ra(end-1))/escenario.paso*t+ra(end)-(ra(end)-ra(end-1))/escenario.paso*420;
            f  = f(421/escenario.paso+1:end);
            f(f <= 0) = 0;
            ra = horzcat(ra,f);
            for i=1:(size(t,2)-T/escenario.paso)
                comidas_mixtas(i+T/escenario.paso) = comidas_mixtas(i+T/escenario.paso)+ra(i);
            end    
            %comidas_mixtas=comidas_mixtas(1:size(t,2));
            escenario.Acomix(j) = CHOPoint(k)*1000;
            escenario.Tcomix(j) = T;
            pregunta = questdlg('¿Desea agregar otra comida?','Comidas mixtas','Si','No','No');
            if strcmp(pregunta,'No')
                flag = 0;
            end  
            j = j+1;
        else
            flag = 0;            
        end
    end
    [escenario.Tcomix ,ind] = sort(escenario.Tcomix);
    escenario.Acomix        = escenario.Acomix(ind);
else
    %Automático
    if any(escenario.Tcomix<100)
        escenario.Tcomix = escenario.Tcomix*60;
    end
    escenario.Acomix = CHOPoint(escenario.comix)'*1000;
    
    %Sin asignación aleatoria de variabilidad inter
    var = 1;
    
    %Asignación aleatoria de variabilidad inter
%     r = rand;
%     if r<=.05
%         var = 1.4;
%     elseif r>.05 && r<=.2
%         var = 1.2;
%     elseif r>.2 && r<=.8
%         var = 1;
%     elseif r>.8 && r<=.95
%         var = .8;
%     else
%         var = .6;
%     end
    
    %Asignación predifinida de variabilidad inter
%     load Vmix
%     for j=1:size(Vmix,2)
%         if strcmp(sujeto,Vmix(j).names)
%            var = Vmix(j).values;
%         end
%     end 

    for k=1:length(escenario.comix)    
        %ra = interp1(0:5:420,RaPoint(comix(k),:),0:paso:420);
        ra = interp1(0:5*var:420*var,RaPoint(escenario.comix(k),:)/var,0:escenario.paso:420*var);
        f  = (ra(end)-ra(end-1))/escenario.paso*t+ra(end)-(ra(end)-ra(end-1))/escenario.paso*420;
        f  = f(421/escenario.paso+1:end);
        f(f <= 0) = 0;
        ra = horzcat(ra,f);
        for i=1:(size(t,2)-escenario.Tcomix(k)/escenario.paso)
            comidas_mixtas(i+escenario.Tcomix(k)/escenario.paso) = comidas_mixtas(i+escenario.Tcomix(k)/escenario.paso)+ra(i);
        end 
    end
end

Tcomix = escenario.Tcomix;
Acomix = escenario.Acomix;
