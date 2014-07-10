function figureHandle = CameraWindow()
h = findall(0,'tag','CameraWindow');
if ~isempty(h)
    figure(h);
    figureHandle = h;
    return;
end
path = which('CameraWindow.m');
path(end-13:end) = [];
if ~exist([path,'camera.mat'],'file')
    if ~exist([path,'neuroPG.config'],'file')
        warndlg('No Camera File (camera.mat) Found');
        % the file, 'camera.mat', needs to be in the same directory as
        % CameraWindow.m and have the following variables saved in the file:
        % ------------------------------------------------------------------
        % adaptor - String. Video adaptor of the camera. Check imaqhwinfo()
        % deviceID - Integer. DeviceID of the camera. Check imaqhwinfo(adaptor)
        % format - String. Video capture format. Check imaqhwinfo(adaptor)
        % resolution - 1x2 matrix. Resolution of the camera for the given format.
        %               ex. 800x600 => [800,600]
        % exposureProperty - String. Name of the exposure property of the camera
        %               or [] if not available.
        % exposurePropertyRange - Matrix. If the range is mostly continuous,
        %               default to double and use 1x2 matrix. For explicit
        %               values, list them all in a matrix of the appropriate
        %               data type.  Ex. logical([0,1]), uint8([0:255]),
        %               {'on','off'}, [0.00001,10] <- (defaults to double)
        % contrastProperty - String. Name of contrast property of the camera or
        %               [] if not available. May be a range or just low-light
        %               setting.
        % contrastPropertyRange - Matrix. Same as exposurePropertyRange.
        % extProperty - Cell of Strings. Same as exposureProperty
        % extPropertyRange - Cell of Matrices. Same as exposurePropertyRange
        % fluorescentExposure - Single Value. Exposure time for fluorescent
        %               preview. Must be a value from exposure range or [].
        % fluorescentCapture - Single Value. Exposure time for fluorescent
        %               snapshot. Must be a value from exposure range or [].
        % savePath - 1x2 Cell Array. If the first cell contains the string
        %               'current', the current MATLAB path will be the base path
        %               and the string in the second cell should be the
        %               relative path or ''. ex. {'current','\Snapshots'}. If the
        %               first cell contains the string 'tag', the string in the
        %               second cell should contain the tag to a text box that
        %               contains the full save path. Otherwise, the first cell
        %               should contain the absolute path and the second cell an
        %               empty string, ''.  Do not terminate paths with a '\'.
        % initialCommands - Cell array of Strings. Contains full commands as
        %               strings to be evaluated by eval after Preview starts.
        figureHandle = [];
        return;
    else
        camera = load([path,'neuroPG.config'],'-mat');
    end
else
    camera = load('camera','-mat');
end
a(1) = ~isfield(camera,'adaptor');
a(end+1) = ~isfield(camera,'deviceID');
a(end+1) = ~isfield(camera,'format');
a(end+1) = ~isfield(camera,'resolution');
if any(a)
    warndlg('Camera.mat Formatting Error');
    % See above comments for camera.mat formatting:  Lines 6-45
    figureHandle = [];
    return;
end

if isempty(imaqhwinfo(camera.adaptor,'DeviceIDs'))
    warndlg(['Specified Camera Not Found: ' camera.adaptor])
    figureHandle = [];
    return;
end
res = camera.resolution;
figureHandle = figure('Units','pixels', ... 
    'MenuBar','none','IntegerHandle','off','Name','CameraWindow', ... 
    'NumberTitle','off','Tag','CameraWindow','CloseRequestFcn', ...
    @closeFcn);
UD.CameraWindow = figureHandle;
if isfield(camera,'CameraWindowPosition')
    set(figureHandle,'Position',camera.CameraWindowPosition);
end
UD.resolution = res;
UD.scale = 1;
UD.previewX = res(2) / 2;
UD.previewY = res(1) / 2;
UD.position = get(figureHandle,'Position');
UD.monitors = get(0,'Monitor');
UD.previewHandle = imagesc(zeros(res(2),res(1)));
UD.videoBuffer = [];
UD.frameCount = 0;
if isfield(camera,'fileName')
    UD.fileName = camera.fileName;
end
if isfield(camera,'snapshotSavePath')
    UD.savePath = camera.snapshotSavePath;
end
set(get(UD.previewHandle,'Parent'),'Tag','CameraAxes');
colormap('Gray')
UD.axesHandle = ancestor(UD.previewHandle,'axes');
set(UD.axesHandle,'Units','normalized','Position',[0,0,1,1]);
set(figureHandle,'UserData',UD,'ResizeFcn',@resizeFcn);
setappdata(UD.previewHandle,'CameraWindow',figureHandle);
axis off
hold all
UD.pointer = plot(20,20,'go','MarkerSize',7,'LineWidth',1,'HitTest','off');
hold off
UD.video = videoinput(camera.adaptor,camera.deviceID,camera.format);
UD.source = getselectedsource(UD.video);
UD.controlsHandle = figure('Units','pixels','Resize','off', ... 
    'MenuBar','none','IntegerHandle','off','Name','Camera Controls', ... 
    'NumberTitle','off','Tag','CameraControls','Color',[.9412,.9412,.9412], ...
    'CloseRequestFcn',@closeFcn,'HandleVisibility','callback');
if isfield(camera,'CameraControlsWindowPosition')
    pos = camera.CameraControlsWindowPosition;
else
    pos = get(UD.controlsHandle,'Position');
    pos(3:4) = [300,480];
end
set(UD.controlsHandle,'Position',pos);
data = getsnapshot(UD.video);
% info = whos('data');
UD.bytesPerFrame = numel(data);
set(figureHandle,'UserData',UD);
set(UD.previewHandle,'ButtonDownFcn',@PreviewBDF);
setappdata(UD.previewHandle,'UpdatePreviewWindowFcn',@CWUpdateFcn);
preview(UD.video,UD.previewHandle);
for i = 1:numel(camera.initialCommands)
    eval(camera.initialCommands{i});
end
t = timer('TimerFcn',{@populateControls,camera,UD},'StopFcn',@(t,e)delete(t), ...
    'Name','CameraWindow Startup Timer');
start(t);
figure(UD.controlsHandle);
if nargout == 0
    clearvars figureHandle
end
end

% Populates the controls on the Camera Controls window
function populateControls(varargin)
camera = varargin{3};
UD = varargin{4};
ch = UD.controlsHandle;
c = camera;
numProps = c.numCameraProperties;
if numProps < 5
    sMax = 1; sVal = 1; sStep = [1,1];
else
    sMax = numProps - 4; sVal = numProps - 4; sStep = [1/(numProps-4),1/(numProps-4)];
end

panel = uipanel(ch,'Units','Pixels','Position',[0,320,280,150],'Title','', ...
    'BackgroundColor',[.9412,.9412,.9412],'Tag','PropBox');
slide = uicontrol(ch,'Style','Slider','Units','Pixels','Position',[280,320,20,150],...
    'Max',sMax,'Value',sVal,'Tag','PropSlide','SliderStep', ... 
    sStep,'Callback',@sliderCBF);
