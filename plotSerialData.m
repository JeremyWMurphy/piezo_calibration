function plotSerialData(src,evt,ax,up_every)

v = str2num(read(src,up_every,'char'));
v = v(2:end-1);
v = 5 * v/1023;
ax.Children(1).set('Ydata',[ax.Children(1).YData(numel(v)+1:end) v']);
drawnow

end
