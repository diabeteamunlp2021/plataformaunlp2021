function [sujetos, bombas, sensores, v] = subj_disp_loader()

sujeto = what('Pacientes'); %lista de archivos MATLAB segun tipo dentro de la carpeta
   
list       = strrep(sujeto.mat,'.mat','');

%Tutti
 [s,v]      = listdlg('ListString',list,'SelectionMode','multiple','Name','Simulador UNLP','PromptString','Lista de pacientes a simular','InitialValue',1:30); % Interfaz gáfica
 sujetos     = list(s); % Arreglo de strings con el nombre de cada archivo correspondiente a los pacientes

%Solo adultos
%adult_list = list(strncmp('adult',list,5)); % Extraigo los adultos de la lista
%[s,v]      = listdlg('ListString',adult_list,'SelectionMode','multiple','Name','Simulador UNLP','PromptString','Lista de pacientes a simular','InitialValue',[1]); % Interfaz gáfica
%sujetos    = adult_list(s); % Arreglo de strings con el nombre de cada archivo correspondiente a los pacientes

aux      = struct2cell(dir('Hardware/*.pmp'));
bombas   = char(aux(1,:));
aux      = struct2cell(dir('Hardware/*.scs'));
sensores = char(aux(1,:));

end