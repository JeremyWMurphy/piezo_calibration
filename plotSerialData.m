function plotSerialData(src,~,fid,ax,ax2,up_every)

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
    ax2.Children(1).set('Ydata',[ax2.Children(1).YData(size(data,1)+1:end) data(:,2)'./4095]);
    ax2.Children(2).set('Ydata',[ax2.Children(2).YData(size(data,1)+1:end) data(:,3)']);

end

end
