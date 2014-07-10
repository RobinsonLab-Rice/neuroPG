function test()

configCameraTestFig_export()

function varargout = configCameraTestFig_export(varargin)
% CONFIGCAMERATESTFIG_EXPORT MATLAB code for configCameraTestFig_export.fig
%      CONFIGCAMERATESTFIG_EXPORT, by itself, creates a new CONFIGCAMERATESTFIG_EXPORT or raises the existing
%      singleton*.
%
%      H = CONFIGCAMERATESTFIG_EXPORT returns the handle to a new CONFIGCAMERATESTFIG_EXPORT or the handle to
%      the existing singleton*.
%
%      CONFIGCAMERATESTFIG_EXPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGCAMERATESTFIG_EXPORT.M with the given input arguments.
%
%      CONFIGCAMERATESTFIG_EXPORT('Property','Value',...) creates a new CONFIGCAMERATESTFIG_EXPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before configCameraTestFig_export_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to configCameraTestFig_export_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help configCameraTestFig_export

% Last Modified by GUIDE v2.5 27-Mar-2014 17:35:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @configCameraTestFig_export_OpeningFcn, ...
                   'gui_OutputFcn',  @configCameraTestFig_export_OutputFcn, ...
                   'gui_LayoutFcn',  @configCameraTestFig_export_LayoutFcn, ...
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


% --- Executes just before configCameraTestFig_export is made visible.
function configCameraTestFig_export_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to configCameraTestFig_export (see VARARGIN)

% Choose default command line output for configCameraTestFig_export
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes configCameraTestFig_export wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = configCameraTestFig_export_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in CamerasBox.
function CamerasBox_Callback(hObject, eventdata, handles)
% hObject    handle to CamerasBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CamerasBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CamerasBox


% --- Executes during object creation, after setting all properties.
function CamerasBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CamerasBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FormatsBox.
function FormatsBox_Callback(hObject, eventdata, handles)
% hObject    handle to FormatsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FormatsBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FormatsBox


% --- Executes during object creation, after setting all properties.
function FormatsBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FormatsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in PropertiesBox.
function PropertiesBox_Callback(hObject, eventdata, handles)
% hObject    handle to PropertiesBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PropertiesBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PropertiesBox


% --- Executes during object creation, after setting all properties.
function PropertiesBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PropertiesBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ExposureButton.
function ExposureButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExposureButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AutoExpButton.
function AutoExpButton_Callback(hObject, eventdata, handles)
% hObject    handle to AutoExpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ContrastButton.
function ContrastButton_Callback(hObject, eventdata, handles)
% hObject    handle to ContrastButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AutoConButton.
function AutoConButton_Callback(hObject, eventdata, handles)
% hObject    handle to AutoConButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in AddPropButton.
function AddPropButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddPropButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in AdditionalBox.
function AdditionalBox_Callback(hObject, eventdata, handles)
% hObject    handle to AdditionalBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns AdditionalBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from AdditionalBox


% --- Executes during object creation, after setting all properties.
function AdditionalBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AdditionalBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RemoveButton.
function RemoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in DuneB.
function DuneB_Callback(hObject, eventdata, handles)
% hObject    handle to DuneB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Creates and returns a handle to the GUI figure. 
function h1 = configCameraTestFig_export_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end

appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', [], ...
    'taginfo', struct(...
    'figure', 2, ...
    'listbox', 6, ...
    'text', 16, ...
    'pushbutton', 8), ...
    'override', 0, ...
    'release', 13, ...
    'resize', 'none', ...
    'accessibility', 'callback', ...
    'mfile', 1, ...
    'callbacks', 1, ...
    'singleton', 1, ...
    'syscolorfig', 1, ...
    'blocking', 0, ...
    'lastSavedFile', 'V:\RobinsonLab Code\MATLAB Code\neuroPG\configCameraTestFig_export.m', ...
    'lastFilename', 'V:\RobinsonLab Code\MATLAB Code\neuroPG\configCameraTestFig.fig');
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [];
appdata.initTags = struct(...
    'handle', [], ...
    'tag', 'figure1');

