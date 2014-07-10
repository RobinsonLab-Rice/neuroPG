function f = configNeuroPG(varargin)

disp(numel(varargin))

fpath = which('neuroPG');
fpath = fpath(1:end-9);
fname = 'neuroPG.config';
if exist([fpath,fname],'file')
    copyfile([fpath,fname],[fpath,fname,'.bak']);
end
f = figure('Units','pixels','MenuBar','none','IntegerHandle','off','Name', ... 
    'neuroPG Configuration Tool','NumberTitle','off','Resize','off','Tag', ...
    'neuroPGConfig','CloseRequestFcn',@mainCRF);
pos = get(f,'Position');
pos(3:4) = [300,300];
set(f,'Position',pos);
uicontrol(f,'Style','PushButton','Units','normalized','Position',[.1,.1,.8,.1], ...
    'String','Configure neuroPG Settings','Callback',@settingsCBF);
uicontrol(f,'Style','PushButton','Units','normalized','Position',[.1,.35,.8,.1], ...
    'String','Configure neuroPG DAQ','Callback',@DAQCBF);
uicontrol(f,'Style','PushButton','Units','normalized','Position',[.1,.6,.8,.1], ...
    'String','Configure neuroPG Camera','Callback',@cameraCBF);
uicontrol(f,'Style','PushButton','Units','normalized','Position',[.1,.85,.8,.1], ...
    'String','Configure neuroPG Windows','Callback',@windowsCBF);


function settingsCBF(~,~)
configSettings(0);


function DAQCBF(~,~)
configDAQ(0);


function cameraCBF(~,~)
configCamera(0);


function windowsCBF(~,~)
configWindows(0);


function mainCRF(obj,~)
UD = get(obj,'UserData');
for i = 1:numel(UD)
    if ishandle(UD{i})
        close(UD{i});
    end
end
delete(obj);


function configSettings(varargin)
fpath = which('neuroPG');
fpath = fpath(1:end-9);
fname = 'neuroPG.config';
if exist([fpath,fname],'file')
    settings = load([fpath,fname],'-mat');
    if numel(varargin) > 0 && varargin{1} == 1
        copyfile([fpath,fname],[fpath,fname,'.bak']);
    end
end
f = figure('Units','pixels','MenuBar','none','IntegerHandle','off','Name', ... 
    'neuroPG Settings','NumberTitle','off','Resize','off');
pos = get(f,'Position');
pos(3:4) = [350,400];
set(f,'Position',pos);

uicontrol(f,'Style','PushButton','Units','normalized','Position',[.05,.925,.9,.05], ...
    'String','Select Default File Path','Callback',{@selectSavePath,f});
h = uicontrol(f,'Style','Edit','Units','normalized','Position',[.05,.875,.9,.05], ...
    'String','','Tag','savePathEdit');
if isfield(settings,'savePath')
    set(h,'String',settings.savePath);
end

uicontrol(f,'Style','PushButton','Units','normalized','Position',[.05,.775,.9,.05], ...
    'String','Select Default Snapshot Path','Callback',{@selectSnapPath,f});
h = uicontrol(f,'Style','Edit','Units','normalized','Position',[.05,.725,.9,.05], ...
    'String','','Tag','snapPathEdit');
if isfield(settings,'snapshotSavePath')
    set(h,'String',settings.snapshotSavePath);
end

uicontrol(f,'Style','PushButton','Units','normalized','Position',[.05,.625,.9,.05], ...
    'String','Enter Default File Name','Enable','inactive');
h = uicontrol(f,'Style','Edit','Units','normalized','Position',[.05,.575,.9,.05], ...
    'String','','Tag','fileNameEdit');
if isfield(settings,'fileName')
    set(h,'String',settings.fileName);
end

uicontrol(f,'Style','PushButton','Units','normalized','Position',[.05,.475,.9,.05], ...
    'String','Enter DMD Visible Pixel Parameters','Enable','inactive');

uicontrol(f,'Style','PushButton','Units','normalized','Position',[.05,.425,.2,.05], ...
    'String','Min Width','Enable','inactive');
