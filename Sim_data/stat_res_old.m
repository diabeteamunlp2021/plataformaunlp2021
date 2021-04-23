clear,clc
%%
%Script de análisis estadístico y comapración entre 2 tratamientos

tratamiento1 = load('sim_withGSAFE_IFB_agr_lc_nom');
tratamiento2 = load('sim_withoutGSAFE_IFB_agr_lc_nom');
Trat1 = tratamiento1.data;
Trat2 = tratamiento2.data;

%Evaluation metrics based on consensus report Maahs et al. 2016
for i=1:length(Trat1)
    Trat1_hipo1(i)     = 100*sum(Trat1(i).glucosa<70)/length(Trat1(i).glucosa);
    Trat1_hipo2(i)     = 100*sum(Trat1(i).glucosa<60)/length(Trat1(i).glucosa);
    Trat1_hipo3(i)     = 100*sum(Trat1(i).glucosa<50)/length(Trat1(i).glucosa);
    Trat1_hiper1(i)    = 100*sum(Trat1(i).glucosa>180)/length(Trat1(i).glucosa);
    Trat1_hiper2(i)    = 100*sum(Trat1(i).glucosa>250)/length(Trat1(i).glucosa);
    Trat1_hiper3(i)    = 100*sum(Trat1(i).glucosa>300)/length(Trat1(i).glucosa);
    Trat2_hipo1(i)     = 100*sum(Trat2(i).glucosa<70)/length(Trat2(i).glucosa);
    Trat2_hipo2(i)     = 100*sum(Trat2(i).glucosa<60)/length(Trat2(i).glucosa);
    Trat2_hipo3(i)     = 100*sum(Trat2(i).glucosa<50)/length(Trat2(i).glucosa);
    Trat2_hiper1(i)    = 100*sum(Trat2(i).glucosa>180)/length(Trat2(i).glucosa);
    Trat2_hiper2(i)    = 100*sum(Trat2(i).glucosa>250)/length(Trat2(i).glucosa);
    Trat2_hiper3(i)    = 100*sum(Trat2(i).glucosa>300)/length(Trat2(i).glucosa); 
    Trat1_gmedia(i)    = mean(Trat1(i).glucosa);
    Trat2_gmedia(i)    = mean(Trat2(i).glucosa);
    Trat1_G(i,:)       = Trat1(i).glucosa;
    Trat2_G(i,:)       = Trat2(i).glucosa;
end

Trat1_mg            = mean(Trat1_G,1);
Trat2_mg            = mean(Trat2_G,1);
Trat1_glucose_mean  = mean(Trat1_mg);
Trat1_glucose_SD    = std(Trat1_mg);
Trat2_glucose_mean  = mean(Trat2_mg);
Trat2_glucose_SD    = std(Trat2_mg);

Trat2_target = 100-Trat2_hipo1-Trat2_hiper1;
Trat1_target = 100-Trat1_hipo1-Trat1_hiper1;

%Wilcoxon signed rank test for zero median
[p_mean,h_mean]     = signrank(Trat2_gmedia,Trat1_gmedia,'Alpha',0.05);
[p_hipo3,h_hipo3]   = signrank(Trat2_hipo3,Trat1_hipo3,'Alpha',0.05);
[p_hipo2,h_hipo2]   = signrank(Trat2_hipo2,Trat1_hipo2,'Alpha',0.05);
[p_hipo1,h_hipo1]   = signrank(Trat2_hipo1,Trat1_hipo1,'Alpha',0.05);
[p_hiper3,h_hiper3] = signrank(Trat2_hiper3,Trat1_hiper3,'Alpha',0.05);
[p_hiper2,h_hiper2] = signrank(Trat2_hiper2,Trat1_hiper2,'Alpha',0.05);
[p_hiper1,h_hiper1] = signrank(Trat2_hiper1,Trat1_hiper1,'Alpha',0.05);
[p_target,h_target] = signrank(Trat2_target,Trat1_target,'Alpha',0.05);

%% Tabla excel para Latex

