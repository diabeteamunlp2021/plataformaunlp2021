%=======================================================================
% **t1dm_unlp**
%   @Description:
%
%   @param:     -t:             number
%               -x:             number
%               -u:             number
%               -flag:          number
%               -parametros:
%               -escenario:
%
%   @return:    -sys:           functions
%               -x0:
%               -str:
%               -ts:
%=======================================================================

function [sys,x0,str,ts] = t1dm_unlp(t,x,u,flag,parametros,escenario)
% x(1) Carbs in first phase of stomach (mg).
% x(2) Carbs in second phase of stomach (mg).
% x(3) Carbs in intestine (mg).
% x(4) Glucose in plasma and insulin-independent tissues (mg/kg).
% x(5) Glucose in insulin-dependent tissues (mg/kg).
% x(6) Insulin in plasma (pmol/kg).
% x(7) Insulin action, X (pmol/L).
% x(8) Delay compartment for insulin action on glucose production (pmol/L).
% x(9) Insulin action on glucose production, Id (pmol/L).
% x(10) Insulin in the liver (pmol/kg).
% x(11) Insulin in first subcutaneous compartment (pmol/kg)
% x(12) Insulin in second subcutaneous compartment (pmol/kg)
% x(13) Subcutaneous glucose (mg/kg)
% x(14) Plasma glucagon (ng/l)
% x(15) Glucagon action (ng/dl)
% x(16) Delayed static glucagon secretion (mg/kg per min)
% x(17) Glucagon in first subcutaneous compartment (mg/kg)
% x(18) Glucagon in second subcutaneous compartment (mg/kg)

% u(1) CHO (mg/min)  
% u(2) SQ insulin (pmol/Kg per min)
% u(3) SQ glucagon (mg/Kg per min)
% u(4) IV insulin
% u(5) IV dextrose
% u(6) Mixed Meals

switch flag,

    %%%%%%%%%%%%%%%%%%
    % Initialization %
    %%%%%%%%%%%%%%%%%%
    case 0,
        [sys,x0,str,ts]=mdlInitializeSizes(parametros);

        %%%%%%%%%%%%%%%
        % Derivatives %
        %%%%%%%%%%%%%%%
    case 1,
        sys = mdlDerivatives(t,x,u,parametros,escenario);

        %%%%%%%%%%
        % Output %
        %%%%%%%%%%
    case 3,
        sys = mdlOutputs(t,x,u,parametros);

        %%%%%%%%%%%%%%%%%%%
        % Unhandled flags %
        %%%%%%%%%%%%%%%%%%%
    case { 2, 4, 9 },
        sys = [];

        %%%%%%%%%%%%%%%%%%%%
        % Unexpected flags %
        %%%%%%%%%%%%%%%%%%%%
    otherwise
        error(['Unhandled flag = ',num2str(flag)]);

end

%end sfundsc1

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(parametros)
sizes = simsizes;

sizes.NumContStates  = 18;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 2;
sizes.NumInputs      = 6;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;



sys = simsizes(sizes);
x0  = parametros.paciente.x0;
str = [];
ts  = [0 0];

% end mdlInitializeSizes

%
%=======================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=======================================================================
%
function sys=mdlDerivatives(t,x,u,parametros,escenario)

persistent qstoatmealtime; 

%Intra-patient variability
if parametros.variacion.varsen||parametros.variacion.visentin  
    parametros.paciente.Vmx = parametros.paciente.Vmx(floor(t/escenario.paso+1));
    parametros.paciente.kp3 = parametros.paciente.kp3(floor(t/escenario.paso+1));
    parametros.paciente.ka1 = parametros.paciente.ka1(floor(t/escenario.paso+1));
    parametros.paciente.ka2 = parametros.paciente.ka2(floor(t/escenario.paso+1));
    parametros.paciente.kd = parametros.paciente.kd(floor(t/escenario.paso+1));
    parametros.paciente.kmax = parametros.paciente.kmax(floor(t/escenario.paso+1));
    parametros.paciente.kmin = parametros.paciente.kmin(floor(t/escenario.paso+1));
    parametros.paciente.kabs = parametros.paciente.kabs(floor(t/escenario.paso+1));
