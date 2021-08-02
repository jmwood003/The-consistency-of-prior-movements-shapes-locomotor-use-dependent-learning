%Data import and individual analysis script for:
%The consistency of prior movements shapes locomotor use-dependent learning

%9/24/2020
%Jonathan Wood

%Analzyses data for a single subject: imports data, checks marker data and
%interpolates and filters marker data. Detects events based on marker data
%than calculates and plots gait outcomes. Finally, all data are saved into
%group data table

%Note: to run this code you will need to change the directories and set the
%paths appropriately for your own computer. 

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
clear; clc; close all;

%Do you want to save the plots?
savestr = 'No';
%Do you want to plot the marker and event data?
pltstr = 'No';

%Set directories
GroupDir = 'Z:\smmorton Lab\Jonathan\Projects\UDP\Data\UDPV\Phase2Data'; 
addpath('Z:\smmorton Lab\Jonathan\Projects\UDP\Codes\UDPV\MMdataprocess\NewFuns');
addpath('Z:\smmorton Lab\Jonathan\Projects\UDP\Codes\UDPV\MMdataprocess\Functions');

cd(GroupDir);

%Load table if it exists
if exist('AllT','var')==0 && exist('UDLVnewAllT.mat','file')==2
    load('UDLVnewAllT');   
    prevS = unique(AllT.sessionID);
elseif exist('UDLVnewAllT','var')==0 && exist('UDLVnewAllT.mat','file')==0
    AllT = [];
    prevS = [];
else
    prevS = unique(AllT.SessionID);
end

%% Import and event detection

%Type the session(s) you want to analyze
%Single session
Subjects = {'UDLV_HV_18'};
%All sessions:
% Subjects = {'UDLV_Constant_01','UDLV_HV_01','UDLV_Constant_02','UDLV_LV_02','UDLV_HV_02',...
% 'UDLV_Constant_04','UDLV_LV_04','UDLV_LV_05','UDLV_HV_05','UDLV_LV_01','UDLV_HV_04','UDLV_Constant_05',...
% 'UDLV_LV_03','UDLV_HV_06','UDLV_Constant_07','UDLV_LV_08','UDLV_HV_03','UDLV_Constant_06',...
% 'UDLV_HV_07','UDLV_Constant_08','UDLV_Constant_03','UDLV_LV_07','UDLV_HV_08','UDLV_LV_06'...
% 'UDLV_LV_10','UDLV_HV_09','UDLV_Constant_09','UDLV_HV_10','UDLV_Constant_11','UDLV_LV_09',...
% 'UDLV_HV_12','UDLV_Constant_10','UDLV_LV_11','UDLV_HV_11','UDLV_HV_13','UDLV_LV_13',...
% 'UDLV_LV_12','UDLV_Constant_13','UDLV_LV_16','UDLV_HV_15','UDLV_HV_16','UDLV_Constant_15',...
% 'UDLV_Constant_12','UDLV_Constant_16','UDLV_Constant_14','UDLV_Constant_17','UDLV_LV_15',...
% 'UDLV_LV_18','UDLV_HV_14','UDLV_LV_17','UDLV_Constant_18','UDLV_LV_14','UDLV_HV_17','UDLV_HV_18'};

for subject_i = 1:length(Subjects)

    tic
    
    %Index the current subject and switch directories
    subject_id = Subjects{subject_i};
    disp(subject_id); 
    Current_dir = [GroupDir '\' subject_id];
    cd(Current_dir)

    %Import raw data into table
    T = ImportRawData(Current_dir); 
    
    %Check, interpolate, and filter marker data
    T = CheckMarkers(T,pltstr); %Check if markers have flipped and flip them back
    T = InterpolateMarkers(T,savestr,pltstr); %Fill gaps
    T = FilterMarkers(T); %Filter
        
    %Event detection
    EventsT = DetectEvents(T);
    EventsT = CheckEvents(EventsT);
    if strcmp(pltstr,'Yes')==1
        PlotEvents(T, EventsT, savestr);
    end
         
    %There are a few participants with erroneous events that the "check
    %events function did not catch. They need to be hard coded in or
    %deleted manually. Below are the session names and the events that will
    %be automatically to be deleted. 
%     disp('Paused: check event plots to make sure there are not errors');
%     keyboard;
    if strcmp(subject_id,'UDLV_HV_01')==1
        EventsT.RTOV_Frames_cor(914) = nan;
        EventsT.LTOV_Frames_cor(913) = nan;  
        EventsT.RTOV_Frames_cor(913) = nan;
        EventsT.RHSV_Frames_cor(912) = nan;
    elseif strcmp(subject_id,'UDLV_Constant_04')==1
        EventsT.RTOV_Frames_cor(1) = nan;
    elseif strcmp(subject_id,'UDLV_HV_06')==1
        EventsT.RTOV_Frames_cor(948) = nan;
        EventsT.RTOV_Frames_cor(949) = nan;
        EventsT.RHSV_Frames_cor(948) = nan;
    elseif strcmp(subject_id,'UDLV_Constant_03')==1
        EventsT.RTOV_Frames_cor(1) = nan;
    elseif strcmp(subject_id,'UDLV_LV_10')==1
        EventsT.StrideChange_cor(776) = nan;
        EventsT.LHSV_Frames_cor(776) = nan;
    elseif strcmp(subject_id,'UDLV_HV_14')==1
        EventsT.LHSV_Frames_cor(667) = 46938;
    elseif strcmp(subject_id,'UDLV_LV_17')==1
        EventsT.StrideChange_cor(260) = 503;
        EventsT.LHSV_Frames_cor(260) = 503;
        EventsT.StrideChange_cor(768) = 724;
        EventsT.LHSV_Frames_cor(768) = 724;        
    end
    
    %Gait and outcome calculations
    SubjT = GaitAnalysis(T, EventsT);
    SubjT = GaitOutcomes(SubjT);
    %Input motion monitor data back into table
    SubjT = MotionMonitorData(T,SubjT);
  
    %Plot 
    SubjT = PlotOutcomes(SubjT, savestr);

%     %Save tables
%     save([subject_id,  '_RawData.mat'], 'T');
%     save([subject_id,  '_GaitEvents.mat'], 'EventsT');
    %Save back into Group table
    cd(GroupDir);
    if ismember(subject_id,prevS)
        Sidx = find(strcmp(subject_id,AllT.SessionID)==1);
        AllT(Sidx,:) = SubjT; 
    else
        AllT = [AllT; SubjT];
    end
    
    clear T EventsT SubjT;
    
    toc
    
end

if strcmp(savestr,'Yes')==1
    save('UDLVnewAllT','AllT');
    disp('Table Saved');
end
