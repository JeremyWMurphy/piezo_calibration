function plotAndSaveSerialData(src,~,f,ax,up_every,fid)

data = read(src,up_every,'char');

% write out raw data
fprintf(fid,'%s',data');

if ~isempty(data)

    strt = find(data=='<',1,'first');
    fin = find(data=='>',1,'last');
    data = data(strt:fin);

    data = sscanf(data,'<%d,%d,%d>\n');

    data = reshape(data,3,[])';

    %data(:,1) = smoothdata(data(:,1),1,'movmean',[10 10]);
    
    ax.Children(1).set('Ydata',[ax.Children(1).YData(size(data,1)+1:end) data(:,1)']);
    ax.Children(2).set('Ydata',[ax.Children(2).YData(size(data,1)+1:end) data(:,2)'./4095]);
    ax.Children(3).set('Ydata',[ax.Children(3).YData(size(data,1)+1:end) data(:,3)']);

    f.UserData.sensor_voltage = mean(ax.Children(2).YData);

end

end
