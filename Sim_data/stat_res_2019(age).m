clear,clc
%Script de análisis estadístico y comapración entre 2 tratamientos

tratamiento1 = load('mpcgsafe_var_v2');
tratamiento2 = load('mpc_var_v2');
% tratamiento1 = load('mpcgsafe_nom_v2');
% tratamiento2 = load('mpc_nom_v2');
% tratamiento1 = load('pdbgsafe_var1');
% tratamiento2 = load('pdbsafe_var1');
% tratamiento1 = load('pdbgsafe_nom1');
% tratamiento2 = load('pdbsafe_nom1');

%%
patients(1,:) = 1:11;
patients(2,:) = 12:22;
patients(3,:) = 23:33;

A(1,:) = {'','Mean BG','BG variability','BG$<$54 mg/dl','BG$<$70 mg/dl','BG$\in$ [70,180]mg/dl','BG$>$180 mg/dl','BG$>$250 mg/dl'};
A(2,:) = {'','(mg/dl)','(\%CV)','(\%time)','(\%time)','(\%time)','(\%time)','(\%time)'};
A(3,1) = {'\hline \multicolumn{8}{l}{\textbf{Children}}'}; 
A(4,1) = {'With GSAFE'}; 
A(5,1) = {'Without GSAFE'};  
A(6,1) = {'$\rho$ - value'};
A(7,1) = {'\hline \multicolumn{8}{l}{\textbf{Adolescents}}'}; 
A(8,1) = {'With GSAFE'}; 
A(9,1) = {'Without GSAFE'};  
A(10,1) = {'$\rho$ - value'};
A(11,1) = {'\hline \multicolumn{8}{l}{\textbf{Adults}}'}; 
A(12,1) = {'With GSAFE'}; 
A(13,1) = {'Without GSAFE'};  
A(14,1) = {'$\rho$ - value'};

for kk = 1:3

Trat1 = tratamiento1.data(patients(kk,:));
Trat2 = tratamiento2.data(patients(kk,:));

%Evaluation metrics based on consensus report Battelino et al. 2019
for i=1:length(Trat1)
    Trat1_TBR1(i)    = 100*sum(Trat1(i).glucosa<70)/length(Trat1(i).glucosa);
    Trat1_TBR2(i)    = 100*sum(Trat1(i).glucosa<54)/length(Trat1(i).glucosa);
    Trat1_TAR1(i)    = 100*sum(Trat1(i).glucosa>180)/length(Trat1(i).glucosa);
    Trat1_TAR2(i)    = 100*sum(Trat1(i).glucosa>250)/length(Trat1(i).glucosa);
    Trat2_TBR1(i)    = 100*sum(Trat2(i).glucosa<70)/length(Trat2(i).glucosa);
    Trat2_TBR2(i)    = 100*sum(Trat2(i).glucosa<54)/length(Trat2(i).glucosa);
    Trat2_TAR1(i)    = 100*sum(Trat2(i).glucosa>180)/length(Trat2(i).glucosa);
    Trat2_TAR2(i)    = 100*sum(Trat2(i).glucosa>250)/length(Trat2(i).glucosa);
    Trat1_gmedia(i)  = mean(Trat1(i).glucosa);
    Trat2_gmedia(i)  = mean(Trat2(i).glucosa);
    Trat1_gsd(i)     = std(Trat1(i).glucosa);
    Trat2_gsd(i)     = std(Trat2(i).glucosa);
    Trat1_G(i,:)     = Trat1(i).glucosa;
    Trat2_G(i,:)     = Trat2(i).glucosa;
end

Trat2_target        = 100-Trat2_TBR1-Trat2_TAR1;
Trat1_target        = 100-Trat1_TBR1-Trat1_TAR1;
Trat1_mg            = mean(Trat1_G,1);
Trat2_mg            = mean(Trat2_G,1);
Trat1_CV            = Trat1_gsd./Trat1_gmedia*100;
Trat2_CV            = Trat2_gsd./Trat2_gmedia*100;
Trat1_glucose_mean  = mean(Trat1_mg);
Trat1_glucose_SD    = std(Trat1_mg);
Trat2_glucose_mean  = mean(Trat2_mg);
Trat2_glucose_SD    = std(Trat2_mg);

%Wilcoxon signed rank test for zero median
[p_mean,h_mean]     = signrank(Trat2_gmedia,Trat1_gmedia,'Alpha',0.05,'method','exact');
[p_TBR2,h_TBR2]     = signrank(Trat2_TBR2,Trat1_TBR2,'Alpha',0.05,'method','exact');
[p_TBR1,h_TBR1]     = signrank(Trat2_TBR1,Trat1_TBR1,'Alpha',0.05,'method','exact');
[p_TAR2,h_TAR2]     = signrank(Trat2_TAR2,Trat1_TAR2,'Alpha',0.05,'method','exact');
[p_TAR1,h_TAR1]     = signrank(Trat2_TAR1,Trat1_TAR1,'Alpha',0.05,'method','exact');
[p_CV,h_CV]         = signrank(Trat2_CV,Trat1_CV,'Alpha',0.05,'method','exact');
[p_target,h_target] = signrank(Trat2_target,Trat1_target,'Alpha',0.05,'method','exact');

