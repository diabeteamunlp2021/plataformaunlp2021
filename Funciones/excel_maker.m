%=======================================================================
% **excel_maker**
%
%   @Description:
%               Funcion encargada de generar un archivo con extencion .xsl
%               (excel)con los datos de salida.
%               
%
%   @param:     -archivo:            filename
%
%   @return:    none
%=======================================================================
function [] = excel_maker(archivo)
load(archivo);
n=length(resultados);
cd Sim_data
comp=fopen([archivo '.xls']);
if comp~=-1
    fclose(comp);
    if size(xlsread([archivo '.xls']),1)>0
        filename = cd;
        filename = strcat(filename,['\' archivo '.xls']);
        %Open Excel as a COM Automation server
        Excel = actxserver('Excel.Application');
        %Open Excel workbook
        Workbook = Excel.Workbooks.Open(filename);
        %Clear the content of the sheet
        tam = strcat('A2:H',num2str(size(xlsread([archivo '.xls']),1)+1));
        Workbook.Worksheets.Item('Hoja1').Range(tam).ClearContents;  
        %Now save/close/quit/delete
        Workbook.Save;
        Excel.Workbook.Close;
        invoke(Excel, 'Quit');
        delete(Excel);    
    end
end

A = {'Paciente','Glucosa media','Glucosa máxima','Glucosa mínima','Excursión','# hipos','Tiempo en hipo %','Tiempo en hiper %'};
for i=1:n   
    A(i+1,:) = {resultados(i).paciente,round(resultados(i).gmedia*100)/100,round(100*resultados(i).gmax)/100,...
        round(100*resultados(i).gmin)/100,round(100*resultados(i).exc)/100,resultados(i).numhipos,...
        round(100*resultados(i).hipo)/100,round(100*resultados(i).hiper)/100};    
end
xlswrite(archivo,A);
cd ..    
end