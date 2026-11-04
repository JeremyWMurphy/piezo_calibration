function[] = piezo_calibration(voltages)

if nargin < 1
    voltages = linspace(0.1,5,10);
end

% parameters
serial_port = 'COM6';
teensy_fs = 2e3;
n_disp = 5 * teensy_fs;
up_every = 500;

teensy_reset = '<S,1>';

data_folder_pth = 'C:\Users\ephys\Desktop\';

f = make_ui_figure(n_disp,data_folder_pth);

gl = get(f,'Children');
ax = gl.Children(1);
ax2 = gl.Children(2);
id_field = gl.Children(3);
pth_field = gl.Children(4);
btn_strt = gl.Children(6);
btn_set = gl.Children(7);
btn_stop = gl.Children(10);

<<<<<<< HEAD
dat_lbls = gl.Children(11:20);
for i = 1:size(dat_lbls,1)
=======

dat_lbls = gl.Children(13:2:32);
for i = 1:size(voltages,2)
>>>>>>> a9f7f5ddb8944feb81c264275e6a3601283a6d18
    dat_lbls(i).Text = num2str(voltages(i));
end

cur_dat_field = 1;

%% wait for start button push
waitfor(btn_strt,'Value',1);
f.UserData.Next = false;

id = id_field.Value;
save_pth = pth_field.Text;

exp_pth = [save_pth id];
mkdir(exp_pth);

ax.Title.String = ['Now Doing Voltage ' num2str(voltages(cur_dat_field+1))];
dat_lbls(cur_dat_field+1).BackgroundColor = [0 0.1 0.5];

%% serial to talk to teensy waveform generator
s = serialport(serial_port,115200);

pause(1)

s.flush;
write_serial(s,teensy_reset); % resetting teensy

chan_type = gl.Children(21).Value;
wave_type = gl.Children(23).Value;
dur_in = gl.Children(25).Value;
ipi_in = gl.Children(27).Value;
base_in = gl.Children(29).Value;
npulse_in = gl.Children(31).Value;

msg_out = ['<' chan_type ',' wave_type ',' dur_in ',' num2str(round(interp1([0,5],[0,4095],voltages(1)))) ',' ipi_in ',' npulse_in ',' base_in '>'];

write_serial(s,msg_out);

%%

go_on = true;
while go_on

    if f.UserData.Next

        f.UserData.Next = false;     
        configureCallback(s,'off');
        fl_val = strrep(num2str(voltages(cur_dat_field)),'.','pt');
        data_fid = fopen([exp_pth '\' fl_val 'v_calibration_data.csv'],'w');
        s.configureCallback('byte',up_every, @(src,evt) plotSerialData(src, evt, data_fid, ax, ax2, up_every));

        % change the color to normal of prior voltage label
        dat_lbls(cur_dat_field).BackgroundColor = [0 0 0];

        % increment to next voltage
        cur_dat_field = cur_dat_field + 1;

        % if we're at the last voltage, wrap back around
        if cur_dat_field > numel(dat_lbls)
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
        chan_type = gl.Children(33).Value;
        wave_type = gl.Children(35).Value;
        dur_in = gl.Children(37).Value;
        ipi_in = gl.Children(39).Value;
        base_in = gl.Children(41).Value;
        npulse_in = gl.Children(43).Value;
        v_out = num2str(round(interp1([0,5],[0,4095],voltages(cur_dat_field))));
        msg_out = ['<' chan_type ',' wave_type ',' dur_in ',' v_out ',' ipi_in ',' npulse_in ',' base_in '>'];
        write_serial(s,msg_out);
    end

<<<<<<< HEAD
=======
    if btn_plt.Value

        btn_plt.Value = false;
        vals = zeros(size(measure_fields));
        for i = 1:size(measure_fields,1)
            vals(i) = str2double(measure_fields(i).Value);
            fprintf(data_fid,'%s,%s\n',measure_fields(i).Value,num2str(voltages(i)));
        end
        mod_fit = fit(voltages',vals,'logistic4');      
        save([exp_pth '\model_fit.mat'],'mod_fit','voltages','vals');

    end

>>>>>>> a9f7f5ddb8944feb81c264275e6a3601283a6d18
    if btn_stop.Value

        fprintf('\nAborted...\n')

        for i = 0:3
            msg_out = ['<' num2str(i) ',0,0,0,0,0,0>'];
            write_serial(s,msg_out);
        end
        
        please_kill_me(s,data_fid);
        return

    end

    pause(0.1)
    
end

end

function[] = please_kill_me(s,data_fid)

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