h = uicontrol(f,'Style','Edit','Units','normalized','Position',[.05,.375,.2,.05], ...
    'String','','Tag','DMDMinWidth');
if isfield(settings,'DMDMinWidth')
    set(h,'String',num2str(settings.DMDMinWidth));
end

uicontrol(f,'Style','PushButton','Units','normalized','Position',[.25,.425,.2,.05], ...
    'String','Max Width','Enable','inactive');
h = uicontrol(f,'Style','Edit','Units','normalized','Position',[.25,.375,.2,.05], ...
    'String','','Tag','DMDMaxWidth');
if isfield(settings,'DMDMaxWidth')
    set(h,'String',num2str(settings.DMDMaxWidth));
end

uicontrol(f,'Style','PushButton','Units','normalized','Position',[.55,.425,.2,.05], ...
    'String','Min Height','Enable','inactive');
h = uicontrol(f,'Style','Edit','Units','normalized','Position',[.55,.375,.2,.05], ...
    'String','','Tag','DMDMinHeight');
if isfield(settings,'DMDMinHeight')
    set(h,'String',num2str(settings.DMDMinHeight));
end

uicontrol(f,'Style','PushButton','Units','normalized','Position',[.75,.425,.2,.05], ...
    'String','Max Height','Enable','inactive');
h = uicontrol(f,'Style','Edit','Units','normalized','Position',[.75,.375,.2,.05], ...
    'String','','Tag','DMDMaxHeight');
if isfield(settings,'DMDMaxHeight')
    set(h,'String',num2str(settings.DMDMaxHeight));
end
uicontrol(f,'Style','Push','Units','normalized','Position',[.05,.325,.7,.05], ...
    'String','Select DMD Orientation Relative to Camera','Enable','inactive');
str = {'Aligned','Vertical Flip','Horizontal Flip','Both Flipped', ...
    ['90',176],['90',176,' Vertical Flip'],['90',176,' Horizontal Flip'], ...
    ['90',176,' Both Flipped']};
h = uicontrol(f,'Style','PopUp','Units','normalized','Position',[.75,.325,.2,.05], ...
    'String',str,'Tag','DMDOrientation');
if isfield(settings,'DMDOrientation')
    set(h,'Value',settings.DMDOrientation);
end

uicontrol(f,'Style','PushButton','Units','normalized','Position',[.05,.225,.9,.05], ...
    'String','Enter DAQ Sgnal Scaling Factors (V/V or A/V)','Enable','inactive');

uicontrol(f,'Style','PushButton','Units','normalized','Position',[.05,.175,.2,.05], ...
    'String','Ch1 V Clamp','Enable','inactive');
h = uicontrol(f,'Style','Edit','Units','normalized','Position',[.05,.125,.2,.05], ...
    'String','','Tag','DAQCh1VClamp');
if isfield(settings,'DAQCh1VClamp')
    set(h,'String',num2str(settings.DAQCh1VClamp));
end

uicontrol(f,'Style','PushButton','Units','normalized','Position',[.25,.175,.2,.05], ...
    'String','Ch1 C Clamp','Enable','inactive');
h = uicontrol(f,'Style','Edit','Units','normalized','Position',[.25,.125,.2,.05], ...
    'String','','Tag','DAQCh1CClamp');
if isfield(settings,'DAQCh1CClamp')
    set(h,'String',num2str(settings.DAQCh1CClamp));
end

uicontrol(f,'Style','PushButton','Units','normalized','Position',[.55,.175,.2,.05], ...
    'String','Ch2 V Clamp','Enable','inactive');
h = uicontrol(f,'Style','Edit','Units','normalized','Position',[.55,.125,.2,.05], ...
    'String','','Tag','DAQCh2VClamp');
if isfield(settings,'DAQCh2VClamp')
    set(h,'String',num2str(settings.DAQCh2VClamp));
end

uicontrol(f,'Style','PushButton','Units','normalized','Position',[.75,.175,.2,.05], ...
    'String','Ch2 C Clamp','Enable','inactive');
h = uicontrol(f,'Style','Edit','Units','normalized','Position',[.75,.125,.2,.05], ...
    'String','','Tag','DAQCh2CClamp');
