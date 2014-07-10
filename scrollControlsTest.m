function scrollControlsTest()

labelPos = [4,122,96,14];
editPos = [100,118,36,22];
slidePos = [137,118,138,22];
numProps = 10;
propStep = 33;

f = figure('Resize','off','Units','Pixels','MenuBar','none');
pos = get(f,'Position');
pos(3:4) = [300,400];
set(f,'Position',pos);
panel = uipanel(f,'Units','Pixels','Position',[0,250,280,150],'Title','', ...
    'BackgroundColor',[.82,.82,.82]);
slide = uicontrol(f,'Style','Slider','Units','Pixels','Position',[280,250,20,150], ...
    'Max',numProps-4,'Value',numProps-4,'SliderStep', ... 
    [1/(numProps-4),1/(numProps-4)],'Callback',@sliderCBF);


for i = 1:numProps
    label(i) = uicontrol(panel,'Style','Text','Units','Pixels','Position',labelPos, ...
        'BackgroundColor',[.82,.82,.82],'String',['Property ',num2str(i),':']);
    editBox(i) = uicontrol(panel,'Style','Edit','Units','Pixels','Position', ...
        editPos);
    propSlide(i) = uicontrol(panel,'Style','Slider','Units','Pixels','Position', ...
        slidePos,'SliderStep',[0.05,0.2]);
    labelPos(2) = labelPos(2) - propStep;
    editPos(2) = editPos(2) - propStep;
    slidePos(2) = slidePos(2) - propStep;
end

positions = cell2mat(get(editBox,'Position'));
belowPanel = positions(:,2) < 1;
set(label(belowPanel),'Visible','off');
set(editBox(belowPanel),'Visible','off');
set(propSlide(belowPanel),'Visible','off');

UD.step = propStep;
UD.objs = [label,editBox,propSlide];
UD.lastVal = numProps - 4;
set(slide,'UserData',UD);


function sliderCBF(obj,~)
val = round(get(obj,'Value'));
set(obj,'Value',val);
UD = get(obj,'UserData');
numSteps = val - UD.lastVal;
UD.lastVal = val;
set(obj,'UserData',UD);
positions = cell2mat(get(UD.objs,'Position'));
positions(:,2) = positions(:,2) - numSteps*UD.step;
for i = 1:size(positions,1)
    set(UD.objs(i),'Position',positions(i,:),'Visible','off');
end
inPanel = positions(:,2) > 0 & (positions(:,2) + positions(:,4)) < 150;
set(UD.objs(inPanel),'Visible','on');