end    

% ABSORPTION (A3)

%Glucose in the stomach
qsto = x(1)+x(2);

if ~isempty(find(t == escenario.Tcomida,1)) && u(1)~=0 %reemplazo el bloque memory anterior
   qstoatmealtime = qsto;               
end

%Stomach solid
sys(1) = -parametros.paciente.kmax*x(1)+u(1); 

dosekempt = qstoatmealtime+escenario.comida(find(escenario.Tcomida<=t,1,'last')); 

if dosekempt>0
    alfa = 5/2/(1-parametros.paciente.b)/dosekempt;
    beta = 5/2/parametros.paciente.d/dosekempt;
    kempt = parametros.paciente.kmin+(parametros.paciente.kmax-parametros.paciente.kmin)/2*(tanh(alfa*(qsto-parametros.paciente.b*dosekempt))-tanh(beta*(qsto-parametros.paciente.d*dosekempt))+2);  
else
    kempt = parametros.paciente.kmax;
end;

%Stomach liquid
sys(2) = parametros.paciente.kmax*x(1)-x(2)*kempt;

%Intestine
sys(3) = kempt*x(2)-parametros.paciente.kabs*x(3);

%Rate of appearance
Rat = parametros.paciente.f*parametros.paciente.kabs*x(3)/parametros.paciente.BW+u(6);

% GLUCOSE PRODUCTION (A5)

%EGPt = parametros.paciente.kp1-parametros.paciente.kp2*x(4)-parametros.paciente.kp3*x(9); %viejo modelo
EGPt = parametros.paciente.kp1-parametros.paciente.kp2*x(4)-parametros.paciente.kp3*x(9)+parametros.paciente.kcounter*x(15);

% GLUCOSE UTILIZATION (A9)
Uiit=parametros.paciente.Fsnc;

% RENAL EXCRETION (A14)
if x(4)>parametros.paciente.ke2
    Et=parametros.paciente.ke1*(x(4)-parametros.paciente.ke2); 
else
    Et=0;
end

% RISK (A12-A13)
G = x(4)/parametros.paciente.Vg;
if ((G<parametros.paciente.Gb) && (G>=60))
    fGp = log(G)^parametros.paciente.r1-parametros.paciente.r2;
    riskt = 10*fGp^2;
elseif G<60
    fGp = log(60)^parametros.paciente.r1-parametros.paciente.r2;
    riskt = 10*fGp^2;
else
    riskt=0;
end  

% GLUCOSE UTILIZATION (A10)
%Vmt=parametros.paciente.Vm0+parametros.paciente.Vmx*x(7); modelo viejo
Vmt    = parametros.paciente.Vm0+parametros.paciente.Vmx*x(7)*(1+parametros.paciente.r3*riskt);
Kmt    = parametros.paciente.Km0; 
Uidt   = Vmt*x(5)/(Kmt+x(5));

% GLUCOSE KINETICS (A1)
sys(4) = max(EGPt,0)+Rat-Uiit-Et-parametros.paciente.k1*x(4)+parametros.paciente.k2*x(5)+u(5); %u(5)= glucosa IV
sys(4) = (x(4)>=0)*sys(4);
sys(5) = -Uidt+parametros.paciente.k1*x(4)-parametros.paciente.k2*x(5);
sys(5) = (x(5)>=0)*sys(5);

% INSULIN KINETICS (A2)
sys(6) = -(parametros.paciente.m2+parametros.paciente.m4)*x(6)+parametros.paciente.m1*x(10)+parametros.paciente.ka1*x(11)+parametros.paciente.ka2*x(12)+u(4); %u4=Insulina IV
It     = x(6)/parametros.paciente.Vi;
sys(6) = (x(6)>=0)*sys(6);