if isfield(settings,'DAQCh2CClamp')
    set(h,'String',num2str(settings.DAQCh2CClamp));
end

uicontrol(f,'Style','PushButton','Units','normalized','Position',[.05,.025,.9,.05], ...
    'String','Save Settings','Callback',{@saveSettings,f,settings,[fpath,fname]});


function selectSavePath(~,~,f)
path = uigetdir();
path = [path,'\'];
set(findall(f,'Tag','savePathEdit'),'String',path);


function selectSnapPath(~,~,f)
path = uigetdir();
path = [path,'\'];
set(findall(f,'Tag','snapPathEdit'),'String',path);


function saveSettings(~,~,f,s,name)
s.savePath = get(findall(f,'Tag','savePathEdit'),'String');
s.snapshotSavePath = get(findall(f,'Tag','snapPathEdit'),'String');
s.fileName = get(findall(f,'Tag','fileNameEdit'),'String');
s.DMDMinWidth = str2double(get(findall(f,'Tag','DMDMinWidth'),'String'));
s.DMDMaxWidth = str2double(get(findall(f,'Tag','DMDMaxWidth'),'String'));
s.DMDMinHeight = str2double(get(findall(f,'Tag','DMDMinHeight'),'String'));
s.DMDMaxHeight= str2double(get(findall(f,'Tag','DMDMaxHeight'),'String'));
s.DMDOrientation = get(findall(f,'Tag','DMDOrientation'),'Value');
s.DAQCh1VClamp = str2double(get(findall(f,'Tag','DAQCh1VClamp'),'String'));
s.DAQCh1CClamp = str2double(get(findall(f,'Tag','DAQCh1CClamp'),'String'));
s.DAQCh2VClamp = str2double(get(findall(f,'Tag','DAQCh2VClamp'),'String'));
s.DAQCh2CClamp = str2double(get(findall(f,'Tag','DAQCh2CClamp'),'String'));
save(name,'-struct','s','-mat');
delete(f)


function configDAQ(varargin)
fpath = which('neuroPG');
fpath = fpath(1:end-9);
fname = 'neuroPG.config';
if exist([fpath,fname],'file')
    settings = load([fpath,fname],'-mat');
    if numel(varargin) > 0 && varargin{1} == 1
        copyfile([fpath,fname],[fpath,fname,'.bak']);
    end
end
resp = questdlg('Reset DAQ to detect new hardware?','neuroPG DAQ','No');
if isempty(resp) || strcmp('Cancel',resp)
    return;
elseif strcmp('Yes',resp)
    daq.reset;
end
devices = daq.getDevices;
if isempty(devices)
    warndlg('No DAQ Hardware Detected','neuroPG DAQ');
    return;
end
for i = 1:numel(devices)
    info{i} = get(devices(i));
    descriptions{i} = info{i}.Description;
    channels = {'',''};
    for j = 1:numel(info{i}.Subsystems)
        switch info{i}.Subsystems(j).SubsystemType
            case 'AnalogInput'
                channels{i,1} = info{i}.Subsystems(j).ChannelNames;
            case 'CounterOutput'
                channels{i,2} = info{i}.Subsystems(j).ChannelNames;
        end
    end
end
f = figure('Units','pixels','MenuBar','none','IntegerHandle','off', ...
    'Name','neuroPG DAQ Hardware','NumberTitle','off','UserData',settings);
pos = get(f,'Position');
pos(1) = pos(1) - 320;
pos(3:4) = [640,300];
set(f,'Position',pos);

UD.info = info;
UD.channels = channels;

uicontrol(f,'Style','Text','Position',[10,270,200,20],'BackgroundColor',[.8,.8,.8],...
    'String','Available Hardware','HorizontalAlignment','left');
uicontrol(f,'Style','Text','Position',[210,270,35,20],'BackgroundColor',[.8,.8,.8],...
    'String','','HorizontalAlignment','right','Tag','ID','Foreground','b');
uicontrol(f,'Style','Listbox','Position',[10,10,255,260],'Tag','Devices','String', ...
    descriptions,'Callback',@devicesCBF,'UserData',UD);
set(findall(f,'Tag','ID'),'String',info{1}.ID);

uicontrol(f,'Style','Text','Position',[275,270,100,20],'BackgroundColor', ...
    [.8,.8,.8],'String','Analog Input','HorizontalAlignment','left');
uicontrol(f,'Style','Text','Position',[375,270,35,20],'BackgroundColor',[.8,.8,.8],...
    'String','','HorizontalAlignment','right','Tag','ACh','Foreground','b');
uicontrol(f,'Style','Listbox','Position',[275,155,155,115],'Tag','Analog','String',...
    channels{1,1},'Callback',@analogCBF);
set(findall(f,'Tag','ACh'),'String',channels{1,1}{1});

uicontrol(f,'Style','Text','Position',[275,125,100,20],'BackgroundColor', ...
    [.8,.8,.8],'String','Timer/Counter','HorizontalAlignment','left');
uicontrol(f,'Style','Text','Position',[375,125,35,20],'BackgroundColor',[.8,.8,.8],...
    'String','','HorizontalAlignment','right','Tag','PCh','Foreground','b');
uicontrol(f,'Style','Listbox','Position',[275,10,155,115],'Tag','Pulse','String', ...
    channels{1,2},'Callback',@pulseCBF);
set(findall(f,'Tag','PCh'),'String',channels{1,2}{1});

uicontrol(f,'Style','PushButton','Position',[440,240,100,30],'UserData',0,'String',...
    'Set Input Ch1','Tag','Ch1B','Enable','off','Callback',@ch1CBF);
uicontrol(f,'Style','Text','Position',[550,240,80,22],'Background',[.8,.8,.8], ...
    'Foreground','b','Tag','Ch1S');

uicontrol(f,'Style','PushButton','Position',[440,200,100,30],'UserData',0,'String',...
    'Set Input Ch2','Tag','Ch2B','Enable','off','Callback',@ch2CBF);
uicontrol(f,'Style','Text','Position',[550,200,80,22],'Background',[.8,.8,.8], ...
    'Foreground','b','Tag','Ch2S');

uicontrol(f,'Style','PushButton','Position',[440,160,100,30],'UserData',0,'String',...
    'Set Input Ch3','Tag','Ch3B','Enable','off','Callback',@ch3CBF);
uicontrol(f,'Style','Text','Position',[550,160,80,22],'Background',[.8,.8,.8], ...
    'Foreground','b','Tag','Ch3S');

if ~isempty(channels{1,1}{1})
    set(findall(f,'Tag','Ch1B'),'Enable','on');
    set(findall(f,'Tag','Ch2B'),'Enable','on');
    set(findall(f,'Tag','Ch3B'),'Enable','on');
end

uicontrol(f,'Style','PushButton','Position',[440,70,100,30],'UserData',0,'String', ...
    'Set Pulse Channel','Tag','PulseB','Enable','off','Callback',@pulseBCBF);
uicontrol(f,'Style','Text','Position',[550,70,80,22],'Background',[.8,.8,.8], ...
    'Foreground','b','Tag','PS');

if ~isempty(channels{1,2}{1})
    set(findall(f,'Tag','PulseB'),'Enable','on');
end

UD2.path = fpath;
UD2.name = fname;

uicontrol(f,'Style','PushButton','Position',[550,10,80,30],'String', ...
    'Done','Callback',@doneCBF,'UserData',UD2,'Tag','DoneB');


function devicesCBF(obj,~)
val = get(obj,'Value');
f = get(obj,'Parent');
UD = get(obj,'UserData');
set(findall(f,'Tag','ID'),'String',UD.info{val}.ID);
str = UD.channels{val,1};
if ~iscell(str)
    str = {str};
end
set(findall(f,'Tag','Analog'),'String',str);
set(findall(f,'Tag','ACh'),'String',str{1});
if ~isempty(str{1})
    set(findall(f,'Tag','Ch1B'),'Enable','on');
    set(findall(f,'Tag','Ch2B'),'Enable','on');
    set(findall(f,'Tag','Ch3B'),'Enable','on');
else
    set(findall(f,'Tag','Ch1B'),'Enable','off');
    set(findall(f,'Tag','Ch2B'),'Enable','off');
    set(findall(f,'Tag','Ch3B'),'Enable','off');
end
str = UD.channels{val,2};
if ~iscell(str)
    str = {str};
end
set(findall(f,'Tag','Pulse'),'String',str);
set(findall(f,'Tag','PCh'),'String',str{1});
if ~isempty(str{1})
    set(findall(f,'Tag','PulseB'),'Enable','on');
else
    set(findall(f,'Tag','PulseB'),'Enable','off');
end


function analogCBF(obj,~)
f = get(obj,'Parent');
val = get(obj,'Value');
str = get(obj,'String');
if ~iscell(str)
    str = {str};
end
set(findall(f,'Tag','ACh'),'String',str{val});


function pulseCBF(obj,~)
f = get(obj,'Parent');
val = get(obj,'Value');
str = get(obj,'String');
if ~iscell(str)
    str = {str};
end
set(findall(f,'Tag','PCh'),'String',str{val});


function ch1CBF(obj,~)
f = get(obj,'Parent');
qs = sprintf(['Enter Analog Channel 1 Range.\nex. ',char(177),'5 Volts = 5']);
range = str2double(inputdlg(qs,'neuroPG DAQ Range'));
if ~isempty(range) && ~isnan(range)
    s1 = get(findall(f,'Tag','ID'),'String');
    s2 = get(findall(f,'Tag','ACh'),'String');
    s3 = ['[-',num2str(range),',',num2str(range),']'];
    set(findall(f,'Tag','Ch1S'),'String',[s1,' ',s2,' ',s3]);
    settings = get(f,'UserData');
    settings.ch1.device = s1;
    settings.ch1.channel = s2;
    settings.ch1.range = [-range,range];
    set(f,'UserData',settings);
    set(obj,'Background','g','UserData',1);
end


function ch2CBF(obj,~)
f = get(obj,'Parent');
qs = sprintf(['Enter Analog Channel 2 Range.\nex. ',char(177),'5 Volts = 5']);
range = str2double(inputdlg(qs,'neuroPG DAQ Range'));
if ~isempty(range) && ~isnan(range)
    s1 = get(findall(f,'Tag','ID'),'String');
    s2 = get(findall(f,'Tag','ACh'),'String');
    s3 = ['[-',num2str(range),',',num2str(range),']'];
    set(findall(f,'Tag','Ch2S'),'String',[s1,' ',s2,' ',s3]);
    settings = get(f,'UserData');
    settings.ch2.device = s1;
    settings.ch2.channel = s2;
    settings.ch2.range = [-range,range];
    set(f,'UserData',settings);
    set(obj,'Background','g','UserData',1);
end


function ch3CBF(obj,~)
f = get(obj,'Parent');
qs = sprintf(['Enter Analog Channel 3 Range.\nex. ',char(177),'5 Volts = 5']);
range = str2double(inputdlg(qs,'neuroPG DAQ Range'));
if ~isempty(range) && ~isnan(range)
    s1 = get(findall(f,'Tag','ID'),'String');
    s2 = get(findall(f,'Tag','ACh'),'String');
    s3 = ['[-',num2str(range),',',num2str(range),']'];
    set(findall(f,'Tag','Ch3S'),'String',[s1,' ',s2,' ',s3]);
    settings = get(f,'UserData');
    settings.ch3.device = s1;
    settings.ch3.channel = s2;
    settings.ch3.range = [-range,range];
    set(f,'UserData',settings);
    set(obj,'Background','g','UserData',1);
end


function pulseBCBF(obj,~)
f = get(obj,'Parent');
s1 = get(findall(f,'Tag','ID'),'String');
s2 = get(findall(f,'Tag','PCh'),'String');
set(findall(f,'Tag','PS'),'String',[s1,' ',s2]);
settings = get(f,'UserData');
settings.pulse.device = s1;
settings.pulse.channel = s2;
set(f,'UserData',settings);
set(obj,'Background','g','UserData',1);


function doneCBF(obj,~)
f = get(obj,'Parent');
b = findall(f,'Style','PushButton');
b(b == obj) = [];
u = cell2mat(get(b,'UserData'));
if any(u == 0)
    resp = questdlg('Configuration incomplete. Exit utility without saving?', ...
        'nueroPG DAQ');
    if strcmp(resp,'Yes')
        delete(f);
    else
        return;
    end
else
    settings = get(f,'UserData'); %#ok<NASGU>
    UD = get(obj,'UserData');
    save([UD.path,UD.name],'-struct','settings','-mat');
end


function configWindows(varargin)
% Creates windows of the same size as neuroPG's windows, some resizeable,
% and allows the user to arrange them to default positions before capturing
% the layout and saving it to the config file.  Placeholder windows cannot
% be closed individually.  Closing the 'Always On Top' controls window will
% close all the placeholder windows and the controls window without saving
% settings.  Before saving the new configuration, a backup of the old
% configuration file is made and stored as neuroPG.config.bak unless a '1'
% is passed as the first parameter to the function.

monitors = get(0,'Monitor');

c = [.9,.9,.8];

win(1) = figure('Visible','off','Color',c,'Units','Pixels','MenuBar', ...
    'None','IntegerHandle','off','Name','neuroPG Main Window','Resize','off', ...
    'NumberTitle','off','CloseRequestFcn',@winCRF);
pos = get(win(1),'Position');
screen = find(pos(1) >= monitors(:,1) & pos(1) <= monitors(:,3) & ...
    pos(2) >= monitors(:,2) & pos(2) <= monitors(:,4));
pos(3:4) = [981,814];
if (pos(2) + pos(4) > monitors(screen,4) - 20)
    pos(2) = monitors(screen,4) - 20 - pos(4);
end
size(1) = pos(4);
set(win(1),'Position',pos,'Visible','on');
uicontrol(win(1),'Style','Text','String','Main Window','Units','normalized', ...
    'Position',[.01,.4,.98,.2],'FontSize',24,'ForegroundColor','b', ...
    'HorizontalAlignment','center','BackgroundColor',c);

win(2) = figure('Visible','off','Color',c,'Units','Pixels','MenuBar', ...
    'None','IntegerHandle','off','Name','Show/Hide Window','Resize','off', ...
    'NumberTitle','off','CloseRequestFcn',@winCRF);
pos = get(win(2),'Position');
pos(3:4) = [200,200];
if (pos(2) + pos(4) > monitors(screen,4) - 20)
    pos(2) = monitors(screen,4) - 20 - pos(4);
end
size(2) = pos(4);
set(win(2),'Position',pos,'Visible','on');
uicontrol(win(2),'Style','Text','String','Show/Hide Window','Units','normalized', ...
    'Position',[.01,.4,.98,.2],'FontSize',24,'ForegroundColor','b', ...
    'HorizontalAlignment','center','BackgroundColor',c);

win(3) = figure('Visible','off','Color',c,'Units','Pixels','MenuBar', ...
    'None','IntegerHandle','off','Name','SmartGrid Window','NumberTitle','off', ...
    'CloseRequestFcn',@winCRF);
pos = get(win(3),'Position');
pos(3:4) = [654,654];
if (pos(2) + pos(4) > monitors(screen,4) - 20)
    pos(2) = monitors(screen,4) - 20 - pos(4);
end
size(3) = pos(4);
set(win(3),'Position',pos,'Visible','on');
uicontrol(win(3),'Style','Text','String','SmartGrid Window','Units','normalized', ...
    'Position',[.01,.4,.98,.2],'FontSize',24,'ForegroundColor','b', ...
    'HorizontalAlignment','center','BackgroundColor',c);

win(4) = figure('Visible','off','Color',c,'Units','Pixels','MenuBar', ...
    'None','IntegerHandle','off','Name','Camera Window','NumberTitle', ...
    'off','CloseRequestFcn',@winCRF);
pos = get(win(4),'Position');
pos(3:4) = [640,480];
if (pos(2) + pos(4) > monitors(screen,4) - 20)
    pos(2) = monitors(screen,4) - 20 - pos(4);
end
size(4) = pos(4);
set(win(4),'Position',pos,'Visible','on');
uicontrol(win(4),'Style','Text','String','Camera Window','Units','normalized', ...
    'Position',[.01,.4,.98,.2],'FontSize',24,'ForegroundColor','b', ...
    'HorizontalAlignment','center','BackgroundColor',c);

win(5) = figure('Visible','off','Color',c,'Units','Pixels','MenuBar', ...
    'None','IntegerHandle','off','Name','Camera Controls Window','Resize','off', ...
    'NumberTitle','off','CloseRequestFcn',@winCRF);
pos = get(win(5),'Position');
pos(3:4) = [300,480];
if (pos(2) + pos(4) > monitors(screen,4) - 20)
    pos(2) = monitors(screen,4) - 20 - pos(4);
end
size(5) = pos(4);
set(win(5),'Position',pos,'Visible','on');
uicontrol(win(5),'Style','Text','Units','normalized','String', ...
    'Camera Controls Window','Position',[.01,.4,.98,.2],'FontSize',24, ...
    'ForegroundColor','b','HorizontalAlignment','center','BackgroundColor',c);


[~,order] = sort(size,'descend');
figure(win(order(1)))
figure(win(order(2)))
figure(win(order(3)))
figure(win(order(4)))
figure(win(order(5)))


f = figure('Units','pixels','MenuBar','none','IntegerHandle','off','Name', ... 
    'neuroPG Window Layout','NumberTitle','off','Resize','off','Tag', ...
    'ControlBox','CloseRequestFcn',{@windowsCRF,win});
pos = get(f,'Position');
pos(3:4) = [300,300];
set(f,'Position',pos);
j = get(handle(f),'JavaFrame');
drawnow;
j.fHG1Client.getWindow.setAlwaysOnTop(1);
uicontrol(f,'Style','Text','Position',[10,250,280,30],'HorizontalAlignment', ...
    'Center','BackgroundColor',[.8,.8,.8],'FontSize',10, ...
    'String','Arrange the windows to their desired positions and click OK.');
uicontrol(f,'Style','PushButton','Position',[100,150,100,50],'String','OK', ...
    'Callback',{@OKButtonCBF,win,varargin});
uicontrol(f,'Style','Text','Position',[10,50,200,30],'BackgroundColor',[.8,.8,.8], ...
    'String','If you know your camera resolution, click below to enforce the aspect ratio.');
uicontrol(f,'Style','PushButton','Position',[10,10,150,30],'Callback', ...
    {@resizeCBF,win(4),j},'String','Resize Camera Window');


function OKButtonCBF(obj,~,win,args)
fpath = which('neuroPG.m');
fpath = fpath(1:end-9);
fname = 'neuroPG.config';
if exist([fpath,fname],'file')
    settings = load([fpath,fname],'-mat');
    if numel(args) > 0 && args{1} == 1
        copyfile([fpath,fname],[fpath,fname,'.bak']);
    end
end
settings.MainWindowPosition = get(win(1),'Position');
settings.AccessWindowPosition = get(win(2),'Position');
settings.SmartGridWindowPosition = get(win(3),'Position');
settings.CameraWindowPosition = get(win(4),'Position');
settings.CameraControlsWindowPosition = get(win(5),'Position');
save([fpath,fname],'-struct','settings','-mat');
delete(win)
delete(get(obj,'Parent'))


function resizeCBF(~,~,window,j)
drawnow;
j.fHG1Client.getWindow.setAlwaysOnTop(0);
width = str2double(inputdlg('Enter camera width','Enter Width'));
height = str2double(inputdlg('Enter camera height','Enter Height'));
drawnow;
j.fHG1Client.getWindow.setAlwaysOnTop(1);
if isempty(width) || isempty(height)
    return;
end
ratio = width / height;
pos = get(window,'Position');
pos(3) = round(pos(4) * ratio);
set(window,'Position',pos);


function winCRF(~,~)
return;


function windowsCRF(obj,~,win)
delete(win);
delete(obj);