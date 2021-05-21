%=======================================================================
%   **guardar**
%   
%   @Description:
%               Funcion encargada de generar un archivo con los datos de 
%               salida de la simulacion.
%
%   @param:     -data:          struct(string,array)
%               -i:             number
%               -sujeto:        array(string(name doc))
%               -parametros:    struct(string,array)
%               -salidas:       
%               -estados:       
%               -escenario:     struct(string,array)
%               -t:             array(number)
%               -ctrl:          struct(string,array)
%               -archi:         filename
%   
%   @return:    -data:          struct(string,array)
%=======================================================================
function [data]=guardar(data,i,sujeto,parametros,salidas,estados,escenario,t,ctrl,archi)

data(i).glucosa        = salidas(:,1);
data(i).t              = t;
data(i).salidas        = salidas;
data(i).estados        = estados;
data(i).parametros     = parametros;
data(i).escenario      = escenario;
data(i).ctrl           = ctrl;

% resultados(i).paciente = char(strrep(sujeto(i),'.mat',''));
% resultados(i).hipo     = 100*sum(salidas(:,1)<escenario.rango(1))/length(salidas(:,1));
% resultados(i).hiper    = 100*sum(salidas(:,1)>escenario.rango(2))/length(salidas(:,1));
% resultados(i).gmedia   = mean(salidas(:,1));
% resultados(i).gmax     = max(salidas(:,1));
% resultados(i).gmin     = min(salidas(:,1))*(min(salidas(:,1))>0);
% resultados(i).exc      =  resultados(i).gmax-resultados(i).gmin;
% resultados(i).numhipos = 0;
% for j=1:length(t)-1
%     if data(i).glucosa(j)>escenario.rango(1) && data(i).glucosa(j+1)<escenario.rango(1) 
%        resultados(i).numhipos = resultados(i).numhipos+1; 
%     end
% end

if i==length(sujeto)
    disp('**Guardando datos**')
    cd Sim_data  
    save(archi,'data');
    %save(['resultados_' archi],'resultados');
    cd ..
end


end


