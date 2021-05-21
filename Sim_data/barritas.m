clear,clc

tratamiento1 = load('mpcgsafe_nom_v2');
tratamiento2 = load('mpc_nom_v2');
tratamiento3 = load('mpcgsafe_var_v2');
tratamiento4 = load('mpc_var_v2');
% tratamiento1 = load('MPC+SAFE/pdbgsafe_nom1');
% tratamiento2 = load('MPC+SAFE/pdbsafe_nom1');
% tratamiento3 = load('MPC+SAFE/pdbgsafe_var1');
% tratamiento4 = load('MPC+SAFE/pdbsafe_var1');

Trat1 = tratamiento1.data;
Trat2 = tratamiento2.data;
Trat3 = tratamiento3.data;
Trat4 = tratamiento4.data;

for i=1:length(Trat1)
    Trat1_TBR1(i)    = 100*sum(Trat1(i).glucosa<70)/length(Trat1(i).glucosa);
    Trat1_TBR2(i)    = 100*sum(Trat1(i).glucosa<54)/length(Trat1(i).glucosa);
    Trat1_TAR1(i)    = 100*sum(Trat1(i).glucosa>180)/length(Trat1(i).glucosa);
    Trat1_TAR2(i)    = 100*sum(Trat1(i).glucosa>250)/length(Trat1(i).glucosa);
    Trat2_TBR1(i)    = 100*sum(Trat2(i).glucosa<70)/length(Trat2(i).glucosa);
    Trat2_TBR2(i)    = 100*sum(Trat2(i).glucosa<54)/length(Trat2(i).glucosa);
    Trat2_TAR1(i)    = 100*sum(Trat2(i).glucosa>180)/length(Trat2(i).glucosa);
    Trat2_TAR2(i)    = 100*sum(Trat2(i).glucosa>250)/length(Trat2(i).glucosa);
    Trat3_TBR1(i)    = 100*sum(Trat3(i).glucosa<70)/length(Trat3(i).glucosa);
    Trat3_TBR2(i)    = 100*sum(Trat3(i).glucosa<54)/length(Trat3(i).glucosa);
    Trat3_TAR1(i)    = 100*sum(Trat3(i).glucosa>180)/length(Trat3(i).glucosa);
    Trat3_TAR2(i)    = 100*sum(Trat3(i).glucosa>250)/length(Trat3(i).glucosa);
    Trat4_TBR1(i)    = 100*sum(Trat4(i).glucosa<70)/length(Trat4(i).glucosa);
    Trat4_TBR2(i)    = 100*sum(Trat4(i).glucosa<54)/length(Trat4(i).glucosa);
    Trat4_TAR1(i)    = 100*sum(Trat4(i).glucosa>180)/length(Trat4(i).glucosa);
    Trat4_TAR2(i)    = 100*sum(Trat4(i).glucosa>250)/length(Trat4(i).glucosa);
end

Trat1_TIR        = 100-Trat1_TBR1-Trat1_TAR1;
Trat2_TIR        = 100-Trat2_TBR1-Trat2_TAR1;
Trat3_TIR        = 100-Trat3_TBR1-Trat3_TAR1;
Trat4_TIR        = 100-Trat4_TBR1-Trat4_TAR1;

% figure
% c = bar([mean(Trat1_TBR2),mean(Trat1_TBR1),mean(Trat1_TIR),mean(Trat1_TAR1),mean(Trat1_TAR2);...
%          mean(Trat2_TBR2),mean(Trat2_TBR1),mean(Trat2_TIR),mean(Trat2_TAR1),mean(Trat2_TAR2);...
%          mean(Trat3_TBR2),mean(Trat3_TBR1),mean(Trat3_TIR),mean(Trat3_TAR1),mean(Trat3_TAR2);...
%          mean(Trat4_TBR2),mean(Trat4_TBR1),mean(Trat4_TIR),mean(Trat4_TAR1),mean(Trat4_TAR2)],'stacked');
% 
% xticklabels({'With GSAFE','Without GSAFE'});
% c(1).FaceColor = rgb('FireBrick');
% c(2).FaceColor = rgb('Red');
% c(3).FaceColor = rgb('LimeGreen');
% c(4).FaceColor = rgb('Yellow');
% c(5).FaceColor = rgb('Gold');
% title('MPC controller')

m1 = [  mean(Trat1_TBR2),mean(Trat1_TBR1),mean(Trat1_TIR),mean(Trat1_TAR1),mean(Trat1_TAR2);...
        mean(Trat2_TBR2),mean(Trat2_TBR1),mean(Trat2_TIR),mean(Trat2_TAR1),mean(Trat2_TAR2)];
