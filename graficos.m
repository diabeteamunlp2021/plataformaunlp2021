%Es necesario setear el archivo que normalmente es el sim.ma en sim_data
function [] = graficos(archivo)

addpath(genpath(cd))

[settings,boton] = settingsdlg(...
    'title'     , 'Gráficos',...
    'separator' , 'Gráficos individuales',...
    {'Piola';'piola'},false,...
    {'Glucosa en plasma';'gp'},false,...
    {'Glucosa intersticial';'gi'},false,...
    {'Glucosa intersticial (sensor)';'sensor'},false,...
    {'Inyección de insulina subcutánea (señal)';'isc'},false,...
    {'Inyección de insulina subcutánea (bomba)';'bomb'},false,...
    {'Bolos y Basal (señal)','bolos'},false,...
    {'IOB';'iob'},false,...
    {'IOB estimado';'iobe'},false,...
    'separator' ,'Gráficos poblacionales',...
    {'Glucosa media + std + excursión';'gm'},false,...
    {'CVGA';'cvga'},false,...
    {'Media Piola';'media_piola'},false);
    
    
if ~strcmp(boton,'OK')
    return;
end

load(archivo);
n = length(data);

if (n>1) && (settings.piola||settings.gp||settings.gi||settings.sensor||settings.isc||settings.bomb||settings.iob||settings.iobe||settings.bolos)
    for jj=1:n
        names(jj,:) = cellstr(data(jj).parametros.paciente.names);        
    end
    s = listdlg('ListString',cellstr(names),'SelectionMode','multiple','Name','Simulador UNLP','PromptString','¿Qué pacientes desea visulaizar?');
else
    s=1;
end
        
set(0,'DefaultFigureWindowStyle','docked') 

