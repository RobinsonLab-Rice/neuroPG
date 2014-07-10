function varargout = nPGHeatMap(varargin)
% nPGHeatMap MATLAB code for nPGHeatMap.fig
%      nPGHeatMap, by itself, creates a new nPGHeatMap or raises the existing
%      singleton*.
%
%      H = nPGHeatMap returns the handle to a new nPGHeatMap or the handle to
%      the existing singleton*.
%
%      nPGHeatMap('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in nPGHeatMap.M with the given input arguments.
%
%      nPGHeatMap('Property','Value',...) creates a new nPGHeatMap or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nPGHeatMap_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nPGHeatMap_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nPGHeatMap

% Last Modified by GUIDE v2.5 29-Apr-2014 17:37:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nPGHeatMap_OpeningFcn, ...
                   'gui_OutputFcn',  @nPGHeatMap_OutputFcn, ...
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


% --- Executes just before nPGHeatMap is made visible.
function nPGHeatMap_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;

handles.data = varargin{1};
handles.regions = varargin{2};
handles.name = varargin{3};
set(handles.HeatMapPathText,'String',varargin{4});
handles.functions = {@MaxVarBaslineHeatMapF,@FastPeakDetector};
for i = 1:numel(handles.functions)
    info = handles.functions{i}('name');
    names{i} = info{1}; %#ok<*AGROW>
    UD.params(i) = info{2};
    if info{2} > 0
        UD.tooltip{i} = info{3};
    else
        UD.tooltip{i} = '';
    end
end
set(handles.FunctionPopup,'String',names,'UserData',UD);
pth = findall(handles.output,'Tag','ParameterText');
set(pth,'Enable','off','TooltipString','','Visible','off');
for i = 4:-1:5-UD.params(1)
    set(pth(i),'Enable','on','TooltipString',UD.tooltip{1},'Visible','on');
end
names{1} = '';
for i = 1:numel(handles.data(:,1))
    names{i} = ['Trace ',num2str(handles.data{i,2})];
end
set(handles.TraceListbox,'String',names);
names = [];
for i = 1:numel(handles.regions)
    names{i} = ['Region ',num2str(i)];
end
set(handles.RegionsListbox,'String',names);
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = nPGHeatMap_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;


% --- Executes on selection change in TraceListbox.
function TraceListbox_Callback(hObject, ~, handles) %#ok<*DEFNU>
select = get(handles.HeatMapGUI,'SelectionType');
switch select
    case 'normal'
        
    case 'open'
        if ~isempty(handles.data)
            names = get(hObject,'String');
            minV = min(handles.data{get(hObject,'Value')}(:,1));
            maxV = max(handles.data{get(hObject,'Value')}(:,1));
            stim = handles.data{get(hObject,'Value')}(:,3);
            stim = stim / 3.3 * (maxV - minV);
            figure('Name',names{get(hObject,'Value')},'NumberTitle','off');
            plot(handles.data{get(hObject,'Value')}(:,1));
            hold all
            plot(stim);
            hold off
            axis tight;
        end
    case 'alternate'
        
%     case 'extend'
%         
end


% --- Executes during object creation, after setting all properties.
function TraceListbox_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in BurstingButton.
function BurstingButton_Callback(hObject, ~, handles)
oldColor = get(hObject,'BackgroundColor');
set(hObject,'BackgroundColor','r','Enable','off');
a = str2double(get(handles.dtAText,'String')) * 10;
b1 = str2double(get(handles.dtB1Text,'String')) * 10;
b2 = str2double(get(handles.dtB2Text,'String')) * 10;
t = str2double(get(handles.ThresholdText,'String'));
removeInd = false(size(handles.data,1),1);
for i = 1:size(handles.data,1)
    removeInd(i) = detectBursting(handles.data(i,:),a,b1,b2,t);
end
newData = handles.data(~removeInd,:);
names{1} = '';
for i = 1:numel(newData(:,1))
    names{i} = ['Trace ',num2str(newData{i,2})];
end
set(handles.TraceListbox,'String',names);
handles.data = newData;
guidata(hObject,handles);
set(hObject,'BackgroundColor',oldColor,'Enable','on');


function bursting = detectBursting(data,dtA,dtB1,dtB2,threshold)
bursting = false;
signal = data{1}(:,1);
stim = data{1}(:,3);
stimInd = stim > 2;
temp = stimInd;
temp(end+1) = temp(end); % stimInd shifted one sample to the left
temp(1) = [];
stimStarts = find((stimInd==0) & (temp==1)); % stim start index
stimEnds = find((stimInd==1) & (temp==0)); % stim end index
if stimEnds + dtA > numel(signal) % Adjust extended stimulation region
    stimEnds = numel(signal);
else
    stimEnds = stimEnds + dtA;
end
acceptable = false(numel(stimInd),1); % logical array of acceptable indecies for APs
acceptable((stimStarts+1):(stimEnds+dtA)) = true; % array filled out
[~,peakInd] = findpeaks(signal,'MinPeakHeight',threshold,'MinPeakDistance',50);
if ~isempty(peakInd)
    peaks = false(numel(stimInd),1); % logical array of peak indicies
    peaks(peakInd) = true; % array filled out
    redFlags = peaks & ~acceptable;% logical array of unacceptable peak indicies
    redFlagInds = find(redFlags); % double array of unacceptable peak indicies
    % logic test for bursting zone start in stim region
    a = (redFlagInds-dtB1 > stimStarts) & (redFlagInds-dtB1 < stimEnds);
    % logic test for bursting zone end in stim region
    b = (redFlagInds+dtB2 > stimStarts) & (redFlagInds+dtB2 < stimEnds);
    if any(a | b) % Bursting zone overlaps extended stimulation region
        bursting = true;
    end
end


% --- Executes on selection change in FunctionPopup.
function FunctionPopup_Callback(hObject, ~, handles)
UD = get(hObject,'UserData');
func = get(hObject,'Value');
params = UD.params(func);
tooltip = UD.tooltip{func};
paramTexts = findall(handles.output,'Tag','ParameterText');
set(paramTexts,'Enable','off','TooltipString','','Visible','off');
for i = 4:-1:5-params
    set(paramTexts(i),'Enable','on','TooltipString',tooltip,'Visible','on');
end


% --- Executes during object creation, after setting all properties.
function FunctionPopup_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RunButton.
function RunButton_Callback(~, ~, handles)
funNum = get(handles.FunctionPopup,'Value');
paramTexts = findall(handles.output,'Tag','ParameterText','Enable','on');
p = cell(1,numel(paramTexts));
for i = 1:numel(paramTexts)
    p{1+numel(paramTexts)-i} = get(paramTexts(i),'String');
end
p{end} = handles.name;
handles.functions{funNum}(handles.data,handles.regions,p{:});


% --- Executes on button press in FunctionButton.
function FunctionButton_Callback(hObject, ~, handles)
[name,~] = uigetfile('*.m','Choose New Function',pwd);
if ~isempty(name)
    name = str2func(name(1:end-2));
    info = name('info');
    handles.functions{end+1} = name;
    names = get(handles.FunctionPopup,'String');
    names{end+1} = info{1};
    UD = get(handles.FunctionPopup,'UserData');
    UD.params(end+1) = info{2};
    if info{2} > 0
        UD.tooltip{end+1} = info{3};
    else
        UD.tooltip{end+1} = '';
    end
    set(handles.FunctionPopup,'String',names,'UserData',UD);
    guidata(hObject,handles);
end


function out = FastPeakDetector(varargin)
if ischar(varargin{1})
    out{1} = 'Fast Peak Detection w/ Filter';
    out{2} = 0;
else
    out = [];
end


function out = MaxVarBaslineHeatMapF (varargin)
if ischar(varargin{1})
    out{1} = 'Max Variation from Baseline - Filtered Data';
    out{2} = 3;
    out{3} = ['1: dt Extension - Extends window for included data by dt ms',10, ...
        '2: Max Threshold - Truncates all values above Max Threshold to Max Threshold' 10, ...
        '3: File Name - Name for output file naming - Automaticall filled in'];
else % Needs parameters: data,regions,dtA*,maxVal*,baseStyle*
    out = [];
    data = varargin{1}; % numTraces,2 dimensional cell array
    % data{*,1} - :,3 dimensional - 1 = signal - 2 = ch2 - 3 = stimulation
    if ~iscell(data)
        data = {data};
    end
    regions = varargin{2}; % 1,numPatterns dimensional cell array of masks
    dtA = str2double(varargin{3}); % extension of stimulation region for acceptable activity, ms
    maxVal = str2double(varargin{4}); % if not NaN, all data > maxVal = maxVal
    imname = varargin{5}; % abf file starting number
    
    indicies = cell(numel(regions),2);
    for i = 1:numel(regions)
        [y,x] = find(regions{i} == 1);
        minx = min(x);
        miny = min(y);
        maxx = max(x);
        maxy = max(y);
        indicies{i,1} = [minx;maxx;miny;maxy];
        indicies{i,2} = [];
    end
    
    numData = size(data,1);
    heatmap = zeros(size(regions{1}));
    unMapped = true(size(regions{1}));
    ids(1) = 0;
    for i = 1:numData
        stim = data{i,1}(:,3);
        stimInd = stim > 2;
        if any(stimInd(end-100:end))
            stimInd(end-100:end) = false;
        end
        stimStarts = find(stimInd == true,1,'first');
        stimEnds = find(stimInd == true,1,'last') + (dtA*10); % 10kHz sample rate
        stimInd(stimStarts:stimEnds) = true; % indicies of data for Heat Map
        signal = data{i,1}(:,1);
        if ~isnan(maxVal)
            signal(signal > maxVal) = maxVal; % maximum value to lower peak influence
        end
        nonStim = signal(~stimInd);
        baseline = mean(nonStim);
        
        snipet = signal(stimStarts:stimEnds);
        if stimStarts - 200 > 0
            c = stimStarts - 200;
        else
            c = 1;
        end
        if stimEnds + 200 > numel(signal)
            d = numel(signal);
        else
            d = stimEnds + 200;
        end
        snipet2 = signal(c:d);
        warmth = max(snipet) - baseline;
        ID = data{i,2};
        indicies{ID,2}{end+1} = snipet2;
        if ~any(ID == ids)
            heatmap = heatmap + warmth .* double(regions{ID});
            unMapped = unMapped & ~regions{ID};
        else
            temp = heatmap .* double(regions{ID});
            temp = (temp + warmth .* double(regions{ID})) ./ 2;
            heatmap(logical(regions{ID})) = temp(logical(regions{ID}));
        end
        ids(i) = ID;
    end
    heatmap(heatmap < 0) = 0;
    Path = get(findall(0,'Tag','HeatMapPathText'),'String');
    cbh = findall(0,'Tag','HeatMapCheckbox');
    show = any(get(cbh,'Value'));
    cbh = findall(0,'Tag','SaveFigureCheckbox');
    save = any(get(cbh,'Value'));
    if show || save
        f = figure('IntegerHandle','off','Name',imname,'NumberTitle','off', ...
            'Visible','off','ResizeFcn',@figResize);
        ih = imagesc(heatmap);
        set(ih,'HitTest','off');
        ah = get(ih,'Parent');
        set(ah,'UserData',indicies,'CLim',[0,30],'ButtonDownFcn', ...
            {@(obj,~)eval(['if strcmp(get(obj,''Visible''),''off''),' ...
            'set(obj,''Visible'',''on''),end;'])});
        colormap('gray');
        if save
            set(f,'Visible','on')
            saveas(f,[Path,'\',imname,'.fig'],'fig');
        end
        if ~show
            delete(f);
        else
            set(f,'Visible','on');
        end
    end
    imwrite(uint16(heatmap), [Path,'\',imname,'.tiff'], 'tiff');
    metadata = ['Region Extension dtA: ',num2str(dtA),10,'Max Value maxVal: ', ...
        num2str(maxVal)];
    fid = fopen([Path,'\',imname,'-metadata.txt'],'wt');
    fprintf(fid, '%s\n', metadata);
    fclose(fid);
end


function figResize(obj,~)
if strcmp(get(obj,'Visible'),'off')
    set(obj,'Visible','on');
end


% --- Executes on selection change in RegionsListbox.
function RegionsListbox_Callback(hObject, ~, handles)
select = get(handles.HeatMapGUI,'SelectionType');
switch select
    case 'normal'
        
    case 'open'
        if ~isempty(handles.regions)
            value = get(hObject,'Value');
            if numel(value) == 1
                names = get(hObject,'String');
                figure('Name',names{value},'NumberTitle','off');
                imagesc(handles.regions{value});
                colormap gray
                axis off
            end
        end
    case 'alternate'
        
%     case 'extend'
%         
end


% --- Executes during object creation, after setting all properties.
function RegionsListbox_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dtAText_Callback(~, ~, ~)


% --- Executes during object creation, after setting all properties.
function dtAText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dtB1Text_Callback(~, ~, ~)


% --- Executes during object creation, after setting all properties.
function dtB1Text_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dtB2Text_Callback(~, ~, ~)


% --- Executes during object creation, after setting all properties.
function dtB2Text_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ThresholdText_Callback(~, ~, ~)


% --- Executes during object creation, after setting all properties.
function ThresholdText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ParameterText_Callback(~, ~, ~)


% --- Executes during object creation, after setting all properties.
function ParameterText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in HeatMapCheckbox.
function HeatMapCheckbox_Callback(hObject, ~, ~)
cbh = findall(0,'Tag','HeatMapCheckbox');
set(cbh,'Value',get(hObject,'Value'));


function HeatMapPathText_Callback(~, ~, ~)


% --- Executes during object creation, after setting all properties.
function HeatMapPathText_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveFigureCheckbox.
function SaveFigureCheckbox_Callback(hObject, eventdata, handles)
cbh = findall(0,'Tag','SaveFigureCheckbox');
set(cbh,'Value',get(hObject,'Value'));
