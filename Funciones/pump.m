function [ubolus_pumped,ubasal_pumped]  = pump(ubolus,ubasal,hardware,BW)
    % pump saturation, quantization and random error
    % adapted from UVa simulator v32
    
    % ubasal and ubolus in pmol/Kg/min (or equivalent units for glucagon)
        
    % ubolus = ubolus*hardware.correction_for_infusate;
    % ubasal = ubasal*hardware.correction_for_infusate;
           
    if (hardware.pump_char)   
        ubolus_pmolmin = ubolus;         % pmol/min
        ubasal_pmolmin = ubasal;         % pmol/min
        
        % saturate
        ubolus_sat = min(max(hardware.minbolus*6000,ubolus_pmolmin),hardware.maxbolus*6000);
        ubasal_sat = min(max(hardware.minbasal*100,ubasal_pmolmin),hardware.maxbasal*100);
        
        % quantize
        qbolus          = hardware.incbolus*6000;
        ubolus_sat_quan = qbolus*floor(ubolus_sat/qbolus);
        qbasal          = hardware.incbasal*100;
        ubasal_sat_quan = qbasal*floor(ubasal_sat/qbasal);
        
        %if (hardware.pump_noise)        
            % add random error
            % TO BE IMPLEMENTED   
        %end
        ubolus_pumped = ubolus_sat_quan/BW;     % back to pmol/Kg/min
        ubasal_pumped = ubasal_sat_quan/BW;     % back to pmol/Kg/min
    else
        ubolus_pumped = ubolus;
        ubasal_pumped = ubasal;
    end
    
    % ubolus_pumped = ubolus_pumped/hardware.correction_for_infusate;   % back to pmol/Kg/min (insulin) or mg/Kg/min (glucagon)
    % ubasal_pumped = ubasal_pumped/hardware.correction_for_infusate;   % back to pmol/Kg/min (insulin) or mg/Kg/min (glucagon)
    
    
    % USE THIS CALL FOR TESTING
    %[a, b] = pump(40.16*6000/patient_struct.BW,10.66*100/patient_struct.BW,hardware.myInsulinPump,patient_struct.BW);
    
return