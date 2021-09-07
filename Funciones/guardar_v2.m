function [data]=guardar_v2(data,i,sujeto,parametros,salidas,estados,escenario,t,ctrl,archi)

data(i).glucosa        = salidas(:,1);
data(i).t              = t;
data(i).salidas        = salidas;
data(i).estados        = estados;
data(i).parametros     = parametros;
data(i).escenario      = escenario;
data(i).ctrl           = ctrl;

if i==length(sujeto)
    disp('**Guardando datos**')
    cd Sim_data
    save(archi,'data');
    cd ..
end

end