function SessBehaviorPowerProfile(varargin)

p = inputParser;
addParameter(p,'expPath',[],@isfolder);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'force',true,@islogical);
addParameter(p,'forceDetect',true,@islogical);
addParameter(p,'fixChannels',true,@islogical)
addParameter(p,'refChannel',[],@isnumeric)
addParameter(p,'maxChan',127,@isnumeric)
parse(p,varargin{:});

expPath = p.Results.expPath;
saveMat = p.Results.saveMat;
force = p.Results.force;
forceDetect = p.Results.forceDetect;
fixChannels = p.Results.fixChannels;
refChannel = p.Results.refChannel;
maxChan = p.Results.maxChan;

if ~exist('expPath') || isempty(expPath)
    expPath = uigetdir; % select folder
end

allpath = strsplit(genpath(expPath),';'); % all folders
cd(allpath{1});
allSess = dir('*_sess*');

if exist('Summ\PowerProfile.mat','file') && ~force 
    disp('Power profile already computed! Loading file.');
    load('Summ\PowerProfile.mat');
else

    for rr = 1:3
        for cc = 1:2
            for zz = 1:6
                PowerProfile.theta{rr,cc}{zz} = [];
                PowerProfile.sg{rr,cc}{zz} = [];
                PowerProfile.mg{rr,cc}{zz} = [];
                PowerProfile.hfo{rr,cc}{zz} = [];
            end
        end
    end

    for ii = 1:size(allSess,1)
        fprintf(' ** Examining session %3.i of %3.i... \n',ii, size(allSess,1));
        cd(strcat(allSess(ii).folder,'\',allSess(ii).name));
        [sessionInfo] = bz_getSessionInfo(pwd, 'noPrompts', true);
        file = dir(('*.SessionPulses.Events.mat'));
        load(file.name);
        file = dir(('*.SessionArmChoice.Events.mat'));
        load(file.name);    
        file = dir(('*.region.mat'));
        load(file.name);    
        
        % Theta profile
        powerProfile_theta = bz_PowerSpectrumProfile_IZ([6 12],'channels',[0:maxChan],'showfig',false,'forceDetect',forceDetect,'fixChannels',fixChannels,'refChannel',refChannel);
        % Slow gamma profile
        powerProfile_sg = bz_PowerSpectrumProfile_IZ([25 45],'channels',[0:maxChan],'showfig',false,'forceDetect',forceDetect,'fixChannels',fixChannels,'refChannel',refChannel);
        % Mid gamma profile
        powerProfile_mg = bz_PowerSpectrumProfile_IZ([45 120],'channels',[0:maxChan],'showfig',false,'forceDetect',forceDetect,'fixChannels',fixChannels,'refChannel',refChannel);
        % HFO profile
        powerProfile_hfo = bz_PowerSpectrumProfile_IZ([120 250],'channels',[0:maxChan],'showfig',false,'forceDetect',forceDetect,'fixChannels',fixChannels,'refChannel',refChannel);
        
        efields = fieldnames(sessionPulses);    

        for jj = 1:length(efields)
            region = sessionPulses.(efields{jj}).region; %1 is CA1/CA3, 2 is mec, 3 is both
            target = sessionPulses.(efields{jj}).target; %1 is stem, 2 is return

            rewardTS = sessionArmChoice.(efields{jj}).timestamps;
            startDelay = sessionArmChoice.(efields{jj}).delay.timestamps(1,:)';     
            endDelay = sessionArmChoice.(efields{jj}).delay.timestamps(2,:)';  

            for zz = 1:6
                %Extract relevant intervals for cross-frequency coupling - 4 cross
                %modulograms
                switch zz
                    case 1  %First, no stim trials, return        
                        startTS = rewardTS(sessionPulses.(efields{jj}).stim(1:(end-1))==0);
                        endTS = startDelay(sessionPulses.(efields{jj}).stim(1:(end-1))==0);
                        events = [startTS'; endTS'];
                    case 2  %No stim, stem
                        startTS = endDelay(sessionPulses.(efields{jj}).stim(1:(end-1))==0);        
                        endTS = rewardTS(find(sessionPulses.(efields{jj}).stim(1:(end-1))==0)+1);
                        events = [startTS';endTS'];
                    case 3 %No stim, delay
                        startTS = startDelay(sessionPulses.(efields{jj}).stim(1:(end-1))==0);        
                        endTS = endDelay(sessionPulses.(efields{jj}).stim(1:(end-1))==0); 
                        events = [startTS';endTS'];  
                    case 4  % Stim, return
                        startTS = rewardTS(sessionPulses.(efields{jj}).stim(1:(end-1))==1);
                        endTS = startDelay(sessionPulses.(efields{jj}).stim(1:(end-1))==1);
                        events = [startTS';endTS'];                    
                    case 5   % Stim, stem
                        startTS = endDelay(sessionPulses.(efields{jj}).stim(1:(end-1))==1);        
                        endTS = rewardTS(find(sessionPulses.(efields{jj}).stim(1:(end-1))==1)+1);
                        events = [startTS';endTS'];                      
                    case 6    %stim, delay
                        startTS = startDelay(sessionPulses.(efields{jj}).stim(1:(end-1))==1);        
                        endTS = endDelay(sessionPulses.(efields{jj}).stim(1:(end-1))==1); 
                        events = [startTS';endTS'];
                end

                if (zz == 3 || zz == 6) && sessionArmChoice.(efields{jj}).delay.dur < 1 
                    thetaProfile = nan;
                    sgProfile = nan;
                    mgProfile = nan;
                    hfoProfile = nan;
                else
                    for pp = 1:length(events)
                        events_tmp = abs(powerProfile_theta.time(1,:)-events(1,pp));
                        [~,idx_start] = min(events_tmp);
                        events_tmp = abs(powerProfile_theta.time(1,:)-events(2,pp));
                        [~,idx_end] = min(events_tmp);
                        
                        thetaProfile(:,pp) = mean(0.1*(powerProfile_theta.power(:,idx_start:idx_end)).^10,2);
                        sgProfile(:,pp) = mean(0.1*(powerProfile_sg.power(:,idx_start:idx_end)).^10,2);
                        mgProfile(:,pp) = mean(0.1*(powerProfile_mg.power(:,idx_start:idx_end)).^10,2);
                        hfoProfile(:,pp) = mean(0.1*(powerProfile_hfo.power(:,idx_start:idx_end)).^10,2);
                    end                        
                end
                PowerProfile.theta{region,target}{zz} = catpad(3,PowerProfile.theta{region,target}{zz},nanmean(thetaProfile,2));
                PowerProfile.sg{region,target}{zz} = catpad(3,PowerProfile.sg{region,target}{zz},nanmean(sgProfile,2));
                PowerProfile.mg{region,target}{zz} = catpad(3,PowerProfile.mg{region,target}{zz},nanmean(mgProfile,2));
                PowerProfile.hfo{region,target}{zz} = catpad(3,PowerProfile.hfo{region,target}{zz},nanmean(hfoProfile,2));
                
                clear thetaProfile sgProfile mgProfile hfoProfile

            end        
            clear rewardTS startDelay events
        end

    end

    if saveMat
        save([expPath '\Summ\' 'PowerProfile.mat'], 'PowerProfile');
    end
end

load(strcat(allSess(1).folder,'\',allSess(1).name,'\',allSess(1).name,'.sessionInfo.mat'));
channels = [1:sessionInfo.nChannels]-1;
reg = {'CA3','mEC','Both'};
zone = {'returnB','stemB','delayB','returnS','stemS','delayS'};
target = {'STEM', 'RETURN'};
nf = 1;
cmap = cbrewer('qual','Paired',6);

for ii = 1:length(reg)
     for jj = 1:length(target)
         figure(nf)
         set(gcf,'Position',[20 20 2500 1200])
         for kk = 1:length(zone)      
             
            if size(PowerProfile.theta{ii,jj}{kk},1)>1 
                meanTheta = mean(PowerProfile.theta{ii,jj}{kk}(:,:,3:end),3);
                meansg  = mean(PowerProfile.sg{ii,jj}{kk}(:,:,3:end),3);
                meanmg  = mean(PowerProfile.mg{ii,jj}{kk}(:,:,3:end),3);
                meanhfo  = mean(PowerProfile.hfo{ii,jj}{kk}(:,:,3:end),3);
                stdTheta = (std(PowerProfile.theta{ii,jj}{kk}(:,:,3:end),[],3))/sqrt(size(PowerProfile.theta{ii,jj}{kk},3)-1);
                stdsg  = std(PowerProfile.sg{ii,jj}{kk}(:,:,3:end),[],3)/sqrt(size(PowerProfile.theta{ii,jj}{kk},3)-1);
                stdmg  = std(PowerProfile.mg{ii,jj}{kk}(:,:,3:end),[],3)/sqrt(size(PowerProfile.theta{ii,jj}{kk},3)-1);
                stdhfo  = std(PowerProfile.hfo{ii,jj}{kk}(:,:,3:end),[],3)/sqrt(size(PowerProfile.theta{ii,jj}{kk},3)-1);

                if kk < 4 
                    colidx = kk*2;
                else
                    colidx = (kk-4)*2+1;
                end


                for shank = 1:(size(sessionInfo.AnatGrps,2)-1)

                    [Lia] = ismember(sessionInfo.AnatGrps(shank).Channels, channels);
                    nC = 1:length(sessionInfo.AnatGrps(shank).Channels);
                    nC = nC(Lia);

                    subplot((size(sessionInfo.AnatGrps,2)-1),4,4*(shank-1)+1)
                    hold on
                    dev1 = meanTheta(sessionInfo.AnatGrps(shank).Channels(Lia)+1)-stdTheta(sessionInfo.AnatGrps(shank).Channels(Lia)+1);
                    dev2 = meanTheta(sessionInfo.AnatGrps(shank).Channels(Lia)+1)+stdTheta(sessionInfo.AnatGrps(shank).Channels(Lia)+1);
                    fill([dev1' flip(dev2')],[nC flip(nC)],cmap(colidx,:),'FaceAlpha',.2,'EdgeColor','none')
                    plot(meanTheta(sessionInfo.AnatGrps(shank).Channels(Lia)+1),nC(Lia),'color',cmap(colidx,:),'LineWidth',1.5); 
                    ylabel('Channels'); xlabel('Power'); title('theta power')
                    set(gca,'YDir','reverse');

                    subplot((size(sessionInfo.AnatGrps,2)-1),4,4*(shank-1)+2)
                    hold on
                    dev1 = meansg(sessionInfo.AnatGrps(shank).Channels(Lia)+1)-stdsg(sessionInfo.AnatGrps(shank).Channels(Lia)+1);
                    dev2 = meansg(sessionInfo.AnatGrps(shank).Channels(Lia)+1)+stdsg(sessionInfo.AnatGrps(shank).Channels(Lia)+1);
                    fill([dev1' flip(dev2')],[nC flip(nC)],cmap(colidx,:),'FaceAlpha',.2,'EdgeColor','none')
                    plot(meansg(sessionInfo.AnatGrps(shank).Channels(Lia)+1),nC(Lia),'color',cmap(colidx,:),'LineWidth',1.5); 
                    ylabel('Channels'); xlabel('Power'); title('sg power')
                    set(gca,'YDir','reverse');

                    subplot((size(sessionInfo.AnatGrps,2)-1),4,4*(shank-1)+3)
                    hold on
                    dev1 = meanmg(sessionInfo.AnatGrps(shank).Channels(Lia)+1)-stdmg(sessionInfo.AnatGrps(shank).Channels(Lia)+1);
                    dev2 = meanmg(sessionInfo.AnatGrps(shank).Channels(Lia)+1)+stdmg(sessionInfo.AnatGrps(shank).Channels(Lia)+1);
                    fill([dev1' flip(dev2')],[nC flip(nC)],cmap(colidx,:),'FaceAlpha',.2,'EdgeColor','none')
                    plot(meanmg(sessionInfo.AnatGrps(shank).Channels(Lia)+1),nC(Lia),'color',cmap(colidx,:),'LineWidth',1.5); 
                    ylabel('Channels'); xlabel('Power'); title('mg power')
                    set(gca,'YDir','reverse');

                    subplot((size(sessionInfo.AnatGrps,2)-1),4,4*(shank-1)+4)
                    hold on
                    dev1 = meanhfo(sessionInfo.AnatGrps(shank).Channels(Lia)+1)-stdhfo(sessionInfo.AnatGrps(shank).Channels(Lia)+1);
                    dev2 = meanhfo(sessionInfo.AnatGrps(shank).Channels(Lia)+1)+stdhfo(sessionInfo.AnatGrps(shank).Channels(Lia)+1);
                    fill([dev1' flip(dev2')],[nC flip(nC)],cmap(colidx,:),'FaceAlpha',.2,'EdgeColor','none')
                    plot(meanhfo(sessionInfo.AnatGrps(shank).Channels(Lia)+1),nC(Lia),'color',cmap(colidx,:),'LineWidth',1.5); 
                    ylabel('Channels'); xlabel('Power'); title('hfo power')
                    set(gca,'YDir','reverse');
                end
            end

        end
    saveas(figure(nf),strcat(expPath,'\Summ\PowerProfile_',reg{ii},'_',target{jj},'.png'),'png');
    saveas(figure(nf),strcat(expPath,'\Summ\PowerProfile_',reg{ii},'_',target{jj},'.fig'),'fig');
    saveas(figure(nf),strcat(expPath,'\Summ\PowerProfile_',reg{ii},'_',target{jj},'.eps'),'epsc');
    nf = nf+1;
    end
end
end