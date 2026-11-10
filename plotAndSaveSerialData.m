function plotAndSaveSerialData(src,~,f,ax,ax2,up_every,fid)

data = read(src,up_every,'char');

% write out raw data
fprintf(fid,'%s',data');

if ~isempty(data)

    strt = find(data=='<',1,'first');
    fin = find(data=='>',1,'last');
    data = data(strt:fin);
    data = sscanf(data,'<%d,%d,%d>\n');
    data = reshape(data,3,[])';

    data(:,2) = smoothdata(data(:,2),1,'movmean',[3 3]);
    data(:,2) = (data(:,2)-2700)./1300;
    ax.Children(2).set('Ydata',[ax.Children(2).YData(size(data,1)+1:end) data(:,2)' + 0]);
    ax2.Children(1).set('Ydata',[ax2.Children(1).YData(size(data,1)+1:end) (data(:,1)'./4095)]);
    ax2.Children(2).set('Ydata',[ax2.Children(2).YData(size(data,1)+1:end) (data(:,3)')]);

    f.UserData.sensor_voltage = mean(ax.Children(2).YData,'omitnan');
    ax.Children(1).String = num2str(round(f.UserData.sensor_voltage,3)); 

end

end
