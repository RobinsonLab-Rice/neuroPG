function varargout = PolygonVideoGui(varargin)
% POLYGONVIDEOGUI MATLAB code for PolygonVideoGui.fig
%      POLYGONVIDEOGUI, by itself, creates a new POLYGONVIDEOGUI or raises the existing
%      singleton*.
%
%      H = POLYGONVIDEOGUI returns the handle to a new POLYGONVIDEOGUI or the handle to
%      the existing singleton*.
%
%      POLYGONVIDEOGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POLYGONVIDEOGUI.M with the given input arguments.
%
%      POLYGONVIDEOGUI('Property','Value',...) creates a new POLYGONVIDEOGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PolygonVideoGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PolygonVideoGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PolygonVideoGui

% Last Modified by GUIDE v2.5 08-Oct-2013 13:02:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PolygonVideoGui_OpeningFcn, ...
                   'gui_OutputFcn',  @PolygonVideoGui_OutputFcn, ...
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


% --- Executes just before PolygonVideoGui is made visible.
function PolygonVideoGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PolygonVideoGui (see VARARGIN)

% Choose default command line output for PolygonVideoGui
handles.output = hObject;
guidata(hObject, handles);
% set(hObject,'UserData',get(hObject,'Position'),'ResizeFcn',@FigResizeFcn);
axes(handles.PolyVidAxes);
axis off;
set(handles.PolyVidAxes,'DataAspectRatio',[1,1,1]);
colormap('Gray');
set(handles.PolyVidAxes,'Units','Normalized');
set(handles.PolyVidAxes,'Position',[0 0 1 1]);
handles.preview = imagesc(zeros(1024,1344));
hold all
handles.pointer = plot(20,20,'go','MarkerSize',7,'LineWidth',1);
hold off
check = imaqhwinfo('hamamatsu');
if ~isempty(check.DeviceIDs)
    % Possible capture modes:
    % 'MONO16_1344x1024'
    % 'MONO16_BIN2x2_672x512'
    % 'MONO16_BIN4x4_336x256'
    % 'MONO16_BIN8x8_168x128'
    handles.vid = videoinput('hamamatsu', 1, 'MONO16_1344x1024');
    handles.src = getselectedsource(handles.vid);
    h = guidata(findall(0,'tag','PolygonGui'));
    h.vidGH = handles.output;
    h.vid = handles.vid;
    h.src = handles.src;
    h.pimg = handles.preview;
    h.paxes = handles.PolyVidAxes;
    handles.Position = h.CameraPosition;
    handles.Remote = h.CRG;
    guidata(h.PolygonGui,h);
    handles.scale = 1;
    handles.previewX = 512;
    handles.previewY = 672;
    set(handles.preview,'ButtonDownFcn',@Vid_BDF);
    % handles.t = timer('Period',.05,'ExecutionMode','FixedSpacing','TimerFcn'...
    %     ,{@histogramTimerFcn,handles.preview,h.hist});
    
    % setappdata(handles.PolyVidAxes, 'HandleToPreview', handles.preview);
    setappdata(handles.preview, 'UpdatePreviewWindowFcn', @this_preview_update);
    preview(handles.vid, handles.preview);
    expCB = get(h.ExposureText,'Callback');
    expCB(h.ExposureText,[]);
    guidata(hObject, handles);
else
    warndlg('No Camera Detected');
    t = timer('StartDelay',.1,'TimerFcn',{@CloseGui,handles.output});
    start(t);
end
% *****************************************************************
% Comment out the following code if not runnning on the primary workstation
t = timer('StartDelay',.2,'TimerFcn',{@OpenTimerFcn,handles.output});
start(t);
%******************************************************************


function OpenTimerFcn (obj,~,fh)
h = guidata(fh);
if isempty(h.Position)
    pos = [-1357,290,958,730];
else
    pos = h.Position;
end
set(fh,'Position',pos);
stop(obj);
delete(obj);


