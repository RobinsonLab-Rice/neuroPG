% Created by Benjamin W. Avants - 2013-2014
% RobinsonLab, Neuroengineering, Electrical and Computer Engineering
% Rice University, Houston, TX, USA
% Concept deign assisted by: Jacob Robinson, Daniel Murphy, and Joel Dapello

function varargout = neuroPGGUIDE(varargin)
% NEUROPGGUIDE MATLAB code for neuroPGGUIDE.fig
%      NEUROPGGUIDE, by itself, creates a new NEUROPGGUIDE or raises the existing
%      singleton*.
%
%      H = NEUROPGGUIDE returns the handle to a new NEUROPGGUIDE or the handle to
%      the existing singleton*.
%
%      NEUROPGGUIDE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NEUROPGGUIDE.M with the given input arguments.
%
%      NEUROPGGUIDE('Property','Value',...) creates a new NEUROPGGUIDE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before neuroPGGUIDE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to neuroPGGUIDE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help neuroPGGUIDE

% Last Modified by GUIDE v2.5 25-Apr-2014 12:03:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @neuroPGGUIDE_OpeningFcn, ...
                   'gui_OutputFcn',  @neuroPGGUIDE_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
               
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%******************************************************************
% Opening Function and General GUI Functions

% --- Executes just before neuroPGGUIDE is made visible.
function neuroPGGUIDE_OpeningFcn(hObject, ~, handles, varargin) %#ok<*DEFNU>

% Choose default command line output for neuroPGGUIDE
handles.output = hObject;

fpath = which('neuroPG');
fpath = fpath(1:end-9);
fname = 'neuroPG.config';
if exist([fpath,fname],'file')
    handles.settings = load([fpath,fname],'-mat');
else
    fh = configNeuroPG();
    waitfor(fh)
    pause(.1)
    if ~exist([fpath,fname],'file')
        delete(hObject)
        warndlg('Configuration File Not Found: Run configNeuroPG.m','neuroPG')
        return;
    end
    handles.settings = load([fpath,fname],'-mat');
end
handles.FilePath = fpath;

if isfield(handles.settings,'savePath')
    set(handles.PathText,'String',handles.settings.savePath);
else
    set(handles.PathText,'String',pwd);
end
if isfield(handles.settings,'fileName')
    set(handles.NameText,'String',handles.settings.fileName);
else
    set(handles.NameText,'String','');
end

logfile = [get(handles.PathText,'String'),'neuroPG.log'];

timestr = datestr(clock,'mm/dd/yy HH:MM AM');
entry = ['-- neuroPG Started ',timestr];
logentry = sprintf('<HTML><BODY color="%s">%s', 'green', entry);
MatPad('log',logfile,'add',logentry,'save');

handles.MainPosition = handles.settings.MainWindowPosition;
handles.CameraPosition = handles.settings.CameraWindowPosition;
handles.SmartGridPosition = handles.settings.SmartGridWindowPosition;
handles.AccessPosition = handles.settings.AccessWindowPosition;

handles.SelectedRects = []; % SmartGrid Patch Objects Selected
handles.Figure = []; % SmartGrid image Figure Handle
handles.Axes = []; % SmartGrid image Axes Handle
handles.Image = []; % SmartGrid Image Handle
handles.MSMaxAlpha = 1; % SmartGrid Alpha Scaler

handles.recTime = 1000; % Record Time for stimulations

handles.scanType = 0; % Flag for what type of scan is being run
% 0 - no recording, 1 - record ch1, 2 - record ch2, 3 - record both

handles.MaskList = []; % PatternList list of masks used to make patterns

handles.daqs = []; % DAQ session for recording data
handles.daqt = []; % DAQ session for triggering / timing

polyPtnSet.bitDepth = 1; % 1,2,4,8, or 24
polyPtnSet.PtnNumber = 1; % Total number of patterns MAX floor(1000/bitDepth)
polyPtnSet.TrigType = 0; % 0= Software, 1= Auto, 2= Ext Rise, 3= Ext Fall 
polyPtnSet.TrigDelay = 0; % Value in microseconds
polyPtnSet.TrigPeriod = 0; % Value in microseconds
polyPtnSet.ExposureTime = 2000; % Value in microseconds, 2M MAX
polyPtnSet.LEDSelection = 2; % 0= Red, 1= Green, 2= Blue
handles.polyPtnSet = polyPtnSet;

polyTrigSet.Enable = 1; % 0= disable, 1= enable
polyTrigSet.TrigDelay = 0; % Value in microseconds
polyTrigSet.TrigPulseWidth = polyPtnSet.ExposureTime;%Value in microseconds
handles.polyTrigSet = polyTrigSet;

handles.polyFlag = 0;


handles.ImgStack = 0;

if isfield(handles.settings,'DMDOrientation')
    handles.DMDO = handles.settings.DMDOrientation;
    if ~any(handles.DMDO == 1:8)
        handles.DMDO = 1;
    end
else
    handles.DMDO = 1; % Valued 1 to 4: 1 - Camera and DMD aligned, 2 - Camera
        % and DMD aligned at 90 degrees, 3 - 180 degrees, 4 - 270 degrees
end
if any(handles.DMDO == 1:4)
    order = [1,2,3,4];
else
    order = [3,4,1,2];
end
if isfield(handles.settings,'DMDMinWidth')
    handles.DMDXMin = handles.settings.DMDMinWidth;
    handles.DMDDims(order(1)) = handles.settings.DMDMinWidth;
else
    handles.DMDXMin = 1;
    handles.DMDDims(order(1)) = 1;
end
set(handles.PolyMinXText,'String',num2str(handles.DMDXMin));
if isfield(handles.settings,'DMDMaxWidth')
    handles.DMDXMax = handles.settings.DMDMaxWidth;
    handles.DMDDims(order(2)) = handles.settings.DMDMaxWidth;
else
    handles.DMDXMax = 608;
    handles.DMDDims(order(2)) = 608;
end
set(handles.PolyMaxXText,'String',num2str(handles.DMDXMax));
if isfield(handles.settings,'DMDMinHeight')
    handles.DMDYMin = handles.settings.DMDMinHeight;
    handles.DMDDims(order(3)) = handles.settings.DMDMinHeight;
else
    handles.DMDYMin = 1;
    handles.DMDDims(order(3)) = 1;
end
set(handles.PolyMinYText,'String',num2str(handles.DMDYMin));
if isfield(handles.settings,'DMDMaxHeight')
    handles.DMDYMax = handles.settings.DMDMaxHeight;
    handles.DMDDims(order(4)) = handles.settings.DMDMaxHeight;
else
    handles.DMDYMax = 684;
    handles.DMDDims(order(4)) = 684;
end
set(handles.PolyMaxYText,'String',num2str(handles.DMDYMax));

handles.PatternCount = 1;
handles.LoadedPatterns = 0;

axes(handles.ThumbnailAxes)
a = abs(handles.DMDDims(2) - handles.DMDDims(1) + 1);
b = abs(handles.DMDDims(4) - handles.DMDDims(3) + 1);
handles.Thumbnail = imagesc(zeros(a,b,'uint8'));
axis off
colormap('Gray');

handles.NameText2 = [];

handles.GridStimFigs = 0;
handles.PairedStimFigs = 1;
guidata(hObject, handles);
t = timer('StartDelay',.25,'TimerFcn',{@OpenTimerFcn,handles.output},'Name', ...
    'neuroPG Startup Timer');
start(t);


function OpenTimerFcn (obj,~,fh)
h = guidata(fh);
monitors = get(0,'Monitor');
if isempty(h.MainPosition)
    pos = [2360,178,981,814];
else
    pos = h.MainPosition;
end
if any(monitors(:,3) >= pos(1)+pos(3)) && any(monitors(:,4) >= pos(2)+pos(4))
    set(fh,'Position',pos);
end
stop(obj);
if isempty(h.AccessPosition)
    pos = [-214,818,200,200];
else
    pos = h.AccessPosition;
end
f = figure('Units','pixels', ... 
    'MenuBar','none','IntegerHandle','off','Name','GUI Access', ... 
    'NumberTitle','off','Resize','off','Tag','ControlBox');
if any(monitors(:,1) <= pos(1)) && any(monitors(:,4) >= pos(2)+pos(4))
    set(f,'Position',pos);
end
j = get(handle(f),'JavaFrame');
drawnow;
j.fHG1Client.getWindow.setAlwaysOnTop(1);
% Main GUI buttons
uicontrol('Style','PushButton','Parent',f,'Units','normalized','tag', ... 
    'B1','Position',[.05,0.7,.4,.25],'String','Show Main', ...
    'Callback',{@B1Fcn,1});
uicontrol('Style','PushButton','Parent',f,'Units','normalized','tag', ... 
    'B2','Position',[.5,0.7,.4,.25],'String','Hide Main', ...
    'Callback',{@B2Fcn,1});
% Video GUI buttons
uicontrol('Style','PushButton','Parent',f,'Units','normalized','tag', ... 
    'B1','Position',[.05,0.4,.4,.25],'String','Show Video', ...
    'Callback',{@B1Fcn,2});
uicontrol('Style','PushButton','Parent',f,'Units','normalized','tag', ... 
    'B2','Position',[.5,0.4,.4,.25],'String','Hide Video', ...
    'Callback',{@B2Fcn,2});
% Minesweeper figure buttons
uicontrol('Style','PushButton','Parent',f,'Units','normalized','tag', ... 
    'B1','Position',[.05,0.1,.4,.25],'String','Show SmartG', ...
    'Callback',{@B1Fcn,3});
uicontrol('Style','PushButton','Parent',f,'Units','normalized','tag', ... 
    'B2','Position',[.5,0.1,.4,.25],'String','Hide SmartG', ...
    'Callback',{@B2Fcn,3});

a(1) = isfield(h.settings,'ch1');
a(end+1) = isfield(h.settings,'ch2');
a(end+1) = isfield(h.settings,'ch3');
a(end+1) = isfield(h.settings,'pulse');
if all(a)
    a(end+1) = isfield(h.settings.ch1,'device');
    a(end+1) = isfield(h.settings.ch1,'channel');
    a(end+1) = isfield(h.settings.ch1,'range');
    a(end+1) = isfield(h.settings.ch2,'device');
    a(end+1) = isfield(h.settings.ch2,'channel');
    a(end+1) = isfield(h.settings.ch2,'range');
    a(end+1) = isfield(h.settings.ch3,'device');
    a(end+1) = isfield(h.settings.ch3,'channel');
    a(end+1) = isfield(h.settings.ch3,'range');
    a(end+1) = isfield(h.settings.pulse,'device');
    a(end+1) = isfield(h.settings.pulse,'channel');
end

if ~isempty(daq.getDevices) && all(a)
    h = guidata(fh);
    
    ch1.device = h.settings.ch1.device;
    ch1.channel = h.settings.ch1.channel;
    ch1.setting = 'Voltage';
    ch1.range = h.settings.ch1.range;
    
    ch2.device = h.settings.ch2.device;
    ch2.channel = h.settings.ch2.channel;
    ch2.setting = 'Voltage';
    ch2.range = h.settings.ch2.range;
    
    ch3.device = h.settings.ch3.device;
    ch3.channel = h.settings.ch3.channel;
    ch3.setting = 'Voltage';
    ch3.range = h.settings.ch3.range;
    
    pulse.device = h.settings.pulse.device;
    pulse.channel = h.settings.pulse.channel;
    pulse.setting = 'PulseGeneration';
    
    h.DaqTimer = [];
    
    h.daqs = daq.createSession('ni');
    h.daqs.IsContinuous = true;
    
    % Set data acquisition rate / signaling rate: MAX 1,000,000
    h.daqRate = 10000;
    h.daqs.Rate = h.daqRate;
    
    % Set number of data points to accumulate between transmissions
    % The divisor '20' will cause data to be sent 20 times per second
    h.daqFreq = 20;
    scans = floor(h.daqRate / h.daqFreq);
    h.daqs.NotifyWhenDataAvailableExceeds = scans;
    
    % Supported input ranges for common NI DAQ boards
    % ±10 V, ±5 V, ±2 V, ±1 V, ±0.5 V, ±0.2 V, ±0.1 V
    
    inCh1 = h.daqs.addAnalogInputChannel(ch1.device,ch1.channel,ch1.setting);
    % Channel 1 Signal Input
    inCh1.Range = ch1.range; 
    %Set the maximum signal range, smallest necessary for best resolution
    inCh2 = h.daqs.addAnalogInputChannel(ch2.device,ch2.channel,ch2.setting); 
    % Channel 2 Signal Input
    inCh2.Range = ch2.range;
    inCh3 = h.daqs.addAnalogInputChannel(ch3.device,ch3.channel,ch3.setting); 
    % Polygon400 Output Trigger
    inCh3.Range = ch3.range;
    
    h.DaqListener = h.daqs.addlistener('DataAvailable',@daqDataCallback);
    
    % Keep track of where in the buffer to store the next available data
    h.daqCount = 1;
    % Initialize the data buffers for 5 seconds of data
    h.daqBuffer1 = zeros(h.daqRate * 5,1);
    h.daqBuffer2 = zeros(h.daqRate * 5,1);
