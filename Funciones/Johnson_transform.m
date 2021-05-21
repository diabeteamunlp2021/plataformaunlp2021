function RT_X = Johnson_transform(PR_TYPE,PR_GAMMA,PR_DELTA,PR_LAMBDA,PR_XI,RT_X)
%RT_X = Johnson_transform(PR_TYPE,PR_GAMMA,PR_DELTA,PR_LAMBDA,PR_XI,RT_X)
%
%  This function transform . 
%
%  Parameters:
%     PR_TYPE - a flag or cell array of flags indicating the system(s) from
%        which the variates are to be drawn. Possible values are 'SL',
%        'SU','SB','NO'.
%
%     PR_GAMMA,PR_DELTA,PR_LAMBDA,PR_XI - scalars or arrays of parameters
%        for the system(s) indicated in PR_TYPE. Note that for the SL
%        system, only the sign of PR_LAMBDA is used. In this case it
%        specifies whether the resulting distribution is positively or
%        negatively skewed.
%
%     RT_X - values to transform.

% First, let's find the appropriate size...

if ~iscell(PR_TYPE)
   PR_TYPE = {PR_TYPE};
end


PR_SIZE=size(RT_X);
% Generate SL variates where required...

LV_TYPE_MASK = strcmp(PR_TYPE,'SL');
if any(LV_TYPE_MASK)
   [LV_X_MASK,LV_GAMMA_MASK,LV_DELTA_MASK,LV_LAMBDA_MASK,LV_XI_MASK] = GET_MASK(LV_TYPE_MASK,PR_GAMMA,PR_DELTA,PR_LAMBDA,PR_XI,PR_SIZE);
   
   RT_X(LV_X_MASK) = PR_XI(LV_XI_MASK) + sign(PR_LAMBDA(LV_LAMBDA_MASK)).*exp((RT_X(LV_X_MASK)-PR_GAMMA(LV_GAMMA_MASK))./PR_DELTA(LV_DELTA_MASK));
end

% Generate SU variates where required...

LV_TYPE_MASK = strcmp(PR_TYPE,'SU');
if any(LV_TYPE_MASK)
   [LV_X_MASK,LV_GAMMA_MASK,LV_DELTA_MASK,LV_LAMBDA_MASK,LV_XI_MASK] = GET_MASK(LV_TYPE_MASK,PR_GAMMA,PR_DELTA,PR_LAMBDA,PR_XI,PR_SIZE);
   
   RT_X(LV_X_MASK) = PR_XI(LV_XI_MASK) + PR_LAMBDA(LV_LAMBDA_MASK).*sinh((RT_X(LV_X_MASK)-PR_GAMMA(LV_GAMMA_MASK))./PR_DELTA(LV_DELTA_MASK));
end

% Generate SB variates where required...

LV_TYPE_MASK = strcmp(PR_TYPE,'SB');
if any(LV_TYPE_MASK)
   [LV_X_MASK,LV_GAMMA_MASK,LV_DELTA_MASK,LV_LAMBDA_MASK,LV_XI_MASK] = GET_MASK(LV_TYPE_MASK,PR_GAMMA,PR_DELTA,PR_LAMBDA,PR_XI,PR_SIZE);
   
%  Check for the boundary case...

   LV_DELTA_ZERO = (PR_DELTA == 0);
   if any(LV_DELTA_ZERO)
      [LV_X_MASK2,LV_GAMMA_MASK2,LV_DELTA_MASK2,LV_LAMBDA_MASK2,LV_XI_MASK2] = GET_MASK(LV_X_MASK & LV_DELTA_ZERO,PR_GAMMA,PR_DELTA,PR_LAMBDA,PR_XI,PR_SIZE);
      
      RT_X(LV_X_MASK2) = (RT_X(LV_X_MASK2)<=PR_GAMMA(LV_GAMMA_MASK2)).*PR_XI(LV_XI_MASK2) + ...
                         (RT_X(LV_X_MASK2)>PR_GAMMA(LV_GAMMA_MASK2)).*(PR_XI(LV_XI_MASK2)+PR_LAMBDA(LV_LAMBDA_MASK2));
      
%     Ensure we don't overwrite these results in the computations for delta ~= 0
      
      LV_X_MASK = LV_X_MASK&(~LV_X_MASK2);
      if length(LV_GAMMA_MASK2) > 1
         LV_GAMMA_MASK = LV_GAMMA_MASK&(~LV_GAMMA_MASK2);
      end
      if length(LV_DELTA_MASK2) > 1
         LV_DELTA_MASK = LV_DELTA_MASK&(~LV_DELTA_MASK2);
      end
      if length(LV_LAMBDA_MASK2) > 1
         LV_LAMBDA_MASK = LV_LAMBDA_MASK&(~LV_LAMBDA_MASK2);
      end
      if length(LV_XI_MASK2) > 1
         LV_XI_MASK = LV_XI_MASK&(~LV_XI_MASK2);
      end
   end
   
   RT_X(LV_X_MASK) = PR_XI(LV_XI_MASK) + PR_LAMBDA(LV_LAMBDA_MASK)./(1+exp(-(RT_X(LV_X_MASK)-PR_GAMMA(LV_GAMMA_MASK))./PR_DELTA(LV_DELTA_MASK)));
end

%%%%%%%%%%%%%%%%%% End of function STAT_JOHNSON_RND %%%%%%%%%%%%%%%

function [RT_X_MASK,RT_GAMMA_MASK,RT_DELTA_MASK,RT_LAMBDA_MASK,RT_XI_MASK] = GET_MASK(PR_TYPE_MASK,PR_GAMMA,PR_DELTA,PR_LAMBDA,PR_XI,PR_SIZE)

RT_X_MASK = true(PR_SIZE);
RT_GAMMA_MASK = true(size(PR_GAMMA));
RT_DELTA_MASK = true(size(PR_DELTA));
RT_LAMBDA_MASK = true(size(PR_LAMBDA));
RT_XI_MASK = true(size(PR_XI));

if length(PR_TYPE_MASK)>1
   RT_X_MASK = PR_TYPE_MASK;
   if length(RT_GAMMA_MASK) > 1
      RT_GAMMA_MASK = PR_TYPE_MASK;
   end
   if length(RT_DELTA_MASK) > 1
      RT_DELTA_MASK = PR_TYPE_MASK;
   end
   if length(RT_LAMBDA_MASK) > 1
      RT_LAMBDA_MASK = PR_TYPE_MASK;
   end
   if length(RT_XI_MASK) > 1
      RT_XI_MASK = PR_TYPE_MASK;
   end
end