if numProps < 5
    set(slide,'Enable','off');
end

labelPos = [4,122,85,14];
editPos = [92,118,44,22];
slidePos = [137,118,138,22];
propStep = 33;

l = [];
e = [];
s = [];

if isfield(c,'exposureProperty')
    lp = c.exposureProperty;
    l(end+1) = uicontrol(panel,'Style','Text','String',[lp,':'], ...
        'HorizontalAlignment','right','Units','pixels','Position',labelPos);
    e(end+1) = uicontrol(panel,'Style','Edit','String','','HorizontalAlignment', ...
        'right','Units','pixels','Position',editPos,'Tag','Exposure');
    val = eval(['UD.source.',lp,';']);
    if ~isa(val,'char')
        val2 = num2str(val);
    else
        val2 = val;
        val = str2double(val);
    end
    set(e(1),'Callback',{@ExposureCBF,c,UD},'String',val2);
    if isa(c.exposurePropertyRange,'double')
        min = c.exposurePropertyRange(1);
        max = c.exposurePropertyRange(2);
        if min == 0
            minStep = (max - min) / 100;
        else
            minStep = min;
        end
        step = (max - min) / 10;
    elseif isa(c.exposurePropertyRange,'logical')
        min = 0;
        minStep = 1;
        step = 1;
        max = 1;
    else
        min = 1;
        if numel(c.exposurePropertyRange) > 2
            minStep = 1 / numel(c.exposurePropertyRange);
        else
            minStep = 1;
        end
        step = minStep;
        max = numel(c.exposurePropertyRange);
        if ~isa(c.exposurePropertyRange,'cell')
            val = find(c.exposurePropertyRange == val);
        else
            val = find(strcmp(c.exposurePropertyRange,val2));
        end
    end
    s(end+1) = uicontrol(panel,'Style','Slider','Min',min,'Max',max,'Value',val, ...
        'Units','pixels','Position',slidePos,'Tag','Exposure','SliderStep', ...
        [minStep,step],'Callback',{@ExposureCBF,c,UD});
    labelPos(2) = labelPos(2) - propStep;
    editPos(2) = editPos(2) - propStep;
    slidePos(2) = slidePos(2) - propStep;
    
    bg = uibuttongroup('Parent',ch,'Units','normalized','Position', ...
        [.63,.39,.35,.15],'Tag','FieldGroup');
    bf = uicontrol(bg,'Style','radiobutton','String','Bright field','Units', ...
        'normalized','Position',[.1,.7,.8,.25],'Value',1,'Tag','BFButton');
    fl = uicontrol(bg,'Style','radiobutton','String','Fluorescent','Units', ...
        'normalized','Position',[.1,.45,.8,.25],'Value',0,'Tag','FLButton');
    uicontrol(bg,'Style','Text','Units','normalized','Position',[.1,.3,.15,.15], ...
        'String','|_','FontSize',6);
    uicontrol(bg,'Style','Text','Units','normalized','Position',[.2,.27,.7,.18], ...
        'String','Exp.    Cap.');
    if isfield(c,'fluorescentExposure')
        st = num2str(c.fluorescentExposure);
    else
        st = '';
    end
    uicontrol(bg,'Style','Edit','Units','normalized','Position',[.23,.05,.3,.22], ...
        'String',st,'Tag','FlExp');
    if isfield(c,'fluorescentCapture')
        st = num2str(c.fluorescentCapture);
    else
        st = '';
    end
    uicontrol(bg,'Style','Edit','Units','normalized','Position',[.58,.05,.3,.22], ...
        'String',st,'Tag','FlCap');
    UDBG.bf = bf;
    UDBG.fl = fl;
    UDBG.expTime = [];
    UDBG.cont = [];
    UDBG.light = [];
    set(bg,'SelectionChangeFcn',{@FieldChangeCBF,c,UD},'UserData',UDBG);
end
if isfield(c,'autoExposureProperty')
    lp = c.autoExposureProperty;
    pUD.property = lp;
    pUD.range = c.autoExposurePropertyRange;
    l(end+1) = uicontrol(panel,'Style','Text','String',[lp,':'], ...
        'HorizontalAlignment','right','Units','pixels','Position',labelPos);
    e(end+1) = uicontrol(panel,'Style','Edit','String','','HorizontalAlignment', ...
        'right','Units','pixels','Position',editPos,'Tag','AutoExposure');
    val = eval(['UD.source.',lp,';']);
    if ~isa(val,'char')
        val2 = num2str(val);
    else
        val2 = val;
        val = str2double(val);
    end
    set(e(end),'Callback',{@PropertyCBF,c,UD},'String',val2,'UserData',pUD);
    if isa(c.autoExposurePropertyRange,'double')
        min = c.autoExposurePropertyRange(1);
        max = c.autoExposurePropertyRange(2);
        if min == 0
            minStep = (max - min) / 100;
        else
            minStep = min;
        end
        step = (max - min) / 10;
    elseif isa(c.autoExposurePropertyRange,'logical')
        min = 0;
        minStep = 1;
        step = 1;
        max = 1;
    else
        min = 1;
        if numel(c.autoExposurePropertyRange) > 2
            minStep = 1 / numel(c.autoExposurePropertyRange);
        else
            minStep = 1;
        end
        step = minStep;
        max = numel(c.autoExposurePropertyRange);
        if ~isa(c.autoExposurePropertyRange,'cell')
            val = find(c.autoExposurePropertyRange == val);
        else
            val = find(strcmp(c.autoExposurePropertyRange,val2));
        end
    end
    s(end+1) = uicontrol(panel,'Style','Slider','Min',min,'Max',max,'Value',val, ...
        'Units','pixels','Position',slidePos,'Tag','AutoExposure','SliderStep', ...
        [minStep,step],'Callback',{@PropertyCBF,c,UD},'UserData',pUD);
    labelPos(2) = labelPos(2) - propStep;
    editPos(2) = editPos(2) - propStep;
    slidePos(2) = slidePos(2) - propStep;
