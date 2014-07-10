function varargout = CameraRemoteGui(varargin)
% CAMERAREMOTEGUI MATLAB code for CameraRemoteGui.fig
%      CAMERAREMOTEGUI, by itself, creates a new CAMERAREMOTEGUI or raises the existing
%      singleton*.
%
%      H = CAMERAREMOTEGUI returns the handle to a new CAMERAREMOTEGUI or the handle to
%      the existing singleton*.
%
%      CAMERAREMOTEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CAMERAREMOTEGUI.M with the given input arguments.
%
%      CAMERAREMOTEGUI('Property','Value',...) creates a new CAMERAREMOTEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CameraRemoteGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CameraRemoteGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CameraRemoteGui

% Last Modified by GUIDE v2.5 22-Nov-2013 14:35:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CameraRemoteGui_OpeningFcn, ...
                   'gui_OutputFcn',  @CameraRemoteGui_OutputFcn, ...
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


% --- Executes just before CameraRemoteGui is made visible.
function CameraRemoteGui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

h = guidata(findall(0,'tag','PolygonGui'));
handles.PG = h.output;
handles.ExposureText2 = h.ExposureText;
handles.AutoButton2 = h.AutoButton;
handles.AutoCheckbox2 = h.AutoCheckBox;
handles.MinHistText2 = h.MinHistText;
handles.MaxHistText2 = h.MaxHistText;
handles.ShowSnapCheckbox2 = h.ShowSnapCheckBox;
handles.SaveSnapCheckbox2 = h.SaveSnapCheckBox;
handles.CameraCheckbox2 = h.CameraCheckbox;
handles.ContrastGainCheckbox2 = h.ContrastGainCheckbox;
handles.LightingCheckbox2 = h.LightingCheckbox;
handles.StackCheckbox2 = h.StackCheckbox;
handles.ExposureSlider2 = h.ExposureSlider;
handles.FluorescenceRB2 = h.FluorescenceRadio;
handles.BrightFieldRB2 = h.BrightFieldRadio;
handles.VideoModePanel2 = h.VideoModePanel;
handles.NameText2 = h.NameText;


guidata(hObject, handles);
% *****************************************************************
% Comment out the following code if not runnning on the primary workstation
t = timer('StartDelay',.2,'TimerFcn',{@OpenTimerFcn,handles.output});
start(t);
%******************************************************************


function OpenTimerFcn (obj,~,fh)
set(fh,'Position',[-75,22,54.6,24.3846]);
stop(obj);
delete(obj);


% --- Executes on button press in CameraCheckbox.
function CameraCheckbox_Callback(hObject, eventdata, handles)
CameraRemoteGui_CloseRequestFcn(handles.output,[],handles);


function ExposureText_Callback(hObject, eventdata, handles)
a = str2double(get(hObject,'String'));
if a <= 0.00001;
    a = 0.00001;
    set(hObject,'String',num2str(a));
elseif a > 2
    a = 2;
    set(hObject,'String',num2str(a));
end
set(handles.ExposureSlider2,'Value',a);
set(handles.ExposureText2,'String',num2str(a));
cbf = get(handles.ExposureText2,'Callback');
cbf(handles.ExposureText2,[]);


% --- Executes on button press in AutoButton.
function AutoButton_Callback(hObject, eventdata, handles)
cbf = get(handles.AutoButton2,'Callback');
cbf(handles.AutoButton2,[]);


% --- Executes on button press in AutoCheckbox.
function AutoCheckbox_Callback(hObject, eventdata, handles)
h = guidata(findall(0,'tag','PolygonVideoGui'));
if get(hObject,'Value') == 1
    set(h.PolyVidAxes,'CLimMode','auto');
    set(handles.AutoCheckbox2,'Value',1);
else
    set(h.PolyVidAxes,'CLimMode','manual');
    set(handles.AutoCheckbox2,'Value',0);
end