%     h.daqBuffer3 = zeros(h.daqRate * 5,1);
    
    h.daqPlot1 = plot(h.DaqAxes1,h.daqBuffer1);
    h.daqPlot2 = plot(h.DaqAxes2,h.daqBuffer2,'Color','r');
    
    % Set X zoom slider ranges - Min: 1 scan, Max: 5 seconds of scans
    set(h.DaqSlider1X,'Max',5*h.daqRate,'Min',...
        h.daqRate / h.daqFreq,'Value',5*h.daqRate);
    set(h.DaqSlider2X,'Max',5*h.daqRate,'Min',...
        h.daqRate / h.daqFreq,'Value',5*h.daqRate);
    
    h.daqX1 = h.daqRate * 5; % defines number of points in X
    h.daqX2 = h.daqRate * 5; % defines number of points in X
    
    h.daqY1 = 100; % defines +- range in Y
    h.daqC1 = 0; % defines center in Y
    h.daqY2 = 100; % defines +- range in Y
    h.daqC2 = 0; % defines center in Y
    
    
    % Common gain settings on MultiClamp
    % 20 mV / V
    % 400 pA / V
    h.daqFactor1 = 1;
    h.daqFactor2 = 1;
    
    % For current clamp: -60 mV would be -3 V & -100 mV would be -5 V
    % For voltage clamp: 400 pA would be 1 V & 1 mA would be 2.5 V
    
    h.daqt = daq.createSession('ni'); % Polygon Trigger Session
    
    h.daqt.addCounterOutputChannel(pulse.device,pulse.channel,pulse.setting);
    
    h.recBuffer = []; % Buffer for recording experiment data
    h.recInd = 1; % Current index to write experiment data into buffer
    
    guidata(fh,h)
    set(h.DAQCheckbox,'Enable','on');
end

delete(obj);


function B1Fcn(obj,~,id)
switch id
    case 1
        h = findall(0,'tag','neuroPG');
    case 2
        h = findall(0,'tag','CameraWindow');
        if ~isempty(h)
            h(2) = findall(0,'tag','CameraControls');
        end
    case 3
        h = findall(0,'tag','SGfig');
end
if ~isempty(h)
    set(h,'Visible','on');
end


function B2Fcn(obj,~,id)
switch id
    case 1
        h = findall(0,'tag','neuroPG');
    case 2
        h = findall(0,'tag','CameraWindow');
        if ~isempty(h)
            h(2) = findall(0,'tag','CameraControls');
        end
    case 3
        h = findall(0,'tag','SGfig');
end
if ~isempty(h)
    set(h,'Visible','off');
end


function FigResizeFcn(obj,~)
po = get(obj,'UserData');
p = get(obj,'Position');
dx = po(3);
dy = po(4);
r = dy / dx;
y = p(2) + p(4);
a = p(3) > po(3);
b = p(4) > po(4);
if r <= 1
    if a && b
        p(4) = round(p(3) * r);
    elseif a
        p(4) = round(p(3) * r);
    elseif b
        p(3) = round(p(4) / r);
    elseif (po(3) - p(3)) < (po(4) - p(4))
        p(3) = round(p(4) / r);
    else
        p(4) = round(p(3) * r);
    end
else
    if a && b
        p(3) = round(p(4) / r);
    elseif b
        p(3) = round(p(4) / r);
    elseif a
        p(4) = round(p(3) * r);
    elseif (po(3) - p(3)) < (po(4) - p(4))
        p(4) = round(p(3) * r);
    else
        p(3) = round(p(4) / r);
    end
end
p(2) = y - p(4);
set(obj,'Position',p,'UserData',p);


function PairedStimTraceCRF(obj,~) 
gh = findall(0,'tag','neuroPG');
if ~isempty(gh)
    h = guidata(gh);
    h.PairedStimFigs = h.PairedStimFigs - 1;
    guidata(gh,h);
end
delete(obj);


function varargout = neuroPGGUIDE_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;


function neuroPG_CloseRequestFcn(hObject, eventdata, handles)
[~,h] = MatPad;
if isempty(h)
    logfile = [get(handles.PathText,'String'),'neuroPG.log'];
    MatPad('log',logfile);
end
if handles.GridStimFigs ~= 0
    close(handles.GridStimFigs);
end
h = findall(0,'tag','CameraWindow');
if ~isempty(h)
    close(h);
end
if ~isempty(handles.daqs)
    if ~isempty(handles.DaqTimer) && any(handles.DaqTimer == timerfind)
        stop(handles.DaqTimer);
        delete(handles.DaqTimer);
    end
    handles.daqs.stop;
    handles.daqs.release;
    delete(handles.daqs);
    clear daqDataCallback
    if get(handles.DAQCheckbox,'Value') == 1
        timestr = datestr(clock,'mm/dd/yy HH:MM AM');
        entry = ['-- DAQ Monitoring Stopped ',timestr];
        logentry = sprintf('<HTML><BODY color="%s">%s', 'red', entry);
        MatPad('add',logentry);
    end
end
if ~isempty(handles.daqt)
    handles.daqt.stop;
    handles.daqt.release;
    delete(handles.daqt);
end
if handles.polyFlag == 1
    handles.DMD.delete;
    timestr = datestr(clock,'mm/dd/yy HH:MM AM');
    entry = ['-- Polygon400 Released ',timestr];
    logentry = sprintf('<HTML><BODY color="%s">%s', 'red', entry);
    MatPad('add',logentry);
%     polymex('DisconnectDev',0);
%     polymex('UnInitDevice');
end
if ~isempty(handles.Figure) && ishandle(handles.Figure)
    delete(handles.Figure);
end
h = findall(0,'tag','ControlBox');
if ~isempty(h)
    close(h);
end
delete(hObject);
timestr = datestr(clock,'mm/dd/yy HH:MM AM');
entry = ['-- neuroPG Closed ',timestr];
logentry = sprintf('<HTML><BODY color="%s">%s', 'red', entry);
MatPad('add',logentry,'save');


% **********************************************************************
% DAQ Graphs Functions


function DAQCheckbox_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == 1
    if ~isempty(handles.daqs)
        handles.daqs.startBackground();
        if isempty(handles.DaqTimer) || ~ishandle(handles.DaqTimer)
            handles.DaqTimer = timer('ExecutionMode','FixedRate','TimerFcn', ...
                {@DaqTimerFcn,handles.daqs},'Period',0.5);
            guidata(hObject,handles);
        end
        start(handles.DaqTimer);
        [~,h] = MatPad;
        if isempty(h)
            logfile = [get(handles.PathText,'String'),'neuroPG.log'];
            MatPad('log',logfile);
        end
        timestr = datestr(clock,'mm/dd/yy HH:MM AM');
        entry = ['-- DAQ Monitoring Started ',timestr];
        logentry = sprintf('<HTML><BODY color="%s">%s', 'blue', entry);
        MatPad('add',logentry,'save');
    else
        set(hObject,'Value',0);
        warndlg('No DAQ Present','neuroPG DAQ Error');
    end
else
    if ~isempty(handles.DaqTimer) && any(handles.DaqTimer == timerfind)
        stop(handles.DaqTimer);
    end
    handles.daqs.stop();
    [~,h] = MatPad;
    if isempty(h)
        logfile = [get(handles.PathText,'String'),'neuroPG.log'];
        MatPad('log',logfile);
    end
    timestr = datestr(clock,'mm/dd/yy HH:MM AM');
    entry = ['-- DAQ Monitoring Stopped ',timestr];
    logentry = sprintf('<HTML><BODY color="%s">%s', 'red', entry);
    MatPad('add',logentry);
end


function DaqTimerFcn(obj,~,daqs)
if ~get(daqs,'IsRunning');
    daqs.startBackground();
end


function daqDataCallback (src,event) %#ok<*INUSL>
persistent daqBuffer1 daqBuffer2 i maxcount points recInd eventPoints recBuffer
h = guidata(findall(0,'tag','neuroPG'));
if isempty(i)
    i = 1;
    freq = h.daqFreq;
    rate = h.daqRate;
    points = ceil(rate / freq);
    maxcount = freq * 5;
    daqBuffer1 = zeros(size(h.daqBuffer1));
    daqBuffer2 = zeros(size(h.daqBuffer2));
    eventPoints = numel(event.Data(:,1));
    recInd = 1;
end
daqBuffer1((i-1)*points+1:(i)*points) = event.Data(:,1) .* h.daqFactor1;
daqBuffer2((i-1)*points+1:(i)*points) = event.Data(:,2) .* h.daqFactor2;
% h.daqBuffer3((i-1)*points+1:(i)*points) = event.Data(:,3);
if i == maxcount
    i = 1;
else
    i = i + 1;
end
if h.daqX1 > i*points
    lim = [1,h.daqX1];
else
    lim = [(i*points)-h.daqX1,i*points];
end
set(h.daqPlot1,'YData',daqBuffer1);
set(h.DaqAxes1,'XLim',lim);
if h.daqX2 > i*points
    lim = [1,h.daqX2];
else
    lim = [(i*points)-h.daqX2,i*points];
end
set(h.daqPlot2,'YData',daqBuffer2);
set(h.DaqAxes2,'XLim',lim);
if h.scanType ~= 0
    if isempty(recBuffer)
        recBuffer = zeros(size(h.recBuffer));
    end
    recInd2 = recInd + eventPoints - 1;
    switch h.scanType
        case 1
            recBuffer(recInd:recInd2,1) = event.Data(:,1);
            recBuffer(recInd:recInd2,2) = 0;
            recBuffer(recInd:recInd2,3) = event.Data(:,3);
        case 2
            recBuffer(recInd:recInd2,1) = event.Data(:,2);
            recBuffer(recInd:recInd2,2) = 0;
            recBuffer(recInd:recInd2,3) = event.Data(:,3);
        case 3
            recBuffer(recInd:recInd2,1) = event.Data(:,1);
            recBuffer(recInd:recInd2,2) = event.Data(:,2);
            recBuffer(recInd:recInd2,3) = event.Data(:,3);
    end
    recInd = recInd2 + 1;
elseif ~isempty(recBuffer)
    h.recBuffer = recBuffer;
    guidata(h.neuroPG,h);
    recBuffer = [];
    recInd = 1;
end


function [alpha,color,fpks,flocs] = evaluateTrace(data,channel,clamp)
% maxV = max(data);
% minV = min(data);
% difV = maxV - minV;
% if difV > .5
%     difV = .5;
% end
% alpha = difV * 2;
% color = [1,0,0];
% alpha = rand / 2 + .35;
% color = [rand,rand,rand];
d = data(:,channel) .* clamp;
f1 = sgolayfilt(d,9,51);
f1 = sgolayfilt(f1,9,11);
f1 = sgolayfilt(f1,9,51);

[fpks,flocs] = findpeaks(f1,'MinPeakDistance',10);

[~,tlocs] = findpeaks(-f1,'MinPeakDistance',10);

for i = 1:numel(flocs)
    k = find(tlocs > flocs(i),1);
    if k > 1
        j = k - 1;
        dif1 = f1(flocs(i)) - f1(tlocs(j));
        dif2 = f1(flocs(i)) - f1(tlocs(k));
        if max(dif1,dif2) < 15 || dif1 < 5
            fpks(i) = -10000;
            flocs(i) = -10000;
        end
        tlocs(1:j) = [];
    else
        fpks(i) = -10000;
        flocs(i) = -10000;
    end
end
fpks(fpks == -10000) = [];
flocs(flocs == -10000) = [];

base = mean(f1(1:100));
maxPeak = abs(max(fpks) - base);
alpha = maxPeak;
if isempty(alpha)
    alpha = 0;