h1 = figure(...
'Units','characters',...
'Color',[0.941176470588235 0.941176470588235 0.941176470588235],...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'IntegerHandle','off',...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'MenuBar','none',...
'Name','configCameraTestFig',...
'NumberTitle','off',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'Position',[103.8 37.3846153846154 120.4 24.4615384615385],...
'Resize','off',...
'HandleVisibility','callback',...
'UserData',[],...
'Tag','figure1',...
'Visible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'CamerasBox';

h2 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)configCameraTestFig_export('CamerasBox_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[2.2 17.6153846153846 35.2 5.07692307692308],...
'String','Camera List',...
'Style','listbox',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)configCameraTestFig_export('CamerasBox_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','CamerasBox');

appdata = [];
appdata.lastValidTag = 'FormatsBox';

h3 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)configCameraTestFig_export('FormatsBox_Callback',hObject,eventdata,guidata(hObject)),...
'Max',2,...
'Position',[2.2 1.07692307692308 35.2 15],...
'String','Formats List',...
'Style','listbox',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)configCameraTestFig_export('FormatsBox_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'UserData',1,...
'Tag','FormatsBox');

appdata = [];
appdata.lastValidTag = 'text1';

h4 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Position',[2.2 22.8461538461538 13.4 1.07692307692308],...
'String','Cameras',...
'Style','text',...
'Tag','text1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text2';

h5 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Position',[2.2 16.2307692307692 13.4 1.07692307692308],...
'String','Formats',...
'Style','text',...
'Tag','text2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'AdaptorText';

h6 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ForegroundColor',[0 0 1],...
'Position',[17 22.8461538461538 10.4 1.07692307692308],...
'String','Adaptor',...
'Style','text',...
'Tag','AdaptorText',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'IDText';

h7 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ForegroundColor',[0 0 1],...
'Position',[28.2 22.8461538461538 5.2 1.07692307692308],...
'String','ID',...
'Style','text',...
'Tag','IDText',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'FormatText';

h8 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ForegroundColor',[0 0 1],...
'Position',[23.2 16.1538461538462 10.4 1.07692307692308],...
'String','Format',...
'Style','text',...
'Tag','FormatText',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'PropertiesBox';

h9 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)configCameraTestFig_export('PropertiesBox_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[40.4 7.69230769230769 26.8 15],...
'String','Properties List',...
'Style','listbox',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)configCameraTestFig_export('PropertiesBox_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','PropertiesBox');

appdata = [];
appdata.lastValidTag = 'text8';

h10 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Position',[40.4 22.8461538461538 13.4 1.07692307692308],...
'String','Properties',...
'Style','text',...
'Tag','text8',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ExposureButton';

h11 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)configCameraTestFig_export('ExposureButton_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[70 19.9230769230769 25.4 1.69230769230769],...
'String','Set Exposure Property',...
'Tag','ExposureButton',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'AutoExpButton';

h12 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)configCameraTestFig_export('AutoExpButton_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[70 17.9230769230769 25.4 1.69230769230769],...
'String','Set Auto Exposure Prop',...
'Tag','AutoExpButton',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'ContrastButton';

h13 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)configCameraTestFig_export('ContrastButton_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[70 15.9230769230769 25.4 1.69230769230769],...
'String','Set Contrast Property',...
'Tag','ContrastButton',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'AutoConButton';

h14 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)configCameraTestFig_export('AutoConButton_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[70 13.9230769230769 25.4 1.69230769230769],...
'String','Set Auto Contrast Prop',...
'Tag','AutoConButton',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'AddPropButton';

h15 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)configCameraTestFig_export('AddPropButton_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[70 11.7692307692308 25.4 1.69230769230769],...
'String','Add Additional Property',...
'Tag','AddPropButton',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'AdditionalBox';

h16 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)configCameraTestFig_export('AdditionalBox_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[70 2.53846153846154 25.2 8.76923076923077],...
'String',blanks(0),...
'Style','listbox',...
'Value',1,...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)configCameraTestFig_export('AdditionalBox_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','AdditionalBox');

appdata = [];
appdata.lastValidTag = 'RemoveButton';

h17 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)configCameraTestFig_export('RemoveButton_Callback',hObject,eventdata,guidata(hObject)),...
'Position',[70 0.846153846153846 13.8 1.69230769230769],...
'String','Remove',...
'Tag','RemoveButton',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'RangeT';

h18 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ForegroundColor',[0 0 1],...
'Position',[40.4 6.07692307692308 23.4 1.07692307692308],...
'String','Range',...
'Style','text',...
'Tag','RangeT',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'TypeT';

h19 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ForegroundColor',[0 0 1],...
'Position',[40.2 4.92307692307692 23.4 1.07692307692308],...
'String','Type',...
'Style','text',...
'Tag','TypeT',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text11';