for i=s 
    if settings.piola
        figure('Name',['Piola ' data(i).parametros.paciente.names(1:3) '#' data(i).parametros.paciente.names((end-1):end)])
        subplot(2,1,1)
        plot(data(i).t/60,data(i).glucosa,'r','DisplayName','Glucosa en plasma') 
        legend('-DynamicLegend');
        xlim([data(i).t(1)/60 data(i).t(end)/60])
        title(['Niveles de glucosa en plasma y tratameinto de ',data(i).parametros.paciente.names]);ylabel('Nivel de glucosa [mg/dl]');xlabel('tiempo [horas]');
        grid on
        subplot(2,1,2)
        yyaxis right
        stairs(data(i).t/60,data(i).salidas(:,5)/6000)
        ylabel('Bolos [U/min]'),ylim([0 (max(data(i).salidas(:,5)/6000)+1)]),xlim([data(i).t(1)/60 data(i).t(end)/60]);
        yyaxis left
        stairs(data(i).t/60,data(i).salidas(:,4)/100)
        ylabel('Ins. Basal [U/h]'),ylim([0 (max(data(i).salidas(:,4)/100)+1)]),xlim([data(i).t(1)/60 data(i).t(end)/60]);
    end
    %Glucosa e Insulina
    if (settings.gp||settings.gi||settings.sensor)&&(settings.isc||settings.bomb)
        figure('Name','Glucosa e insulina')
        subplot(2,1,1)
        if settings.gp
            plot(data(i).t/60,data(i).glucosa,'r','DisplayName','Glucosa en plasma') 
            legend('-DynamicLegend');
            hold all
        end
        if settings.gi
            plot(data(i).t/60,data(i).estados(:,13)/data(i).parametros.paciente.Vg,'g','DisplayName','Glucosa subcutánea')
            legend('-DynamicLegend');
            hold all
        end
        if settings.sensor
            stairs(data(i).t/60,data(i).salidas(:,2),'b','Displayname','Glucosa sensor')
            legend('-DynamicLegend');
            hold all
        end
        xlim([data(i).t(1)/60 data(i).t(end)/60])
        title(['Niveles de glucosa en plasma, intersticial y en salida de sensor de ',data(i).parametros.paciente.names]);ylabel('Nivel de glucosa [mg/dl]');xlabel('tiempo [horas]');
        grid on
        subplot(2,1,2)
        if settings.bomb
            stairs(data(i).t/60,data(i).salidas(:,3),'Displayname','Iny. sc. bomba')
            legend('-DynamicLegend');
            hold all
        end
        if settings.isc
            plot(data(i).t/60,(data(i).salidas(:,4)+data(i).salidas(:,5)),'Displayname','Iny. sc. señal')
            legend('-DynamicLegend');
            hold all
        end
        title(['Inyección de insulina subcutánea de ',data(i).parametros.paciente.names]),ylabel('Insulina [pmol/min]'),xlabel('tiempo [horas]'),xlim([data(i).t(1)/60 data(i).t(end)/60]);
        grid on
    elseif (settings.gp||settings.gi||settings.sensor)
        figure('Name','Glucosa')
        if settings.gp
            plot(data(i).t/60,data(i).glucosa,'r','DisplayName','Glucosa plasma') 
            legend('-DynamicLegend');
            hold all
        end
        if settings.gi
            plot(data(i).t/60,data(i).estados(:,13)/data(i).parametros.paciente.Vg,'g','DisplayName','Glucosa subcutánea')
            legend('-DynamicLegend');
            hold all
        end
        if settings.sensor
            stairs(data(i).t/60,data(i).salidas(:,2),'b','Displayname','Glucosa sensor')
            legend('-DynamicLegend');
            hold all
        end
        xlim([data(i).t(1)/60 data(i).t(end)/60])
        title(['Niveles de glucosa en plasma, intersticial y en salida de sensor de ',data(i).parametros.paciente.names]);ylabel('Nivel de glucosa [mg/dl]');xlabel('tiempo [horas]');
        grid on
    elseif (settings.isc||settings.bomb)
        figure('Name','Insulina')
        if settings.bomb
            stairs(data(i).t/60,data(i).salidas(:,3),'Displayname','Iny. sc. bomba')
            legend('-DynamicLegend');
            hold all
        end
        if settings.isc
            plot(data(i).t/60,(data(i).salidas(:,4)+data(i).salidas(:,5)),'Displayname','Iny. sc. señal')
            legend('-DynamicLegend');
            hold all
        end
        title(['Inyección de insulina subcutánea de ',data(i).parametros.paciente.names]),ylabel('Insulina [pmol/min]'),xlabel('tiempo [horas]'),xlim([data(i).t(1)/60 data(i).t(end)/60]);
        grid on
    end  
    
    %BOLOS y BASAL
    if settings.bolos
        figure('Name','Bolos y basal')   
        if strcmp(version('-release'),'2016b')||strcmp(version('-release'),'2016a')
            yyaxis left
            stairs(data(i).t/60,data(i).salidas(:,5)/6000)
            ylabel('Bolos [U/min]'),ylim([0 (max(data(i).salidas(:,5)/6000)+1)]),xlim([data(i).t(1)/60 data(i).t(end)/60]);
            yyaxis right
            stairs(data(i).t/60,data(i).salidas(:,4)/100)
            ylabel('Ins. Basal [U/h]'),ylim([0 (max(data(i).salidas(:,4)/100)+1)]),xlim([data(i).t(1)/60 data(i).t(end)/60]);
        else
            [hAx,hLine1,hLine2] = plotyy(data(i).t/60,data(i).salidas(:,5)/6000,data(i).t/60,data(i).salidas(:,4)/100);
            ylabel(hAx(2),'Ins. Basal [U/h]'),ylim(hAx(2),[0 (max(data(i).salidas(:,25)/100)+1)]),xlim(hAx(2),[data(i).t(1)/60 data(i).t(end)/60]);    
            ylabel(hAx(1),'Bolos [U/min]'),ylim(hAx(1),[0 (max(data(i).salidas(:,26)/6000)+1)]),xlim(hAx(1),[data(i).t(1)/60 data(i).t(end)/60]);  
            set(hLine2,'Color', [1 0.647 0],'LineWidth',2);
            set(hAx(2),'Ycolor','k');
            set(hLine1,'Color', 'b','LineWidth',2);
            set(hAx(1),'Ycolor','k');
            grid on
            title(['Inyección de insulina subcutánea de ',data(i).parametros.paciente.names]),xlabel('tiempo [horas]');
        end
    end
    
    %IOB
    if (settings.iob||settings.iobe)
        figure('Name','IOB')
        if  settings.iob
            plot(data(i).t/60,(data(i).estados(:,11)+data(i).estados(:,12))*data(i).parametros.paciente.BW/6000,'g','DisplayName','IOB fisio','LineWidth',2)
            hold on  
        end
        if settings.iobe
            stairs(data(i).t/60,data(i).salidas(:,6),'--r','DisplayName','IOB estimado','LineWidth',2),                 
        end
        grid on
        title(['IOB de ',data(i).parametros.paciente.names])
        ylabel('IOB [U]'),xlabel('tiempo [horas]'),xlim([data(i).t(1)/60 data(i).t(end)/60]);
    end      
end 

%G media poblacional
if settings.media_piola
    for i=1:n
       G(i,:)=data(i).glucosa;
       bolos(i,:) = data(i).salidas(:,5)/6000;
       basal(i,:) = data(i).salidas(:,4)/100;
    end
    mbol = mean(bolos,1);
    mbas = mean(basal,1);
    mg   = mean(G,1);
    sdg  = std(G,0,1);
    sdg1 = sdg;
    for k=1:length(data(i).t)
        if mod(data(i).t(k),50)~=0
            sdg1(k)=NaN;
        end
    end
    figure('Name','Media Piola')
    subplot(2,1,1)
    plot(data(1).t/60,mg)
    %errorbar(data(1).t/60,mg,sdg1)    
    xlim([data(i).t(1)/60 data(i).t(end)/60])
    ylabel('Nivel de glucosa [mg/dl]');xlabel('tiempo [horas]');
    grid on
    
    subplot(2,1,2)
    yyaxis right    
    stairs(data(i).t/60,mbol)
    ylabel('Bolos [U/min]'),ylim([0 (max(mbol)+1)]),xlim([data(i).t(1)/60 data(i).t(end)/60]);
    yyaxis left
    stairs(data(i).t/60,mbas)
    ylabel('Ins. Basal [U/h]'),ylim([0 (max(mbas)+1)]),xlim([data(i).t(1)/60 data(i).t(end)/60]);
