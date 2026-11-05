function[] = piezo_calibration()

voltages = linspace(0.1,5,10);
step_size = 50;
steps = 50:step_size:1000;

% parameters
serial_port = 'COM6';
teensy_fs = 2e3;
n_disp = 5 * teensy_fs;
up_every = 2000;

ntrials = 50;
iti = 3;

teensy_stim = '<P,1>';
teensy_run_on = '<R,1>';
teensy_run_off = '<R,0>';

f = make_ui_figure(n_disp);

gl = get(f,'Children');

ax = gl.Children(1);

pth_field = gl.Children(3);
btn_set = gl.Children(8);

save_pth = pth_field.Text;
mkdir(save_pth);

% serial to talk to teensy waveform generator
s = serialport(serial_port,115200);
write_serial(s,teensy_run_off); % turn off streaming data and wave presenting if it's on for some reason
s.flush;

set(f, 'CloseRequestFcn', @(src,evt) window_close(src,evt,s));

chan_type = gl.Children(11).Value;
wave_type = gl.Children(13).Value;
dur_in = gl.Children(15).Value;
ipi_in = gl.Children(17).Value;
base_in = gl.Children(19).Value;
npulse_in = gl.Children(21).Value;

%%

s.configureCallback('byte',up_every, @(src,evt) plotSerialData(src, evt,f, ax, up_every));
pause(1)
write_serial(s,teensy_run_on)

go_on = true;
while go_on

    if btn_set.Value
        btn_set.Value = false;
        chan_type = gl.Children(11).Value;
        wave_type = gl.Children(13).Value;
        dur_in = gl.Children(15).Value;
        ipi_in = gl.Children(17).Value;
        base_in = gl.Children(19).Value;
        npulse_in = gl.Children(21).Value;
    end

    if f.UserData.state == 1 % cal sensor

        cals_fid = fopen([save_pth '\sensor_calibration_data.csv'],'w');
        fprintf(cals_fid,'Distance, Voltage\n');

        ax.Title.String('Move the sensor so it''s at the minimum voltage, then press any key')
        waitforbuttonpress
        for s = 1:num(steps)
            if f.UserData.state == 3
                break
            end
            ax.Title.String = ['Move Down ' num2str(step_size) 'um to'  num2str(steps(s)) 'um'];
            waitforbuttonpress
            val = f.UserData.sensor_voltage;
            fprintf(cals_fid,[num2str(steps(s)) ', ' num2str(val) '\n']);
        end

        fclose(cals_fid);
        ax.Title.String('Done ...')
        pause(3)
        f.UserData.state = 0;

    elseif f.UserData.state == 2 % cal piezo

        for v = 1:numel(voltages)

            configureCallback(s, 'off');

            v_str = num2str(voltages(v));
            v_str = strrep(v_str,'.','pt');
            fid = fopen([save_pth '\piezo_calibration_data_' v_str 'V.csv'],'w');

            s.configureCallback('byte',config.up_every, @(src,evt) plotAndSaveSerialData(src,evt,f,ax,up_every,fid));

            % tell the teensy to output this much
            v_out = num2str(round(interp1([0,5],[0,4095],voltages(v))));
            msg_out = ['<W,' chan_type ',' wave_type ',' dur_in ',' v_out ',' ipi_in ',' npulse_in ',' base_in '>'];
            write_serial(s,msg_out);
            ax.Title.String = ['Now Doing Voltage ' num2str(voltages(v))];

            for t = 1:ntrials

                ax.Title.String = ['Now Doing Voltage ' num2str(voltages(v)) ', Trial ' num2str(t) ' of ' num2str(ntrials)];
                pause(iti)
                write_serial(s,teensy_stim)

                if f.UserData.state == 3
                    break
                end

            end

            fclose(fid);

            if f.UserData.state == 3
                break
            end

        end

    elseif f.UserData.state == 3 % quit
        go_on = false;
    end

    pause(0.1)

end

end

fclose('all');
%stop io
configureCallback(s, 'off');
write(s,'<P,0>','string'); % no stims
write(s,'<R,0>','string'); % idle
clear s
% get rig of figure(s)
all_fig = findall(0, 'type', 'figure');
close(all_fig)

function[] = write_serial(s,msg)
write(s,msg,'string');
end

%% on window close
function[] = window_close(src,~,s)

fclose('all');
configureCallback(s, 'off');
%stop io
write(s,'<P,0>','string'); % no stims
write(s,'<R,0>','string'); % idle
clear s
delete(src);

end