end
switch numel(fpks)
    case 0
        color = [1,0,0];
    case 1
        color = [1,0,0];
    case 2
        color = [0,1,0];
    otherwise
        color = [0,0,1];
end


function DaqSlider1_Callback(hObject, eventdata, h)
h.daqY1 = 10^(get(hObject,'Value'));
guidata(hObject,h);
set(h.DaqAxes1,'YLim',[h.daqC1-h.daqY1,h.daqC1+h.daqY1]);


function DaqSlider2_Callback(hObject, eventdata, h)
h.daqY2 = 10^(get(hObject,'Value'));
guidata(hObject,h);
set(h.DaqAxes2,'YLim',[h.daqC2-h.daqY2,h.daqC2+h.daqY2]);


function DaqSlider1X_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
set(handles.TimeWindow1Text,'String',num2str(val / handles.daqRate));
handles.daqX1 = val;
guidata(hObject,handles);


function DaqSlider2X_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
set(handles.TimeWindow2Text,'String',num2str(val / handles.daqRate));
handles.daqX2 = val;
guidata(hObject,handles);


function DaqYCenter1Text_Callback(hObject, eventdata, handles)
string = get(hObject,'String');
if strcmpi(string(1),'a')
    set(hObject,'String','A');
    set(handles.Auto1Button,'Value',1);
    set(handles.DaqAxes1,'YLimMode','auto');
else
    val = str2double(string) * handles.daqFactor1;
    handles.daqC1 = val;
    os = handles.daqY1;
    guidata(hObject,handles);
    set(handles.DaqAxes1,'YLim',[val-os,val+os]);
end


function DaqYCenter2Text_Callback(hObject, eventdata, handles)
string = get(hObject,'String');
if strcmpi(string(1),'a')
    set(hObject,'String','A');
    set(handles.Auto2Button,'Value',1);
    set(handles.DaqAxes2,'YLimMode','auto');
else
    val = str2double(string) * handles.daqFactor2;
    handles.daqC2 = val;
    os = handles.daqY2;
    guidata(hObject,handles);
    set(handles.DaqAxes2,'YLim',[val-os,val+os]);
end


function TimeWindow1Text_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String')) * handles.daqRate;
set(handles.DaqSlider1X,'Value',val);
handles.daqX1 = val;
guidata(hObject,handles);


function TimeWindow2Text_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String')) * handles.daqRate;
set(handles.DaqSlider2X,'Value',val);
handles.daqX2 = val;
guidata(hObject,handles);


function Auto1Button_Callback(hObject, eventdata, handles)
v = get(hObject,'Value');
if v == 1
    set(handles.DaqYCenter1Text,'String','A','Enable','off');
    set(handles.DaqAxes1,'YLimMode','auto');
else
    set(handles.DaqYCenter1Text,'String','?','Enable','on');
    set(handles.DaqAxes1,'YLimMode','manual');
end


function Auto2Button_Callback(hObject, eventdata, handles)
v = get(hObject,'Value');
if v == 1
    set(handles.DaqYCenter2Text,'String','A','Enable','off');
    set(handles.DaqAxes2,'YLimMode','auto');
else
    set(handles.DaqYCenter2Text,'String','?','Enable','on');
    set(handles.DaqAxes2,'YLimMode','manual');
end


function VFactor1Text_Callback(~, ~, ~)


function AFactor1Text_Callback(~, ~, ~)


function VFactor2Text_Callback(~, ~, ~)


function AFactor2Text_Callback(~, ~, ~)


function ChannelPopup_Callback(~, ~, ~)



% _________ Create Functions _________


function DaqSlider1_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function DaqSlider2_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function DaqSlider1X_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function DaqSlider2X_CreateFcn(hObject, ~, ~)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function edit2_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DaqYCenter1Text_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit5_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DaqYCenter2Text_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TimeWindow2Text_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TimeWindow2Label_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TimeWindow1Text_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TimeWindow1Label_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function AFactor2Text_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function VFactor2Text_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function AFactor1Text_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function VFactor1Text_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ChannelPopup_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ***********************************************************************
% Microscope Camera Functions


function CameraCheckbox_Callback(hObject, ~, ~)
objs = get(get(hObject,'Parent'),'Children');
objs(objs == hObject) = [];
if get(hObject,'Value') == 1
    if ~isempty(objs)
        delete(objs)
    end
    cwh = CameraWindow;
    if ~isempty(cwh)
        warning('off','MATLAB:childaddedcbk:CallbackWillBeOverwritten');
        UD = get(cwh,'UserData');
        objs = get(UD.controlsHandle,'Children');
        oldah = findall(objs,'Type','axes');
        newobjs = copyobj(objs,get(hObject,'Parent'));
        hist = findall(newobjs,'Tag','Histogram');
        delete(hist);
        ah = findall(newobjs,'Type','axes');
        bar(0:255,zeros(1,256),'Parent',ah,'Tag','Histogram','FaceColor','w');
        set(ah,'Color','k','XTickLabel',[],'YTickLabel',[],'XLim',[0,255], ... 
            'YLim',get(oldah,'YLim'));
    else
        set(hObject,'Value',0);
        warndlg('CameraWindow did not open','neuroPG CameraWindow Error');
    end
else
    if ~isempty(objs)
        delete(objs)
    end
    cwh = findall(0,'Tag','CameraWindow');
    if ~isempty(cwh)
        close(cwh);
    end
end


% ***********************************************************************
% File & Path Functions


function PathText_Callback(~, ~, ~)


function PathSelectButton_Callback(hObject, eventdata, handles)
myPath = uigetdir(oldPath);
if ischar(myPath)
    set(handles.PathText,'String',myPath);
end


function NameText_Callback(hObject, eventdata, handles)
if ishandle(handles.NameText2)
    set(handles.NameText2,'String',get(hObject,'String'));
end


function MatPadButton_Callback(~, ~, handles)
% hObject    handle to MatPadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[~,mph] = MatPad;
if ishandle(mph)
    if strcmp(get(mph,'Visible'),'on')
        MatPad('hide')
    else
        MatPad('open')
    end
else
    logfile = [get(handles.PathText,'String'),'neuroPG.log'];
    MatPad('log',logfile,'open');
end



% _________ Create Functions _________


function PathText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NameText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NameLabel_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ***********************************************************************
% Pattern Functions


function PatternList_Callback(hObject, eventdata, handles)
select = get(handles.neuroPG,'SelectionType');
switch select
    case 'normal'
        if ~isempty(handles.MaskList)
            set(handles.Thumbnail,'CData',handles.MaskList{get(hObject,'Value')});
        else
            a = abs(handles.DMDDims(2) - handles.DMDDims(1) + 1);
            b = abs(handles.DMDDims(4) - handles.DMDDims(3) + 1);
            set(handles.Thumbnail,'CData',zeros(a,b));
        end
    case 'open'
        if ~isempty(handles.MaskList)
            f = figure('MenuBar','none','Units','pixels');
            imh = imagesc(handles.MaskList{get(hObject,'Value')});
            set(f,'UserData',get(f,'Position'),'ResizeFcn', ...
                {@FigResizeFcn});
            s = size(handles.MaskList{get(hObject,'Value')});
            axis equal off;
            colormap('Gray');
            set(get(imh,'Parent'),'Units','normalized','Position',[0 0 1 1]);
            set(get(imh,'Parent'),'YLim',[0,s(1)],'XLim',[0,s(2)]);
        end
%     case 'alt'
%         
%     case 'extend'
%         
end


function DeleteListItemCallback (varargin)
h = guidata(varargin{1});
if ~isempty(h.MaskList)
    select = get(h.PatternList,'Value');
    if numel(h.MaskList) == 1
        set(h.PatternList,'String','No Patterns');
        h.MaskList = [];
        guidata(h.output,h);
        xmin = h.DMDDims(1);
        xmax = h.DMDDims(2);
        ymin = h.DMDDims(3);
        ymax = h.DMDDims(4);
%         xmax = h.DMDXMax;
%         xmin = h.DMDXMin;
%         ymax = h.DMDYMax;
%         ymin = h.DMDYMin;
        set(h.Thumbnail,'CData',zeros(xmax-xmin+1,ymax-ymin+1));
    else
        values = get(h.PatternList,'String');
        if select == numel(h.MaskList)
            set(h.PatternList,'Value',select-1);
        end
        h.MaskList = [h.MaskList(1:select-1);h.MaskList(select+1:end)];
        values(select,:) = [];
        set(h.PatternList,'String',num2str(values));
        guidata(h.output,h);
        set(h.Thumbnail,'CData',h.MaskList{get(h.PatternList,'Value')});
    end
end


function MoveUpCallback(varargin)
h = guidata(findall(0,'tag','neuroPG'));
pat = get(h.PatternList,'Value');
n = get(h.PatternList,'String');
ml = h.MaskList;
if numel(ml) > 1 && pat > 1
    ml = [ml(1:(pat-2));ml(pat);ml(pat-1);ml((pat+1):end)];
    n = [n(1:(pat-2));n(pat);n(pat-1);n((pat+1):end)];
    h.MaskList = ml;
    set(h.PatternList,'String',n,'Value',pat-1);
    guidata(h.output,h);
    cbf = get(h.PatternList,'Callback');
    cbf(h.PatternList,[]);
end


function MoveDownCallback(varargin)
h = guidata(findall(0,'tag','neuroPG'));
pat = get(h.PatternList,'Value');
n = get(h.PatternList,'String');
ml = h.MaskList;
if numel(ml) > 1 && pat < numel(ml)
    ml = [ml(1:(pat-1));ml(pat+1);ml(pat);ml((pat+2):end)];
    n = [n(1:(pat-1));n(pat+1);n(pat);n((pat+2):end)];
    h.MaskList = ml;
    set(h.PatternList,'String',n,'Value',pat+1);
    guidata(h.output,h);
    cbf = get(h.PatternList,'Callback');
    cbf(h.PatternList,[]);
end


function PatternUpButton_Callback(hObject, eventdata, handles)
h = handles;
pat = get(h.PatternList,'Value');
n = get(h.PatternList,'String');
ml = h.MaskList;
if numel(ml) > 1 && pat > 1
    ml = [ml(1:(pat-2));ml(pat);ml(pat-1);ml((pat+1):end)];
    n = [n(1:(pat-2),:);n(pat,:);n(pat-1,:);n((pat+1):end,:)];
    h.MaskList = ml;
    set(h.PatternList,'String',n,'Value',pat-1);
    guidata(hObject,h);
    cbf = get(h.PatternList,'Callback');
    cbf(h.PatternList,[]);
end


function PatternDownButton_Callback(hObject, eventdata, handles)
h = handles;
pat = get(h.PatternList,'Value');
n = get(h.PatternList,'String');
ml = h.MaskList;
if numel(ml) > 1 && pat < numel(ml)
    ml = [ml(1:(pat-1));ml(pat+1);ml(pat);ml((pat+2):end)];
    n = [n(1:(pat-1),:);n(pat+1,:);n(pat,:);n((pat+2):end,:)];
    h.MaskList = ml;
    set(h.PatternList,'String',n,'Value',pat+1);
    guidata(hObject,h);
    cbf = get(h.PatternList,'Callback');
    cbf(h.PatternList,[]);
end


function ROITypePopup_Callback(~, ~, ~)


function LoadImageCheckBox_Callback(~, ~, ~)


function DefineMultipleCheckBox_Callback(~, ~, ~)


function PermuteButton_Callback(~, ~, ~)


function RandomizeButton_Callback(hObject, eventdata, handles)
order = randperm(numel(handles.MaskList));
values = get(handles.PatternList,'String');
values = values(order,:);
set(handles.PatternList,'String',values);
handles.MaskList = handles.MaskList(order);
guidata(hObject,handles);
PatternList_Callback(handles.PatternList,[],handles);


function PatternButton_Callback(hObject, eventdata, handles)
a = get(handles.LoadImageCheckBox,'Value');
b = get(handles.DefineMultipleCheckBox,'Value');
type = get(handles.ROITypePopup,'Value');
if a == 1 && b == 1
    [f,imh] = LoadImage(handles);
    if ~isempty(f)
        mask = GetMasks(f,imh,type);
    else
        mask = [];
    end
elseif a == 1
    [f,imh] = LoadImage(handles);
    if ~isempty(f)
        mask = GetOneMask(f,imh,type);
    else
        mask = [];
    end
