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
    'ControlBox','CloseRequestFcn',{@mainCRF,win});
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


function mainCRF(obj,~,win)
delete(win);
delete(obj);