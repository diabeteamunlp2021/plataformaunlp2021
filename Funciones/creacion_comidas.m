%=======================================================================
%   creacion_comidas
%
%   @Description:
%               Funcion encarga de generar vector de comidas.
%
%   @param:     -escneario:          struct(string,array)
%               -t:                  array(time)
%
%   @return:    -comidas:            array
%=======================================================================

function [comidas] = creacion_comidas(escenario,t)

comidas = zeros(1,size(t,2));

for j=1:size(escenario.Tcomida,2)
    aux = floor((escenario.Tcomida(1,j))/escenario.paso)+1;
    aux2 = floor(escenario.durcomida(j)/escenario.paso);
    if aux<size(t,2)
        if aux2==0
           comidas(1,aux)=escenario.comida(1,j);
        else
           for k=0:aux2-1
               comidas(1,aux+k)=escenario.comida(1,j)/escenario.durcomida(j);
            end
        end
    else
        break
    end
end