elseif b == 1
    cwh = findall(0,'Tag','CameraWindow');
    if ~isempty(cwh)
        [f,imh] = LoadSnap(handles,cwh);
        mask = GetMasks(f,imh,type);
    else
        warndlg('CameraWindow not found','neuroPG Define Patterns');
        mask = [];
    end
else
    cwh = findall(0,'Tag','CameraWindow');
    if ~isempty(cwh)
        [f,imh] = LoadSnap(handles,cwh);
        mask = GetOneMask(f,imh,type);
    else
        warndlg('CameraWindow not found','neuroPG Define Patterns');
        mask = [];
    end
end
if isempty(handles.MaskList)
    handles.MaskList = mask;
else
    elements = numel(handles.MaskList);
    new = numel(mask);
    for i = (elements+1):(elements+new)
        handles.MaskList{i} = mask{i-elements};
    end
end
guidata(hObject,handles);
nums = (1:numel(handles.MaskList))';
if isempty(nums)
    set(handles.PatternList,'String','No ROI''s','Value',1);
else
    set(handles.PatternList,'String',num2str(nums),'Value',numel(nums));
end
PatternList_Callback(handles.PatternList,[],handles);


function [f,imh] = LoadImage (handles)
patht = [get(handles.PathText,'String'),'\'];
[name,fpath,~] = uigetfile([patht,'*.*'],'Select Image to define ROI');
if ischar(name)
    xmin = handles.DMDDims(1);
    xmax = handles.DMDDims(2);
    ymin = handles.DMDDims(3);
    ymax = handles.DMDDims(4);
    img = imread([fpath,name]);
    res = size(img);
    img = imresize(img,[abs(xmax-xmin+1), abs(ymax-ymin+1)]);
    f = figure('NumberTitle','off','Name','Define Patterns','Units','pixels', ...
        'MenuBar','none');
    imh = imagesc(img);
    s = size(img);
    axis off;
    colormap('Gray');
    set(get(imh,'Parent'),'Units','normalized','Position',[0 0 1 1],'YLim', ...
        [0,s(1)],'XLim',[0,s(2)],'DataAspectRatio',[s(2)/res(2),s(1)/res(1),1]);
    pos = get(f,'Position');
    pos(3) = round(pos(4) / res(1) * res(2));
    set(f,'Position',pos,'UserData',pos,'ResizeFcn',{@FigResizeFcn});
else
    f = [];
    imh = [];
end


function [f,imh] = LoadSnap (handles,cwh)
UD = get(cwh,'UserData');
xmin = handles.DMDDims(1);
xmax = handles.DMDDims(2);
ymin = handles.DMDDims(3);
ymax = handles.DMDDims(4);
img = getsnapshot(UD.video);
if ndims(img) == 3
    img = rgb2gray(img);
end
res = size(img);
img = imresize(img,[abs(xmax-xmin+1), abs(ymax-ymin+1)]);
f = figure('NumberTitle','off','Name','Define Patterns','Units','pixels', ...
    'MenuBar','none');
imh = imagesc(img);
s = size(img);
set(f,'UserData',get(f,'Position'),'ResizeFcn',{@FigResizeFcn});
set(get(imh,'Parent'),'Units','normalized','Position',[0 0 1 1],'YLim', ...
        [0,s(1)],'XLim',[0,s(2)],'DataAspectRatio',[s(2)/res(2),s(1)/res(1),1]);
colormap('Gray');
axis off;
colormap('Gray');
pos = get(f,'Position');
pos(3) = round(pos(4) / res(1) * res(2));
set(f,'Position',pos,'UserData',pos,'ResizeFcn',{@FigResizeFcn});


function mask = GetOneMask(f,imh,type)
axes(get(imh,'Parent'));
switch type
    case 1
        ROI = imellipse;
    case 2
        ROI = imrect;
    case 3
        ROI = impoly;
end
wait(ROI);
mask{1} = uint8(createMask(ROI,imh)); % createMask is a method of impoly types
delete(f);


function mask = GetMasks(f,imh,type)
count = 1;
next = 'Yes';
axes(get(imh,'Parent'));
while strcmp(next,'Yes')
    switch type
        case 1
            ROI = imellipse;
        case 2
            ROI = imrect;
        case 3
            ROI = impoly;
    end
    wait(ROI);
    mask{count,1} = uint8(createMask(ROI,imh)); %#ok<AGROW> % createMask is a method of impoly types
    count = count + 1;
    next = questdlg('Define Another?','Continue?','Yes','No', ... 
        'Change Type','No');
    if strcmp(next,'Change Type')
        next = questdlg('Select Type','Which Type?','Ellipse', ... 
            'Rectangle','Poly','Ellipse');
        if ~isempty(next)
            switch next
                case 'Ellipse'
                    type = 1;
                case 'Rectangle'
                    type = 2;
                case 'Poly'
                    type = 3;
            end
        end
        next = 'Yes';
    end
end
delete(f);


function LoadPatternsButton_Callback(hObject, eventdata, handles)
patht = [get(handles.PathText,'String'),'\'];
[name,fpath,~] = uigetfile([patht,'*.*'],'Select Images to Load', ...
    'MultiSelect','on');
if ischar(name)
    img = imread([fpath,name]);
    xmax = handles.DMDDims(2);
    xmin = handles.DMDDims(1);
    ymax = handles.DMDDims(4);
    ymin = handles.DMDDims(3);
    if size(img) ~= [684,608] %#ok<BDSCA>
        img1 = imresize(img,[xmax-xmin+1, ymax-ymin+1]);
    else
        img1 = img(xmin:xmax,ymin:ymax);
    end
    mask{1} = logical(img1);
elseif iscell(name)
    xmax = handles.DMDDims(2);
    xmin = handles.DMDDims(1);
    ymax = handles.DMDDims(4);
    ymin = handles.DMDDims(3);
    for i = 1:numel(name)
        img = imread([fpath,name{i}]);
        if size(img) ~= [684,608] %#ok<BDSCA>
            img1 = imresize(img,[xmax-xmin+1, ymax-ymin+1]);
        else
            img1 = img(xmin:xmax,ymin:ymax);
        end
        mask{i} = logical(img1); %#ok<AGROW>
    end
else
    mask = [];
end
if isempty(handles.MaskList)
    handles.MaskList = mask;
else
    elements = numel(handles.MaskList);
    new = numel(mask);
    for i = (elements+1):(elements+new)
        handles.MaskList{i} = mask{i-elements};
    end
end
guidata(hObject,handles);
nums = (1:numel(handles.MaskList))';
if isempty(nums)
    set(handles.PatternList,'String','No ROI''s','Value',1);
else
    set(handles.PatternList,'String',num2str(nums),'Value',numel(nums));
end
PatternList_Callback(handles.PatternList,[],handles);


function SavePatternsButton_Callback(hObject, eventdata, handles)
if ~isempty(handles.MaskList)
    name = inputdlg('Enter Mask(s) Name:','Name Mask(s)',[1,35]);
    if isempty(name)
        return;
    end
    name = name{1};
    myPath = get(handles.PathText,'String');
    if isempty(myPath)
        myPath = uigetdir;
        set(handles.PathText,'String',myPath);
    end
    dims = handles.DMDDims;
    for i = 1:numel(handles.MaskList)
        mask = false(684,608);
        mask(dims(1)+1:dims(2)-1,dims(3)+1:dims(4)-1) = logical(handles.MaskList{i});
        imwrite(mask,[myPath,name,'-',num2str(i),'.bmp']);
%         imwrite(handles.MaskList{i},[myPath,'\',name,'-',num2str(i),'.bmp']);
    end
end


function ClearPatternButton_Callback(hObject, eventdata, handles)
set(handles.PatternList,'String','No ROI''s','Value',1);
handles.MaskList = [];
guidata(hObject,handles);
cbf = get(handles.PatternList,'Callback');
cbf(handles.PatternList,[]);


function UploadPatternsButton_Callback(hObject, eventdata, handles)
set(hObject,'BackgroundColor',[.5,.5,.5]);
ML = handles.MaskList; % ML - Mask List
ptns = numel(ML);
handles.polyPtnSet.PtnNumber = ptns;
set(handles.PatternsText,'String',num2str(ptns));
guidata(hObject,handles);
bd = handles.polyPtnSet.bitDepth;
PL = zeros(684,608,ptns,'uint8');% PL - Pattern List
x1 = handles.DMDDims(1);
y1 = handles.DMDDims(3);
for i = 1:ptns
    msize = size(ML{i});
    x2 = x1 + msize(1) - 1;
    y2 = y1 + msize(2) - 1;
    PL(x1:x2,y1:y2,i) = ML{i};
end
code = handles.DMD.upload(PL,bd,0,1);
if code == -1
    warndlg('Pattern Upload Failed','neuroPG: Upload Patterns');
    set(hObject,'BackgroundColor',[.9412,.9412,.9412]);
    return;
end
handles.LoadedPatterns = ptns;
set(handles.PatternList,'Value',1);
handles.PatternCount = 0;
guidata(hObject,handles);
set(hObject,'BackgroundColor','g')
pause(.5);
set(hObject,'BackgroundColor',[.9412,.9412,.9412]);


function PairedStimButton_Callback(hObject, eventdata, h)
list = h.MaskList;
if numel(list) ~= 2
    warndlg('The ROI List must conatin exactly 2 regions to run Ba-Bam!')
    return;
end
a = get(h.PolygonCheckbox,'Value');
b = get(h.DAQCheckbox,'Value');
if a == 0 || b == 0
    c = get(hObject,'BackgroundColor');
    set(hObject,'BackgroundColor','r');
    w = warndlg('Both the DAQ and the Polygon must be enabled to run Ba-Bam!');
    set(w,'Units','pixels');
    pos = get(h.output,'Position');
    pos2 = get(w,'Position');
    pos2(1) = pos(1)+100;
    pos2(2) = pos(2)+50;
    set(w,'Position',pos2);
    pause(.25);
    set(hObject,'BackgroundColor',c);
    return;
end
set(hObject,'Enable','off');
h.PairedStimt1 = 0;
h.PairedStimt2 = 0;
guidata(hObject,h);
f = figure('Units','pixels','Position',[2550,200,250,275], ... 
    'MenuBar','none','IntegerHandle','off','Name','Paired Stim', ... 
    'NumberTitle','off','Resize','off','tag','PairedStim');
j = get(handle(f),'JavaFrame');
drawnow;
j.fHG1Client.getWindow.setAlwaysOnTop(1);

uicontrol('Style','text','Parent',f,'Units','normalized', ... 
    'Position',[.03,0.9,.92,.1],'String', ... 
    ['Delay Time may be greater than Exposure Time', ...
    '.  In this case there will be no Overlap.'], ... 
    'HitTest','off','BackgroundColor',[.8,.8,.8]);

uicontrol('Style','text','Parent',f,'Units','normalized', ... 
    'Position',[.05,0.75,.45,.1],'String','Exposure Time:', ... 
    'HitTest','off','BackgroundColor',[.8,.8,.8]);
uicontrol('Style','text','Parent',f,'Units','normalized', ... 
    'Position',[.05,0.65,.45,.1],'String','Delay Time:', ... 
    'HitTest','off','BackgroundColor',[.8,.8,.8]);

uicontrol('Style','text','Parent',f,'Units','normalized', ... 
    'Position',[.8,0.75,.15,.1],'String','ms','HitTest','off', ...
    'BackgroundColor',[.8,.8,.8],'HorizontalAlignment','left');
uicontrol('Style','text','Parent',f,'Units','normalized', ... 
    'Position',[.8,0.65,.15,.1],'String','ms','HitTest','off', ...
    'BackgroundColor',[.8,.8,.8],'HorizontalAlignment','left');

t1 = uicontrol('Style','edit','Parent',f,'Units','normalized','String', ... 
    '0','Position',[.525,0.8,.25,.075],'HorizontalAlignment','right');
t2 = uicontrol('Style','edit','Parent',f,'Units','normalized','String', ... 
    '0','Position',[.525,0.69,.25,.075],'HorizontalAlignment','right');

uicontrol('Style','PushButton','Parent',f,'Units','normalized','String', ... 
    'Stimulate','Position',[.45,0.05,.5,.1],'Callback',{@PairedStimCBF,t1,t2,h},...
    'KeyPressFcn',{@PairedStimCBF,t1,t2,h});

ax = axes('Parent',f,'Units','normalized','Position',[.11,.2,.78,.4509],...
    'XTick',[],'YTick',[]);

img = imread('PairedStim - Timing Diagram 2.png');
imshow(img,'Parent',ax);
uicontrol(t1);
uiwait(f);
h = guidata(hObject);
dt1 = h.PairedStimt1;
dt2 = h.PairedStimt2;
if dt1 == 0
    set(hObject,'Enable','on');
    return;
elseif dt1 + dt2 > 5 || h.recTime*10 > 50000
    warndlg('Total Time Exceeds Max Recording Time of 5 Seconds');
    set(hObject,'Enable','on');
    return;
end
s = size(list{1});
blank = zeros(s(1),s(2),class(list{1})); %#ok<ZEROLIKE>
if dt1 > dt2
    list{3} = list{2};
    list{2} = uint8(list{1} | list{2});
elseif dt1 ~= dt2
    list{3} = list{2};
    list{2} = blank;
end
list{end+1} = blank;
list{end+1} = blank;
h.MaskList = list;
h.polyPtnSet.TrigType = 2;
set(h.TriggerTypePopup,'Value',3);
oldExp = h.polyPtnSet.ExposureTime;
h.polyPtnSet.ExposureTime = 2000000; % Value in microseconds, 2M MAX
guidata(hObject,h);
cbf = get(h.UploadPatternsButton,'Callback');
cbf(h.UploadPatternsButton,[]);
if ~isempty(h.daqs3)
    h.daqs3.release;
end
time = round(max(h.recTime * 10,(dt1+dt2+.01)*10000)); % Assumes 10 kHz DAQ Rate
h.recTime = uint32(ceil(time/10));

if h.PairedStimFigs <= 0
    h.PairedStimFigs = 1;
    guidata(hObject,h);
end

if dt1 > dt2
    a = dt2;
    b = dt1 - dt2;
    c = dt1 - b;
elseif dt1 ~= dt2
    a = dt1;
    b = dt2 - dt1;
    c = dt1;
else
    a = dt1;
    b = [];
    c = dt1;
end
t = [a,b,c];

h.pCount = min(h.tCount,96);
h.picFlag = 0;
h.scanType = 3;
h.skipRecording = numel(t) + 1;
guidata(hObject,h);
rtime = max(h.recTime/1000,dt1+dt2+.01) - (dt1+dt2); % recTime is in milliseconds
h.daqs2.outputSingleScan([h.PairedStimFigs/100,h.PairedStimFigs/-100]);
tic;
h.daqsB.outputSingleScan(1);
while toc < 0.0002
end
h.daqsB.outputSingleScan(0);
for i = 1:numel(t)
    tic;
    while toc < t(i)
    end
    tic;
    h.daqsB.outputSingleScan(1);
    while toc < 0.0002
    end
    h.daqsB.outputSingleScan(0);
end
tic;
while toc < rtime
end
h.daqs2.outputSingleScan([0,0]);
tic;
h.daqsB.outputSingleScan(1);
while toc < 0.0002
end
h.daqsB.outputSingleScan(0);
h.daqsB.release;
h = guidata(hObject);
set(hObject,'Enable','on');
if dt1 ~= dt2
    h.MaskList = {list{1},list{3}};
else
    h.MaskList = {list{1},list{2}};
end
h.recTime = str2double(get(h.RecordTimeText,'String'));
guidata(hObject,h);
h.polyPtnSet.ExposureTime = oldExp;


function PairedStimCBF(obj,~,t1,t2,h)
T1 = str2double(get(t1,'String'))/1000; % Solves for time in seconds
T2 = str2double(get(t2,'String'))/1000; % Solves for time in seconds
if T1 > 2
    warndlg('Exposure Time Maximum is 2000 ms');
    return;
elseif T1 < 0 || T2 < 0
    warndlg('Times Cannot Be Negative');
    return;
else
    h.PairedStimt1 = T1;
    h.PairedStimt2 = T2;
    guidata(h.output,h);
    close(get(obj,'Parent'));
end


function AutoStimButton_Callback(hObject, eventdata, handles)
h = handles;
set(hObject,'Enable','off');
c = get(hObject,'BackgroundColor');
set(hObject,'BackgroundColor','r');
drawnow;
a = get(h.DAQCheckbox,'Value');
b = get(h.PolygonCheckbox,'Value');
if a == 0 || b == 0
    w = warndlg('Both the DAQ and the Polygon must be enabled to run AutoStim');
    set(w,'Units','pixels');
    pos = get(h.output,'Position');
    pos2 = get(w,'Position');
    pos2(1) = pos(1)+100;
    pos2(2) = pos(2)+25;
    set(w,'Position',pos2);
    pause(.25);
    set(hObject,'Enable','on','BackgroundColor',c);
    return;
end

ML = handles.MaskList; % ML - Mask List
tCount = numel(ML); % Total pattern count
PL = zeros(684,608,tCount,'uint8');
x1 = handles.DMDDims(1);
y1 = handles.DMDDims(3);
bd = str2double(get(h.BitDepthText,'String'));
bytes = 608 * 684 /  (8 / bd);
ptns = zeros(bytes,tCount,'uint8');
for i = 1:tCount
    msize = size(ML{i});
    x2 = x1 + msize(1) - 1;
    y2 = y1 + msize(2) - 1;
    PL(x1:x2,y1:y2,i) = ML{i};
end
pps = h.polyPtnSet;
pps.TrigType = 2;
set(h.TriggerTypePopup,'Value',3);
pps.TrigDelay = str2double(get(h.TrigDelayText,'String'));
pps.TrigPeriod = str2double(get(h.TrigPeriodText,'String'));
pps.ExposureTime = str2double(get(h.PatternExposureText,'String')) * 1000;
pps.LEDSelection = get(h.LEDColorPopup,'Value') - 1;
set(h.BitDepthText,'String','1');
pps.bitDepth = 1;
set(h.PatternsText,'String',num2str(tCount));
if tCount > 1000
    pps.PtnNumber = 100;
else
    pps.PtnNumber = tCount;
end
h.polyPtnSet = pps;
h.polyTrigSet.TrigPulseWidth = pps.ExposureTime;
guidata(hObject,h);
code = handles.DMD.setPtnSettings(h.polyPtnSet);
if code ~= -1
    code = handles.DMD.setOutTrigSettings(h.polyTrigSet);
else
    warndlg('PtnSettings failed','neuroPG AutoStim');
end
if code ~= -1
    code = handles.DMD.upload(PL,bd,0,1);
else
    warndlg('OutTrigSettings failed','neuroPG AutoStim');
end
if code == -1
    warndlg('DMD Upload Failed','neuroPG DMD Error')
    return;
end
val = round(str2double(get(handles.LEDIntensityText,'String')) * 10);
r = 0; g = 1000; b = 0;
switch get(handles.LEDColorPopup,'Value');
    case 1
        r = val;
    case 2
        g = val;
    case 3
        b = val;
end
code = h.DMD.SetDevLEDCurrent(r,g,b);
if code == -1
    warndlg('Polygon LED Setting Failed');
    set(h.SweepButton,'Enable','on');
    return;
end

pCount = 0;
rate = 1000 / h.recTime;
pulse = h.daqt.Channels;
pulse.Frequency = rate;
pulse.DutyCycle = rate * .0002; % 0.2 ms pulse - 2 points @ 10 kHz
h.daqt.DurationInSeconds = h.recTime / 1000 * (min(tCount,96)-1);
waitTimer = timer('StartDelay',h.recTime / 1000 * min(tCount,96),'TimerFcn', ...
    @(obj,~)stop(obj));
h.scanType = 3;
% dataPoints = recordTime(ms) * rateFactor(10) * totalPatterns + buffer
t = (h.recTime * 10 * tCount) + 1000 + (2000 * idivide(tCount,int8(96),'ceil'));
h.recBuffer = zeros(t,3);
[~,mph] = MatPad;
if isempty(mph)
    logfile = [get(handles.PathText,'String'),'neuroPG.log'];
    MatPad('log',logfile);
end
timestr = datestr(clock,'mm/dd/yy HH:MM AM');
entry = ['-- Starting AutoStim ',timestr];
logentry = sprintf('<HTML><BODY color="%s">%s', 'purple', entry);
MatPad('add',logentry);
entry = [num2str(tCount),' Patterns'];
MatPad('add',entry);
entry = ['Record Time: ',num2str(h.recTime),' ms'];
MatPad('add',entry);
switch get(h.LEDColorPopup,'Value')
    case 1
        entry = 'LED Color: Red';
    case 2
        entry = 'LED Color: Green';
    case 3
        entry = 'LED Color: Blue';
end
MatPad('add',entry);
entry = ['LED Intensity: ',get(h.LEDIntensityText,'String'),'%'];
MatPad('add',entry);
entry = ['Pattern Exposure Time: ',get(h.PatternExposureText,'String'),' ms'];
MatPad('add',entry,'save');
guidata(hObject,h);

while pCount < tCount
    pause(.1);
    h.daqt.startBackground();
    start(waitTimer);
    wait(waitTimer);
    h = guidata(hObject);
    h.scanType = 0;
    guidata(hObject,h);
    pCount = pCount + 1000;
    if pCount < tCount
        entry = sprintf('<HTML><BODY color="%s">%s','orange','-- Pausing AutoStim');
        MatPad('add',entry,'save');
        if tCount - pCount > 1000
            pps.PtnNumber = 1000;
        else
            pps.PtnNumber = tCount - pCount;
        end
        h.polyPtnSet = pps;
        settings = cell2mat(struct2cell(h.polyPtnSet));
        code = polymex('SetDevPtnSetting',0,int32(settings));
        if code == -1
            warndlg('Polygon Pattern Settings update FAILED');
            set(h.SweepButton,'Enable','on');
            return;
        end
        entry = sprintf('<HTML><BODY color="%s">%s','orange','-- Uploading Patterns');
        MatPad('add',entry,'save');
        for i = 1:min(tCount - pCount,1000)
            code = polymex('SetDevPtnDef',0,i-1,bd,ptns(:,i + pCount));
            if code == -1
                warndlg(['Pattern Load Faild on Pattern #' num2str(i)]);
                set(h.SweepButton,'Enable','on');
                return;
            end
        end
        % Start Patterns without initial flash
        code = polymex('SetDevLEDCurrent',0,0,0,0);
        if code == -1
            warndlg('Polygon LED Setting Failed');
            set(h.SweepButton,'Enable','on');
            return;
        end
        code = polymex('StartPattern',0);
        if code == -1
            warndlg('Polygon Start Pattern Failed');
            set(h.SweepButton,'Enable','on');
            return;
        end
        % pause(max(pps.ExposureTime / 1000000,.01));
        val = round(str2double(get(handles.LEDIntensityText,'String')) * 10);
        r = 0; g = 1000; b = 0;
        switch get(handles.LEDColorPopup,'Value');
            case 1
                r = val;
            case 2
                g = val;
            case 3
                b = val;
        end
        code = polymex('SetDevLEDCurrent',0,r,g,b);
        if code == -1
            warndlg('Polygon LED Setting Failed');
            set(h.SweepButton,'Enable','on');
            return;
        end
        h = guidata(hObject);
        h.daqt.DurationInSeconds = h.recTime / 1000 * (min(tCount-pCount,96)-1);
        set(waitTimer,'StartDelay',h.recTime / 1000 * min(tCount-pCount,96));
        h.scanType = 3;
        entry = sprintf('<HTML><BODY color="%s">%s','orange','-- Resuming AutoStim');
        MatPad('add',entry,'save');
        guidata(hObject,h);
    end
end
delete(waitTimer);
% Evaluate Data - clean buffer, split into stims, calc and assign IDs, generate maps
entry = sprintf('<HTML><BODY color="%s">%s','purple','-- Stimulation Complete');
MatPad('add',entry,'save');
pause(.1)
h = guidata(hObject);
data = h.recBuffer;
temp1 = data(:,3) > 2;
temp2 = [false;temp1(1:end-1)];
stims = find(temp1 & ~temp2);
keep1 = stims - 200; % This changes the length of pre-stim data that is kept
keep2 = stims + h.recTime*10 - 200;
if keep2(end) > numel(data(:,1))
    keep2(end) = numel(data(:,1));
end
if numel(keep1) ~= numel(keep2)
    disp('keep size mismatch 2343');
end
traces = cell(numel(keep1),2);
for i = 1:numel(keep1)
    traces{i,1} = data(keep1(i):keep2(i),:);
    traces{i,2} = i;
end
myPath = get(h.PathText,'String');
if isempty(myPath)
    cbh = get(h.PathSelectButton,'Callback');
    cbh(h.PathSelectButton,[]);
    myPath = get(h.PathText,'String');
    if isempty(myPath)
        myPath = pwd;
    end
end
if myPath(end) ~= '\'
    myPath(end+1) = '\';
end
myName = get(h.NameText,'String');
if isempty(myName)
    myName = inputdlg('Enter save file name.','Name',1,{datestr(clock,'mmm_dd HH-MM')});
    myName = myName{1};
end
if ~isempty(myName)
    fullname = fullfile(myPath,[myName,' - traces.m']);
else
    fullname = [];
end
if ~isempty(fullname) && exist(fullname,'file')
    resp = questdlg('Overwrite existing file?','Overwrite','No');
    if strcmp(resp,'No') || strcmp(resp,'Cancel')
        myName = inputdlg('Enter save file name.','Name',1,{datestr(clock,'mmm_dd HH-MM')});
        myName = myName{1};
        if ~isempty(myName)
            fullname = fullfile(myPath,[myName,' - traces.m']);
        else
            fullname = [];
        end
    end
end
if ~isempty(fullname)
    save(fullname,'traces');
    entry = sprintf('<HTML><BODY color="%s">%s','gray','-- Data Saved');
    MatPad('add',entry);
    MatPad('add',fullname,'save');
else
    myName = datestr(clock,'mmm_dd HH-MM');
end
set(hObject,'Enable','on','BackgroundColor',c);
entry = sprintf('<HTML><BODY color="%s">%s','purple','-- Starting nPGHeatMap');
MatPad('add',entry);
nPGHeatMap(traces,ML,myName,myPath);


function mask = MakeMask2(h,rects)
h = guidata(findall(0,'tag','neuroPG'));
xmax = h.DMDDims(1);
xmin = h.DMDDims(2);
ymax = h.DMDDims(3);
ymin = h.DMDDims(4);
mask = zeros(abs(xmax-xmin+1),abs(ymax-ymin+1),'uint8');
for i = 1:numel(rects)
    verts = get(rects(i),'Vertices');
    wmin = verts(1,2);
    if wmin < 1
        wmin = 1;
    end
    wmax = verts(4,2);
    if wmax > size(mask,1)
        wmax = size(mask,1);
    end
    hmin = verts(1,1);
    if hmin < 1
        hmin = 1;
    end
    hmax = verts(2,1);
    if hmax > size(mask,2)
        hmax = size(mask,2);
    end
    mask(wmin:wmax,hmin:hmax) = 1;
end


% _________ Create Functions _________


function PatternList_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% Define a context menu; it is not attached to anything
hcmenu = uicontextmenu;
% Define the context menu items and install their callbacks
uimenu(hcmenu,'Label','delete','Callback',{@DeleteListItemCallback});
uimenu(hcmenu,'Label','Move Up','Callback',{@MoveUpCallback});
uimenu(hcmenu,'Label','Move Down','Callback',{@MoveDownCallback});
% item2 = uimenu(hcmenu, 'Label', 'dotted', 'Callback', hcb2);
% item3 = uimenu(hcmenu, 'Label', 'solid',  'Callback', hcb3);
set(hObject,'uicontextmenu',hcmenu);


function ROITypePopup_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ***********************************************************************
% Polygon Control & Pattern Settings Functions


function PolygonCheckbox_Callback(hObject, eventdata, handles)
h = get(handles.PolygonSettingsPanel,'Children');
h2 = get(handles.PolygonControlsPanel,'Children');
h2(h2 == hObject) = [];
h2(h2 == handles.BitDepthText) = [];
h2(h2 == handles.PatternsText) = [];
h3 = handles.UploadPatternsButton;
if get(hObject,'Value') == 1
    handles.DMD = Polygon400.connect(0);
    connected = handles.DMD.connected;
    if connected == 1
        set(h,'Enable','on');
        set(h2,'Enable','on');
        set(h3,'Enable','on');
        handles.polyFlag = 1;
        guidata(hObject,handles);
        if any(handles.DMDO == [2,4,6,8])
            vFlip = 1;
        else
            vFlip = 0;
        end
        if any(handles.DMDO == [3,4,7,8])
            hFlip = 1;
        else
            hFlip = 0;
        end
        code = handles.DMD.SetDevDisplaySetting(vFlip,hFlip);
        if code == -1
            warndlg('Polygon400 Orientation Failed','neuroPG DMD')
        end
        [~,h] = MatPad;
        if isempty(h)
            logfile = [get(handles.PathText,'String'),'neuroPG.log'];
            MatPad('log',logfile);
        end
        timestr = datestr(clock,'mm/dd/yy HH:MM AM');
        entry = ['-- Polygon400 Initialized ',timestr];
        logentry = sprintf('<HTML><BODY color="%s">%s', 'blue', entry);
        MatPad('add',logentry,'save');
    else
        warndlg('DMD Connection Failed','neuroPG Warning');
        set(hObject,'Value',0);
        handles.DMD.delete;
    end
else
    set(h,'Enable','off');
    set(h2,'Enable','off');
    set(h3,'Enable','off');
    if handles.polyFlag == 1
        handles.DMD.delete;
        [~,h] = MatPad;
        if isempty(h)
            logfile = [get(handles.PathText,'String'),'neuroPG.log'];
            MatPad('log',logfile);
        end
        timestr = datestr(clock,'mm/dd/yy HH:MM AM');
        entry = ['-- Polygon400 Released ',timestr];
        logentry = sprintf('<HTML><BODY color="%s">%s', 'red', entry);
        MatPad('add',logentry,'save');
        handles.polyFlag = 0;
        guidata(hObject,handles);
    end
end


function PolyMinXText_Callback(hObject, ~, ~)
val = str2double(get(hObject,'String'));
if val < 1
    val = 1;
elseif val > 684
    val = 684;
end
set(hObject,'String',num2str(val),'BackgroundColor','r');


function PolyMaxXText_Callback(hObject, ~, ~)
val = str2double(get(hObject,'String'));
if val < 1
    val = 1;
elseif val > 684
    val = 684;
end
set(hObject,'String',num2str(val),'BackgroundColor','r');


function PolyMinYText_Callback(hObject, ~, ~)
val = str2double(get(hObject,'String'));
if val < 1
    val = 1;
elseif val > 608
    val = 608;
end
set(hObject,'String',num2str(val),'BackgroundColor','r');


function PolyMaxYText_Callback(hObject, ~, ~)
val = str2double(get(hObject,'String'));
if val < 1
    val = 1;
elseif val > 608
    val = 608;
end
set(hObject,'String',num2str(val),'BackgroundColor','r');


function CommitButton_Callback(hObject, eventdata, handles)
xmax = str2double(get(handles.PolyMaxXText,'String'));
handles.DMDXMax = xmax;
xmin = str2double(get(handles.PolyMinXText,'String'));
handles.DMDXMin = xmin;
ymax = str2double(get(handles.PolyMaxYText,'String'));
handles.DMDYMax = ymax;
ymin = str2double(get(handles.PolyMinYText,'String'));
handles.DMDYMin = ymin;
if xmin >= xmax || ymin >= ymax
    warndlg('Innapropriate Values for Pattern Window');
else
    delete(handles.Thumbnail);
    axes(handles.ThumbnailAxes)
    handles.Thumbnail = imagesc(zeros(xmax-xmin+1,ymax-ymin+1,'uint8'));
    axis off
    set(handles.PolyMaxXText,'BackgroundColor','g');
    set(handles.PolyMinXText,'BackgroundColor','g');
    set(handles.PolyMaxYText,'BackgroundColor','g');
    set(handles.PolyMinYText,'BackgroundColor','g');
    guidata(hObject,handles);
end


function DefaultPatternSizeButton_Callback(hObject, eventdata, handles)
delete(handles.Thumbnail);
axes(handles.ThumbnailAxes)
handles.Thumbnail = imagesc(zeros(545,362,'uint8'));
axis off
set(handles.PolyMaxXText,'String','672','BackgroundColor','g');
set(handles.PolyMinXText,'String','128','BackgroundColor','g');
set(handles.PolyMaxYText,'String','505','BackgroundColor','g');
set(handles.PolyMinYText,'String','144','BackgroundColor','g');
handles.DMDXMax = 672;
handles.DMDXMin = 128;
handles.DMDYMax = 505;
handles.DMDYMin = 144;
guidata(hObject,handles);


function StartPatternButton_Callback(hObject, eventdata, handles)

code = handles.DMD.start;
if code == -1
    warndlg('Polygon Start Pattern Failed');
else
    set(handles.PatternList,'Value',1);
    handles.PatternCount = 0;
    guidata(hObject,handles);
end


function NextPatternButton_Callback(hObject, eventdata, handles)
code = handles.DMD.next;
if code == -1
    warndlg('Polygon Next Pattern Failed');
else
    ptns = handles.LoadedPatterns;
    if ptns ~= 0
        i = handles.PatternCount;
        if i == ptns
            i = 1;
        else
            i = i + 1;
        end
        if i <= size(get(handles.PatternList,'String'),1)
            set(handles.PatternList,'Value',i);
            set(handles.Thumbnail,'CData',handles.MaskList{i});
        end
        handles.PatternCount = i;
        guidata(hObject,handles);
    end
end


function StopPatternButton_Callback(~, ~,handles)
code = handles.DMD.stop;
if code == -1
    warndlg('Polygon Stop Pattern Failed');
end


function LEDIntensityText_Callback(hObject, eventdata, handles)
val = round(str2double(get(hObject,'String')) * 10);
if val > 1000
    val = 1000;
    set(hObject,'String',num2str(val));
elseif val < 0
    val = 0;
    set(hObject,'String',num2str(val));
end
r = 0; g = 1000; b = 0;
switch get(handles.LEDColorPopup,'Value');
    case 1
        r = val;
    case 2
        g = val;
    case 3
        b = val;
end
code = handles.DMD.SetDevLEDCurrent(r,g,b);
if code == -1
    warndlg('Polygon LED Setting Failed');
end


function LEDColorPopup_Callback(hObject, eventdata, handles)
handles.polyPtnSet.LEDSelection = get(hObject,'Value') - 1;
guidata(hObject,handles);


function PatternExposureText_Callback(hObject, eventdata, handles)
time = str2double(get(hObject,'String'));
if time < 0
    time = 0;
    set(hObject,'String',num2str(time));
elseif time > 2000
    time = 2000;
    set(hObject,'String',num2str(time));
end
time = time * 1000;
handles.polyPtnSet.ExposureTime = time;
guidata(hObject,handles);


function TrigDelayText_Callback(hObject, eventdata, handles)
handles.polyPtnSet.TrigDelay = str2double(get(hObject,'String'))*10;
guidata(hObject,handles);


function TrigPeriodText_Callback(hObject, eventdata, handles)
handles.polyPtnSet.TrigPeriod = str2double(get(hObject,'String'))*10;
guidata(hObject,handles);


function TriggerTypePopup_Callback(hObject, eventdata, handles)
handles.polyPtnSet.TrigType = get(hObject,'Value') - 1;
guidata(hObject,handles);


function UpdatePolygonButton_Callback(hObject, eventdata, handles)
code = handles.DMD.setPtnSettings(handles.polyPtnSet);
if code ~= -1
    code = handles.DMD.setOutTrigSettings(handles.polyTrigSet);
else
    warndlg('PtnSettings failed','neuroPG AutoStim');
end
if code ~= -1
    code = handles.DMD.SetDevLEDCurrent(0,0,0);
else
    warndlg('Polygon LED Setting Failed');
end
if code == -1
    warndlg('Polygon Start Pattern Failed');
else
    set(handles.PatternList,'Value',1);
    handles.PatternCount = 0;
end
r = 0; g = 1000; b = 0;
val = str2double(get(handles.LEDIntensityText,'String')) * 10;
switch get(handles.LEDColorPopup,'Value');
    case 1
        r = val;
    case 2
        g = val;
    case 3
        b = val;
end
code = handles.DMD.SetDevLEDCurrent(r,g,b);
if code == -1
    warndlg('Polygon LED Setting Failed');
end


function BitDepthText_Callback(~, ~, ~)


function PatternsText_Callback(~, ~, ~)


% _________ Create Functions _________


function XDimsLabel_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function YDimsLabel_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PolyMinXText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PolyMaxXText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PolyMinYText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PolyMaxYText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LEDIntensityLabel_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LEDIntensityText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function LEDColorPopup_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ExposureLabel_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PatternExposureText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TrigDelayLabel_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TrigDelayText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function trigPeriodLabel_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TrigPeriodText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TriggerTypePopup_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BitDepthLabel_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function BitDepthText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PatternsLabel_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function PatternsText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% ***********************************************************************
% SmartGrid Functions


function SmartGridCheckbox_Callback(hObject, eventdata, handles)
objs = get(handles.SmartGrid,'Children');
if get(hObject,'Value') == 1
    mypath = get(handles.PathText,'String');
    [myfile,mypath,~] = uigetfile([mypath,'\*.*'],'Select Image');
    if ischar(myfile)
        set(objs,'Enable','on');
        handles.Width = abs(handles.DMDDims(2) - handles.DMDDims(1));
        handles.Height = abs(handles.DMDDims(4) - handles.DMDDims(3));
        y = handles.Width;
        x = handles.Height;
        img = imresize(imread([mypath,myfile]),[y,x]);
        opengl software;
        handles.Figure = figure('NumberTitle','off','Name','SmartGrid Map',...
            'CloseRequestFcn',{@FigureCRF,handles.output}, ...
            'MenuBar','none','Color','k','Units','pixels','tag','SGfig', ...
            'ResizeFcn',@SGResizeFcn,'Position',handles.SmartGridPosition, ...
            'IntegerHandle','off');
        set(handles.Figure,'UserData',get(handles.Figure,'Position'));
        handles.Image = imagesc(img);
        axis square off;
        colormap('Gray');
        handles.Axes = get(handles.Image,'Parent');
        myaxes = handles.Axes;
        set(myaxes,'Units','normalized', ...
            'Position',[0,0,1,1]);
        handles.Axes2 = axes('Parent',handles.Figure,'Units','normalized', ...
            'Position',[0,0,1,1],'XLim',[1,x],'YLim',[1,y],'HitTest','off', ...
            'Color','none','XTick',[],'YTick',[],'YDir','reverse');
        data.channel1{1} = 0;
        data.channel2{1} = 0;
        data.id = 1;
        data.alpha = 0;
        data.color = [1,0,0];
        patch([1,x,x,1],[1,1,y,y],'r', ...
            'FaceAlpha',0,'Parent',myaxes,'EdgeColor','r', ...
            'ButtonDownFcn',{@PatchBDF,handles.neuroPG}, ...
            'UserData',data);
    else
        set(hObject,'Value',0);
        handles.Figure = [];
        handles.Image = [];
    end
else
    if ~isempty(handles.Figure)
        delete(handles.Figure);
        handles.Figure = [];
    end
    set(objs,'Enable','off');
    set(hObject,'Enable','on');
end
handles.MSMaxAlpha = 1;
guidata(hObject,handles);


function SGShowButton_Callback(hObject, eventdata, handles)
if strcmp(get(hObject,'String'),'Show')
    figure(handles.Figure);
    set(handles.Figure,'Visible','on');
    set(hObject,'String','Hide');
else
    set(handles.Figure,'Visible','off');
    set(hObject,'String','Show');
end


function RowsText_Callback(~, ~, ~)


function ColumnsText_Callback(~, ~, ~)


function SegmentButton_Callback(hObject, eventdata, handles)
h = handles;
if h.GridStimFigs ~= 0
    close(h.GridStimFigs);
end
data.channel1{1} = 0;
data.channel2{1} = 0;
data.id = 0;
data.alpha = 0;
data.color = [1,0,0];
for k = 1:numel(h.SelectedRects)
    verts = get(h.SelectedRects(k),'Vertices');
    delete(h.SelectedRects(k));
    xmin = verts(1,1);
    xmax = verts(2,1);
    x = xmax - xmin;
    ymin = verts(1,2);
    ymax = verts(4,2);
    y = ymax - ymin;
    numrows = str2double(get(h.RowsText,'String'));
    numcols = str2double(get(h.ColumnsText,'String'));
    xstep = floor(x / numcols);
    ystep = floor(y / numrows);
    xmins = xmin:xstep:xmax;
    xmaxes = (xmin+xstep-1):xstep:xmax;
    xmaxes(end) = xmax;
    ymins = ymin:ystep:ymax;
    ymaxes = (ymin+ystep-1):ystep:ymax;
    ymaxes(end) = ymax;
    for i = 1:numrows
        for j = 1:numcols
            patch([xmins(j),xmaxes(j),xmaxes(j),xmins(j)],...
                [ymins(i),ymins(i),ymaxes(i),ymaxes(i)],'r', ...
                'FaceAlpha',0,'Parent',h.Axes,'EdgeColor','r', ...
                'ButtonDownFcn',{@PatchBDF,handles.output}, ...
                'UserData',data);
        end
    end
end
h.SelectedRects = [];
guidata(hObject,h);
rects = findall(h.Axes,'type','patch');
for i = 1:numel(rects)
    data = get(rects(i),'UserData');
    data.id = i;
    set(rects(i),'UserData',data);
end


function CombineButton_Callback(hObject, eventdata, handles)
h = handles;
if numel(h.SelectedRects) > 1
    verts = get(h.SelectedRects,'Vertices');
    xmins = zeros(numel(verts),1);
    xmaxes = zeros(numel(verts),1);
    ymins = zeros(numel(verts),1);
    ymaxes = zeros(numel(verts),1);
    for i = 1:numel(verts)
        xmins(i) = verts{i}(1,1);
        xmaxes(i) = verts{i}(2,1);
        ymins(i) = verts{i}(1,2);
        ymaxes(i) = verts{i}(4,2);
    end
    xmins = unique(xmins);
    xmaxes = unique(xmaxes);
    ymins = unique(ymins);
    ymaxes = unique(ymaxes);
    allRects = findall(h.Axes,'type','patch');
    if numel(xmins)*numel(ymins) == numel(h.SelectedRects)  || ...
            numel(allRects) == numel(h.SelectedRects)
        if h.GridStimFigs ~= 0
            close(h.GridStimFigs);
        end
        xmin = min(xmins);
        xmax = max(xmaxes);
        ymin = min(ymins);
        ymax = max(ymaxes);
        for i = numel(allRects):-1:1
            verts = get(allRects(i),'Vertices');
            x = verts(:,1);
            y = verts(:,2);
            if ~all([xmin<=x;xmax>=x;ymin<=y;ymax>=y])
                allRects(i) = [];
            end
        end
        delete(allRects);
        data.channel1{1} = 0;
        data.channel2{1} = 0;
        data.id = 0;
        data.alpha = 0;
        data.color = [1,0,0];
        h.SelectedRects = patch([xmin,xmax,xmax,xmin],...
            [ymin,ymin,ymax,ymax],'r', ...
            'FaceAlpha',0,'Parent',h.Axes,'EdgeColor','g', ...
            'ButtonDownFcn',{@PatchBDF,handles.output}, ...
            'UserData',data);
        guidata(hObject,h);
        rects = findall(h.Axes,'type','patch');
        for i = 1:numel(rects)
            data = get(rects(i),'UserData');
            data.id = i;
            set(rects(i),'UserData',data);
        end
    end
end


function AllButton_Callback(hObject, eventdata, handles)
h = handles;
rects = findall(h.Axes,'type','patch');
set(rects,'EdgeColor','g');
h.SelectedRects = rects;
guidata(hObject,h);


function NoneButton_Callback(hObject, eventdata, handles)
h = handles;
rects = findall(h.Axes,'type','patch');
set(rects,'EdgeColor','r');
h.SelectedRects = [];
guidata(hObject,h);


function ExportGroupedButton_Callback(hObject, eventdata, handles)
h = handles;
list = h.SelectedRects;
mask = cell(1,1);
mask{1} = MakeMask2(h,list);
if isempty(handles.MaskList)
    handles.MaskList = mask;
else
    handles.MaskList{end+1} = mask{1};
end
guidata(hObject,handles);
nums = (1:numel(handles.MaskList))';
if isempty(nums)
    set(handles.PatternList,'String','No ROI''s','Value',1);
else
    set(handles.PatternList,'String',num2str(nums),'Value',numel(nums));
end
PatternList_Callback(handles.PatternList,[],handles);


function ExportPatternsButton_Callback(hObject, eventdata, handles)
list = handles.SelectedRects;
tCount = numel(list); % Total pattern count
masks = cell(tCount,1);
for i = 1:tCount
    masks{i} = MakeMask2(handles,list(i));
end
if isempty(handles.MaskList)
    handles.MaskList = masks;
else
    elements = numel(handles.MaskList);
    new = numel(masks);
    for i = (elements+1):(elements+new)
        handles.MaskList{i} = masks{i-elements};
    end
end
guidata(hObject,handles);
nums = (1:numel(handles.MaskList))';
if isempty(nums)
    set(handles.PatternList,'String','No ROI''s','Value',1);
else
    set(handles.PatternList,'String',num2str(nums),'Value',numel(nums));
end
PatternList_Callback(handles.PatternList,[],handles);


function SGSavePatternsButton_Callback(hObject, eventdata, handles)
h = handles;
list = h.SelectedRects;
if ~isempty(list)
    name = inputdlg('Enter Mask(s) Name:','Name Mask(s)',[1,35]);
    if isempty(name)
        return;
    end
    name = name{1};
    myPath = get(h.PathText,'String');
    if isempty(myPath)
        myPath = uigetdir;
        set(h.PathText,'String',myPath);
    end
    for i = 1:numel(list)
        masks = logical(MakeMask(h,list(i)));
        imwrite(masks,[myPath,name,'-',num2str(i),'.bmp']);
    end
end


function RecordTimeText_Callback(hObject, eventdata, handles)
val = str2double(get(hObject,'String'));
if val < 0
    val = 0;
elseif val > 50000
    val = 50000;
end
set(hObject,'String',num2str(val));
handles.recTime = val;
guidata(hObject,handles);


function GridStimButton_Callback(hObject, eventdata, handles)
h = handles;
set(hObject,'Enable','off');
drawnow;
a = get(h.DAQCheckbox,'Value');
b = get(h.PolygonCheckbox,'Value');
if a == 0 || b == 0
    c = get(hObject,'BackgroundColor');
    set(hObject,'BackgroundColor','r');
    w = warndlg('Both the DAQ and the Polygon must be enabled to run Minesweeper');
    set(w,'Units','pixels');
    pos = get(h.output,'Position');
    pos2 = get(w,'Position');
    pos2(1) = pos(1)+200;
    pos2(2) = pos(2)+25;
    set(w,'Position',pos2);
    pause(.25);
    set(hObject,'Enable','on','BackgroundColor',c);
    return;
end
list = h.SelectedRects;
tCount = numel(list); % Total pattern count
masks = zeros(684,608,tCount,'uint8');
ptns = zeros(51984,tCount,'uint8');
order = randperm(tCount);
list = list(order);
for i = 1:tCount
    masks(:,:,i) = MakeMask(h,list(i));
end
name = [get(h.PathText,'String'),'\Sweep Patterns ',datestr(clock,'mmm_dd HH-MM')];
save(name,'masks');
for i = 1:tCount
    ptns(:,i) = bitPack(masks(:,:,i),1);
end
pps = h.polyPtnSet;
pps.TrigType = 2;
set(h.TriggerTypePopup,'Value',3);
pps.TrigDelay = str2double(get(h.TrigDelayText,'String'));
pps.TrigPeriod = str2double(get(h.TrigPeriodText,'String'));
pps.ExposureTime = str2double(get(h.PatternExposureText,'String')) * 1000;
pps.LEDSelection = get(h.LEDColorPopup,'Value') - 1;
set(h.BitDepthText,'String','1');
pps.bitDepth = 1;
set(h.PatternsText,'String',num2str(tCount));
if tCount > 1000
    pps.PtnNumber = 1000;
else
    pps.PtnNumber = tCount;
end
h.polyPtnSet = pps;
h.polyTrigSet.TrigPulseWidth = pps.ExposureTime;
guidata(hObject,h);
settings = cell2mat(struct2cell(h.polyTrigSet));
code = polymex('SetOutTrigSetting',0,int32(settings));
if code == -1
    warndlg('Output Trigger Settings update FAILED');
    set(h.SweepButton,'Enable','on');
    return;
end
settings = cell2mat(struct2cell(h.polyPtnSet));
code = polymex('SetDevPtnSetting',0,int32(settings));
if code == -1
    warndlg('Polygon Pattern Settings update FAILED');
    set(h.SweepButton,'Enable','on');
    return;
end
bd = str2double(get(h.BitDepthText,'String'));
for i = 1:min(tCount,1000)
    code = polymex('SetDevPtnDef',0,i-1,bd,ptns(:,i));
    if code == -1
        warndlg(['Pattern Load Faild on Pattern #' num2str(i)]);
        set(h.SweepButton,'Enable','on');
        return;
    end
end
% Start Patterns without initial flash
code = polymex('SetDevLEDCurrent',0,0,0,0);
if code == -1
    warndlg('Polygon LED Setting Failed');
end
code = polymex('StartPattern',0);
if code == -1
    warndlg('Polygon Start Pattern Failed');
    set(h.SweepButton,'Enable','on');
    return;
end
% pause(max(pps.ExposureTime / 1000000,.01));
val = round(str2double(get(handles.LEDIntensityText,'String')) * 10);
r = 0; g = 1000; b = 0;
switch get(handles.LEDColorPopup,'Value');
    case 1
        r = val;
    case 2
        g = val;
    case 3
        b = val;
end
code = polymex('SetDevLEDCurrent',0,r,g,b);
if code == -1
    warndlg('Polygon LED Setting Failed');
    set(h.SweepButton,'Enable','on');
    return;
end

pCount = 0;

rate = 1000 / h.recTime;

pulse = h.daqt.Channels;
pulse.Frequency = rate;
pulse.DutyCycle = rate * .0002; % 0.2 ms pulse - 2 points @ 10 kHz
h.daqt.DurationInSeconds = h.recTime / 1000 * (min(tCount,1000)-1);
h.scanType = 3;
% dataPoints = recordTime(ms) * rateFactor(10) * totalPatterns + buffer
t = (h.recTime * 10 * tCount) + 1000 + (2000 * idivide(tCount,int8(1000),'ceil'));
h.recBuffer = zeros(t,3);
guidata(hObject,h);

while pCount < tCount
    pause(.1);
    h.daqt.startBackground();
    pause(h.recTime / 1000 * (min(tCount,1000)+1));
    h = guidata(hObject);
    h.scanType = 0;
    guidata(hObject,h);
    pCount = pCount + 1000;
    if pCount < tCount
        if tCount-pCount > 1000
            pps.PtnNumber = 1000;
        else
            pps.PtnNumber = tCount - pCount;
        end
        h.polyPtnSet = pps;
        settings = cell2mat(struct2cell(h.polyPtnSet));
        code = polymex('SetDevPtnSetting',0,int32(settings));
        if code == -1
            warndlg('Polygon Pattern Settings update FAILED');
            set(h.SweepButton,'Enable','on');
            return;
        end
        for i = pCount+1:min(tCount,1000)
            code = polymex('SetDevPtnDef',0,i-pCount-1,bd,ptns(:,i));
            if code == -1
                warndlg(['Pattern Load Faild on Pattern #' num2str(i)]);
                set(h.SweepButton,'Enable','on');
                return;
            end
        end
        % Start Patterns without initial flash
        code = polymex('SetDevLEDCurrent',0,0,0,0);
        if code == -1
            warndlg('Polygon LED Setting Failed');
            set(h.SweepButton,'Enable','on');
            return;
        end
        code = polymex('StartPattern',0);
        if code == -1
            warndlg('Polygon Start Pattern Failed');
            set(h.SweepButton,'Enable','on');
            return;
        end
        % pause(max(pps.ExposureTime / 1000000,.01));
        val = round(str2double(get(handles.LEDIntensityText,'String')) * 10);
        r = 0; g = 1000; b = 0;
        switch get(handles.LEDColorPopup,'Value');
            case 1
                r = val;
            case 2
                g = val;
            case 3
                b = val;
        end
        code = polymex('SetDevLEDCurrent',0,r,g,b);
        if code == -1
            warndlg('Polygon LED Setting Failed');
            set(h.SweepButton,'Enable','on');
            return;
        end
        h = guidata(hObject);
        h.daqt.DurationInSeconds = h.recTime / 1000 * (min(tCount-pCount,1000)-1) ;
        h.scanType = 3;
        guidata(hObject,h);
    end
end
h = guidata(hObject);
h.scanType = 0;
guidata(hObject,h);
% Evaluate Data - clean buffer, split into stims, calc and assign IDs, generate maps
pause(.1)
h = guidata(hObject);
data = h.recBuffer;
temp1 = data(:,3) > 2;
temp2 = [false;temp1(1:end-1)];
stims = find(temp1 & ~temp2);
keep1 = stims - 200; % This changes the length of pre-stim data that is kept
keep2 = stims + h.recTime*10;
if keep2(end) > numel(data(:,1))
    keep2(end) = numel(data(:,1));
end
traces = cell(numel(keep1),2);
for i = 1:numel(keep1)
    traces{i,1} = data(keep1(i):keep2(i),:);
    traces{i,2} = i;
end
for i = 1:size(traces,1)
    UD = get(list(i),'UserData');
    if UD.channel1{1} == 0
        UD.channel1{1} = traces{i,1}(:,1);
        UD.channel2{1} = traces{i,1}(:,2);
    else
        UD.channel1{end+1} = traces{i,1}(:,1);
        UD.channel2{end+1} = traces{i,1}(:,2);
    end
    [alpha,color,~,~] = evaluateTrace(traces{i,1},1,1);
    UD.alpha = UD.alpha + alpha;
    newAlpha = min(1,(UD.alpha / h.MSMaxAlpha));
    if UD.color ~= [0,0,1] %#ok<BDSCA>
        if color ~= [1,0,0] %#ok<BDSCA>
            UD.color = color;
        end
    end
    set(list(i),'FaceAlpha',newAlpha)
    set(list(i),'FaceColor',UD.color)
    set(list(i),'UserData',UD);
end

set(hObject,'Enable','on');


function SaveHeatmapButton_Callback(hObject, eventdata, handles)
name = inputdlg('Enter File Name','Name');
fname = [handles.SavePath,'\',name,'.fig'];
saveas(handles.Figure,fname,'fig');


function ClearHeatmapButton_Callback(hObject, eventdata, handles)
h = handles;
rects = findall(h.Axes,'type','patch');
data.channel1 = {0};
data.channel2 = {0};
data.alpha = 0;
data.color = [1,0,0];
for i = 1:numel(rects)
    d = get(rects(i),'UserData');
    data.id = d.id;
    set(rects(i),'FaceAlpha',0,'FaceColor','r','UserData',data);
end


function AlphaScaleText_Callback(hObject, eventdata, handles)
h = handles;
a = str2double(get(hObject,'String'));
rects = findall(h.Axes,'type','patch');
for i = 1:numel(rects)
    data = get(rects(i),'UserData');
    newAlpha = min(1,data.alpha / a);
    set(rects(i),'FaceAlpha',newAlpha);
end


function mask = MakeMask(h,rects)
mask = zeros(684,608,'uint8');
hoff = h.DMDDims(3);
woff = h.DMDDims(1);
for i = 1:numel(rects)
    verts = get(rects(i),'Vertices');
    wmin = verts(1,2) + woff;
    wmax = verts(4,2) + woff;
    hmin = verts(1,1) + hoff;
    hmax = verts(2,1) + hoff;
    mask(wmin:wmax,hmin:hmax) = 1;
end


function PatchBDF(obj,~,gui)
if ishghandle(gui)
    h = guidata(gui);
else
    h = [];
end
switch get(h.Figure,'SelectionType')
    case 'normal'
        if ~isempty(h)
            if get(obj,'EdgeColor') == [1,0,0] %#ok<BDSCA>
                if numel(h.SelectedRects) > 0
                    set(h.SelectedRects,'EdgeColor','r');
                end
                set(obj,'EdgeColor','g');
                h.SelectedRects = (obj);
            else
                set(h.SelectedRects,'EdgeColor','r');
                h.SelectedRects = [];
            end
        end
    case 'extend'
        if ~isempty(h)
            if get(obj,'EdgeColor') == [1,0,0] %#ok<BDSCA>
                set(obj,'EdgeColor','g');
                h.SelectedRects(end+1) = (obj);
            else
                set(obj,'EdgeColor','r');
                h.SelectedRects(h.SelectedRects == obj) = [];
            end
        end
    case 'alt'
        data = get(obj,'UserData');
        ch1 = data.channel1;
        ch2 = data.channel2;
        if numel(ch1{1} > 1)
            verts = get(obj,'Vertices');
            vx = mean(verts(:,1));
            difx = max(verts(:,1)) - min(verts(:,1));
            vy = mean(verts(:,2));
            dify = max(verts(:,2)) - min(verts(:,2));
            if difx > 20 && dify > 20
                fs = 16;
            else
                fs = 10;
            end
            index = data.id;
            th = text(vx,vy,num2str(index),'Parent',h.Axes2, ...
                'Color','m','HorizontalAlignment','center', ...
                'VerticalAlignment','middle', ...
                'FontSize',fs);
            f = figure;
            if ~isempty(h)
                if h.GridStimFigs == 0
                    h.GridStimFigs = f;
                else
                    h.GridStimFigs(end+1) = f;
                end
                guidata(h.output,h);
            end
            set(f,'Name',['GridStim Trace ' num2str(index)], ... 
                'NumberTitle','off','CloseRequestFcn',{@GridStimTraceCRF,th});
            plot(ch1{1},'HitTest','off','Color','b');
            hold all
            for i = 2:numel(ch1)
                plot(ch1{i},'HitTest','off','Color','b');
            end
            for i = 1:numel(ch2)
                plot(ch2{i},'Color','r','HitTest','off','Visible','off');
            end
            hold off
            axis tight
            xlim([1,numel(ch1{1})]);
            ylim([-.1,.1]);
% ************************** Change pos(1&2) to change monitor position
            pos = [1700,542,1120,420];
            set(f,'Position',pos);
            ah = get(f,'Children');
            % Assuming DAQ Rate = 10 kHz
            xlabel = num2str(str2num(get(ah,'XTickLabel')) ./ 10); %#ok<ST2NM>
            set(ah,'LooseInset',get(ah,'TightInset'),'XTickLabel',xlabel);
            set(ah,'ButtonDownFcn',@traceBDF);
        end
end
if ~isempty(h)
    guidata(gui,h);
end


function traceBDF (obj,~)
switch get(get(obj,'Parent'),'SelectionType')
    case 'extend'
        if strcmp(get(obj,'YLimMode'),'manual')
            set(obj,'YLimMode','auto');
        else
            set(obj,'YLimMode','manual','YLim',[-.1,.1]);
        end
    case 'alt'
        c = get(obj,'Children');
        c1 = findall(c,'Visible','off');
        if ~isempty(c1)
            set(c,'Visible','off');
            set(c1,'Visible','on');
        else
            set(c,'Visible','on');
        end
end


function GridStimTraceCRF(obj,~,th)
gh = findall(0,'tag','neuroPG');
if ~isempty(gh)
    h = guidata(gh);
    if numel(h.GridStimFigs > 1)
        ind = find(h.GridStimFigs == obj,1);
        h.GridStimFigs(ind) = [];
    else
        h.GridStimFigs = 0;
    end
    guidata(gh,h);
end
if ishandle(th)
    delete(th);
end
delete(obj);


function SGResizeFcn(obj,~)
po = get(obj,'UserData');
p = get(obj,'Position');
y = p(2) + p(4);
if p(3) > po(3) && p(4) > po(4)
    if (p(3) == 1680 && p(4) == 988) || (p(3) == 1366 && p(4) == 746)
        p(3) = p(4);
    elseif p(3) > p(4)
        p(4) = p(3);
    else
        p(3) = p(4);
    end
elseif p(3) > po(3) && p(4) == po(4)
    p(4) = p(3);
elseif p(4) > po(4) && p(3) == po(3)
    p(3) = p(4);
else
    if p(3) < p(4)
        p(4) = p(3);
    else
        p(3) = p(4);
    end
end
p(2) = y - p(4);
set(obj,'Position',p,'UserData',p);


function FigureCRF(obj,~,gh)
if ishghandle(gh)
    h = guidata(gh);
    set(h.SmartGridCheckbox,'Value',0);
    cbf = get(h.SmartGridCheckbox,'Callback');
    cbf(h.SmartGridCheckbox,[]);
    h.SelectedRects = [];
    guidata(h.output,h);
else
    delete(obj)
end


% _________ Create Functions _________


function RowsText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ColumnsText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RecordTimeText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function AlphaScaleText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
