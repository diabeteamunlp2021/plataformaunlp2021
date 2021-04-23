function [x0] = condiciones_iniciales(parametros,escenario)

%Se recalculan las condiciones iniciales si se cambio los niveles de glucosa en plasma iniciales
if parametros.variacion.varsen||parametros.variacion.visentin
    parametros.paciente.Vmx = parametros.paciente.Vmx(floor(escenario.ti/escenario.paso+1));
    parametros.paciente.kp3 = parametros.paciente.kp3(floor(escenario.ti/escenario.paso+1));
    parametros.paciente.ka1 = parametros.paciente.ka1(floor(escenario.ti/escenario.paso+1));
    parametros.paciente.ka2 = parametros.paciente.ka2(floor(escenario.ti/escenario.paso+1));
    parametros.paciente.kd = parametros.paciente.kd(floor(escenario.ti/escenario.paso+1));
    parametros.paciente.kmax = parametros.paciente.kmax(floor(escenario.ti/escenario.paso+1));
    parametros.paciente.kmin = parametros.paciente.kmin(floor(escenario.ti/escenario.paso+1));
    parametros.paciente.kabs = parametros.paciente.kabs(floor(escenario.ti/escenario.paso+1));
end
    
if ~isempty(escenario.BGini)    
        if escenario.BGini<parametros.paciente.Gb && escenario.BGini>parametros.paciente.Gth
            fGp  = log(escenario.BGini/parametros.paciente.Gb)^parametros.paciente.r2;
            risk = 10*fGp^2;
        elseif escenario.BGini<parametros.paciente.Gth
            fGp  = log(parametros.paciente.Gth/parametros.paciente.Gb)^parametros.paciente.r2;
            risk = 10*fGp^2;
        else
            risk = 0;
        end
        if escenario.BGini*parametros.paciente.Vg>parametros.paciente.ke2
            Et = parametros.paciente.ke1*(escenario.BGini*parametros.paciente.Vg-parametros.paciente.ke2);
        else
            Et = 0;
        end
        Gpop    = escenario.BGini*parametros.paciente.Vg;
        GGta    = -parametros.paciente.k2-parametros.paciente.Vmx*(1+parametros.paciente.r3*risk)*parametros.paciente.k2/parametros.paciente.kp3;
        GGtb    = parametros.paciente.k1*Gpop-parametros.paciente.k2*parametros.paciente.Km0-parametros.paciente.Vm0+parametros.paciente.Vmx*(1+parametros.paciente.r3*risk)*parametros.paciente.Ib+...
                  (parametros.paciente.Vmx*(1+parametros.paciente.r3*risk)*(parametros.paciente.k1+parametros.paciente.kp2)*Gpop-parametros.paciente.Vmx*(1+parametros.paciente.r3*risk)*parametros.paciente.kp1+parametros.paciente.Vmx*(1+parametros.paciente.r3*risk)*(parametros.paciente.Fsnc+Et))/parametros.paciente.kp3;
        GGtc    = parametros.paciente.k1*Gpop*parametros.paciente.Km0;
        Gtop    = (-GGtb-sqrt(GGtb^2-4*GGta*GGtc))/(2*GGta);
        Idop    = max([0 (-(parametros.paciente.k1+parametros.paciente.kp2)*Gpop+parametros.paciente.k2*Gtop+parametros.paciente.kp1-(parametros.paciente.Fsnc+Et))/parametros.paciente.kp3]);
        Ipop    = Idop*parametros.paciente.Vi;
        ILop    = parametros.paciente.m2*Ipop/(parametros.paciente.m1+parametros.paciente.m30); 
        Xop     = Ipop/parametros.paciente.Vi-parametros.paciente.Ib;
        isc1op  = max([0 ((parametros.paciente.m2+parametros.paciente.m4)*Ipop-parametros.paciente.m1*ILop)/(parametros.paciente.ka1+parametros.paciente.kd)]);
        isc2op  = parametros.paciente.kd*isc1op/parametros.paciente.ka2;        
        
        x0 = [0 0 0 Gpop Gtop Ipop Xop Idop Idop ILop isc1op isc2op Gpop parametros.paciente.Gnb 0 parametros.paciente.k01g*parametros.paciente.Gnb 0 0];
else
    x0 = parametros.paciente.x0;  
    x0(13) = parametros.paciente.x0(4); %SCG = Plamsma G
end
