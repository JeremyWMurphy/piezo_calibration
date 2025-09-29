function fig = make_ui_figure(n_disp,pth)

edit_name_loc = {1,[1 2]};
pth_txt_loc = {1,[4 10]};
pth_btn_loc = {1,3};
strt_btn_loc = {15,1};
set_btn_loc = {15,2};
nxt_btn_loc = {15,3};
plt_btn_loc = {15,4};
stp_btn_loc = {15,15};

ax_loc = {[2 10],[4 14]};

chan_lbl_loc = {1,15};
chan_dd_loc = {2,15};
wave_lbl_loc = {3,15};
wave_dd_loc = {4,15};
dur_edit_loc = {6,15};
dur_lbl_loc = {5,15};
ipi_edit_loc = {8,15};
ipi_lbl_loc = {7,15};
base_edit_loc = {10,15};
base_lbl_loc = {9,15};
rep_edit_loc = {12,15};
rep_lbl_loc = {11,15};

ax2_loc = {[11 15],[4 14]};

default_id = char(datetime('now','format','yyyy-MM-dd''_T''HH-mm-ss'));

% main figure
fig = uifigure('Position',[1920/4,1080/4, 1024, 512],'Color','black');
gl = uigridlayout(fig,[15 15],'BackgroundColor','black');

