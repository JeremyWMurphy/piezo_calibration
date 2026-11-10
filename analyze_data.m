%%
pth =   'C:\Users\jeremy\Desktop\Piezo_Calibration_2026-11-09_T20-16-27\';

fl = dir(fullfile(pth,'sensor*'));

sensor_calibration = readtable(fullfile(pth,fl(1).name));

[fitresult, gof] = fit(sensor_calibration.Voltage,sensor_calibration.Distance, 'poly1');

%%
pth =   'C:\Users\jeremy\Desktop\Piezo_Calibration_2026-11-09_T20-24-53\';

fls = dir(fullfile(pth,'*.csv'));

Fs = 2e3;
n_trials = 500;

pre = 0.1;
post = 0.5;
win = -Fs*pre:Fs*post;

EPs = zeros(numel(win),n_trials,size(fls,1));
volts = zeros(size(fls,1),1);
lbls = {};

for i = 1:size(fls,1)

    s = strsplit(fls(i).name,'_');
    s = s{4};
    s = strsplit(s,'V');
    s = s{1};
    v = str2double(strrep(s,'pt','.'));
    volts(i) = v;
    lbls{i} = num2str(v);

    fid = fopen([pth fls(i).name]);
    l1 = fgetl(fid);
    if ~isempty(l1) 
        if strcmp(l1(1),'<')
            frewind(fid)
        end
    end
    data = fscanf(fid,'<%d,%d,%d>\n');
    r = mod(size(data,1),3);
    data = data(1:end-r);
    data = reshape(data,3,size(data,1)/3);

    data(2,:) = (data(2,:)-2700)./1300; % this is kind of silly but it's how i centered/scaled the data in the gui, so the sensor calibration is in this form as well
    p_onsets = find(diff(data(3,:))>0.5);

    epochs = zeros(numel(win),numel(p_onsets));
    for j = 1:numel(p_onsets)
        epochs(:,j) = data(2,p_onsets(j)+win);
    end

    EPs(:,:,i) = epochs;

end

%%

[~,ix] = sort(volts);
EPs_sorted = EPs(:,:,ix);
volts = volts(ix);

%%

t = win/Fs;

EPs_sm = smoothdata(EPs_sorted,1,'movmed',[1 1]);

EPs_scaled = EPs_sm*fitresult.p1 + fitresult.p2;
bs = mean(EPs_scaled(t<0,:,:),1);
EPs_bs = EPs_scaled-bs;

pks = max(squeeze(mean(EPs_bs,2)));

figure, 
subplot(2,5,1)
plot(fitresult, sensor_calibration.Voltage,sensor_calibration.Distance);
title(['R-squared value: ' num2str(gof.rsquare)]);
xlabel('Voltage')
ylabel('Distance')

subplot(2,4,5)
plot(volts,pks,'-ok')
xlabel('Voltage in')
ylabel('Distance out')

subplot(2,4,[2 3 4 6 7 8])
plot(t,squeeze(mean(EPs_bs,2))) 
ylabel('Distance (um)')
xlabel('Time (Sec)')

exportgraphics(gcf,[pth 'data_fig.png'])

%%

save([pth 'calibration_result.mat'],'volts','EPs_sorted','sensor_calibration','fitresult')