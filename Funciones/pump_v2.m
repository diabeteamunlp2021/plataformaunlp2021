function [ubolus_pumped,ubasal_pumped]  = pump_v2(ubolus,ubasal,hardware,pump_flag,BW)
    % pump saturation, quantization and random error
    % adapted from UVa simulator v32
   
    % ubasal and ubolus in pmol/Kg/min (or equivalent units for glucagon)
    % ubolus = ubolus*hardware.correction_for_infusate;
    % ubasal = ubasal*hardware.correction_for_infusate;
    if (pump_flag)
        %ubolus_pmolmin = ubolus*BW;         % pmol/min
        %ubasal_pmolmin = ubasal*BW;         % pmol/min
        ubolus_pmolmin = ubolus;        % pmol/kg
        ubasal_pmolmin = ubasal*hardware.pump_sampling;        % pmol/kg
        % saturate
        ubolus_sat = min(max(hardware.pump_bolus_min,ubolus_pmolmin),hardware.pump_bolus_max);
        ubasal_sat = min(max(hardware.pump_basal_min,ubasal_pmolmin),hardware.pump_basal_max);
        % quantize
        qbolus          = hardware.pump_bolus_inc;
        ubolus_sat_quan = qbolus*(ubolus_sat/qbolus); %
        qbasal          = hardware.pump_basal_inc;
        ubasal_sat_quan = qbasal*(ubasal_sat/qbasal); %

        
%       if (hardware.pump_noise)
            % add random error
            % TO BE IMPLEMENTED
%       end
        ubolus_pumped = ubolus_sat_quan/BW;     % back to pmol/Kg/min
        ubasal_pumped = ubasal_sat_quan/BW;     % back to pmol/Kg/min
    else
        ubolus_pumped = ubolus/BW;
        ubasal_pumped = ubasal/BW;
    end
    %ubolus_pumped = ubolus_pumped/hardware.correction_for_infusate;   % back to pmol/Kg/min (insulin) or mg/Kg/min (glucagon)
    %ubasal_pumped = ubasal_pumped/hardware.correction_for_infusate;   % back to pmol/Kg/min (insulin) or mg/Kg/min (glucagon)
    % USE THIS CALL FOR TESTING
    %[a, b] = pump(40.16*6000/patient_struct.BW,10.66*100/patient_struct.BW,hardware.myInsulinPump,patient_struct.BW);
return