function MinHistText_Callback(hObject, eventdata, handles)
set(handles.MinHistText2,'String',get(hObject,'String'));
mymin = str2double(get(hObject,'String'));
mymax = str2double(get(handles.MaxHistText,'String'));
h = guidata(findall(0,'tag','PolygonVideoGui'));
if ~isempty(h)
    set(h.PolyVidAxes,'CLim',[mymin,mymax]);
end


function MaxHistText_Callback(hObject, eventdata, handles)
set(handles.MaxHistText2,'String',get(hObject,'String'));
mymax = str2double(get(hObject,'String'));
mymin = str2double(get(handles.MinHistText,'String'));
h = guidata(findall(0,'tag','PolygonVideoGui'));
if ~isempty(h)
    set(h.PolyVidAxes,'CLim',[mymin,mymax]);
end


% --- Executes on button press in SnapshotButton.
function SnapshotButton_Callback(hObject, eventdata, handles)
h = guidata(findall(0,'tag','PolygonGui'));
if isfield(h,'vid')
    oldExp = h.src.ExposureTime;
    if get(h.FluorescenceRadio,'Value') == 1
        expTime = 0.75;
        h.src.ExposureTime = expTime;
        pause(expTime*2);
    end
    img = getsnapshot(h.vid);
    h.src.ExposureTime = oldExp;
    if get(h.SaveSnapCheckBox,'Value') == 1
        myPath = get(h.PathText,'String');
        if isempty(myPath)
            myPath = uigetdir;
            set(h.PathText,'String',myPath);
        end
        myName = get(h.NameText,'String');
        if isempty(myName)
            resp = questdlg('Enter a Name?','Attention','Yes','No','Yes');
            switch resp
                case 'No'
                    time = clock;
                    name = [num2str(time(2)) '-' num2str(time(3)) '-' ...
                        num2str(time(4)) '-' num2str(time(5)) ... 
                        '-' num2str(round(time(6))) '.tif'];
                case 'Yes'
                    return;
            end
        else
            list = dir([myPath '\' myName '*']);
            if ~isempty(list)
                numfile = str2double(list(end).name(size(myName,2)+2:end-4));
                name = [myName '-' num2str(numfile+1) '.tif'];
            else
                name = [myName '-1.tif'];
            end
        end
        imwrite(img,[myPath '\' name]);
    end
    if get(h.ShowSnapCheckBox,'Value') == 1
        if get(h.StackCheckbox,'Value') == 0 || h.ImgStack == 0
            s = size(img);
            f = figure('MenuBar','none','Units','pixels');
            ah = axes('Parent',f,'YLim',[0,s(1)],'XLim',[0,s(2)], ...
                'ButtonDownFcn',@StackBDF,'NextPlot','add', ...
                'Units','normalized','Position',[0 0 1 1],'XTick',[], ...
                'YTick',[],'YDir','reverse');
            h.ImgStack = ah;
            guidata(h.output,h);
            imh = imagesc(img,'Parent',ah,'HitTest','off');
            set(ah,'UserData',[1,1,imh]);
            set(f,'UserData',get(f,'Position'),'ResizeFcn', ...
                {@FigResizeFcn,imh},'CloseRequestFcn',@StackCRF);
            axis equal;
            colormap('gray');
        elseif h.ImgStack ~= 0
            ah = h.ImgStack;
            set(get(ah,'Children'),'Visible','off');
            imh = imagesc(img,'Parent',ah,'HitTest','off');
            ud = get(ah,'UserData');
            set(ah,'UserData',[ud(1)+1,ud(1)+1,ud(3:end),imh]);
        end
    end
end


function StackBDF (obj,~)
switch get(get(obj,'Parent'),'SelectionType')
    case 'normal'
        ud = get(obj,'UserData');
        if ud(2) < ud(1)
            ud(2) = ud(2) + 1;
        else
            ud(2) = 1;
        end
        set(ud(3:end),'Visible','off');
        set(ud(ud(2)+2),'Visible','on');
        set(obj,'UserData',ud);
    case 'open'
        ud = get(obj,'UserData');
        if ud(2) < ud(1)
            ud(2) = ud(2) + 1;
        else
            ud(2) = 1;
        end
        set(ud(3:end),'Visible','off');
        set(ud(ud(2)+2),'Visible','on');
        set(obj,'UserData',ud);
    case 'alt'
        
    case 'extend'
        
end


function StackCRF(obj,~)
h = guidata(findall(0,'tag','PolygonGui'));
h.ImgStack = 0;
guidata(h.output,h);
delete(obj);


function FigResizeFcn(obj,~,imh)
po = get(obj,'UserData');
p = get(obj,'Position');
ax = get(imh,'XData');
ax = ax(2);
ay = get(imh,'YData');
ay = ay(2) - ay(1);
r = ay / ax;
y = p(2) + p(4);
if p(3) > po(3) && p(4) > po(4)
    if (p(3) == 1680 && p(4) == 988) || (p(3) == 1366 && p(4) == 746)
        p(3) = round(p(4)/r);
    elseif p(3)*r > p(4)
        p(4) = round(p(3)*r);
    else
        p(3) = round(p(4)/r);
    end
elseif p(3) > po(3) && p(4) == po(4)
    p(4) = round(p(3)*r);
elseif p(4) > po(4) && p(3) == po(3)
    p(3) = round(p(4)/r);
else
    if p(3)*r < p(4)
        p(4) = round(p(3)*r);
    else
        p(3) = round(p(4)/r);
    end
end
p(2) = y - p(4);
set(obj,'Position',p,'UserData',p);


% --- Executes on button press in ContrastGainCheckbox.
function ContrastGainCheckbox_Callback(hObject, eventdata, handles)
a = get(hObject,'Value');
set(handles.ContrastGainCheckbox2,'Value',a);
cbf = get(handles.ContrastGainCheckbox2,'Callback');
cbf(handles.ContrastGainCheckbox2,[]);


% --- Executes on button press in LightingCheckbox.
function LightingCheckbox_Callback(hObject, eventdata, handles)
a = get(hObject,'Value');
set(handles.LightingCheckbox2,'Value',a);
cbf = get(handles.LightingCheckbox2,'Callback');
cbf(handles.LightingCheckbox2,[]);


% --- Executes on button press in ShowSnapCheckbox.
function ShowSnapCheckbox_Callback(hObject, eventdata, handles)
set(handles.ShowSnapCheckbox2,'Value',get(hObject,'Value'));


% --- Executes on button press in SaveSnapCheckbox.
function SaveSnapCheckbox_Callback(hObject, eventdata, handles)
set(handles.SaveSnapCheckbox2,'Value',get(hObject,'Value'));


% --- Executes on button press in StackCheckbox.
function StackCheckbox_Callback(hObject, eventdata, handles)
set(handles.StackCheckbox2,'Value',get(hObject,'Value'));


% --- Executes when selected object is changed in VideoModePanel.
function VideoModePanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in VideoModePanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
scf = get(handles.VideoModePanel2,'SelectionChangeFcn');
if eventdata.NewValue == handles.FluorescenceRB
    ed.NewValue = handles.FluorescenceRB2;
    set(handles.VideoModePanel2,'SelectedObject',handles.FluorescenceRB2);
else
    ed.NewValue = handles.BrightFieldRB2;
    set(handles.VideoModePanel2,'SelectedObject',handles.BrightFieldRB2);
end
scf(handles.VideoModePanel2,ed);


function NameText_Callback(hObject, eventdata, handles)
set(handles.NameText2,'String',get(hObject,'String'));


% --- Executes when user attempts to close CameraRemoteGui.
function CameraRemoteGui_CloseRequestFcn(hObject, eventdata, handles)
if get(handles.CameraCheckbox2,'Value') == 1
    set(handles.CameraCheckbox2,'Value',0);
    pause(0.01);
    cbf = get(handles.CameraCheckbox2,'Callback');
    cbf(handles.CameraCheckbox2,[]);
else
    delete(hObject);
end


%*************************************************************************
%Create Functions and Other Unedited Content

function varargout = CameraRemoteGui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function ExposureText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MinHistText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MaxHistText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NameText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