% INSULIN ACTION ON GLUCOSE UTILIZATION (A11)
sys(7) = -parametros.paciente.p2u*x(7)+parametros.paciente.p2u*(It-parametros.paciente.Ib);

% INSULIN ACTION ON PRODUCTION (A6 - A7)
sys(8) = -parametros.paciente.ki*(x(8)-It);
sys(9) = -parametros.paciente.ki*(x(9)-x(8));

% INSULIN IN THE LIVER (pmol/kg)
sys(10) = -(parametros.paciente.m1+parametros.paciente.m30)*x(10)+parametros.paciente.m2*x(6);
sys(10) = (x(10)>=0)*sys(10);

% SUBCUTANEOUS INSULIN KINETICS (A17) 
sys(11)=u(2)-(parametros.paciente.ka1+parametros.paciente.kd)*x(11); % u2=insulina sc
sys(11)=(x(11)>=0)*sys(11);

sys(12)=parametros.paciente.kd*x(11)-parametros.paciente.ka2*x(12);
sys(12)=(x(12)>=0)*sys(12);

% SUBCUTANEOUS GLCUOSE (A22)
sys(13)=(-parametros.paciente.ksc*x(13)+parametros.paciente.ksc*x(4));
sys(13)=(x(13)>=0)*sys(13);

% PLASMA GLUCAGON (A23-A28)
SRhdt = parametros.paciente.kGSRd*max(-sys(4)/parametros.paciente.Vg,0); %(A26)
SRhst = x(16);
SRht  = SRhst+SRhdt;  %(A24) 

Raht = parametros.paciente.SQgluc_k2*x(18); %(A28) mg/Kg/min
Raht = Raht*1e6/(parametros.paciente.SQgluc_Vgcn*1e-3);  %ng/L/min (distribution volume in mL/Kg)

if (escenario.endoglucagon) %Parametro agregado que anula la secreción
    sys(14)=-parametros.paciente.k01g*x(14)+SRht+Raht;
else
    sys(14)=-parametros.paciente.k01g*x(14)+Raht;
end
%sys(14)=(x(14)>=0)*sys(14);

%GLUCAGON ACTION ON PRODUCTION (A8)
sys(15) = -parametros.paciente.kXGn*x(15)+parametros.paciente.kXGn*max(x(14)-parametros.paciente.Gnb,0);
%sys(15)=(x(15)>=0)*sys(15);

%DELAYED GLUCAGON SECRETION (A20**)
SRHb = parametros.paciente.x0(16); 
if G>=parametros.paciente.Gb
    sys(16) = -parametros.paciente.alfaG*(x(16)-SRHb);
else
    sys(16) = -parametros.paciente.alfaG*(x(16)-max((parametros.paciente.kGSRs*(parametros.paciente.Gth-x(4)/parametros.paciente.Vg))/(1+x(6)/parametros.paciente.Vi-parametros.paciente.Ith)+SRHb,0));
end
%sys(16)=(x(16)>=0)*sys(16);

%GLUCAGON ABSORPTION KINETICS (A22)
% Input glucagon (mg/Kg/min)
sys(17) = -(parametros.paciente.SQgluc_k1+parametros.paciente.SQgluc_kc1)*x(17)+u(3);   
sys(17) = (x(17)>=0)*sys(17);

sys(18) = parametros.paciente.SQgluc_k1*x(17)-parametros.paciente.SQgluc_k2*x(18);
sys(18) = (x(18)>=0)*sys(18);

% end mdlDerivatives

%
%=======================================================================
% mdlOutputs
% Return the output vector for the S-function
%=======================================================================
%
function sys = mdlOutputs(t,x,u,parametros)

sys(1)    = x(4)/parametros.paciente.Vg;     %Plasma glucose
sys(2)    = x(13)/parametros.paciente.Vg;    %Subcutanoeous glucose
