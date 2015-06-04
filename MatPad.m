function varargout = MatPad(varargin)
varargout = {};
persistent h editing
if isempty(h) && numel(varargin) ~= 0
    h = makeFig();
end
if isempty(editing)
    editing = false;
end
if numel(varargin) == 0
    if isempty(h)
        varargout{1} = 'MatPad is closed';
        varargout{2} = [];
        clear MatPad
    else
        varargout{1} = 'MatPad is running';
        varargout{2} = h;
    end
end
i = 1;
editH = findall(0,'Tag','MatPadEditor');
while i <= numel(varargin)
    if any(ishandle(varargin{i})) || any(isempty(varargin{i}))
        i = i + 1;
    else
        if ischar(varargin{i})
            varargin{i} = lower(varargin{i});
        end
        switch varargin{i}
            case 'open'
                set(h,'Visible','on');
                figure(h);
                i = i + 1;
                
            case 'close'
                editing = false;
                if ~isempty(h) && ishandle(h)
                    close(h);
                end
                return;
                
            case 'string'
                editing = false;
                if ~isempty(editH)
                    delete(editH);
                end
                text = varargin{i+1};
                lbh = findall(h,'Tag','MatPadListbox');
                set(lbh,'String',text);
                i = i + 2;
                
            case 'add'
                editing = false;
                if ~isempty(editH)
                    delete(editH);
                end
                lbh = findall(h,'Tag','MatPadListbox');
                text = get(lbh,'String');
                if ~iscell(text) && ~isempty(text)
                    text = {text};
                end
                if ~isempty(text) && ischar(varargin{i+1})
                    temp = varargin{i+1};
                    if size(temp,2) < 6 || ~strcmp(temp(1:6),'<HTML>')
                        temp = textwrap(lbh,{temp},45);
                    end
                    text = [text;temp];  %#ok<AGROW>
                else
                    temp = get(findall(h,'Tag','MatPadEntryText'),'String');
                    set(findall(h,'Tag','MatPadEntryText'),'String','');
                    if strcmp(temp,'delete')
                        text(end) = [];
                    elseif strcmp(temp,'edit')
                        editing = true;
                        editText(text);
                    else
                        if size(temp,2) < 6 || ~strcmp(temp(1:6),'<HTML>')
                            temp = textwrap(lbh,{temp},45);
                        end
                        text = [text;temp]; %#ok<AGROW>
                    end
                end
                set(lbh,'String',text);
                pause(.1)
                set(lbh,'ListboxTop',numel(text));
                i = i + 2;
                
            case 'editreturn'
                if editing == true && iscell(varargin{i+1})
                    editing = false;
                    text = varargin{i+1};
                    lbh = findall(h,'Tag','MatPadListbox');
                    set(lbh,'String',text);
                end
                i = i + 2;
                
            case 'log'
                editing = false;
                if ~isempty(editH)
                    delete(editH);
                end
                lth = findall(h,'Tag','MatPadFileText');
                clf = get(lth,'String');
                if ~isempty(clf)
                    logFile = fopen(clf,'wt');
                    text = get(findall(h,'Tag','MatPadListbox'),'String');
                    if ~iscell(text)
                        text = {text};
                    end
                    for j = 1:numel(text)
                        fprintf(logFile, '%s\n', text{j,:});
                    end
                    fclose(logFile);
                end
                lf = varargin{i+1};
                set(lth,'String',lf,'UserData',lf);
                if exist(lf,'file')
                    logFile = fopen(lf,'r');
                    text = textscan(logFile,'%s','Delimiter','\n');
                    text = text{1};
                    lbh = findall(h,'Tag','MatPadListbox');
                    set(lbh,'String',text);
                end
                i = i + 2;
                
            case 'hide'
                set(h,'Visible','off');
                i = i + 1;
                
            case 'save'
                lf = get(findall(h,'Tag','MatPadFileText'),'String');
                if ~isempty(lf)
                    logFile = fopen(lf,'wt');
                    text = get(findall(h,'Tag','MatPadListbox'),'String');
                    if ~iscell(text)
                        text = {text};
                    end
                    for i = 1:numel(text)
                        fprintf(logFile, '%s\n', text{i,:});
                    end
                    fclose(logFile);
                end
                i = i + 1;
                
                
            otherwise
                inputs = [{'Unrecognized Property/Value pairs or commands:'},...
                    varargin(i:end)];
                warndlg(inputs,'MatPad Error');
                return;
        end
    end

end

