function ExampleTrgts(LrnStrides,reprng,Tmu)

%Plot example target distributions and stride by stride data for each
%condition

%LrnStrides = number of strides during the learning phsae
%reprng = frequency of target change (randomized between [x1 x2] strides)
%Tmu = mean of the targets for each condition

%Set the targets for each condition
N = 1; %Number of target sets - only need 1 here
T_Constant = Ctargets(LrnStrides,Tmu,N);
T_LV = LVtargets(LrnStrides,Tmu,reprng,N);
T_HV = HVtargets(LrnStrides,reprng,N);

%Set colors for plotting
colors = lines(3);
Ccolor = colors(1,:);
LVcolor = colors(2,:);
HVcolor = colors(3,:);

%Plot constant condition
figure; hold on
subplot(2,3,1); hold on
histogram(T_Constant(251:750),'FaceColor',Ccolor);
xlim([0 45]);
ylabel('SAI Target Count','FontSize',10);
title('Constant Condition','FontSize',12);

subplot(2,3,4); hold on
rectangle('Position',[0,-5,250,50],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[750,-5,750,50],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
plot(T_Constant,'-', 'Color', Ccolor, 'LineWidth',3);
ylim([-5 45]); xlim([0 1500]);
set(gca,'xtick',[]);
ylabel('SAI Target (%)','FontSize',10);

%Plot low variability condition
subplot(2,3,2); hold on
histogram(T_LV(251:750),15,'FaceColor',LVcolor);
xlim([0 45]); ylim([0 120]);
xlabel('SAI Target (%)','FontSize',10);
title('Low Variability Condition','FontSize',12);

subplot(2,3,5); hold on
rectangle('Position',[0,-5,250,50],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[750,-5,750,50],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
plot(T_LV,'-','Color', LVcolor, 'LineWidth',1);
ylim([-5 45]); xlim([0 1500]);
set(gca,'xtick',[125, 500, 1125]);
set(gca,'xticklabel',{'Bsl','Learning','Washout'});
xlabel('Strides','FontSize',10);

%Plot high variability condition
subplot(2,3,3); hold on
histogram(T_HV(251:750),15,'FaceColor',HVcolor);
xlim([0 45]); ylim([0 120]);
title('High Variability Condition','FontSize',12);

subplot(2,3,6); hold on
rectangle('Position',[0,-5,250,50],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[750,-5,750,50],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
plot(T_HV,'-','Color',HVcolor ,'LineWidth',1);
ylim([-5 45]); xlim([0 1500]);
set(gca,'xtick',[]);


end