%Estructura de strings con los resultados
res.Trat1.MeanBG = [num2str(round(100*Trat1_glucose_mean)/100),' $\pm$ ',num2str(round(100*Trat1_glucose_SD)/100)];
res.Trat2.MeanBG = [num2str(round(100*Trat2_glucose_mean)/100),' $\pm$ ',num2str(round(100*Trat2_glucose_SD)/100)];
res.Trat1.hipo1  = [num2str(round(100*mean(Trat1_hipo1))/100),' $\pm$ ',num2str(round(100*std(Trat1_hipo1))/100)];
res.Trat2.hipo1  = [num2str(round(100*mean(Trat2_hipo1))/100),' $\pm$ ',num2str(round(100*std(Trat2_hipo1))/100)];
res.Trat1.hipo2  = [num2str(round(100*mean(Trat1_hipo2))/100),' $\pm$ ',num2str(round(100*std(Trat1_hipo2))/100)];
res.Trat2.hipo2  = [num2str(round(100*mean(Trat2_hipo2))/100),' $\pm$ ',num2str(round(100*std(Trat2_hipo2))/100)];
res.Trat1.hipo3  = [num2str(round(100*mean(Trat1_hipo3))/100),' $\pm$ ',num2str(round(100*std(Trat1_hipo3))/100)];
res.Trat2.hipo3  = [num2str(round(100*mean(Trat2_hipo3))/100),' $\pm$ ',num2str(round(100*std(Trat2_hipo3))/100)];
res.Trat1.target  = [num2str(round(100*mean(Trat1_target))/100),' $\pm$ ',num2str(round(100*std(Trat1_target))/100)];
res.Trat2.target  = [num2str(round(100*mean(Trat2_target))/100),' $\pm$ ',num2str(round(100*std(Trat2_target))/100)];
res.Trat1.hiper1  = [num2str(round(100*mean(Trat1_hiper1))/100),' $\pm$ ',num2str(round(100*std(Trat1_hiper1))/100)];
res.Trat2.hiper1  = [num2str(round(100*mean(Trat2_hiper1))/100),' $\pm$ ',num2str(round(100*std(Trat2_hiper1))/100)];
res.Trat1.hiper2  = [num2str(round(100*mean(Trat1_hiper2))/100),' $\pm$ ',num2str(round(100*std(Trat1_hiper2))/100)];
res.Trat2.hiper2  = [num2str(round(100*mean(Trat2_hiper2))/100),' $\pm$ ',num2str(round(100*std(Trat2_hiper2))/100)];
res.Trat1.hiper3  = [num2str(round(100*mean(Trat1_hiper3))/100),' $\pm$ ',num2str(round(100*std(Trat1_hiper3))/100)];
res.Trat2.hiper3  = [num2str(round(100*mean(Trat2_hiper3))/100),' $\pm$ ',num2str(round(100*std(Trat2_hiper3))/100)];

%%
A(1,:) = {'','Mean BG','BG$<$50 mg/dl','BG$<$60 mg/dl','BG$<$70 mg/dl','BG$\in$ [70,180]mg/dl','BG$>$180 mg/dl','BG$>$250 mg/dl','BG$>$300 mg/dl'};
A(2,:) = {'','(mg/dl)','(\%time)','(\%time)','(\%time)','(\%time)','(\%time)','(\%time)','(\%time)'};
A(3,1) = {'Treatment 1'}; 
A(4,1) = {'Treatment 2'};  
A(5,1) = {'$\rho$ - value'};
A(3,2:9) = {res.Trat1.MeanBG,res.Trat1.hipo3,res.Trat1.hipo2,res.Trat1.hipo1,res.Trat1.target,res.Trat1.hiper1,res.Trat1.hiper2,res.Trat1.hiper3};
A(4,2:9) = {res.Trat2.MeanBG,res.Trat2.hipo3,res.Trat2.hipo2,res.Trat2.hipo1,res.Trat2.target,res.Trat2.hiper1,res.Trat2.hiper2,res.Trat2.hiper3};
A(5,2:9) = {num2str(round(1000*p_mean)/1000),num2str(round(1000*p_hipo3)/1000),num2str(round(1000*p_hipo2)/1000),num2str(round(1000*p_hipo1)/1000),num2str(round(1000*p_target)/1000),num2str(round(1000*p_hiper1)/1000),num2str(round(1000*p_hiper2)/1000),num2str(round(1000*p_hiper3)/1000)};

%%
for ii=1:size(A,1)
    for jj=0:size(A,2)-1
        if (ii==5)&&(str2double(A(ii,jj+1))<0.05)
            C(ii,2*jj+1)   = strcat(A(ii,jj+1),'$^\star$');
            C(ii,2*jj+2) = {'&'};
        else
            C(ii,2*jj+1)   = A(ii,jj+1);
            C(ii,2*jj+2) = {'&'};
        end
    end
    C(ii,2*jj+2) = {'\\'};
end

xlswrite('lc_agr_nom',C);

%%
B = A';
for ii=1:size(B,1)
    for jj=0:size(B,2)-1
        if (jj==5)&&(str2double(B(ii,jj+1))<0.05)
            C(ii,2*jj+1) = strcat(B(ii,jj+1),'$^\star$');
            C(ii,2*jj+2) = {'\\'};
        else
            C(ii,2*jj+1)   = B(ii,jj+1);
            C(ii,2*jj+2) = {'&'};
        end
    end
    C(ii,2*jj+2) = {'\\'};
end

