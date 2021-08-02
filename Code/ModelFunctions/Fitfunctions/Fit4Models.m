function S = Fit4Models(Data,Trgt,Cidx,Pidx,num_initials)

%This function fits all 4 models to the data and calculates the parameters
%for the best fits and saves them into a structure

%Inputs:
%Data = data to fit
%Trgt = corresponding targets for the data
%Cidx = corresponding indexing variable for the condtitions
%Pidx = correspinding indexing variable for the phases
%num_initials = number of initializations
%Outputs:
%S = structure including: R2, AIC, parameters, and simulations for each
%model and R2 and AIC for the washout phase only

S = struct;
for initials_i = 1:num_initials

    %Fit models to data
    [ABparams,ABerror,AB_AIC,~] = ABfit(Data,Trgt);
    [SUparams,SUerror,SU_AIC,~] = SUfit(Data,Trgt);
    [SU2_params,SU2_error,SU2_AIC,~] = SU2fit(Data,Trgt,Cidx);
    [AB2_params,AB2_error,AB2_AIC,~] = AB2fit(Data,Trgt);

    %Save all params, error, r2, and AIC
    %AB
    ABbest_err = Inf;
    if ABerror <= ABbest_err
        ABbest_err = ABerror;
        bestparamAB = ABparams;
        SSr = ABerror;
        SSt = sum((Data - mean(Data)).^2);
        ABr2 = 1 - (SSr/SSt);
    end
    temp_best_errAB(initials_i,:) = ABbest_err;
    temp_bestparamAB(initials_i,:) = bestparamAB;
    temp_r2AB(initials_i,:) = ABr2;
    tempaicAB(initials_i,:) = AB_AIC;

    %SU
    SUbest_err = Inf;
    if SUerror <= SUbest_err
        SUbest_err = SUerror;
        bestparamSU = SUparams;
        SSr = SUerror;
        SSt = sum((Data - mean(Data)).^2);
        SUr2 = 1 - (SSr/SSt);
    end
    temp_best_errSU(initials_i,:) = SUbest_err;
    temp_bestparamSU(initials_i,:) = bestparamSU;
    temp_r2SU(initials_i,:) = SUr2;
    tempaicSU(initials_i,:) = SU_AIC;

    %Modified SU
    SUgain_best_err = Inf;
    if SU2_error <= SUgain_best_err
        SUgain_best_err = SU2_error;
        bestparam_SUgain = SU2_params;
        SSr = SU2_error;
        SSt = sum((Data - mean(Data)).^2);
        SUgain_r2 = 1 - (SSr/SSt);
    end
    temp_best_err_SU2(initials_i,:) = SUgain_best_err;
    temp_bestparam_SU2(initials_i,:) = bestparam_SUgain;
    temp_r2_SU2(initials_i,:) = SUgain_r2;
    tempaic_SU2(initials_i,:) = SU2_AIC;

    %Modified AB
    AB_2L2B_best_err = Inf;
    if AB2_error <= AB_2L2B_best_err
        AB_2L2B_best_err = AB2_error;
        bestparam_AB_2L2B = AB2_params;
        SSr = AB2_error;
        SSt = sum((Data - mean(Data)).^2);
        AB_2L2B_r2 = 1 - (SSr/SSt);
    end
    temp_best_err_AB2(initials_i,:) = AB_2L2B_best_err;
    temp_bestparam_AB2(initials_i,:) = bestparam_AB_2L2B;
    temp_r2_AB2(initials_i,:) = AB_2L2B_r2;
    tempaic_AB2(initials_i,:) = AB2_AIC;   

end

%Save the best parameters into structure
%SU
[sseSU,bestidxSU] = min(temp_best_errSU);
S.SU.params = temp_bestparamSU(bestidxSU,:);
S.SU.r2 = temp_r2SU(bestidxSU,:);
S.SU.aic = tempaicSU(bestidxSU,:);

%AB
[sseAB,bestidxAB] = min(temp_best_errAB);
S.AB.params = temp_bestparamAB(bestidxAB,:);
S.AB.r2 = temp_r2AB(bestidxAB,:);
S.AB.aic = tempaicAB(bestidxAB,:);

%Modified SU
[sse_SU2,bestidx_SU2] = min(temp_best_err_SU2);
S.SU2.params = temp_bestparam_SU2(bestidx_SU2,:);
S.SU2.r2 = temp_r2_SU2(bestidx_SU2,:);
S.SU2.aic = tempaic_SU2(bestidx_SU2,:);

%Modified AB
[sse_AB2,bestidx_AB2] = min(temp_best_err_AB2);
S.AB2.params = temp_bestparam_AB2(bestidx_AB2,:);
S.AB2.r2 = temp_r2_AB2(bestidx_AB2,:);
S.AB2.aic = tempaic_AB2(bestidx_AB2,:);

%Simulate data and save into structure
[S.AB.tmap] = ABsim(S.AB.params,Trgt);
[S.SU.x,S.SU.w,S.SU.s] = ...
    SUsim(S.SU.params,Trgt);
[S.SU2.x,S.SU2.w,S.SU2.s] = SU2sim(...
    S.SU2.params,Trgt,Cidx);
[S.AB2.tmap] = AB2sim(S.AB2.params,Trgt);

%Calculate Washout only r2 and AIC
%Washout index
wshidx = find(Pidx==3);
%Sum of squares total for the washout phsae
SStot = nansum((Data(wshidx) - nanmean(Data(wshidx))).^2);

%AB
Wsh_sseAB = nansum((Data(wshidx) - S.AB.tmap(wshidx)).^2);
S.AB.r2W = 1 - (Wsh_sseAB/SStot);
%SU
Wsh_sseSU = nansum((Data(wshidx) - S.SU.x(wshidx)).^2);
S.SU.r2W = 1 - (Wsh_sseSU/SStot);
%Modified AB
Wsh_sseAB2 = nansum((Data(wshidx) - S.AB2.tmap(wshidx)).^2);
S.AB2.r2W = 1 - (Wsh_sseAB2/SStot);
%Modified SU
Wsh_sseSU2 = nansum((Data(wshidx) - S.SU2.x(wshidx)).^2);
S.SU2.r2W = 1 - (Wsh_sseSU2/SStot);

%Calculate washout only AIC
S.AB.aicW = 2*length(ABparams) + length(wshidx)*log(Wsh_sseAB/length(wshidx));
S.SU.aicW = 2*length(SUparams) + length(wshidx)*log(Wsh_sseSU/length(wshidx));
S.AB2.aicW = 2*length(AB2_params) + length(wshidx)*log(Wsh_sseAB2/length(wshidx));
S.SU2.aicW = 2*length(SU2_params) + length(wshidx)*log(Wsh_sseSU2/length(wshidx));

end
    