end
if isfield(c,'contrastProperty')
    cp = c.contrastProperty;
    l(end+1) = uicontrol(panel,'Style','Text','String',[cp,':'], ...
        'HorizontalAlignment','right','Units','pixels','Position',labelPos);
    e(end+1) = uicontrol(panel,'Style','Edit','String','','HorizontalAlignment', ...
        'right','Units','pixels','Position',editPos,'Tag','Contrast');
    val = eval(['UD.source.',cp,';']);
    if ~isa(val,'char')
        val2 = num2str(val);
    else
        val2 = val;
        val = str2double(val);
    end
    set(e(end),'Callback',{@ContrastCBF,c,UD},'String',val2);
    if isa(c.contrastPropertyRange,'double')
        min = c.contrastPropertyRange(1);
        max = c.contrastPropertyRange(2);
        if min == 0
            minStep = (max - min) / 100;
        else
            minStep = min;
        end
        step = (max - min) / 10;
    elseif isa(c.contrastPropertyRange,'logical')
        min = 0;
        minStep = 1;
        step = 1;
        max = 1;
    else
        min = 1;
        if numel(c.contrastPropertyRange) > 2
            minStep = 1 / numel(c.contrastPropertyRange);
        else
            minStep = 1;
        end
        step = minStep;
        max = numel(c.contrastPropertyRange);
        if ~isa(c.contrastPropertyRange,'cell')
            val = find(c.contrastPropertyRange == val);
        else
            val = find(strcmp(c.contrastPropertyRange,val2));
        end
    end
    s(end+1) = uicontrol(panel,'Style','Slider','Value',val,'Units','pixels', ...
        'Position',slidePos,'Tag','Contrast','SliderStep', ... 
        [minStep,step],'Max',max,'Min',min,'Callback',{@ContrastCBF,c,UD});
    labelPos(2) = labelPos(2) - propStep;
    editPos(2) = editPos(2) - propStep;
    slidePos(2) = slidePos(2) - propStep;
end
if isfield(c,'autoContrastProperty')
    lp = c.autoContrastProperty;
    pUD.property = lp;
    pUD.range = c.autoContrastPropertyRange;
    l(end+1) = uicontrol(panel,'Style','Text','String',[lp,':'], ...
        'HorizontalAlignment','right','Units','pixels','Position',labelPos);
    e(end+1) = uicontrol(panel,'Style','Edit','String','','HorizontalAlignment', ...
        'right','Units','pixels','Position',editPos,'Tag','AutoContrast');
    val = eval(['UD.source.',lp,';']);
    if ~isa(val,'char')
        val2 = num2str(val);
    else
        val2 = val;
        val = str2double(val);
    end
    set(e(end),'Callback',{@PropertyCBF,c,UD},'String',val2,'UserData',pUD);
    if isa(c.autoContrastPropertyRange,'double')
        min = c.autoContrastPropertyRange(1);
        max = c.autoContrastPropertyRange(2);
        if min == 0
            minStep = (max - min) / 100;
        else
            minStep = min;
        end
        step = (max - min) / 10;
    elseif isa(c.autoContrastPropertyRange,'logical')
        min = 0;
        minStep = 1;
        step = 1;
        max = 1;
    else
        min = 1;
        if numel(c.autoContrastPropertyRange) > 2
            minStep = 1 / numel(c.autoContrastPropertyRange);
        else
            minStep = 1;
        end
        step = 1;
        max = numel(c.autoContrastPropertyRange);
        if ~isa(c.autoContrastPropertyRange,'cell')
            val = find(c.autoContrastPropertyRange == val);
        else
            val = find(strcmp(c.autoContrastPropertyRange,val2));
        end
    end
    s(end+1) = uicontrol(panel,'Style','Slider','Value',val,'Units','pixels', ...
        'Position',slidePos,'Tag','AutoContrast','UserData',pUD,'SliderStep', ... 
        [minStep,step],'Max',max,'Min',min,'Callback',{@PropertyCBF,c,UD});
    labelPos(2) = labelPos(2) - propStep;
    editPos(2) = editPos(2) - propStep;
    slidePos(2) = slidePos(2) - propStep;
end
if isfield(c,'extProperty')
    for i = 1:numel(c.extProperty)
        lp = c.extProperty{i};
        range = c.extPropertyRange{i};
        pUD.property = lp;
        pUD.range = range;
        tag = ['CamProp',num2str(i)];
        l(end+1) = uicontrol(panel,'Style','Text','String',[lp,':'],...
            'HorizontalAlignment','right','Units','pixels','Position',labelPos);
        e(end+1) = uicontrol(panel,'Style','Edit','String','','Tag',tag, ...
            'HorizontalAlignment','right','Units','pixels','Position',editPos);
        val = eval(['UD.source.',lp,';']);
        if ~isa(val,'char')
            val2 = num2str(val);
        else
            val2 = val;
            val = str2double(val);
        end
        set(e(end),'Callback',{@PropertyCBF,c,UD},'String',val2,'UserData',pUD);
        if isa(range,'double')
            min = range(1);
            max = range(2);
            if min == 0
                minStep = (max - min) / 100;
            else
                minStep = min;
            end
            step = (max - min) / 10;
        elseif isa(range,'logical')
            min = 0;
            minStep = 1;
            step = 1;
            max = 1;
        else
            min = 1;
            if numel(range) > 2
                minStep = 1 / numel(range);
            else
                minStep = 1;
            end
            step = 1;
            max = numel(range);
            if ~isa(range,'cell')
                val = find(range == val);
            else
                val = find(strcmp(range,val2));
            end
        end
        s(end+1) = uicontrol(panel,'Style','Slider','Value',val,'Units','pixels', ...
            'Position',slidePos,'Tag',tag,'SliderStep',[minStep,step],'Max',max, ...
            'Min',min,'Callback',{@PropertyCBF,c,UD},'UserData',pUD);
        labelPos(2) = labelPos(2) - propStep;
        editPos(2) = editPos(2) - propStep;
        slidePos(2) = slidePos(2) - propStep;
    end
end

sUD.step = propStep;
sUD.lastVal = numProps - 4;
set(slide,'UserData',sUD);

positions = cell2mat(get(e,'Position'));
belowPanel = positions(:,2) < 1;
set(l(belowPanel),'Visible','off');
set(e(belowPanel),'Visible','off');
set(s(belowPanel),'Visible','off');

ah = axes('Parent',ch,'Units','normalized','Position',[.05,.065,.9,.25]);
bar(0:255,zeros(1,256),'Parent',ah,'Tag','Histogram','FaceColor','w');
set(ah,'Color','k','XTickLabel',[],'YTickLabel',[],'XLim',[0,255], ... 
    'YLim',[0,prod(UD.resolution)]);
uicontrol(ch,'Style','Checkbox','Units','normalized','Position',[.05,.01,.15,.05],...
    'String','Auto','Callback',{@AutoCBF,c,UD},'Tag','AutoCheckbox');
uicontrol(ch,'Style','Edit','String','0','Units','normalized','Position', ...
    [.2,.01,.1,.05],'Callback',{@HistMinCBF,c,UD},'Tag','HistMin');
uicontrol(ch,'Style','Edit','String','255','Units','normalized','Position', ...
    [.3,.01,.1,.05],'Callback',{@HistMaxCBF,c,UD},'Tag','HistMax');

uicontrol(ch,'Style','PushButton','Units','normalized','Position',[.05,.39,.2,.15], ...
    'String','Snap','FontSize',10,'Callback',{@SnapCBF,c,UD},'UserData',0, ...
    'Tag','SnapButton');
uicontrol(ch,'Style','Checkbox','Units','normalized','Position',[.3,.49,.3,.05], ...
    'String','Save Snap','Tag','SaveCheckbox','Callback',@checkCBF);
uicontrol(ch,'Style','Checkbox','Units','normalized','Position',[.3,.44,.3,.05], ...
    'String','Show Snap','Tag','ShowCheckbox','Callback',@checkCBF);
