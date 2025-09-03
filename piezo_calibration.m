function[] = piezo_calibration(voltages)

if nargin < 1
    voltages = [0 1 2 3 4 5];
end

% parameters

serial_port = 'COM4';
n_disp = 5e3;
up_every = 2048;

%%
f = make_ui_figure(n_disp);

gl = get(f,'Children');
ax = gl.Children(1);
ax2 = gl.Children(2);
id_field = gl.Children(3);
pth_field = gl.Children(4);
btn_strt = gl.Children(6);
btn_set = gl.Children(7);
btn_plt = gl.Children(9);
btn_stop = gl.Children(10);

notes = gl.Children(25);

dat_lbls = gl.Children(13:2:23);
for i = 1:size(dat_lbls,1)
    dat_lbls(i).Text = num2str(voltages(i));
end

measure_fields = gl.Children(14:2:24);

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
s.configureCallback('byte',up_every, @(src,evt) plotSerialData(src, evt, ax, ax2, up_every));
s.flush;

chan_type = gl.Children(26).Value;
wave_type = gl.Children(28).Value;
dur_in = gl.Children(30).Value;
ipi_in = gl.Children(32).Value;
base_in = gl.Children(34).Value;
npulse_in = gl.Children(36).Value;

msg_out = ['<' chan_type ',' wave_type ',' dur_in ',' num2str(round(interp1([0,5],[0,4095],voltages(1)))) ',' ipi_in ',' npulse_in ',' base_in '>'];

write_serial(s,msg_out);

%%

go_on = true;
while go_on

    if f.UserData.Next 

        f.UserData.Next = false;

        % record whatever is in the prior field
        fprintf(data_fid,'%s,%s\n',measure_fields(cur_dat_field).Value,num2str(voltages(cur_dat_field)));

        % change the color to normal of prior voltage label
        dat_lbls(cur_dat_field).BackgroundColor = [0 0 0];

        % increment to next voltage
        cur_dat_field = cur_dat_field + 1;

        % if we're at the last voltage, wrap back around
        if cur_dat_field > numel(measure_fields)
            cur_dat_field = 1;
        end

        % tell the teensy to output this much
        v_out = num2str(round(interp1([0,5],[0,4095],voltages(cur_dat_field))));
        msg_out = ['<' chan_type ',' wave_type ',' dur_in ',' v_out ',' ipi_in ',' npulse_in ',' base_in '>'];
        write_serial(s,msg_out);  

        ax.Title.String = ['Now Doing Voltage ' num2str(voltages(cur_dat_field))];
        dat_lbls(cur_dat_field).BackgroundColor = [0 0.1 0.5];

    end

    if btn_set.Value
        btn_set.Value = false;
        chan_type = gl.Children(26).Value;
        wave_type = gl.Children(28).Value;
        dur_in = gl.Children(30).Value;
        ipi_in = gl.Children(32).Value;
        base_in = gl.Children(34).Value;
        npulse_in = gl.Children(36).Value;
        v_out = num2str(round(interp1([0,5],[0,4095],voltages(cur_dat_field))));
        msg_out = ['<' chan_type ',' wave_type ',' dur_in ',' v_out ',' ipi_in ',' npulse_in ',' base_in '>'];
        write_serial(s,msg_out);
    end

    if btn_plt.Value

        btn_plt.Value = false;
        fields = gl.Children(14:2:24);
        vals = zeros(size(fields));
        for i = 1:size(fields,1)
            vals(i) = str2double(fields(i).Value);
        end
        figure,
        plot(voltages,vals,'-ok')
        
    end

    if btn_stop.Value

        fprintf('\nAborted...\n')

        for i = 0:3
            msg_out = ['<' num2str(i) ',0,0,0,0,0,0>'];
            write_serial(s,msg_out);
        end
        
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









