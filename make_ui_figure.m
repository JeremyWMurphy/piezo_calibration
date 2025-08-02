function fig = make_ui_figure(n_disp)

default_id = char(datetime('now','format','yyyy-MM-dd''_T''HH-mm-ss'));

% main figure
fig = uifigure('Position',[1920/4,1080/4, 1024, 512],'Color','black');
gl = uigridlayout(fig,[8 10],'BackgroundColor','black');

% subj name field
edt = uieditfield(gl, 'Value',default_id, ...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);

edt.Layout.Row = 1;
edt.Layout.Column = [1 2];

% display and set save path field
pth_txt = uilabel(gl, ...
    'Text','C:\Users\jerem\Desktop\',...    
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);

pth_txt.Layout.Row = 1;
pth_txt.Layout.Column = [4 10];

pth_btn = uibutton(gl,...
    'BackgroundColor',[0 0 0],...
    'Text', 'Set Path',...
    'FontColor',[0 1 0],...
    "ButtonPushedFcn", @(src,event) pthButtonPushed(pth_txt));

pth_btn.Layout.Row = 1;
pth_btn.Layout.Column = 3;

% start button
strt_btn = uibutton(gl,'state',...
    'BackgroundColor',[0 0 0],...
    'Text', 'Start',...
    'FontColor',[0 1 0],...
    'Value', false);
strt_btn.Layout.Row = 10;
strt_btn.Layout.Column = 1;

% stop button
stp_btn = uibutton(gl,'state',...
    'BackgroundColor',[0 0 0],...
    'Text', 'Stop',...
    'FontColor',[0 1 0],...
    'Value', false);
stp_btn.Layout.Row = 10;
stp_btn.Layout.Column = 2;

% nxt button
nxt_btn = uibutton(gl,'Text','Next', ...
     'BackgroundColor',[0 0 0],...
    'Text', 'Next',...
    'FontColor',[0 1 0],...
    'ButtonPushedFcn', @(src,event) NextButtonPushed(fig));
nxt_btn.Layout.Row = 10;
nxt_btn.Layout.Column = 3;
fig.UserData.Next = false;


% 

dat_tbl_lbls = {};

%
dat_tbl_lbls{1} = uilabel(gl, ...
    'Text','voltage',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);

dat_tbl_lbls{1}.Layout.Row = 2;
dat_tbl_lbls{1}.Layout.Column = 3;

%
dat_tbl_lbls{2} = uilabel(gl, ...
    'Text','microns',...
    'BackgroundColor',[0 0 0],...
    'FontColor',[0 1 0]);
dat_tbl_lbls{2}.Layout.Row = 2;
dat_tbl_lbls{2}.Layout.Column = 4;

r = 3:8;
c = [3 4];

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
ax.Layout.Row = [2 10];
ax.Layout.Column = [5 10];
ax.NextPlot = 'add';
ax.Color = [0 0 0];
ax.XColor = [0 1 0];
ax.YColor = [0 1 0];
ax.XLabel.String = 'SECS';
ax.YLim = [-1 5];
ax.Title.Color = [1 0 1];
ax.Title.FontSize = 12;
ax.Title.FontWeight = 'normal';
ax.Title.String = 'Piezo Data';

ax.YTick = [0 1 2 3 4 5];
nan_vec = nan(n_disp,1);

plot(ax,1:n_disp,nan_vec,'m'); % piezo signal

notes = uitextarea(gl);
notes.Layout.Column = [1 2];
notes.Layout.Row = [2 9];
notes.BackgroundColor = [0 0 0];
notes.FontColor = [0 1 0];
notes.Value = {'notes here...'};

end

function pthButtonPushed(txt)
    selpath = uigetdir('C:\Users\jerem\Desktop\');
    txt.Text = selpath;
end

function NextButtonPushed(fig)
    fig.UserData.Next = true;
end


