h20 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ForegroundColor',[0 0 1],...
'HorizontalAlignment','left',...
'Position',[96 20.2307692307692 23.4 1.07692307692308],...
'String','Property',...
'Style','text',...
'Tag','text11',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text12';

h21 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ForegroundColor',[0 0 1],...
'HorizontalAlignment','left',...
'Position',[96 18.2307692307692 23.4 1.07692307692308],...
'String','Property',...
'Style','text',...
'Tag','text12',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text13';

h22 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ForegroundColor',[0 0 1],...
'HorizontalAlignment','left',...
'Position',[96 16.2307692307692 23.4 1.07692307692308],...
'String','Property',...
'Style','text',...
'Tag','text13',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text14';

h23 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'ForegroundColor',[0 0 1],...
'HorizontalAlignment','left',...
'Position',[96 14.2307692307692 23.4 1.07692307692308],...
'String','Property',...
'Style','text',...
'Tag','text14',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'DuneB';

h24 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback',@(hObject,eventdata)configCameraTestFig_export('DuneB_Callback',hObject,eventdata,guidata(hObject)),...
'FontSize',10,...
'Position',[103.8 0.923076923076923 13.8 2.15384615384615],...
'String','Done',...
'Tag','DuneB',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );


hsingleton = h1;


% --- Set application data first then calling the CreateFcn. 
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
   names = fieldnames(appdata);
   for i=1:length(names)
       name = char(names(i));
       setappdata(hObject, name, getfield(appdata,name));
   end
end

if ~isempty(createfcn)
   if isa(createfcn,'function_handle')
       createfcn(hObject, eventdata);
   else
       eval(createfcn);
   end
end


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)