uicontrol(ch,'Style','Text','Units','normalized','Position',[.3,.39,.05,.05], ...
    'String','|_','FontSize',6);
uicontrol(ch,'Style','Checkbox','Units','normalized','Position',[.35,.39,.25,.05], ...
    'String','Stack','Tag','StackCheckbox','Callback',@checkCBF);

uicontrol(ch,'Style','Text','Units','normalized','Position',[.05,.595,.17,.05], ...
    'HorizontalAlignment','right','String','File Name:');
uicontrol(ch,'Style','Edit','Units','normalized','Position',[.225,.605,.4,.04], ...
    'Callback',{@NameCBF,c,UD},'Tag','PicNameText');
if isfield(c,'fileName')
    set(findall(0,'Tag','PicNameText'),'String',c.fileName);
end
uicontrol(ch,'Style','Text','Units','normalized','Position',[.05,.545,.17,.05], ...
    'HorizontalAlignment','right','String','File Path:');
uicontrol(ch,'Style','Edit','Units','normalized','Position',[.225,.555,.75,.04], ...
    'Callback',{@PathCBF,c,UD},'Tag','PicPathText');
if isfield(c,'snapshotSavePath')
    set(findall(0,'Tag','PicPathText'),'String',c.snapshotSavePath);
end

uicontrol(ch,'Style','ToggleButton','Units','normalized','Tag','VideoB','Position',...
    [.05,.32,.2,.065],'String','Video','Callback',@videoCBF);
uicontrol(ch,'Style','Text','Units','normalized','Tag','VidTimeText','Position', ...
    [.3,.33,.6,.035],'Foreground','r','String','Initializing','Horizontal','left');

if any(strcmp(fieldnames(get(UD.source)),'FrameRate'))
    UD.frameRate = get(UD.source,'FrameRate');
    if ischar(UD.frameRate)
        UD.frameRate = str2double(UD.frameRate);
    end
else
    resp = inputdlg('No FrameRate property: Specify frame rate', ...
        'CameraWindow: FrameRate Error');
    if isempty(resp)
        UD.frameRate = 30;
    else
        UD.frameRate = str2double(resp);
    end
end

set(UD.CameraWindow,'UserData',UD)

start(timer('Name','MemTimer','ExecutionMode','FixedRat','Period',1,'TimerFcn', ...
    {@memTimerFcn,UD}))

[~,h] = MatPad;
if ~isempty(h)
    timestr = datestr(clock,'mm/dd/yy HH:MM AM');
    entry = ['-- CameraWindow Started ',timestr];
    logentry = sprintf('<HTML><BODY color="%s">%s', 'blue', entry);
    MatPad('add',logentry,'save');
end
end

% Callback for Properties Panel Slider
function sliderCBF(obj,~)
val = round(get(obj,'Value'));
h = findall(0,'Tag','PropSlide');
UD = get(obj,'UserData');
numSteps = val - UD.lastVal;
UD.lastVal = val;
set(h,'UserData',UD,'Value',val);
pbh = findall(0,'Tag','PropBox');
objs = get(pbh,'Children');
if iscell(objs)
    objs = cell2mat(objs);
end
positions = cell2mat(get(objs,'Position'));
positions(:,2) = positions(:,2) - numSteps*UD.step;
for i = 1:size(positions,1)
    set(objs(i),'Visible','off','Position',positions(i,:));
end
inPanel = positions(:,2) > 0 & (positions(:,2) + positions(:,4)) < 150;
set(objs(inPanel),'Visible','on');
end

% Callback for field selection buttongroup change
function FieldChangeCBF(obj,eventdata,camera,UD)
UDBG = get(obj,'UserData');
if eventdata.NewValue == UDBG.fl
    set(findall(0,'Tag','FLButton'),'Value',1);
    set(findall(0,'Tag','BFButton'),'Value',0);
    expTexts = findall(0,'Tag','Exposure','Style','edit');
    expTime = get(expTexts(1),'String');
    flExps = findall(0,'Tag','FlExp');
    set(expTexts,'String',get(flExps(1),'String'));
    ExposureCBF(expTexts(1),[],camera,UD);
    autoCBs = findall(0,'Tag','AutoCheckbox');
    set(autoCBs,'Value',1);
    AutoCBF(autoCBs(1),[],[],UD);
%     if ~isempty(camera.contrastProperty)
%         contCBs = findall(0,'Tag','Contrast','Style','edit');
%         cont = get(contCBs(1),'String');
%         if ~iscell(camera.contrastPropertyRange)
%             value = num2str(camera.contrastPropertyRange(end));
%         else
%             value = camera.contrastPropertyRange{end};
%         end
%         set(contCBs,'String',value);
%         ContrastCBF(contCBs(1),[],camera,UD);
%     end
%     if ~isempty(camera.lightingProperty)
%         lightCBs = findall(0,'Tag','Lighting','Style','edit');
%         light = get(lightCBs(1),'String');
%         if ~iscell(camera.lightingPropertyRange)
%             value = num2str(camera.lightingPropertyRange(end));
%         else
%             value = camera.lightingPropertyRange{end};
%         end
%         set(lightCBs,'String',value);
%         LightingCBF(lightCBs(1),[],camera,UD);
%     end
    groups = findall(0,'Tag','FieldGroup');
    for i = 1:numel(groups)
        temp = get(groups(i),'UserData');
        temp.expTime = expTime;
%         temp.cont = cont;
%         temp.light = light;
        set(groups(i),'UserData',temp);
    end
else
    set(findall(0,'Tag','FLButton'),'Value',0);
    set(findall(0,'Tag','BFButton'),'Value',1);
    if ~isempty(UDBG.expTime)
        expTexts = findall(0,'Tag','Exposure','Style','edit');
        set(expTexts,'String',UDBG.expTime);
        ExposureCBF(expTexts(1),[],camera,UD);
    end
%     if ~isempty(UDBG.cont)
%         contCBs = findall(0,'Tag','Contrast','Style','edit');
%         set(contCBs,'String',UDBG.cont);
%         cbf = get(contCBs(1),'Callback');
%         cbf(contCBs(1),[],camera,UD);
%     end
%     if ~isempty(UDBG.light)
%         lightCBs = findall(0,'Tag','Lighting','Style','edit');
%         set(lightCBs,'String',UDBG.light);
%         cbf = get(lightCBs(1),'Callback');
%         cbf(lightCBs(1),[],camera,UD);
%     end
end
end

% Callback Function for Exposure Setting
function ExposureCBF(obj,~,camera,UD)
style = get(obj,'Style');
range = camera.exposurePropertyRange;
if strcmp(style,'slider')
    value = get(obj,'Value');
else
    value = get(obj,'String');
    if ~isa(range,'cell')
        value = str2double(value);
    end
