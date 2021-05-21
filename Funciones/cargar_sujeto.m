%=======================================================================
%   **cargar_sujeto**
%   
%   @Description:
%               Funcion encargada de devolver una estructura con los 
%               parametros de los sujetos de prueba.
%
%   @param:     -sujeto:        struct(string,array)
%               -parametros:    struct(string,array)
%               
%   
%   @return:    -parametros:    struct(string,array)
%=======================================================================
function [parametros] = cargar_sujeto(sujeto,parametros)

load(sujeto)

parametros.paciente = struttura;

%Carga de parámetros del sujeto      
% parametros.BW       =BW;
% parametros.EGPb     =EGPb;
% parametros.Gb       =Gb;
% parametros.Ib       =Ib;
% parametros.kabs     =kabs;
% parametros.kmax     =kmax;
% parametros.kmin     =kmin;
% parametros.b        =b;
% parametros.f        =f;
% parametros.c        =d;
% parametros.Vg       =Vg;
% parametros.Vi       =Vi;
% parametros.Gpb      =Gpb;
% parametros.Ipb      =Ipb;
% parametros.Vmx      =Vmx;
% parametros.Km0      =Km0;
% parametros.k1       =k1;
% parametros.k2       =k2;
% parametros.Fcns     =Fsnc;
% parametros.Gtb      =Gtb;
% parametros.Vm0      =Vm0;
% parametros.Rdb      =Rdb;
% parametros.PCRb     =PCRb;
% parametros.p2u      =p2u;
% parametros.m1       =m1;
% parametros.m30      =m30;
% parametros.m4       =m4;
% parametros.m2       =m2;
% parametros.m5       =m5;
% parametros.CL       =CL;
% parametros.HEb      =HEb;
% parametros.Ilb      =Ilb;
% parametros.ki       =ki;
% parametros.kp1      =kp1;
% parametros.kp2      =kp2;
% parametros.kp3      =kp3;
% parametros.ke1      =ke1;
% parametros.ke2      =ke2;
% parametros.ksc      =ksc;
% parametros.kd       =kd;
% parametros.ka1      =ka1;
% parametros.ka2      =ka2;
% parametros.dosekempt=dosekempt;
% parametros.x0       =x0;
% parametros.u2ss     =u2ss;
% parametros.isc1ss   =isc1ss;
% parametros.isc2ss   =isc2ss;

end