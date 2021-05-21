%=======================================================================
% **meal_announce**
%
%   @Description:
%               
%
%   @param:     -t:            number
%
%   @return:    -y:            number
%=======================================================================
function y = meal_announce(t)

global ctrl
persistent flag

if t == ctrl.ti
    flag = 0;
end

y = 0;

if any(ctrl.Tcomida==t-flag)    
    idx  = find(ctrl.Tcomida==t-flag);
    meal = ctrl.comida(idx);
    if meal < 35000
        cho = 40000/ctrl.Ts;
    elseif meal >= 35000 && meal <65000
        cho = 55000/ctrl.Ts;
    else
        cho = 70000/ctrl.Ts;
    end
    flag = flag+1;
    y = cho;
end

if flag == 5
    flag = 0;
end



