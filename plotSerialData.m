function plotSerialData(src,~,ax,ax2,up_every)

v = read(src,up_every,'char');
v = extractBetween(v,'<','>');

if ~isempty(v)

    v = cellfun(@(x) eval(['[' x ']']),v,'UniformOutput',false);
    v = [v{:}];
    dat = [v(1:2:end)' v(2:2:end)'];
    ax.Children(1).set('Ydata',[ax.Children(1).YData(size(dat,1)+1:end) dat(:,1)'./1023]);
    ax2.Children(1).set('Ydata',[ax2.Children(1).YData(size(dat,1)+1:end) interp1([0 4095],[0 5],dat(:,2)')]);
    drawnow

end

end