function CloseGui(obj,event,fh)
PolygonVideoGui_CloseRequestFcn(fh,[],guidata(fh));


% --- Outputs from this function are returned to the command line.
function varargout = PolygonVideoGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function this_preview_update(obj, event, hImage)
graph = findall(0,'tag','HistBar');
[hist, ~] = imhist(event.Data);
set(graph,'YData',hist);
% disp(size(event.Data));
h = guidata(findall(0,'tag','PolygonVideoGui'));
switch h.scale
    case 1
%         x1 = 1;x2 = 1024;y1 = 1;y2 = 1344;
        img = event.Data;
    case 2
%         x1 = 256;x2 = 768;y1 = 336;y2 = 1008;
        x = h.previewX;
        y = h.previewY;
        img = imresize(event.Data(x-256:x+256,y-336:y+336),h.scale);
    case 4
%         x1 = 384;x2 = 640;y1 = 504;y2 = 840;
        x = h.previewX;
        y = h.previewY;
        img = imresize(event.Data(x-128:x+128,y-168:y+168),h.scale);
end
set(hImage, 'CData', img);
refreshdata(hImage);


% --- Executes when user attempts to close PolygonVideoGui.
function PolygonVideoGui_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to PolygonVideoGui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% stop(handles.t);
% delete(handles.t);
gh = findall(0,'tag','PolygonGui');
if ~isempty(gh)
    h = guidata(gh);
    if isfield(h,'vidGH')
        h = rmfield(h,'vidGH');
    end
    if isfield(h,'vid')
        h = rmfield(h,'vid');
    end
    if isfield(h,'src')
        h = rmfield(h,'src');
    end
    if isfield(h,'pimg')
        h = rmfield(h,'pimg');
    end
    if isfield(h,'paxes')
        h = rmfield(h,'paxes');
    end
    set(h.CameraCheckbox,'Value',0);
    cbf = get(h.CameraCheckbox,'Callback');
    guidata(h.PolygonGui,h);
    cbf(h.CameraCheckbox,[]);
end
if isfield(handles,'vid')
    stoppreview(handles.vid);
end
% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes when PolygonVideoGui is resized.
function PolygonVideoGui_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to PolygonVideoGui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
po = get(hObject,'UserData');
p = get(hObject,'Position');
r = 1024/1344;
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
set(hObject,'Position',p,'UserData',p);
% set(handles.PolyVidAxes,'DataAspectRatio',[1,1,1]);


% --- Executes on mouse press over axes background.
function Vid_BDF(hObject, eventdata)
% hObject    handle to PolyVidAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
select = get(handles.PolygonVideoGui,'SelectionType');
myAxes = get(hObject,'Parent');
pos = get(myAxes,'CurrentPoint');
x = ceil(pos(1,2));
if x < 257
    x = 257;
elseif x > 768
    x = 768;
end
y = ceil(pos(1,1));
if y < 337
    y = 337;
elseif y > 1008
    y = 1008;
end
switch select
    case 'normal'
        switch handles.scale
            case 1
                handles.scale = 2;
                handles.previewX = x;
                handles.previewY = y;
                guidata(hObject,handles);
            case 2
                handles.scale = 4;
                handles.previewX = round(x / 2) - 256 + handles.previewX;
                handles.previewY = round(y / 2) - 336 + handles.previewY;
                guidata(hObject,handles);
            case 4
                handles.scale = 1;
%                 x = 0;
%                 y = 0;
                guidata(hObject,handles);
        end
%         disp([x,y]);
% %     case 'open'
% %         
    case 'alt'
        set(handles.pointer,'Xdata',pos(1,1),'YData',pos(1,2));
% %     case 'extend'
% %         
end
refresh(handles.output);


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function PolygonVideoGui_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PolygonVideoGui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% select = get(handles.PolygonVideoGui,'SelectionType');
% switch select
%     case 'normal'
%         
%     case 'open'
%         
%     case 'alt'
%         
%     case 'extend'
%         
% end