% subj name field
edt = uieditfield(gl, 'Value',default_id, ...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
edt.Layout.Row = edit_name_loc{1};
edt.Layout.Column = edit_name_loc{1};

% display and set save path field
pth_txt = uilabel(gl, ...
    'Text',pth,...    
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
pth_txt.Layout.Row = pth_txt_loc{1};
pth_txt.Layout.Column = pth_txt_loc{1};

% set path button
pth_btn = uibutton(gl,...
    'BackgroundColor',[0 0 0],...
    'Text', 'Set Path',...
    'FontColor',[0 1 0],...
    "ButtonPushedFcn", @(src,event) pthButtonPushed(pth_txt,pth));
pth_btn.Layout.Row = pth_btn_loc{1};
pth_btn.Layout.Column = pth_btn_loc{2};

% start button
strt_btn = uibutton(gl,'state',...
    'BackgroundColor',[0 0 0],...
    'Text', 'Start',...
    'FontColor',[0 1 0],...
    'Value', false);
strt_btn.Layout.Row = strt_btn_loc{1};
strt_btn.Layout.Column = strt_btn_loc{2};

% set parameters button
set_btn = uibutton(gl,'state',...
    'BackgroundColor',[0 0 0],...
    'Text', 'Set',...
    'FontColor',[0 1 0],...
    'Value', false);
set_btn.Layout.Row = set_btn_loc{1};
set_btn.Layout.Column = set_btn_loc{2};

% next button
nxt_btn = uibutton(gl,'Text','Next', ...
     'BackgroundColor',[0 0 0],...
    'Text', 'Next',...
    'FontColor',[0 1 0],...
    'ButtonPushedFcn', @(src,event) NextButtonPushed(fig));
nxt_btn.Layout.Row = nxt_btn_loc{1};
nxt_btn.Layout.Column = nxt_btn_loc{2};
fig.UserData.Next = false;

% plot button
plt_btn = uibutton(gl,'state',...
    'BackgroundColor',[0 0 0],...
    'Text', 'Plot',...
    'FontColor',[0 1 0],...
    'Value', false);
plt_btn.Layout.Row = plt_btn_loc{1};
plt_btn.Layout.Column = plt_btn_loc{2};

% stop button
stp_btn = uibutton(gl,'state',...
    'BackgroundColor',[0 0 0],...
    'Text', 'Quit',...
    'FontColor',[0 1 0],...
    'Value', false);
stp_btn.Layout.Row = stp_btn_loc{1};
stp_btn.Layout.Column = stp_btn_loc{2};

% column of voltage labels, and edit boxes for entering distance
dat_tbl_lbls = {};

dat_tbl_lbls{1} = uilabel(gl, ...
    'Text','voltage',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);

dat_tbl_lbls{1}.Layout.Row = 2;
dat_tbl_lbls{1}.Layout.Column = 2;

dat_tbl_lbls{2} = uilabel(gl, ...
    'Text','microns',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
dat_tbl_lbls{2}.Layout.Row = 2;
dat_tbl_lbls{2}.Layout.Column = 3;

r = 3:12;
c = [2 3];

vlbls = {};
dat_tbl = {};
for i = 1:numel(r)

    vlbls{i} = uilabel(gl, ...
        'Text','-',...
        'BackgroundColor',[0 0 0],...
        'FontColor',[0 1 0]);
    vlbls{i}.Layout.Row = r(i);
    vlbls{i}.Layout.Column = c(1);

    dat_tbl{i} = uieditfield(gl, 'Value','0', ...
        'BackgroundColor',[0 0 0],...
        'FontColor',[0 1 0]);
    dat_tbl{i}.Layout.Row = r(i);
    dat_tbl{i}.Layout.Column = c(2);
       
end

% main axes
ax = axes(gl);
ax.Layout.Row = ax_loc{1};
ax.Layout.Column = ax_loc{2};
ax.NextPlot = 'add';
ax.Color = [0 0 0];
ax.XColor = [0 1 0];
ax.YColor = [0 1 0];
ax.YLim = [-0.1 1.1];
ax.Title.Color = [1 0 1];
ax.Title.FontSize = 12;
ax.Title.FontWeight = 'normal';
ax.Title.String = 'Beam-Break Data';
ax.YTick = [-1 0 1 2];
ax.XTick = [];
ax.LineWidth = 1;

nan_vec = nan(n_disp,1);
plot(ax,1:n_disp,nan_vec,'m'); % piezo signal
ax.Children(1).LineWidth = 2;

chan_dd = uidropdown(gl,Items={'0','1','2','3'},ItemsData=['0';'1';'2';'3']);
chan_dd.Layout.Row = chan_dd_loc{1};
chan_dd.Layout.Column = chan_dd_loc{2};
chan_dd.FontColor = [0 1 0];
chan_dd.BackgroundColor = [0 0 0];
chan_lbl = uilabel(gl, ...
    'Text','Channel:',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
chan_lbl.Layout.Row = chan_lbl_loc{1};
chan_lbl.Layout.Column = chan_lbl_loc{2};

wave_dd = uidropdown(gl,Items={'Whale','Square','Ramp up', 'Ramp down', 'Pyramid'},ItemsData=['0';'1';'2';'3';'4']);
wave_dd.Layout.Row = wave_dd_loc{1};
wave_dd.Layout.Column = wave_dd_loc{2};
wave_dd.FontColor = [0 1 0];
wave_dd.BackgroundColor = [0 0 0];
wave_lbl = uilabel(gl, ...
    'Text','Waveform:',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
wave_lbl.Layout.Row = wave_lbl_loc{1};
wave_lbl.Layout.Column = wave_lbl_loc{2};

dur_edit = uieditfield(gl, 'Value','40', ...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
dur_edit.Layout.Row = dur_edit_loc{1};
dur_edit.Layout.Column = dur_edit_loc{2};
dur_lbl = uilabel(gl, ...
    'Text','Duration:',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
dur_lbl.Layout.Row = dur_lbl_loc{1};
dur_lbl.Layout.Column = dur_lbl_loc{2};

IPI_edit = uieditfield(gl, 'Value','0', ...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
IPI_edit.Layout.Row = ipi_edit_loc{1};
IPI_edit.Layout.Column = ipi_edit_loc{2};
IPI_lbl = uilabel(gl, ...
    'Text','Inter-pulse-interval:',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
IPI_lbl.Layout.Row = ipi_lbl_loc{1};
IPI_lbl.Layout.Column = ipi_lbl_loc{2};

base_edit = uieditfield(gl, 'Value','0', ...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
base_edit.Layout.Row = base_edit_loc{1};
base_edit.Layout.Column = base_edit_loc{2};
base_lbl = uilabel(gl, ...
    'Text','Baseline:',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
base_lbl.Layout.Row = base_lbl_loc{1};
base_lbl.Layout.Column = base_lbl_loc{2};

rep_edit = uieditfield(gl, 'Value','5', ...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
rep_edit.Layout.Row = rep_edit_loc{1};
rep_edit.Layout.Column = rep_edit_loc{2};
rep_lbl = uilabel(gl, ...
    'Text','N Pulses:',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
rep_lbl.Layout.Row = rep_lbl_loc{1};
rep_lbl.Layout.Column = rep_lbl_loc{2};

ax2 = axes(gl);
ax2.Layout.Row = ax2_loc{1};
ax2.Layout.Column = ax2_loc{2};
ax2.NextPlot = 'add';
ax2.Color = [0 0 0];
ax2.XColor = [0 1 0];
ax2.YColor = [0 1 0];
ax2.YLim = [-0.1 5.1];
ax2.Title.Color = [1 0 1];
ax2.Title.FontSize = 12;
ax2.Title.FontWeight = 'normal';
ax2.Title.String = 'Piezo Data';
ax2.YTick = [-1 0 2 4 6];
ax2.XTick = [];
ax2.LineWidth = 1;
plot(ax2,1:n_disp,nan_vec,'y'); % piezo signal
ax2.Children.LineWidth = 1;

end

function pthButtonPushed(txt,pth)
    selpath = uigetdir(pth);
    txt.Text = selpath;
end

function NextButtonPushed(fig)
    fig.UserData.Next = true;
end


















