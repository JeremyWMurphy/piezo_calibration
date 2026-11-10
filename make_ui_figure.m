function fig = make_ui_figure_calibrate(n_disp)

pth_main = ['C:\Users\' getenv('USERNAME') '\Desktop\'];
default_id = ['Piezo_Calibration_' char(datetime('now','format','yyyy-MM-dd''_T''HH-mm-ss'))];

%% main figure
fig = uifigure('Position',[1920/4,1080/4, 1024, 512],'Color','black');
fig.UserData = struct('state',0);
gl = uigridlayout(fig,[15 15],'BackgroundColor','black');

%% locations

% path and id
edit_name_loc = {1,[1 5]};
pth_txt_loc = {1,[7 13]};
pth_btn_loc = {1,6};
% state buttons
cals_btn_loc = {2,[1 2]};
calp_btn_loc = {2,[3 4]};
stp_btn_loc = {15,3};
next_btn_loc = {2,[5 6]};
% axis
ax_loc = {[3 10],[1 13]};
% axis
ax2_loc = {[10 14],[1 13]};
% waveform parameters
wave_header_loc = {1,[14 15]};

chan_lbl_loc = {2,14};
chan_dd_loc = {2,15};

wave_lbl_loc = {3,14};
wave_dd_loc = {3,15};
dur_lbl_loc = {4,14};
dur_edit_loc = {4,15};
ipi_lbl_loc = {5,14};
ipi_edit_loc = {5,15};
base_lbl_loc = {6,14};
base_edit_loc = {6,15};
rep_lbl_loc = {7,14};
rep_edit_loc = {7,15};
set_btn_loc = {8,[14 15]};

%% components

% subj name field
edt = uieditfield(gl, 'Value',default_id, ...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
edt.Layout.Row = edit_name_loc{1};
edt.Layout.Column = edit_name_loc{2};

% display and set save path field
pth_txt = uilabel(gl, ...
    'Text',pth_main,...    
    'BackgroundColor',[0 0 0],...
    'FontColor',[1 1 1], ...
    'FontSize', 16);
pth_txt.Layout.Row = pth_txt_loc{1};
pth_txt.Layout.Column = pth_txt_loc{2};

% set path button
pth_btn = uibutton(gl,...
    'BackgroundColor',[0 0 0],...
    'Text', 'Set Path',...
    'FontColor',[0 1 0],...
    'ButtonPushedFcn', @(src,event) pthButtonPushed(pth_txt,pth));
pth_btn.Layout.Row = pth_btn_loc{1};
pth_btn.Layout.Column = pth_btn_loc{2};

% calibrate sensor
cals_btn = uibutton(gl,...
    'BackgroundColor',[0 0 0],...
    'Text', 'Cal Sensor',...
    'FontColor',[0 1 0],...
    'ButtonPushedFcn', @(src,event) setState(fig,1));
cals_btn.Layout.Row = cals_btn_loc{1};
cals_btn.Layout.Column = cals_btn_loc{2};

% run piezo calibration
calp_btn = uibutton(gl,...
    'BackgroundColor',[0 0 0],...
    'Text', 'Cal Piezo',...
    'FontColor',[0 1 0],...
    'ButtonPushedFcn', @(src,event) setState(fig,2));
calp_btn.Layout.Row = calp_btn_loc{1};
calp_btn.Layout.Column = calp_btn_loc{2};

% quit button
stp_btn = uibutton(gl,...
    'BackgroundColor',[0 0 0],...
    'Text', 'Quit',...
    'FontColor',[0 1 0],...
    'ButtonPushedFcn', @(src,event) setState(fig,3));
stp_btn.Layout.Row = stp_btn_loc{1};
stp_btn.Layout.Column = stp_btn_loc{2};

% set parameters button
set_btn = uibutton(gl,'state',...
    'BackgroundColor',[0 0 0],...
    'Text', 'Set Params',...
    'FontColor',[0 1 0],...
    'Value', false);
set_btn.Layout.Row = set_btn_loc{1};
set_btn.Layout.Column = set_btn_loc{2};

% main axes
ax = axes(gl);
ax.Layout.Row = ax_loc{1};
ax.Layout.Column = ax_loc{2};
ax.NextPlot = 'add';
ax.Color = [0 0 0];
ax.XColor = [1 1 1];
ax.YColor = [1 1 1];
ax.YLim = [0 1];
ax.Title.Color = [1 0 1];
ax.Title.FontSize = 12;
ax.Title.FontWeight = 'normal';
ax.Title.String = '';
ax.XAxis.Visible  = 'off';
ax.YTick = [0];
ax.XTick = [];
ax.YTickLabel = {'Sensor'};
ax.LineWidth = 1;

nan_vec = nan(n_disp,1);
plot(ax,1:n_disp,nan_vec,'m');
ax.Children(1).LineWidth = 1;
text(ax,n_disp-(n_disp/10),0.5,'NAN','Color','m','FontSize',14);


% main axes
ax2 = axes(gl);
ax2.Layout.Row = ax2_loc{1};
ax2.Layout.Column = ax2_loc{2};
ax2.NextPlot = 'add';
ax2.Color = [0 0 0];
ax2.XColor = [1 1 1];
ax2.YColor = [1 1 1];
ax2.YLim = [-0.1 1.1];
ax2.Title.Color = [1 0 1];
ax2.Title.FontSize = 12;
ax2.Title.FontWeight = 'normal';
ax2.Title.String = '';
ax2.XAxis.Visible  = 'off';
ax2.YTick = [0];
ax2.YTickLabel = {'Piezo'};
ax2.XTick = [];
ax2.LineWidth = 1;

nan_vec = nan(n_disp,1);
plot(ax2,1:n_disp,nan_vec,'c');
plot(ax2,1:n_disp,nan_vec,'y');
ax2.Children(1).LineWidth = 1;
ax2.Children(2).LineWidth = 1;

wave_hdr = uilabel(gl, ...
    'Text','Wave Params:',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0], ...
    'FontSize',14);
wave_hdr.Layout.Row = wave_header_loc{1};
wave_hdr.Layout.Column = wave_header_loc{2};

chan_lbl = uilabel(gl, ...
    'Text','Channel:',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
chan_lbl.Layout.Row = chan_lbl_loc{1};
chan_lbl.Layout.Column = chan_lbl_loc{2};

chan_dd = uidropdown(gl,Items={'0','1','2','3'},ItemsData=['0';'1';'2';'3']);
chan_dd.Layout.Row = chan_dd_loc{1};
chan_dd.Layout.Column = chan_dd_loc{2};
chan_dd.FontColor = [0 1 0];
chan_dd.BackgroundColor = [0 0 0];

wave_lbl = uilabel(gl, ...
    'Text','Waveform:',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
wave_lbl.Layout.Row = wave_lbl_loc{1};
wave_lbl.Layout.Column = wave_lbl_loc{2};

wave_dd = uidropdown(gl,Items={'Whale','Square','Ramp up', 'Ramp down', 'Pyramid'},ItemsData=['0';'1';'2';'3';'4']);
wave_dd.Layout.Row = wave_dd_loc{1};
wave_dd.Layout.Column = wave_dd_loc{2};
wave_dd.FontColor = [0 1 0];
wave_dd.BackgroundColor = [0 0 0];

dur_lbl = uilabel(gl, ...
    'Text','Duration:',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
dur_lbl.Layout.Row = dur_lbl_loc{1};
dur_lbl.Layout.Column = dur_lbl_loc{2};

dur_edit = uieditfield(gl, 'Value','40', ...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
dur_edit.Layout.Row = dur_edit_loc{1};
dur_edit.Layout.Column = dur_edit_loc{2};

IPI_lbl = uilabel(gl, ...
    'Text','Inter-pulse-interval:',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
IPI_lbl.Layout.Row = ipi_lbl_loc{1};
IPI_lbl.Layout.Column = ipi_lbl_loc{2};

IPI_edit = uieditfield(gl, 'Value','0', ...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
IPI_edit.Layout.Row = ipi_edit_loc{1};
IPI_edit.Layout.Column = ipi_edit_loc{2};

base_lbl = uilabel(gl, ...
    'Text','Baseline:',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
base_lbl.Layout.Row = base_lbl_loc{1};
base_lbl.Layout.Column = base_lbl_loc{2};

base_edit = uieditfield(gl, 'Value','0', ...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
base_edit.Layout.Row = base_edit_loc{1};
base_edit.Layout.Column = base_edit_loc{2};

rep_lbl = uilabel(gl, ...
    'Text','N Pulses:',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
rep_lbl.Layout.Row = rep_lbl_loc{1};
rep_lbl.Layout.Column = rep_lbl_loc{2};

rep_edit = uieditfield(gl, 'Value','5', ...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
rep_edit.Layout.Row = rep_edit_loc{1};
rep_edit.Layout.Column = rep_edit_loc{2};

% set parameters button
next_btn = uibutton(gl,'state',...
    'BackgroundColor',[0 0 0],...
    'Text', 'Next',...
    'FontColor',[0 1 0],...
    'Value', false);
next_btn.Layout.Row = next_btn_loc{1};
next_btn.Layout.Column = next_btn_loc{2};

end

function pthButtonPushed(txt,pth)
    selpath = uigetdir(pth);
    txt.Text = selpath;
end

function setState(fig,st)
    fig.UserData.state = st;
end


