end
if isa(range,'double') && (numel(range) == 2) % (semi)Continuous range of values
    if value < range(1)
        value = range(1);
    elseif value > range(2)
        value = range(2);
    end
    eval(['UD.source.',camera.exposureProperty,'=value;']);
    objs = findall(0,'Tag','Exposure');
    sliders = strcmp(get(objs,'Style'),'slider');
    set(objs(sliders),'Value',value);
    value = round(value*1000000)/1000000;
    set(objs(~sliders),'String',num2str(value));
    
elseif isa(range,'cell') % String values - whole numbers translate to values
    if isa(value,'char')
        propVal = value;
        value = find(strcmp(value,range),1);
    else
        if value < 1
            value = 1;
        elseif value > numel(range)
            value = numel(range);
        end
        value = round(value);
        propVal = range{value};
    end
    eval(['UD.source.',camera.exposureProperty,'=propVal;']);
    objs = findall(0,'Tag','Exposure');
    sliders = strcmp(get(objs,'Style'),'slider');
    set(objs(sliders),'Value',value);
    set(objs(~sliders),'String',propVal);
    
else % Any other ennumerated list of possible values
    if strcmp(style,'slider')
        value = range(round(value));
    end
    value = cast(value,class(range));
    if any(value == range)
        %  Continue editting here. Set value to source and Exposure objects
        eval(['UD.source.',camera.exposureProperty,'=value;']);
        objs = findall(0,'Tag','Exposure');
        sliders = strcmp(get(objs,'Style'),'slider');
        set(objs(sliders),'Value',find(range == value));
        set(objs(~sliders),'String',num2str(value));
    else
        % Error of some kind.
        warndlg('Not a valid Exposure Property value.');
        eval(['value=UD.source.',camera.exposureProperty,';']);
    end
end
end

% Callback Function for Contrast Setting
function ContrastCBF(obj,~,camera,UD)
style = get(obj,'Style');
range = camera.contrastPropertyRange;
if strcmp(style,'slider')
    value = get(obj,'Value');
else
    value = get(obj,'String');
    if ~isa(range,'cell')
        value = str2double(value);
    end
end
if isa(range,'double') && (numel(range) == 2) % (semi)Continuous range of values
    if value < range(1)
        value = range(1);
    elseif value > range(2)
        value = range(2);
    end
    eval(['UD.source.',camera.contrastProperty,'=value;']);
    objs = findall(0,'Tag','Contrast');
    sliders = strcmp(get(objs,'Style'),'slider');
    set(objs(sliders),'Value',value);
    value = round(value*1000000)/1000000;
    set(objs(~sliders),'String',num2str(value));
    
elseif isa(range,'cell') % String values - whole numbers translate to values
    if isa(value,'char')
        propVal = value;
        value = find(strcmp(value,range),1);
    else
        if value < 1
            value = 1;
        elseif value > numel(range)
            value = numel(range);
        end
        value = round(value);
        propVal = range{value};
    end
    eval(['UD.source.',camera.contrastProperty,'=propVal;']);
    objs = findall(0,'Tag','Contrast');
    sliders = strcmp(get(objs,'Style'),'slider');
    set(objs(sliders),'Value',value);
    set(objs(~sliders),'String',propVal);
    
else % Any other ennumerated list of possible values
    if strcmp(style,'slider')
        value = range(round(value));
    end
    value = cast(value,class(range));
    if any(value == range)
        %  Continue editting here. Set value to source and Exposure objects
        eval(['UD.source.',camera.contrastProperty,'=value;']);
        
    else
        % Error of some kind.
        warndlg('Not a valid Contrast Property value.');
        eval(['value=UD.source.',camera.contrastProperty,';']);
    end
    objs = findall(0,'Tag','Contrast');
    sliders = strcmp(get(objs,'Style'),'slider');
    set(objs(sliders),'Value',find(range == value));
    set(objs(~sliders),'String',num2str(value));
end
end

% Callback Function for Lighting Setting
function LightingCBF(obj,~,camera,UD)
style = get(obj,'Style');
range = camera.lightingPropertyRange;
if strcmp(style,'slider')
    value = get(obj,'Value');
else
    value = get(obj,'String');
    if ~isa(range,'cell')
        value = str2double(value);
    end
end
if isa(range,'double') && (numel(range) == 2) % (semi)Continuous range of values
    if value < range(1)
        value = range(1);
    elseif value > range(2)
        value = range(2);
    end
    eval(['UD.source.',camera.lightingProperty,'=value;']);
    objs = findall(0,'Tag','Lighting');
    sliders = strcmp(get(objs,'Style'),'slider');
    set(objs(sliders),'Value',value);
    value = round(value*1000000)/1000000;
    set(objs(~sliders),'String',num2str(value));
    
elseif isa(range,'cell') % String values - whole numbers translate to values
    if isa(value,'char')
        propVal = value;
        value = find(strcmp(value,range),1);
    else
        if value < 1
            value = 1;
        elseif value > numel(range)
            value = numel(range);
        end
        value = round(value);
        propVal = range{value};
    end
    eval(['UD.source.',camera.lightingProperty,'=propVal;']);
    objs = findall(0,'Tag','Lighting');
    sliders = strcmp(get(objs,'Style'),'slider');
    set(objs(sliders),'Value',value);
    set(objs(~sliders),'String',propVal);
    
else % Any other ennumerated list of possible values
    if strcmp(style,'slider')
        value = range(round(value));
    end
    value = cast(value,class(range));
    if any(value == range)
        %  Continue editting here. Set value to source and Exposure objects
        eval(['UD.source.',camera.lightingProperty,'=value;']);
        
    else
        % Error of some kind.
        warndlg('Not a valid Lighting Property value.');
        eval(['value=UD.source.',camera.lightingProperty,';']);
    end
    objs = findall(0,'Tag','Lighting');
    sliders = strcmp(get(objs,'Style'),'slider');
    set(objs(sliders),'Value',find(range == value));
    set(objs(~sliders),'String',num2str(value));
end
end

% Callback Function for Lighting Setting
function PropertyCBF(obj,~,camera,UD)
style = get(obj,'Style');
tag = get(obj,'Tag');
pUD = get(obj,'UserData');
range = pUD.range;
property = pUD.property;
if strcmp(style,'slider')
    value = get(obj,'Value');
else
    value = get(obj,'String');
    if ~isa(range,'cell')
        value = str2double(value);
    end
end
if isa(range,'double') && (numel(range) == 2) % (semi)Continuous range of values
    if value < range(1)
        value = range(1);
    elseif value > range(2)
        value = range(2);
    end
    eval(['UD.source.',property,'=value;']);
    objs = findall(0,'Tag',tag);
    sliders = strcmp(get(objs,'Style'),'slider');
    set(objs(sliders),'Value',value);
    value = round(value*1000000)/1000000;
    set(objs(~sliders),'String',num2str(value));
    