function editText(textIn)
f = figure('Units','pixels','MenuBar','none','IntegerHandle','off', ...
    'Name','MatPad - Edit Log File','NumberTitle','off','Tag','MatPadEditor', ...
    'CloseRequestFcn',{@editCloseFcn},'Resize','off');
pos = get(f,'Position');
pos(3:4) = [400,400];
set(f,'Position',pos);
tbh = uicontrol(f,'Style','edit','Position',[5,25,390,370],'String',textIn, ...
    'HorizontalAlignment','left','Max',100000,'Tag','EditorText', ...
    'Callback',@editorCbf);
uicontrol(f,'Style','PushButton','Position',[300,5,75,20],'String','Done', ...
    'Callback',{@editorDoneCbf,tbh});
uicontrol(tbh)



function editorCbf(obj,~)
returnText = get(obj,'String');
MatPad('editReturn',returnText);
delete(get(obj,'Parent'))



function editorDoneCbf(~,~,tbh)
cbf = get(tbh,'Callback');
cbf(tbh,[]);


function editCloseFcn(obj,~)
resp = questdlg('Discard Changes?','MatPad Editor','No');
if strcmp(resp,'Yes')
    delete(obj);
end


function logCbf(obj,~)
h = findall(0,'Tag','MatPad');
oldLF = get(obj,'UserData');
if ~isempty(oldLF)
    logFile = fopen(oldLF,'w');
    text = get(findall(h,'Tag','MatPadListbox'),'String');
    if ~iscell(text)
        text = {text};
    end
    for i = 1:numel(text)
        fprintf(logFile, '%s\n', text{i,:});
    end
    fclose(logFile);
end
lf = get(obj,'String');
set(obj,'UserData',lf);
if exist(lf,'file')
    logFile = fopen(lf,'r');
    text = textscan(logFile,'%s','Delimiter','\n');
    if ~isempty(text) && (ischar(text) || iscell(text))
        set(findall(h,'Tag','MatPadListbox'),'String',text);
    else
        set(findall(h,'Tag','MatPadListbox'),'String','');
    end
else
    set(findall(h,'Tag','MatPadListbox'),'String','');
end


function h = makeFig()
h = figure('Units','pixels','MenuBar','none','IntegerHandle','off', ...
    'Name','MatPad','NumberTitle','off','Tag','MatPad', ...
    'CloseRequestFcn',@closeFcn,'Visible','off','Resize','off');
pos = get(h,'Position');
pos(3:4) = [400,450];
set(h,'Position',pos);
uicontrol(h,'Style','Listbox','Tag','MatPadListbox','Position',[10,150,380,290], ...
    'Enable','inactive','Max',2,'Value',[],'FontName','FixedWidth','FontSize',10);
uicontrol(h,'Style','Text','Position',[10,120,70,17],'String','Log File:', ...
    'BackgroundColor',[.8,.8,.8]);
uicontrol(h,'Style','Edit','Tag','MatPadFileText','Position',[80,120,250,20], ...
    'Callback',@logCbf,'UserData',[],'String','Default.log');
uicontrol(h,'Style','Text','Position',[10,80,50,20],'String','Entry:', ...
    'BackgroundColor',[.8,.8,.8]);
uicontrol(h,'Style','Edit','Tag','MatPadEntryText','Position',[60,80,330,30], ...
    'HorizontalAlignment','left','Callback',{@MatPad,'add',[]});
uicontrol(h,'Style','PushButton','String','Add Entry','Position',[300,25,60,30], ...
    'Callback',{@MatPad,'add',[]});


function closeFcn(obj,~)
if strcmp(get(obj,'Visible'),'on')
    resp = questdlg('Close MatPad?','MatPad','Yes','Hide','Cancel','Hide');
    switch resp
        case 'Cancel'
            close = 0;
        case 'Hide'
            set(obj,'Visible','off');
            close = 0;
        case 'Yes'
            close = 1;
    end
else
    close = 1;
end
if close == 1
    editH = findall(0,'Tag','MatPadEditor');
    if ~isempty(editH)
        delete(editH);
    end
    lf = get(findall(obj,'Tag','MatPadFileText'),'String');
    if ~isempty(lf)
        logFile = fopen(lf,'wt');
        text = get(findall(obj,'Tag','MatPadListbox'),'String');
        if ~iscell(text)
            text = {text};
        end
        for i = 1:numel(text)
            fprintf(logFile, '%s\n', text{i,:});
        end
        fclose(logFile);
    end
    delete(obj);
    clear MatPad
end