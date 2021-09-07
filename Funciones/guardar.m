%=======================================================================
%   guardar
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
function [data]=guardar(data,i,glucosa,parametros,salidas,estados,escenario,t,ctrl,archi)

data(i).glucosa        = glucosa;
data(i).t              = t;
data(i).salidas        = salidas;
data(i).estados        = estados;
data(i).parametros     = parametros;
data(i).escenario      = escenario;
data(i).ctrl           = ctrl;

end