elseif isa(range,'cell') % String values - whole numbers translate to values
    if isa(value,'char')
        propVal = value;
        value = find(strcmp(value,range),1);
    else
        if value < 1
            value = 1;
        elseif value > numel(range)
            value = numel(range);
        end
        value = round(value);
        propVal = range{value};
    end
    eval(['UD.source.',property,'=propVal;']);
    objs = findall(0,'Tag',tag);
    sliders = strcmp(get(objs,'Style'),'slider');
    set(objs(sliders),'Value',value);
    set(objs(~sliders),'String',propVal);
    
else % Any other ennumerated list of possible values
    if strcmp(style,'slider')
        value = range(round(value));
    end
    value = cast(value,class(range));
    if any(value == range)
        %  Continue editting here. Set value to source and Exposure objects
        eval(['UD.source.',property,'=value;']);
        
    else
        % Error of some kind.
        warndlg('Not a valid Property value.');
        eval(['value=UD.source.',property,';']);
    end
    objs = findall(0,'Tag',tag);
    sliders = strcmp(get(objs,'Style'),'slider');
    set(objs(sliders),'Value',find(range == value));
    set(objs(~sliders),'String',num2str(value));
end
end

% Callback Function for Auto checkbox
function AutoCBF(obj,~,~,UD)
if get(obj,'Value') == 1
    set(UD.axesHandle,'CLimMode','auto');
    set(findall(0,'Tag','AutoCheckbox'),'Value',1);
else
    set(UD.axesHandle,'CLimMode','manual');
    set(findall(0,'Tag','AutoCheckbox'),'Value',0);
end
end

% Callback Function for HistMin textbox
function HistMinCBF(obj,~,~,UD)
set(findall(0,'Tag','AutoCheckbox'),'Value',0);
set(UD.axesHandle,'CLimMode','manual');
clim = str2double(get(obj,'String'));
if clim < 0
    clim = 0;
elseif clim > 254
    clim = 254;
end
set(findall(0,'Tag','HistMin'),'String',num2str(clim));
clim(2) = str2double(get(findall(UD.controlsHandle,'Tag','HistMax'),'String'));
if clim(2) < 1
    clim(2) = 1;
elseif clim(2) > 255
    clim(2) = 255;
end
set(findall(0,'Tag','HistMax'),'String',num2str(clim(2)));
set(UD.axesHandle,'CLim',clim);
end

% Callback Function for HistMax textbox
function HistMaxCBF(obj,~,~,UD)
set(findall(0,'Tag','AutoCheckbox'),'Value',0);
set(UD.axesHandle,'CLimMode','manual');
clim = str2double(get(findall(0,'Tag','HistMin'),'String'));
if clim < 0
    clim = 0;
elseif clim > 254
    clim = 254;
end
set(findall(0,'Tag','HistMin'),'String',num2str(clim));
clim(2) = str2double(get(obj,'String'));
if clim(2) < 1
    clim(2) = 1;
elseif clim(2) > 255
    clim(2) = 255;
end
set(findall(0,'Tag','HistMax'),'String',num2str(clim(2)));
set(UD.axesHandle,'CLim',clim);
end

% Callback Function for Snap button
function SnapCBF(obj,~,camera,UD)
ImgStack = get(obj,'UserData');
if isempty(camera.exposureProperty)
    expProp = 0;
    fl = 0;
else
    expProp = 1;
    eval(['oldExp=UD.source.',camera.exposureProperty,';']);
    flbh = findall(0,'Tag','FLButton');
    if numel(flbh) > 1
        flbh = flbh(1);
    end
    if get(flbh,'Value') == 1
        fl = 1;
        h = findall(0,'Tag','FlCap');
        expTime = str2double(get(h(1),'String'));
        eval(['UD.source.',camera.exposureProperty,'=expTime;']);
        pause(expTime*2);
    else
        fl = 0;
    end
end
img = getsnapshot(UD.video);
if expProp == 1
    eval(['UD.source.',camera.exposureProperty,'=oldExp;']);
