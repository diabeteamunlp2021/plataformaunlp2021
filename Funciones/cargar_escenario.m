%=======================================================================
% cargar_escenario
%
%   @Description:
%               Funcion encargada de interpretar lineas de texto del archivo
%               dentro de la carpeta "/Escenarios", las cuales son
%               configuraciones necesarias para la simulacion.
%               Configuracion del Escenario.
%
%   @param:     -escenario:          struct(string,array)
%
%   @return:    -escenario:          struct(string,array)
%=======================================================================
function [escenario] = cargar_escenario(escenario)

%default values
Gtarget      = [];
LAoptimo     = [];
sensibilidad = [];
QTmeals      = 1;
QTbolus      = 1;
basal        = [];
Tbolus       = [];
Abolus       = [];
Tmeals       = [];
Ameals       = [];
TIVD         = 0;
AIVD         = 0;
TIVINS       = 0;
AIVINS       = 0;
Dmeals       = 15;
deltat       = 0;
BGinit       = [];
Tcomix       = [];
comix        = [];
edosis       = [];
endoglucagon = 0;

%read file
content=textread(['Escenarios\' escenario.nombre],'%s','delimiter','\n');

%loop on the read lines, identify known headers, and extract data if need
%be
n=length(content);
if n~=0
    for i=1:n
        line=content{i};
        if ~isempty(line)
            if strcmp(line(1),'%')
                line=line(2:end);
                
                if ~isempty(strfind(line,'QTmeals'))
                    p=strfind(line,'QTmeals');
                    p2=1+strfind(line(p:end),'=');
                    QTmeals=(line(p-1+p2:end));
                    switch QTmeals
                        case 'min'
                            QTmeals=1;
                        case 'hour'
                            QTmeals=60;
                        case 'day'
                            QTmeals=1440;
                        otherwise
                            display('bad meal times units, using minutes')
                            QTmeals=1;
                    end
                elseif ~isempty(strfind(line,'Tmeals'))
                    p=strfind(line,'Tmeals');
                    p2=1+strfind(line(p:end),'=');
                    Tmeals=str2num(str2mat(line(p-1+p2:end)));

                elseif ~isempty(strfind(line,'Dmeals'))
                    p=strfind(line,'Dmeals');
                    p2=1+strfind(line(p:end),'=');
                    Dmeals=str2num(str2mat(line(p-1+p2:end)));
                    
                elseif ~isempty(strfind(line,'QTbolus'))
                    p=strfind(line,'QTbolus');
                    p2=1+strfind(line(p:end),'=');
                    QTbolus=line(p-1+p2:end);
                    switch QTbolus
                        case 'min'
                            QTbolus=1;
                        case 'hour'
                            QTbolus=60;
                        case 'day'
                            QTbolus=1440;
                        otherwise
                            display('bad bolus times units, using minutes');
                    end
                elseif ~isempty(strfind(line,'Tbolus'))
                    p=strfind(line,'Tbolus');
                    p2=1+strfind(line(p:end),'=');
                    Tbolus=str2num(str2mat(line(p-1+p2:end)));
                    
                elseif ~isempty(strfind(line,'Ameals'))
                    p=strfind(line,'Ameals');
                    p2=1+strfind(line(p:end),'=');
                    Ameals=str2num(str2mat(line(p-1+p2:end)))*1e3;
                    
                elseif ~isempty(strfind(line,'varcomida'))                    
                    p=strfind(line,'varcomida');
                    p2=1+strfind(line(p:end),'=');                 
                    varcomida=str2double(line(p-1+p2:end));                    
                    
                elseif ~isempty(strfind(line,'Abolus'))
                    p=strfind(line,'Abolus');
                    p2=1+strfind(line(p:end),'=');
                    Abolus=str2num(str2mat(line(p-1+p2:end)));                    
                
                elseif ~isempty(strfind(line,'basal'))                    
                    p=strfind(line,'basal');
                    p2=1+strfind(line(p:end),'=');                 
                    basal=str2double(line(p-1+p2:end));
                    if basal<0 || isnan(basal)
                        display('negative or badly formatted basal rate, using subject specific basal instead');
                        basal=[];
                    end
                    
                elseif ~isempty(strfind(line,'TIVINS'))
                    p=strfind(line,'TIVINS');
                    p2=1+strfind(line(p:end),'=');
                    TIVINS=str2num(str2mat(line(p-1+p2:end)));
                    
                elseif ~isempty(strfind(line,'AIVINS'))
                    p=strfind(line,'AIVINS');
                    p2=1+strfind(line(p:end),'=');
                    AIVINS=str2num(str2mat(line(p-1+p2:end)));                   
                    
                elseif ~isempty(strfind(line,'TIVD'))
                    p=strfind(line,'TIVD');
                    p2=1+strfind(line(p:end),'=');
                    TIVD=str2num(str2mat(line(p-1+p2:end)));
                    
                elseif ~isempty(strfind(line,'AIVD'))
                    p=strfind(line,'AIVD');
                    p2=1+strfind(line(p:end),'=');
                    AIVD=str2num(str2mat(line(p-1+p2:end)));
                    
                elseif ~isempty(strfind(line,'deltat'))
                    p=strfind(line,'deltat');
                    p2=1+strfind(line(p:end),'=');
                    deltat=str2double(line(p-1+p2:end));
                    
                elseif ~isempty(strfind(line,'BGinit'))
                    p=strfind(line,'BGinit');
                    p2=1+strfind(line(p:end),'=');
                    BGinit=str2double(line(p-1+p2:end));
                    if ~isa(BGinit,'numeric') || isnan(BGinit)
                        display('bad formatting of initial glucose, using patient fasting state')
                        BGinit=[];
                    end
                    
                elseif ~isempty(strfind(line,'LAoptimo'))
                    p=strfind(line,'LAoptimo');
                    p2=1+strfind(line(p:end),'=');
                    LAoptimo=line(p-1+p2:end);
                    if ~strcmp(LAoptimo,'on')
                        LAoptimo='off';
                    end
                    
                elseif ~isempty(strfind(line,'sensibilidad'))
                    p=strfind(line,'sensibilidad');
                    p2=1+strfind(line(p:end),'=');
                    sensibilidad=str2double(line(p-1+p2:end));
                    
                elseif ~isempty(strfind(line,'Gtarget'))
                    p=strfind(line,'Gtarget');
                    p2=1+strfind(line(p:end),'=');
                    Gtarget=str2double(line(p-1+p2:end));
                    
                elseif ~isempty(strfind(line,'Tcomix'))
                    p=strfind(line,'Tcomix');
                    p2=1+strfind(line(p:end),'=');
                    Tcomix=str2num(str2mat(line(p-1+p2:end)));

                elseif ~isempty(strfind(line,'comix'))
                    p=strfind(line,'comix');
                    p2=1+strfind(line(p:end),'=');
                    comix=str2num(str2mat(line(p-1+p2:end)));
                end
            end
        end
    end
%--------------------------------------------------------------------------
    %check that size of time and value vectorsz are equal and set defaults
    if ~isempty(Dmeals)
        if length(Dmeals)==1
            Dmeals=Dmeals*ones(size(Tmeals));
        end
    else
        Dmeals=15*ones(size(Tmeals));
    end
    meal_check=isempty(find((size(Tmeals)==size(Ameals))==0,1)) && ...
        isempty(find((size(Tmeals)==size(Dmeals))==0,1)) && ...
        isempty(find((size(TIVD)==size(AIVD))==0,1));
    bolus_check=isempty(find((size(Tbolus)==size(Abolus))==0,1)) && ...
        isempty(find((size(TIVINS)==size(AIVINS))==0,1));

    if meal_check && bolus_check        

        if min(Tmeals)<=0
            Tmeals(Tmeals<=0)=1;
            warning_message('string',...
                'meal detected before or at t=0, time changed to t=1');
        end
        if min(Ameals)<=0
            Ameals(Ameals<=0)=0;
            warning_message('string','negative meals were deleted');
        end

        [Tmeals,ind]=sort(QTmeals*Tmeals);
        Ameals=Ameals(ind);

        if min(Tbolus)<=0
            Tbolus(Tbolus<=0)=1;
            warning_message('string',...
                'boluses detected before or at t=0, time changed to t=1');
        end
        if min(Abolus)<=0
            Abolus(Abolus<=0)=0;
            warning_message('string','negative boluses were deleted');
        end
        [Tbolus,ind]=sort(QTbolus*Tbolus);
        Abolus=Abolus(ind);

    else
        error('The meals and/or bolus time and values vectors in the file do not match')
    end
    
    if isempty(BGinit) && ~isempty(Gtarget)
        BGinit = Gtarget;
    end
    
    escenario.Tcomida       = Tmeals;
    escenario.comida        = Ameals;
    escenario.durcomida     = Dmeals;
    escenario.Tcomix        = Tcomix;
    escenario.comix         = comix;
    escenario.BGinit        = BGinit;
    escenario.Tbolos        = Tbolus;
    escenario.bolos         = Abolus;
    escenario.basal         = basal;
    escenario.Tivd          = TIVD;
    escenario.ivd           = AIVD;
    escenario.Tivins        = TIVINS;
    escenario.ivins         = AIVINS;
    escenario.Gtarget       = Gtarget;
    escenario.BGini         = BGinit;
    escenario.LAoptimo      = LAoptimo;
    escenario.deltat        = deltat;
    escenario.sensibilidad  = sensibilidad;
    escenario.edosis        = edosis;
    escenario.endoglucagon  = endoglucagon;
    
else
    error('string', 'The file is empty or not in the proper directory')
end