%Estructura de strings con los resultados
res(kk).Trat1.MeanBG    = [num2str(round(100*Trat1_glucose_mean)/100),' $\pm$ ',num2str(round(100*Trat1_glucose_SD)/100)];
res(kk).Trat2.MeanBG    = [num2str(round(100*Trat2_glucose_mean)/100),' $\pm$ ',num2str(round(100*Trat2_glucose_SD)/100)];
res(kk).Trat1.CV        = [num2str(round(100*Trat1_glucose_SD/Trat1_glucose_mean))];
res(kk).Trat2.CV        = [num2str(round(100*Trat2_glucose_SD/Trat2_glucose_mean))];
res(kk).Trat1.TBR1      = [num2str(round(100*mean(Trat1_TBR1))/100),' $\pm$ ',num2str(round(100*std(Trat1_TBR1))/100)];
res(kk).Trat2.TBR1      = [num2str(round(100*mean(Trat2_TBR1))/100),' $\pm$ ',num2str(round(100*std(Trat2_TBR1))/100)];
res(kk).Trat1.TBR2      = [num2str(round(100*mean(Trat1_TBR2))/100),' $\pm$ ',num2str(round(100*std(Trat1_TBR2))/100)];
res(kk).Trat2.TBR2      = [num2str(round(100*mean(Trat2_TBR2))/100),' $\pm$ ',num2str(round(100*std(Trat2_TBR2))/100)];
res(kk).Trat1.target    = [num2str(round(100*mean(Trat1_target))/100),' $\pm$ ',num2str(round(100*std(Trat1_target))/100)];
res(kk).Trat2.target    = [num2str(round(100*mean(Trat2_target))/100),' $\pm$ ',num2str(round(100*std(Trat2_target))/100)];
res(kk).Trat1.TAR1      = [num2str(round(100*mean(Trat1_TAR1))/100),' $\pm$ ',num2str(round(100*std(Trat1_TAR1))/100)];
res(kk).Trat2.TAR1      = [num2str(round(100*mean(Trat2_TAR1))/100),' $\pm$ ',num2str(round(100*std(Trat2_TAR1))/100)];
res(kk).Trat1.TAR2      = [num2str(round(100*mean(Trat1_TAR2))/100),' $\pm$ ',num2str(round(100*std(Trat1_TAR2))/100)];
res(kk).Trat2.TAR2      = [num2str(round(100*mean(Trat2_TAR2))/100),' $\pm$ ',num2str(round(100*std(Trat2_TAR2))/100)];
res(kk).p_mean          = num2str(round(1000*p_mean)/1000);
res(kk).p_CV            = num2str(round(1000*p_CV)/1000);
res(kk).p_TBR2          = num2str(round(1000*p_TBR2)/1000);
res(kk).p_TBR1          = num2str(round(1000*p_TBR1)/1000);    
res(kk).p_target        = num2str(round(1000*p_target)/1000);
res(kk).p_TAR1          = num2str(round(1000*p_TAR1)/1000);
res(kk).p_TAR2          = num2str(round(1000*p_TAR2)/1000);

A(kk*4,2:8) = {res(kk).Trat1.MeanBG,res(kk).Trat1.CV,res(kk).Trat1.TBR2,res(kk).Trat1.TBR1,res(kk).Trat1.target,res(kk).Trat1.TAR1,res(kk).Trat1.TAR2};
A(kk*4+1,2:8) = {res(kk).Trat2.MeanBG,res(kk).Trat2.CV,res(kk).Trat2.TBR2,res(kk).Trat2.TBR1,res(kk).Trat2.target,res(kk).Trat2.TAR1,res(kk).Trat2.TAR2};
A(kk*4+2,2:8) = {res(kk).p_mean,res(kk).p_CV,res(kk).p_TBR2,res(kk).p_TBR1,res(kk).p_target,res(kk).p_TAR1,res(kk).p_TAR2};

for ii=1:size(A,1)
    for jj=0:size(A,2)-1
        if strncmp(A(ii,jj+1),'\hline',6)
            C(ii,2*jj+1)   = A(ii,jj+1);
            break 
        end
        if any(ii==[6 10 14])&&(str2double(A(ii,jj+1))<0.05)
            if (str2double(A(ii,jj+1))<0.01)
                C(ii,2*jj+1)   = {'$<0.01^\star$'};
            else
                C(ii,2*jj+1)   = strcat(A(ii,jj+1),'$^\star$');
            end
            C(ii,2*jj+2) = {'&'};
        else
            C(ii,2*jj+1)   = A(ii,jj+1);
            C(ii,2*jj+2) = {'&'};
        end        
    end
    C(ii,2*jj+2) = {'\\'};
end

end
%%
disp('Escribiendo tabla')
xlswrite('mpc_var_v2',C);
disp('Listo el pollo')