gui_StateFields =  {'gui_Name'
    'gui_Singleton'
    'gui_OpeningFcn'
    'gui_OutputFcn'
    'gui_LayoutFcn'
    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error(message('MATLAB:guide:StateFieldNotFound', gui_StateFields{ i }, gui_Mfile));
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [gui_State.(gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % CONFIGCAMERATESTFIG_EXPORT
    % create the GUI only if we are not in the process of loading it
    % already
    gui_Create = true;
elseif local_isInvokeActiveXCallback(gui_State, varargin{:})
    % CONFIGCAMERATESTFIG_EXPORT(ACTIVEX,...)
    vin{1} = gui_State.gui_Name;
    vin{2} = [get(varargin{1}.Peer, 'Tag'), '_', varargin{end}];
    vin{3} = varargin{1};
    vin{4} = varargin{end-1};
    vin{5} = guidata(varargin{1}.Peer);
    feval(vin{:});
    return;
elseif local_isInvokeHGCallback(gui_State, varargin{:})
    % CONFIGCAMERATESTFIG_EXPORT('CALLBACK',hObject,eventData,handles,...)
    gui_Create = false;
else
    % CONFIGCAMERATESTFIG_EXPORT(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = true;
end

if ~gui_Create
    % In design time, we need to mark all components possibly created in
    % the coming callback evaluation as non-serializable. This way, they
    % will not be brought into GUIDE and not be saved in the figure file
    % when running/saving the GUI from GUIDE.
    designEval = false;
    if (numargin>1 && ishghandle(varargin{2}))
        fig = varargin{2};
        while ~isempty(fig) && ~ishghandle(fig,'figure')
            fig = get(fig,'parent');
        end
        
        designEval = isappdata(0,'CreatingGUIDEFigure') || isprop(fig,'__GUIDEFigure');
    end
        
    if designEval
        beforeChildren = findall(fig);
    end
    
    % evaluate the callback now
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else       
        feval(varargin{:});
    end
    
    % Set serializable of objects created in the above callback to off in
    % design time. Need to check whether figure handle is still valid in
    % case the figure is deleted during the callback dispatching.
    if designEval && ishghandle(fig)
        set(setdiff(findall(fig),beforeChildren), 'Serializable','off');
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end

    % Check user passing 'visible' P/V pair first so that its value can be
    % used by oepnfig to prevent flickering
    gui_Visible = 'auto';
    gui_VisibleInput = '';
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        % Recognize 'visible' P/V pair
        len1 = min(length('visible'),length(varargin{index}));
        len2 = min(length('off'),length(varargin{index+1}));
        if ischar(varargin{index+1}) && strncmpi(varargin{index},'visible',len1) && len2 > 1
            if strncmpi(varargin{index+1},'off',len2)
                gui_Visible = 'invisible';
                gui_VisibleInput = 'off';
            elseif strncmpi(varargin{index+1},'on',len2)
                gui_Visible = 'visible';
                gui_VisibleInput = 'on';
            end
        end
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.

    
    % Do feval on layout code in m-file if it exists
    gui_Exported = ~isempty(gui_State.gui_LayoutFcn);
    % this application data is used to indicate the running mode of a GUIDE
    % GUI to distinguish it from the design mode of the GUI in GUIDE. it is
    % only used by actxproxy at this time.   
    setappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]),1);
    if gui_Exported
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);

        % make figure invisible here so that the visibility of figure is
        % consistent in OpeningFcn in the exported GUI case
        if isempty(gui_VisibleInput)
            gui_VisibleInput = get(gui_hFigure,'Visible');
        end
        set(gui_hFigure,'Visible','off')

        % openfig (called by local_openfig below) does this for guis without
        % the LayoutFcn. Be sure to do it here so guis show up on screen.
        movegui(gui_hFigure,'onscreen');
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        end
    end
    if isappdata(0, genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]))
        rmappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]));
    end

    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);

    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    % Singleton setting in the GUI M-file takes priority if different
    gui_Options.singleton = gui_State.gui_Singleton;

    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end

        % Generate HANDLES structure and store with GUIDATA. If there is
        % user set GUI data already, keep that also.
        data = guidata(gui_hFigure);
        handles = guihandles(gui_hFigure);
        if ~isempty(handles)
            if isempty(data)
                data = handles;
            else
                names = fieldnames(handles);
                for k=1:length(names)
                    data.(char(names(k)))=handles.(char(names(k)));
                end
            end
        end
        guidata(gui_hFigure, data);
    end

    % Apply input P/V pairs other than 'visible'
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        len1 = min(length('visible'),length(varargin{index}));
        if ~strncmpi(varargin{index},'visible',len1)
            try set(gui_hFigure, varargin{index}, varargin{index+1}), catch break, end
        end
    end

    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end

    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});

    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        % Handle the default callbacks of predefined toolbar tools in this
        % GUI, if any
        guidemfile('restoreToolbarToolPredefinedCallback',gui_hFigure); 
        
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);

        % Call openfig again to pick up the saved visibility or apply the
        % one passed in from the P/V pairs
        if ~gui_Exported
            gui_hFigure = local_openfig(gui_State.gui_Name, 'reuse',gui_Visible);
        elseif ~isempty(gui_VisibleInput)
            set(gui_hFigure,'Visible',gui_VisibleInput);
        end
        if strcmpi(get(gui_hFigure, 'Visible'), 'on')
            figure(gui_hFigure);
            
            if gui_Options.singleton
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end

        % Done with GUI initialization
        if isappdata(gui_hFigure,'InGUIInitialization')
            rmappdata(gui_hFigure,'InGUIInitialization');
        end

        % If handle visibility is set to 'callback', turn it on until
        % finished with OutputFcn
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end

    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end

    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end

function gui_hFigure = local_openfig(name, singleton, visible)

% openfig with three arguments was new from R13. Try to call that first, if
% failed, try the old openfig.
if nargin('openfig') == 2
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = openfig(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
else
    gui_hFigure = openfig(name, singleton, visible);  
    %workaround for CreateFcn not called to create ActiveX
    if feature('HGUsingMATLABClasses')
        peers=findobj(findall(allchild(gui_hFigure)),'type','uicontrol','style','text');    
        for i=1:length(peers)
            if isappdata(peers(i),'Control')
                actxproxy(peers(i));
            end            
        end
    end
end

function result = local_isInvokeActiveXCallback(gui_State, varargin)

try
    result = ispc && iscom(varargin{1}) ...
             && isequal(varargin{1},gcbo);
catch
    result = false;
end

function result = local_isInvokeHGCallback(gui_State, varargin)

try
    fhandle = functions(gui_State.gui_Callback);
    result = ~isempty(findstr(gui_State.gui_Name,fhandle.file)) || ...
             (ischar(varargin{1}) ...
             && isequal(ishghandle(varargin{2}), 1) ...
             && (~isempty(strfind(varargin{1},[get(varargin{2}, 'Tag'), '_'])) || ...
                ~isempty(strfind(varargin{1}, '_CreateFcn'))) );
catch
    result = false;
end


