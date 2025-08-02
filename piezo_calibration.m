function[] = piezo_calibration(voltages)

if nargin < 1
    voltages = [1 2 3 4 5 6];
end

% parameters

serial_port = 'COM3';
n_disp = 1e3;
up_every = 256;


%%
f = make_ui_figure(n_disp);

gl = get(f,'Children');
ax = gl.Children(1);
id_field = gl.Children(2);
pth_field = gl.Children(3);
btn_strt = gl.Children(5);
btn_stop = gl.Children(6);
btn_nxt = gl.Children(7);
notes = gl.Children(22);

dat_lbls = gl.Children(10:2:21);
for i = 1:size(dat_lbls,1)
    dat_lbls(i).Text = num2str(voltages(i));
end

measure_fields = gl.Children(11:2:22);

cur_dat_field = 1;

%% wait for start button push
waitfor(btn_strt,'Value',1);

id = id_field.Value;
save_pth = pth_field.Text;

exp_pth = [save_pth id];
mkdir(exp_pth);
data_fid = fopen([exp_pth '\calibration_data.csv'],'w');
fprintf(data_fid,'%s\n',id);

ax.Title.String = ['Now Doing Voltage ' num2str(voltages(cur_dat_field))];
dat_lbls(cur_dat_field).BackgroundColor = [0 0.1 0.5];

%% serial to talk to teensy waveform generator
s = serialport(serial_port,115200);
s.configureCallback('byte',up_every, @(src,evt) plotSerialData(src, evt, ax, up_every));
s.flush;

%%

go_on = true;
while go_on

    if f.UserData.Next 

        f.UserData.Next = false;
        fprintf(data_fid,'%s\n',measure_fields(cur_data_field.Value));

        dat_lbls(cur_dat_field).BackgroundColor = [0 0 0];
        % write_serial(['<' voltages(cur_dat_field) '>'])
      
        cur_dat_field = cur_dat_field + 1;

        if cur_dat_field > numel(measure_fields)
            cur_dat_field = 1;
        end
  
        fprintf(['\n<' num2str(voltages(cur_dat_field)) '>'])
        ax.Title.String = ['Now Doing Voltage ' num2str(voltages(cur_dat_field))];
        dat_lbls(cur_dat_field).BackgroundColor = [0 0.1 0.5];

    end

    if btn_stop.Value
        fprintf('\nAborted...\n')
        please_kill_me(s,data_fid,notes);
        return
    end

    pause(0.001)
    
end

end

function[] = please_kill_me(s,data_fid,notes)

for i = 1:size(notes.Value,1)
    fprintf(data_fid,'%s\n',notes.Value{i});
end

s.delete;

% close files
fclose(data_fid);

daqreset

all_fig = findall(0, 'type', 'figure');
close(all_fig)

end

function[] = write_serial(s,msg)
write(s,msg,'string');
end









