function[] = my_daq2()
% parameters

serial_port = 'COM5';



%% serial to talk to teensy waveform generator
s = serialport(serial_port,115200);


data = zeros(1,1000);

s.flush;

while true

    v = str2num(read(s,32,'char'));
    v = v(2:end-1);
    data = [data(numel(v):end) v' ];
    plot(data)
    drawnow
    fprintf(['\n' num2str(s.NumBytesAvailable)])
    %fprintf(['\n' v])


end










