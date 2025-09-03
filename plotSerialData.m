function plotSerialData(src,~,ax,ax2,up_every)

data = read(src,up_every,'char');

if ~isempty(data)

    strt = find(data=='<',1,'first');
    fin = find(data=='>',1,'last');
    data = data(strt:fin);
    data = sscanf(data,'<%d,%d>\n');    
    data = reshape(data,2,[])';
    ax.Children(1).set('Ydata',[ax.Children(1).YData(size(data,1)+1:end) data(:,1)'./1023]);
    ax2.Children(1).set('Ydata',[ax2.Children(1).YData(size(data,1)+1:end) interp1([0 4095],[0 5],data(:,2)')]);

end

end