m2 = [  mean(Trat3_TBR2),mean(Trat3_TBR1),mean(Trat3_TIR),mean(Trat3_TAR1),mean(Trat3_TAR2);...
        mean(Trat4_TBR2),mean(Trat4_TBR1),mean(Trat4_TIR),mean(Trat4_TAR1),mean(Trat4_TAR2)];
m(1,:,:) = m1;
m(2,:,:) = m2;

%% Barritas
b = plotBarStackGroups(m,{'Nominal scenario', 'Realistic scenario'},{'With GSAFE','Without GSAFE'});
b(1,1).FaceColor = rgb('FireBrick');
b(1,2).FaceColor = rgb('Red');
b(1,3).FaceColor = rgb('LimeGreen');
b(1,4).FaceColor = rgb('Yellow');
b(1,5).FaceColor = rgb('Gold');
b(2,1).FaceColor = rgb('FireBrick');
b(2,2).FaceColor = rgb('Red');
b(2,3).FaceColor = rgb('LimeGreen');
b(2,4).FaceColor = rgb('Yellow');
b(2,5).FaceColor = rgb('Gold');
set(gca,'ytick',[])
set(gca,'yticklabel',[])
box on
set(gca,'FontSize',16)
set(gcf,'units','points','position',[10,10,700,700])

xdata(1) =  b(1,1).XData(1);
xdata(2) =  b(2,1).XData(1);
xdata(3) =  b(1,1).XData(2);
xdata(4) =  b(2,1).XData(2);
ydata = [cumsum(m1(1,:),2);cumsum(m1(2,:),2);cumsum(m2(1,:),2);cumsum(m2(2,:),2)];

for jj=1:4
for kk=1:5
    if kk<=2
       ydata(jj,kk)=ydata(jj,kk)+5;
    end
    if jj<=2
        htext = text(xdata(jj),ydata(jj,kk),num2str(m1(jj,kk),'%.2f'));
        set(htext, 'VerticalAlignment','top', 'HorizontalAlignment', 'center','FontSize',14,'fontweight','bold','Color','k');
    else
        htext = text(xdata(jj),ydata(jj,kk),num2str(m2(jj-2,kk),'%.2f'));
        set(htext, 'VerticalAlignment','top', 'HorizontalAlignment', 'center','FontSize',14,'fontweight','bold','Color','k');
    end
end
end



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Nominal tuning 
% 
% hipo_nom  = [.54 1.81; .33 2.23];
% targ_nom  = [76.43 77.11; 69.93 73.37];
% hiper_nom = [23.03 21.08; 29.75 24.4];
% 
% hipo_agg  = [3 7.69; 2.96 6.22];
% targ_agg  = [79.62 76.01; 74.8 74.77]; 
% hiper_agg = [17.37 16.3; 22.25 19.01];
% 
% 
% figure
% 
% %nominal
% subplot(2,3,1)
% b = bar(hipo_nom);
% xticklabels({'Nominal','Realistic'});
% b(1).FaceColor = rgb('DarkTurquoise');
% b(2).FaceColor = rgb('DarkMagenta');
% title('%time in hypoglycemia')
% ylim([0 8])
% 
% subplot(2,3,2)
% b = bar(targ_nom);
% b(1).FaceColor = rgb('DarkTurquoise');
% b(2).FaceColor = rgb('DarkMagenta');
% xticklabels({'Nominal','Realistic'});
% title('%time in range')
% ylim([0 80])
% 
% subplot(2,3,3)
% b = bar(hiper_nom);
% b(1).FaceColor = rgb('DarkTurquoise');
% b(2).FaceColor = rgb('DarkMagenta');
% xticklabels({'Nominal','Realistic'});
% title('%time in hyperglycemia')
% ylim([0 30])
% 
% %aggressive
% subplot(2,3,4)
% b = bar(hipo_agg);
% b(1).FaceColor = rgb('DarkTurquoise');
% b(2).FaceColor = rgb('DarkMagenta');
% xticklabels({'Nominal','Realistic'});
% title('%time in hypoglycemia')
% ylim([0 8])
% 
% subplot(2,3,5)
% b = bar(targ_agg);
% b(1).FaceColor = rgb('DarkTurquoise');
% b(2).FaceColor = rgb('DarkMagenta');
% xticklabels({'Nominal','Realistic'});
% title('%time in range')
% ylim([0 80])
% 
% subplot(2,3,6)
% b = bar(hiper_agg);
% b(1).FaceColor = rgb('DarkTurquoise');
% b(2).FaceColor = rgb('DarkMagenta');
% xticklabels({'Nominal','Realistic'});
% title('%time in hyperglycemia')
% ylim([0 30])
