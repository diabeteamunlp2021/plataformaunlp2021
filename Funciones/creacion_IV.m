%=======================================================================
% **creacion_IV**
%
%   @Description:
%               Funcion encarga de generar vectores de insulina y dextrosa
%               intravenosa.
%
%   @param:     -escneario:          struct(string,array)
%               -t:                  array(time)
%
%   @return:    -iv:                 array
%=======================================================================
function [iv] = creacion_IV(escenario,t)

iv = zeros(2,size(t,2));

for i=1:size(t,2)
    for j=1:size(escenario.Tivd,2)
        if i==floor(escenario.Tivd(1,j)/escenario.paso)+1
            iv(1,i)=1e3*escenario.ivd(1,j); 
        end
    for k=1:size(escenario.Tivins,2)
        if i==floor(escenario.Tivins(1,k)/escenario.paso)+1
            iv(2,i)=6000*escenario.ivins(1,k);
        end
    end
    end
end