end
sach = findall(0,'Tag','SaveCheckbox');
if get(sach(1),'Value') == 1
    pth = findall(0,'Tag','PicPathText');
    myPath = get(pth(1),'String');
    if isempty(myPath)
        myPath = uigetdir;
        set(findall(0,'Tag','PicPathText'),'String',myPath);
    elseif strcmp('current',myPath(1,1:7))
        myPath = [pwd,myPath(1,8:end)];
    elseif strcmp('tag',myPath(1,1:3))
        pathTexts = findall(0,'Tag',myPath(1,4:end));
        myPath = get(pathTexts(1),'String');
        if isempty(myPath)
            myPath = uigetdir;
            set(pathTexts,'String',myPath);
        end
    end
    names = findall(0,'Tag','PicNameText');
    myName = get(names(1),'String');
    if isempty(myName)
        resp = questdlg('Enter a Name?','Attention','Yes','No','Yes');
        switch resp
            case 'No'
                time = clock;
                name = [num2str(time(2)) '-' num2str(time(3)) '-' ...
                    num2str(time(4)) '-' num2str(time(5)) ...
                    '-' num2str(round(time(6)))];
                if fl == 1
                    name = [name,' Fl.tif'];
                elseif expProp == 1
                    name = [name,' Bf.tif'];
                else
                    name = [name,'.tif'];
                end
            case 'Yes'
                return;
        end
    else
        list = dir([myPath '\' myName '*.tif']);
        if ~isempty(list)
            list = cell2mat({list.name}');
            list = mat2cell(list(:,end-5:end-4),ones(1,size(list,1)),2);
            if expProp == 0
                name = [myName,'-',num2str(numel(list)+1,'%03u'),'.tif'];
            elseif fl == 0
                list(strcmp('Fl',list)) = [];
                name = [myName,'-',num2str(numel(list)+1,'%03u'),' Bf.tif'];
            else
                list(strcmp('Bf',list)) = [];
                name = [myName,'-',num2str(numel(list)+1,'%03u'),' Fl.tif'];
            end
        else
            if expProp == 0
                name = [myName '-001.tif'];
            elseif fl == 0
                name = [myName '-001 Bf.tif'];
            else
                name = [myName '-001 Fl.tif'];
            end
        end
    end
    imwrite(img,[myPath '\' name]);
    [~,h] = MatPad;
    if ~isempty(h)
        timestr = datestr(clock,'mm/dd/yy HH:MM AM');
        entry = ['-- Snapshot Saved ',timestr];
        logentry = sprintf('<HTML><BODY color="%s">%s', 'gray', entry);
        MatPad('add',logentry);
        MatPad('add',name,'save');
    end
end
sch = findall(0,'Tag','ShowCheckbox');
if get(sch(1),'Value') == 1
    stch = findall(0,'Tag','StackCheckbox');
    if get(stch(1),'Value') == 0 || ImgStack == 0
        s = size(img);
        f = figure('MenuBar','none','Units','pixels');
        ImgStack = axes('Parent',f,'YLim',[0,s(1)],'XLim',[0,s(2)], ...
            'ButtonDownFcn',@StackBDF,'NextPlot','add', ...
            'Units','normalized','Position',[0 0 1 1],'XTick',[], ...
            'YTick',[],'YDir','reverse');
        set(obj,'UserData',ImgStack);
        imh = imagesc(img,'Parent',ImgStack,'HitTest','off');
        set(ImgStack,'UserData',[1,1,imh]);
        UD2.position = get(f,'Position');
        UD2.monitors = UD.monitors;
        UD2.resolution = UD.resolution;
        set(f,'UserData',UD2,'ResizeFcn',@resizeFcn,'CloseRequestFcn',@StackCRF);
%         axis equal;
        colormap('gray');
    elseif ImgStack ~= 0
        set(get(ImgStack,'Children'),'Visible','off');
        imh = imagesc(img,'Parent',ImgStack,'HitTest','off');
        ud = get(ImgStack,'UserData');
        set(ImgStack,'UserData',[ud(1)+1,ud(1)+1,ud(3:end),imh]);
    end
end

end

% Button Down Function for image stacks
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
end

% Close Request Function for image stacks
function StackCRF(obj,~)
buttons = findall(0,'Tag','SnapButton');
if any(get(buttons(1),'UserData') == get(obj,'Children'))
    set(buttons,'UserData',0)
end
delete(obj);
end

% Callback Function for Name textbox
function NameCBF(obj,~,~,~)
nameTexts = findall(0,'Tag','PicNameText');
set(nameTexts,'String',get(obj,'String'));
end

% Callback Function for Path textbox
function PathCBF(obj,~,~,~)
pathTexts = findall(0,'Tag','PicPathText');
set(pathTexts,'String',get(obj,'String'));
end

% Callback for general checkboxes used to synch values
function checkCBF(obj,~)
tag = get(obj,'Tag');
h = findall(0,'Tag',tag);
set(h,'Value',get(obj,'Value'));
end

% Callback Function for Video Toggle Button
function videoCBF(obj,~)
h = findall(0,'Tag','VideoB');
if get(obj,'Value') == 1
    set(h,'Foreground','r','Value',1);
    [~,h] = MatPad;
    if ~isempty(h)
        timestr = datestr(clock,'mm/dd/yy HH:MM AM');
        entry = ['-- Recording Video ',timestr];
        logentry = sprintf('<HTML><BODY color="%s">%s', 'purple', entry);
        MatPad('add',logentry);
    end
else
    set(h,'Foreground','k','Value',0);
end
end

% Timer Function for MemTimer
function memTimerFcn(~,~,UD)
th = findall(0,'Tag','VidTimeText');
[~,sys] = memory;
a = sys.PhysicalMemory.Available * .9;
set(th,'String',['~',num2str(floor(a / UD.bytesPerFrame / UD.frameRate)) ...
    ,' seconds of video possible']);
end

% Resize Function for the CameraWindow or image stacks
function resizeFcn(obj,~)
if ~libisloaded('user32') % Windows library gives access to mouse button state
    loadlibrary('user32.dll','user32.h');
end
m = calllib('user32','GetAsyncKeyState',int32(1)); % Read left mouse button state
if  m ~= -32767 % Left mouse button not clicked
    
    p = get(obj,'Position');
    UD = get(obj,'UserData');
    pO = UD.position;
    mon = UD.monitors;
    r = UD.resolution(2) / UD.resolution(1); % aspect ratio y/x
    y = p(2) + p(4); % pixel position of top of figure
    
    a = p(3) == pO(3);
    b = p(4) == pO(4);
    
    newX = round(p(4)/r); % New width if using current height
    newY = round(p(3)*r); % New height if using current width
    
    if ~(a && b)
        if p(1) == 1 && p(2) == 41 && r < 1 % Check for Maximized and manually reshape
            p(3) = newX;
        elseif p(1) == 1 && p(2) == 41 && r > 1
            p(4) = newY;
        elseif a % Resizing by dragging the bottom border
            if newX + p(1) > mon(:,3) % Check right side of figure will be on a screen
                p(3) = max(mon(:,3)) - p(1); % Find max width
                p(4) = round(p(3)*r); % Recalculate new height
            else
                p(3) = newX;
            end
        elseif b % Resizing by dragging the right border
            p(4) = newY;
        else % Resizing by draggind corner or Win+<arrow key> commands
            difX = p(3) - pO(3); % Find whether width or height changed more
            difY = p(4) - pO(4);
            if abs(difX) > abs(difY) % Greater change in width, scale height
                p(4) = newY;
            else % Greater change in height, scale width
                if newX + p(1) > mon(:,3) % Check right side of resized figure
                    p(3) = max(mon(:,3)) - p(1); % Find max width if off screen
                    p(4) = round(p(3)*r); % Recalculate height
                else
                    p(3) = newX;
                end
            end
        end
    else
        % Currently, do nothing
    end
    
    p(2) = y - p(4); % modify y position to maintain top of figure pixel position
    
    UD.position = p; % Save resizing results
    set(obj,'Position',p,'UserData',UD) % Resize figure
else
    % Currently, do nothing
end
end

% Button Down Function for the preview image.
function PreviewBDF(obj, ~)
CameraWindow = getappdata(obj,'CameraWindow'); % Get CameraWindow handle
UD = get(CameraWindow,'UserData'); % get CameraWindow UserData struct
select = get(CameraWindow,'SelectionType'); % check mouse click type
myAxes = UD.axesHandle;
pos = get(myAxes,'CurrentPoint'); % Find position of mouse click on axes
% Calculate zoom region and prevent centering zoom too close to a border
x = ceil(pos(1,2));
xMin = round(UD.resolution(2) / 4);
if x < xMin
    x = xMin;
elseif x > 3 * xMin
    x = round(3 * xMin);
end
y = ceil(pos(1,1));
yMin = round(UD.resolution(1) / 4);
if y < yMin
    y = yMin;
elseif y > yMin * 3
    y = round(yMin * 3);
end
switch select % Different functionality based on mouse click type
    case 'normal' % Left click - Zoom - actually implemented in the preview listener
        switch UD.scale
            case 1 % Zoom to 2x
                UD.scale = 2;
                UD.previewX = x;
                UD.previewY = y;
            case 2 % Zoom to 4x
                UD.scale = 4;
                UD.previewX = round(x / 2 - xMin + 1 + UD.previewX);
                UD.previewY = round(y / 2 - yMin + 1 + UD.previewY);
            case 4 % Return to 1x normal view
                UD.scale = 1;
        end
        set(CameraWindow,'UserData',UD);
%     case 'open' % Double click
%         
    case 'alt' % Right click - Move pointer
        set(UD.pointer,'Xdata',pos(1,1),'YData',pos(1,2)); % Move the pointer
        refresh(CameraWindow); % refresh the figure
    
    case 'extend' % Shift+Left click or middle mouse button click
        figure(UD.controlsHandle);
end
end

% Update Function the preview window when the preview supplies a new frame
function CWUpdateFcn(~,event,hImage)
persistent videoBuffer frameCount;
if isempty(frameCount)
    frameCount = 0;
end
data = event.Data;
acbh = findall(0,'Tag','AutoCheckbox');
if numel(acbh) > 1
    acbh = acbh(1);
end
if ndims(data) > 2 %#ok<ISMAT>
    histD = rgb2gray(data);
    if get(acbh,'Value') == 1
        stretch = stretchlim(histD,[0.1,0.99]);
        data = imadjust(data,stretch,[0,1]);
        s2 = round(stretch * 255);
        set(findall(0,'Tag','HistMin'),'String',num2str(s2(1)));
        set(findall(0,'Tag','HistMax'),'String',num2str(s2(2)));
    else
        minT = findall(0,'Tag','HistMin');
        if numel(minT) > 1
            minT = minT(1);
        end
        min = str2double(get(minT,'String')) / 255;
        maxT = findall(0,'Tag','HistMax');
        if numel(maxT) > 1
            maxT = maxT(1);
        end
        max = str2double(get(maxT,'String')) / 255;
        data = imadjust(data,[min,max],[0,1]);
    end
else
    histD = data;
    if get(acbh,'Value') == 1
        clim = get(findall(0,'Tag','CameraAxes'),'CLim');
        set(findall(0,'Tag','HistMin'),'String',num2str(clim(1)));
        set(findall(0,'Tag','HistMax'),'String',num2str(clim(2)));
    end
end
graph = findall(0,'Tag','Histogram');
if ~isempty(graph)
    [hist, ~] = imhist(histD);
    for i = 1:numel(graph)
        set(graph(i),'YData',hist);
    end
end
UD = get(findall(0,'Tag','CameraWindow'),'UserData');
res = UD.resolution;
switch UD.scale
    % -------------- Modify to Generalize to other Resolutions ------------
    case 1
%         x1 = 1;x2 = 1024;y1 = 1;y2 = 1344;
        img = data;
    case 2
%         x1 = 256;x2 = 768;y1 = 336;y2 = 1008;
        x = UD.previewX;
        dx = round(res(2) / 4);
        a = x - dx;
        if a < 1
            a = 1;
        end
        b = x + dx;
        if b > res(2)
            b = res(2);
        end
        y = UD.previewY;
        dy = round(res(1) / 4);
        c = y - dy;
        if c < 1
            c = 1;
        end
        d = y + dy;
        if d > res(1)
            d = res(1);
        end
        img = imresize(data(a:b,c:d,:),UD.scale);
    case 4
%         x1 = 384;x2 = 640;y1 = 504;y2 = 840;
        x = UD.previewX;
        dx = round(res(2) / 8);
        a = x - dx;
        if a < 1
            a = 1;
        end
        b = x + dx;
        if b > res(2)
            b = res(2);
        end
        y = UD.previewY;
        dy = round(res(1) / 8);
        c = y - dy;
        if c < 1
            c = 1;
        end
        d = y + dy;
        if d > res(1)
            d = res(1);
        end
        img = imresize(data(a:b,c:d,:),UD.scale);
end
set(hImage,'CData',img);
refreshdata(hImage);
vbh = findall(0,'Tag','VideoB');
if numel(vbh) > 1
    vbh = vbh(1);
end
if get(vbh,'Value') == 1
    frameCount = frameCount + 1;
%     data = getsnapshot(UD.video);
    if isempty(videoBuffer)
        [~,sys] = memory;
        maxFrames = floor(sys.PhysicalMemory.Available / UD.bytesPerFrame * .9);
        temp = cell(maxFrames,1);
        temp(1:maxFrames) = {zeros(size(data),class(data))};
        videoBuffer = temp;
    end
    videoBuffer{frameCount} = data;
    if frameCount >= numel(videoBuffer)
        set(findall(UD.controlsHandle,'Tag','VideoB'),'Value',0,'Foreground','k');
    end
else
    if frameCount > 0
        data = videoBuffer;  % Commands done in this order for memory management
        videoBuffer = [];
        data = data(1:frameCount);
        frameCount = 0;
        start(timer('TimerFcn',{@saveVid,data}));
    end
end
end

% Timer Function for saving video
function saveVid(obj,~,data)
[~,h] = MatPad;
if ~isempty(h)
    timestr = datestr(clock,'mm/dd/yy HH:MM AM');
    entry = ['-- Video Stopped ',timestr];
    logentry = sprintf('<HTML><BODY color="%s">%s', 'purple', entry);
    MatPad('add',logentry);
end
cw = findall(0,'Tag','CameraWindow');
UD = get(cw,'UserData');
fname = get(findall(UD.controlsHandle,'Tag','PicNameText'),'String');
if isempty(fname)
    fname = UD.fileName;
end
fpath = get(findall(UD.controlsHandle,'Tag','PicPathText'),'String');
if isempty(fpath)
    fpath = UD.savePath;
end
fullname = fullfile(fpath,fname);
profiles = VideoWriter.getProfiles;
if ndims(data{1}) == 3
    if any(strcmp({profiles.Name},'Uncompressed AVI'))
        outputVideo = VideoWriter(fullname,'Uncompressed AVI');
    else
        outputVideo = VideoWriter(fullname);
    end
else
    if any(strcmp({profiles.Name},'Grayscale AVI'))
    outputVideo = VideoWriter(fullname,'Grayscale AVI');
    elseif any(strcmp({profiles.Name},'Uncompressed AVI'))
        outputVideo = VideoWriter(fullname,'Uncompressed AVI');
    else
        outputVideo = VideoWriter(fullname);
    end
end
outputVideo.FrameRate = UD.frameRate;
open(outputVideo);
for i = 1:numel(data)
    writeVideo(outputVideo,data{i});
end
close(outputVideo);
[~,h] = MatPad;
if ~isempty(h)
    timestr = datestr(clock,'mm/dd/yy HH:MM AM');
    entry = ['-- Video Saved ',timestr];
    logentry = sprintf('<HTML><BODY color="%s">%s', 'gray', entry);
    MatPad('add',logentry);
    MatPad('add',[fname,'.avi'],'save');
end
stop(obj);
delete(obj);
end

function closeFcn(~,~)
t = timerfind('Name','MemTimer');
if ~isempty(t)
    stop(t);
    delete(t);
end
cwh = findall(0,'Tag','CameraWindow');
cch = findall(0,'Tag','CameraControls');
if ~isempty(cwh)
    UD = get(cwh(1),'UserData');
    stoppreview(UD.video);
    delete(UD.video);
    delete(cwh);
end
if ~isempty(cch)
    delete(cch);
end
cbh = findall(0,'Tag','CameraCheckbox');
if ~isempty(cbh)
    set(cbh,'Value',0);
    for i = 1:numel(cbh)
        cbcb = get(cbh(i),'Callback');
        cbcb(cbh(i),[])
    end
end
clear CWUpdateFcn
[~,h] = MatPad;
if ~isempty(h)
    timestr = datestr(clock,'mm/dd/yy HH:MM AM');
    entry = ['-- CameraWindow Closed ',timestr];
    logentry = sprintf('<HTML><BODY color="%s">%s', 'red', entry);
    MatPad('add',logentry,'save');
end
end