end
    
if settings.gm  
    figure('Name','Gmedia')
    for i=1:n
       G(i,:)=data(i).glucosa;
    end
    mg   = mean(G,1);
    sdg  = std(G,0,1);
    maxg = max(G);
    ming = min(G);
    sdg1 = sdg;
    for k=1:length(data(i).t)
        if mod(data(i).t(k),50)~=0
            sdg1(k)=NaN;
        end
    end
    errorbar(data(1).t/60,mg,sdg1)
    hold on
    plot(data(1).t/60,maxg,'-.r')
    plot(data(1).t/60,ming,'-.r')
    title('Glucosa media \pm 1 STD y valores min/max (rojo)'),xlim([data(i).t(1)/60 data(i).t(end)/60]),xlabel('tiempo [horas]'),ylabel('Glucosa en plasma [mg/dl]')
    grid on
    patch([data(1).t(1)/60 data(1).t(1)/60 data(1).t(end)/60 data(1).t(end)/60],[70 180 180 70],'w','FaceColor',[0.5 0.5 0.5],'FaceAlpha',0.2,'EdgeColor',[0.5 0.5 0.5],'EdgeAlpha',0.2)
end

%CVGA
if settings.cvga
    figure('Name','CVGA')
    load CVGA
    imagesc(CVEG)
    set(gca,'Ytick',[10 833 1653 2472],'YtickLabel',[400 300 180 110])
    axis([0 2482 0 2482])
    set(gca,'Xtick',[10 832 1652 2472],'XtickLabel',[110 90 70 50])
    set(gca,'Box','off')
    hold on
    xlabel('[mg/dl]')
    ylabel('[mg/dl]')
% Teniendo en cuenta el 95%
    for i=1:n
        T=data(i).t;
        G=data(i).glucosa;
        [f,x]=ecdf(G);
        mini(i)=min([110 max([50 x(find(f<=0.025,1,'last'))])]);
        maxi(i)=max([110 min([400 x(find(f<=0.975,1,'last'))])]);
        plot(bmin(1)*mini(i)+bmin(2),bmax(1)*maxi(i).^3+bmax(2)*maxi(i).^2+bmax(3)*maxi(i)+bmax(4),'o','MarkerFaceColor',[0 0 0],'DisplayName',data(i).parametros.paciente.names)
    end
%Sin toolbox
%     for i=1:n
%         T=data(i).t;
%         G=data(i).glucosa;
%         mini(i)=min([110 max([50 min(G)])]);
%         maxi(i)=max([110 min([400 max(G)])]);
%         plot(bmin(1)*mini(i)+bmin(2),bmax(1)*maxi(i).^3+bmax(2)*maxi(i).^2+bmax(3)*maxi(i)+bmax(4),'o','MarkerFaceColor',[0 0 0],'DisplayName',data(i).parametros.paciente.names)
%     end

    %plot(bmin(1)*mini+bmin(2),bmax(1)*maxi.^3+bmax(2)*maxi.^2+bmax(3)*maxi+bmax(4),'o','MarkerFaceColor',[0 0 0])
    A=round(100*sum(maxi<=180 & mini>=90)/length(maxi));
    B=round(100*sum((maxi >180 & maxi<=300 & mini>=70) | (mini<90 & maxi<=180 & mini>=70))/length(maxi));
    C=round(100*sum((maxi >300 & mini>=90) | (mini<70 & maxi<=180))/length(maxi));
    D=round(100*sum((maxi >300 & mini<90 & mini>=70) | (mini<70 & maxi>180 & maxi<300))/length(maxi));
    E=round(100*sum((maxi >300 & mini<70))/length(maxi));
    if A+B+C+D+E<100
        t=find(max([A B C D E])==[A B C D E],1,'first');
        switch t
            case 1
                A=A+100-A-B-C-D-E;
            case 2
                B=B+100-A-B-C-D-E;
            case 3
                C=C+100-A-B-C-D-E;
            case 4
                D=D+100-A-B-C-D-E;
            otherwise
        end
    end
    title(['A zone ' num2str(A) '%, B zone ' num2str(B) '%, C zone ' num2str(C) '%, D zone ' num2str(D) '%, E zone ' num2str(E) '%'])
    drawnow 
end
clear sujetos s j n


set(0,'DefaultFigureWindowStyle','normal') 