% opcion tomar el valor 1 a 6 segun simulación a realizar;
% opcion 7 graficos de las entradas
% nro es el numero de paciente, 1 adulto_1 o 2 adolescente_1;

function [] = graf_tasks(opcion,nro,data)
tf = length(data(nro).parametros.comidas);
t = [0:1:tf-1];  %creación del vector de tiempo de simulación

switch opcion
    case 1
        %% ----- Simulación 1a
        figure,
        subplot(3,1,1)
        plot(data(nro).t/60,data(nro).glucosa,'r','DisplayName','Glucosa en plasma')
        xlim([data(nro).t(1)/60 data(nro).t(end)/60])
        title([' ',data(nro).parametros.paciente.names]);
        ylabel('Glucosa en plasma [mg/dl]'); xlabel('tiempo [horas]');
        grid on
        subplot(3,1,2)
        plot(data(nro).t/60,data(nro).salidas(5,:)/6000)
        ylabel('Bolos [U/min]');%ylim([0 (max(data(nro).salidas(:,5)/6000)+1)]),
        xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,1,3)
        plot(data(nro).t/60,data(nro).salidas(4,:)/100)
        ylabel('Ins. Basal [U/h]');%ylim([0 (max(data(nro).salidas(:,4)/100)+1)]),
        xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        
    case 2
        %% ---------- Simulación 2
        figure,
        subplot(3,1,1)
        plot(data(nro).t/60,data(nro).glucosa,'r','DisplayName','Glucosa en plasma')
        xlim([data(nro).t(1)/60 data(nro).t(end)/60])
        title([' ',data(nro).parametros.paciente.names]);
        ylabel('Glucosa en plasma [mg/dl]'); xlabel('tiempo [horas]');
        grid on
        subplot(3,1,2)
        plot(t./60, data(nro).parametros.comidas);
        xlim([data(nro).t(1)/60 data(nro).t(end)/60])
        ylabel('Comidas'); xlabel('tiempo [horas]');
        grid on
        subplot(3,1,3)
        dato = data(nro).t/60;
        estado6 = data(nro).estados(6,:);
        plot(dato,estado6); %Estado Insulina en plasma
        xlim([data(nro).t(1)/60 data(nro).t(end)/60])
        ylabel('Insulina en plasma '); xlabel('tiempo [horas]');
        grid on
        
    case 3
        %% ---------- Simulación 3
        figure,
        subplot(3,1,1)
        plot(data(nro).t/60,data(nro).glucosa,'r','DisplayName','Glucosa en plasma')
        xlim([data(nro).t(1)/60 data(nro).t(end)/60]);
        title(['Escenario con bomba Combo de ',data(nro).parametros.paciente.names]);
        ylabel('Glucosa en plasma [mg/dl]'); xlabel('tiempo [horas]');
        grid on
        subplot(3,1,2)
        plot(data(nro).t./60, data(nro).salidas(3,:));
        xlim([data(nro).t(1)/60 data(nro).t(end)/60]);
        ylabel('Insulina de Bomba'); xlabel('tiempo [horas]');
        grid on
        subplot(3,1,3)
        %plot(t./60, (data(1).parametros.insulina(1,:)+data(1).parametros.insulina(2,:)));  %simulacion 2
        %plot(data(1).t./60, (data(1).salidas(:,3)+data(1).salidas(:,4)));
        plot(data(nro).t/60,data(nro).estados(6,:)) %Estado Insulina en plasma
        xlim([data(nro).t(1)/60 data(nro).t(end)/60]);
        ylabel('Insulina en Plasma'); xlabel('tiempo [horas]');
        grid on
        
    case 4
        %% ------------- Simulación 4
        figure,
        subplot(3,1,1) %simulacion 1a
        plot(data(nro).t/60,data(nro).glucosa,'r','DisplayName','Glucosa en plasma')
        xlim([data(nro).t(1)/60 data(nro).t(end)/60])
        title(['Escenario con bomba y sensor de ',data(nro).parametros.paciente.names]);
        ylabel('Glucosa en plasma [mg/dl]'); xlabel('tiempo [horas]');
        grid on
        subplot(3,1,2)
        plot(data(nro).t/60,data(nro).estados(13,:)/data(nro).parametros.paciente.Vg)
        ylabel('Glucemia Subcutanea'),xlim([data(nro).t(1)/60 data(nro).t(end)/60]);
        xlabel('tiempo [horas]');
        grid on
        subplot(3,1,3)
        plot(data(nro).t/60,data(nro).salidas(2,:))
        ylabel('Glucemia CGM'),xlim([data(nro).t(1)/60 data(nro).t(end)/60]);
        xlabel('tiempo [horas]');
        grid on
        
    case 5
        %% ---------- Simulación 5
        
        Rat = data(nro).parametros.paciente.f*data(nro).parametros.paciente.kabs*data(nro).estados(:,3)/data(nro).parametros.paciente.BW+data(nro).parametros.ra_comidas_mixtas(1,:)';
        
        %         Describe la transicion de la glucosa en el estomago y el intestino, donde el estomago
        %         esta representado por dos compartimentos (fase solida Qsto1 y triturada Qsto2), mientras
        %         que un solo compartimiento describe al intestino (Qgut).
        
        figure,
        plot(data(nro).t/60, Rat);
        title(['Tasa de aparición de glucosa en sangre de  ',data(nro).parametros.paciente.names]);
        ylabel('Ra(t)'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]); xlabel('tiempo [horas]');
        grid on;
        
    case 6
        %% ---------- Simulación 6
        figure,
        subplot(3,2,1)
        plot(data(nro).t/60,data(nro).estados(1,:),'r','DisplayName','Glucosa en plasma')
        title('Carbs in first phase of stomach');xlim([data(nro).t(1)/60 data(nro).t(end)/60]); xlabel('tiempo [horas]');
        grid on
        subplot(3,2,2)
        plot(data(nro).t/60,data(nro).estados(2,:))
        title('Carbs in second phase of stomach'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]); xlabel('tiempo [horas]');
        grid on
        subplot(3,2,3)
        plot(data(nro).t/60,data(nro).estados(3,:))
        title('Carbs in intestine'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]); xlabel('tiempo [horas]');
        grid on
        subplot(3,2,4)
        plot(data(nro).t/60,data(nro).estados(4,:))
        title('Glucose in plasma and insulin-independent tissues'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]); xlabel('tiempo [horas]');
        grid on
        subplot(3,2,5)
        plot(data(nro).t/60,data(nro).estados(5,:))
        title('Glucose in insulin-dependent tissues'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]); xlabel('tiempo [horas]');
        grid on
        subplot(3,2,6)
        plot(data(nro).t/60,data(nro).estados(6,:))
        title('Insulin in plasma'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]); xlabel('tiempo [horas]');
        grid on
        
        figure,
        subplot(3,2,1)
        plot(data(nro).t/60,data(nro).estados(7,:),'r','DisplayName','Glucosa en plasma')
        title('Insulin action, X'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,2)
        plot(data(nro).t/60,data(nro).estados(8,:))
        title('Delay compartment for insulin action on glucose production'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,3)
        plot(data(nro).t/60,data(nro).estados(9,:))
        title('Insulin action on glucose production, Id'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]); xlabel('tiempo [horas]');
        grid on
        subplot(3,2,4)
        plot(data(nro).t/60,data(nro).estados(10,:))
        title('Insulin in the liver'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,5)
        plot(data(nro).t/60,data(nro).estados(11,:))
        title('Insulin in first subcutaneous compartment'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]); xlabel('tiempo [horas]');
        grid on
        subplot(3,2,6)
        plot(data(nro).t/60,data(nro).estados(12,:))
        title('Insulin in second subcutaneous compartment'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        
        figure,
        subplot(3,2,1)
        plot(data(nro).t/60,data(nro).estados(13,:),'r','DisplayName','Glucosa en plasma')
        title('Subcutaneous glucose'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,2)
        plot(data(nro).t/60,data(nro).estados(14,:))
        title('Plasma glucagon'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,3)
        plot(data(nro).t/60,data(nro).estados(15,:))
        title('Glucagon action'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,4)
        plot(data(nro).t/60,data(nro).estados(16,:))
        title('Delayed static glucagon secretion'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,5)
        plot(data(nro).t/60,data(nro).estados(17,:))
        title('Glucagon in first subcutaneous compartment'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,6)
        plot(data(nro).t/60,data(nro).estados(18,:))
        title('Glucagon in second subcutaneous compartment'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        
        figure,
        subplot(3,2,1)
        plot(data(nro).t/60,data(nro).estados(19,:))
        title('IOB C1'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,2)
        plot(data(nro).t/60,data(nro).estados(20,:))
        title('IOB C2'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,3)
        plot(data(nro).t/60,data(nro).estados(21,:))
        title(''); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,4)
        plot(data(nro).t/60,data(nro).estados(22,:))
        title(''); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,5)
        plot(data(nro).t/60,data(nro).estados(23,:))
        title(''); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        
    case 7
        subplot(3,2,1)
        %plot(data(nro).t/60,data(nro).parametros.comidas)
        plot(t./60, data(nro).parametros.comidas);
        title('Comidas'); 
        xlim([data(nro).t(1)/60 data(nro).t(end)/60]);
        xlabel('tiempo [horas]');
        grid on
        subplot(3,2,2)
        plot(t./60,data(nro).parametros.insulina(2,:))
        title('Insulina Subcutanea Basal'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,3)
        plot(t./60,data(nro).parametros.insulina(1,:))
        title('Insulina Subcutanea Bolo'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,4)
        plot(t./60,data(nro).parametros.iv(2,:))
        title('Insulina IV'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,5)
        plot(t./60,data(nro).parametros.iv(1,:))
        title('Glucosa IV'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
        subplot(3,2,6)
        plot(t./60,data(nro).parametros.ra_comidas_mixtas)
        title('Comidas Mixtas'); xlim([data(nro).t(1)/60 data(nro).t(end)/60]);xlabel('tiempo [horas]');
        grid on
end
end