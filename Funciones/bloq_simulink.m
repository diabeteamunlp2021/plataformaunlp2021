function = bloq_simulink[parametros ]
% For cada paciente
%   k=1     // paciente
%   controlador(k)
%   for Simulink
%       bloque_la_lc(k) --> 
            la_lc(...) --> [in: ins_subc_basal, ins_subc_bolo, basal_cont, bolo_cont;
%                          out: ubolus,ubasal]
%       bloque_bomba(k) --> 
            pump(...)--> [in: ubolus,ubasal,hardware,BW;
%                        out: ubolus_pumped,ubasal_pumped, senal*]
%       bloque_paciente(k) --> t1dm_unlp.m
%       bloque_sensor(k) --> 
            sensor(...) --> [in: IG=parametros.paciente.Vg; 
                            out: CGM=glucossa sensor)
%       bloque_controlador(k)--> 
            controlador(...) --> [in: CGM_sensor, parametros.comidas, Ins_LA(inyeccion insulina bomba*);
%                                 out: basal_cont, bolo_cont]
%   end Simulink
% end Paciente




        
