classdef (Sealed) Polygon400 < handle   %#ok<*BDSCA>
    % Interfaces and Controls the MightEx Polygon400 microscope DMD
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        connected
        dialog
        displayMode
        LEDCurrent
        lockTrigPulseWidth
        polyPtnSet
        polyTrigSet
    end
    
    methods (Access = private)
        % Constructor
        function obj = Polygon400(dialogOutput)
            obj.dialog = dialogOutput;
            % Build Ptn Settings struct with defaults
            obj.polyPtnSet.bitDepth = 1; % 1,2,4,or 8
            obj.polyPtnSet.PtnNumber = 1; % Total number of patterns MAX 96/bitDepth
            obj.polyPtnSet.TrigType = 0; % 0=Software, 1=Auto, 2=Ext Rise, 3=Ext Fall
            obj.polyPtnSet.TrigDelay = 0; % Value in microseconds
            obj.polyPtnSet.TrigPeriod = 0; % Value in microseconds
            obj.polyPtnSet.ExposureTime = 2000000; % Value in microseconds, 2M MAX
            obj.polyPtnSet.LEDSelection = 2; % 0= Red, 1= Green, 2= Blue
            % Build OutTrig Settings struct with defaults
            obj.polyTrigSet.Enable = 1; % 0= disable, 1= enable
            obj.polyTrigSet.TrigDelay = 0; % Value in microseconds
            obj.polyTrigSet.TrigPulseWidth = 2000000;%Value in microseconds
            % Slave OutTrig Pulse Width to Exposure Time - default TRUE
            obj.lockTrigPulseWidth = true;
            % Set default display mode to pattern (1)
            obj.displayMode = 1;
            % Attempt initialization and Setup
            for i = 1:1
                % Initialize
                code = polymex('InitDevice',-1,[]);
                if code == -1
                    codeType = 1;
                    break;
                end
                % Connect
                code = polymex('ConnectDev',0);
                if code == -1
                    polymex('UnInitDevice');
                    codeType = 2;
                    break;
                end
                % Set Pattern Display mode instead of color
                code = polymex('SetDevDisplayMode',0,1);
                if code == -1
                    polymex('DisconnectDev',0);
                    polymex('UnInitDevice');
                    codeType = 3;
                    break;
                end
                % Set OutTrig settings
                settings = cell2mat(struct2cell(obj.polyTrigSet));
                code = polymex('SetOutTrigSetting',0,int32(settings));
                if code == -1
                    polymex('DisconnectDev',0);
                    polymex('UnInitDevice');
                    codeType = 4;
                    break;
                end
                codeType = 0;
                % Vertical and Horizontal inversion settings
                polymex('SetDevDisplaySetting',0,0,1);
                % Turn all LED current to MAX (1000)
                obj.LEDCurrent(1) = 1000;
                obj.LEDCurrent(2) = 1000;
                obj.LEDCurrent(3) = 1000;
                polymex('SetDevLEDCurrent',0,1000,1000,1000);
            end
            if code == -1
                obj.connected = 0;
                % Display appropriate error message if dialog is flagged
                if obj.dialog == 1
                    switch codeType
                        case 1
                            warndlg('Polygon Init Failed');
                        case 2
                            warndlg('Polygon Connect Failed');
                        case 3
                            warndlg('Polygon Pattern Mode Setting Failed');
                        case 4
                            warndlg('Ploygon Output Trigger Setting Failed');
                    end
                end
            else
                obj.connected = 1;
                % Display device ready notification if dialog is flagged
                if obj.dialog == 1
                    warndlg('Polygon Connected and Ready');
                end
            end
        end
        
        % packImg converts images from MATLAB format to bit Polygon400 form
        function packed = packImg(~,ptn,bd)
% packImg returns a single column array with values from img packed
% together into Bytes.  This only works for bitDepths of 1,2,4,8 or 24 bits
% per pixel.  The values in ptn MUST NOT exceed the maximum value possible
% for the associated bit representation.  i.e. 1 BD 1, 3 BD 2, 15 BD 4...
% Bitmaps are scanned from the bottom left across the row then up the rows.
% Because of this, img will be flipped top to bottom before conversion to
% be compatible with bitmap format.  Packing takes place along rows.  the
% array, ptn, is expected to have a row length that is a multiple of 8.
            ptn = ptn(end:-1:1,:); %Flips img top to bottom
            ptn = reshape(ptn',8 / bd,[])'; %Reshapes img so each row is one byte, in order
            if any(bd == [8,24])
                packed = uint8(ptn); % Store as a byte array
                return;
            elseif any(bd == [1,2,4])
                factor = 2 .^ (0:bd:7);
                factor = factor(end:-1:1)';
                packed = uint8(single(ptn) * factor);
            else
                packed = [];
            end
        end
    end
    
    methods (Static)
        % Enforces a single instance of this class.  Instantiation is
        % private and the connect function either finds an existing handle
        % to this object or creates a new one using the constructor.
        function singleObj = connect(dialogOutput)
            persistent PolygonObj
            if isempty(PolygonObj) || ~isvalid(PolygonObj)
                PolygonObj = Polygon400(dialogOutput);
            else
                PolygonObj.dialog = dialogOutput;
            end
            if PolygonObj.connected == 0 && dialogOutput == 1
                disp('Connection to Polygon400 Failed');
            end
            
            singleObj = PolygonObj;
        end
        
        % Calls Start Pattern on the Polygon400
        function code = start()
            code = polymex('StartPattern',0);
        end
        
        % Software Trigger Next Pattern on the Polygon400
        function code = next()
            code = polymex('NextPattern',0);
        end
        
        % Calls Stop Pattern on the Polygon400
        function code = stop()
            code = polymex('StopPattern',0);
        end
    end
        
    methods
        % Set Display Settings - Vertical and Horizontal Mirroring
        function code = SetDevDisplaySetting(~,vert,horiz)
            if any(vert == [0,1]) && any(horiz == [0,1])
                code = polymex('SetDevDisplaySetting',0,int32(vert),int32(horiz));
            else
                code = -1;
            end
        end
        
        % Set BitDepth and update Ptn Settings
        function code = setBitDepth(obj,bitDepth)
            if any(bitDepth == [1,2,4,8])
                pps = obj.polyPtnSet;
                pps.bitDepth = bitDepth;
                settings = cell2mat(struct2cell(pps));
                code = polymex('SetDevPtnSetting',0,int32(settings));
                if code == 0
                    obj.polyPtnSet = pps;
                end
            else
                code = -1;
            end
        end
        
        % Set Trigger Type and update Ptn Settings
        function code = setTrigType(obj,trigType)
            if any(trigType == [0,1,2,3])
                pps = obj.polyPtnSet;
                pps.TrigType = trigType;
                settings = cell2mat(struct2cell(pps));
                code = polymex('SetDevPtnSetting',0,int32(settings));
                if code == 0
                    obj.polyPtnSet = pps;
                end
            else
                code = -1;
            end
        end
        
        % Set Trigger Delay and update Ptn Settings
        function code = setTrigDelay(obj,trigDelay)
            if trigDelay >= 0
                pps = obj.polyPtnSet;
                pps.TrigDelay = trigDelay;
                settings = cell2mat(struct2cell(pps));
                code = polymex('SetDevPtnSetting',0,int32(settings));
                if code == 0
                    obj.polyPtnSet = pps;
                end
            else
                code = -1;
            end
        end
        
        %Set Trigger Period and update Ptn Settings
        function code = setTrigPeriod(obj,trigPeriod)
            if trigPeriod >= 0
                pps = obj.polyPtnSet;
                pps.TrigPeriod = trigPeriod;
                settings = cell2mat(struct2cell(pps));
                code = polymex('SetDevPtnSetting',0,int32(settings));
                if code == 0
                    obj.polyPtnSet = pps;
                end
            else
                code = -1;
            end
        end
        
        % Set Exposure Time and update Ptn Settings
        function code = setExposureTime(obj,exposureTime)
            if exposureTime >= 0 && exposureTime <= 2000000
                pps = obj.polyPtnSet;
                pps.ExposureTime = exposureTime;
                settings = cell2mat(struct2cell(pps));
                code = polymex('SetDevPtnSetting',0,int32(settings));
                if code == 0
                    if obj.lockTrigPulseWidth == true;
                        pts = obj.polyTrigSet;
                        pts.TrigPulseWidth = exposureTime;
                        set = cell2mat(struct2cell(pts));
                        code = polymex('SetOutTrigSetting',0,int32(set));
                        if code == 0
                            obj.polyTrigSet = pts;
                        end
                    end
                    obj.polyPtnSet = pps;
                end
            else
                code = -1;
            end
        end
        
        % Set LED Selection and update Ptn Settings
        function code = setLEDSelection(obj,LEDSelection)
            if any(LEDSelection == [0,1,2])
                pps = obj.polyPtnSet;
                pps.LEDSelection = LEDSelection;
                settings = cell2mat(struct2cell(pps));
                code = polymex('SetDevPtnSetting',0,int32(settings));
                if code == 0
                    obj.polyPtnSet = pps;
                end
            else
                code = -1;
            end
        end
        
        % Set Output Trigger On/Off and update OutTrig Settings
        function code = setOutputTrigger(obj,enabled)
            if any(enabled == [0,1])
                pts = obj.polyTrigSet;
                pts.Enable = enabled;
                settings = cell2mat(struct2cell(pts));
                code = polymex('SetOutTrigSetting',0,int32(settings));
                if code == 0
                    obj.polyTrigSet = pts;
                end
            else
                code = -1;
            end
        end
        
        % Set Output Trigger Delay and update OutTrig Settings
        function code = setOutTrigDelay(obj,delay)
            if delay >= 0 && delay <= 2000000
                pts = obj.polyTrigSet;
                pts.TrigDelay = delay;
                settings = cell2mat(struct2cell(pts));
                code = polymex('SetOutTrigSetting',0,int32(settings));
                if code == 0
                    obj.polyTrigSet = pts;
                end
            else
                code = -1;
            end
        end
        
        % Set Output Trigger Pulse Width and update OutTrig Settings
        % returns -1 if lockTrigPulseWidth is set true
        function code = setOutTrigPulseWidth(obj,width)
            if width >= 0 && width <= 2000000 && obj.lockTrigPulseWidth == false
                pts = obj.polyTrigSet;
                pts.TrigDelay = width;
                settings = cell2mat(struct2cell(pts));
                code = polymex('SetOutTrigSetting',0,int32(settings));
                if code == 0
                    obj.polyTrigSet = pts;
                end
            else
                code = -1;
            end
        end
        
        % Set and update Ptn Settings - only uses recognized struct fields
        function code = setPtnSettings(obj,settings)
            code = 0;
            pps = obj.polyPtnSet;
            for i = 1:1
                if isfield(settings,'bitDepth')
                    if any(settings.bitDepth == [1,2,4,8])
                        pps.bitDepth = settings.bitDepth;
                    else
                        code = -1;
                        break;
                    end
                end
                if isfield(settings,'TrigType')
                    if any(settings.TrigType == [0,1,2,3])
                        pps.TrigType = settings.TrigType;
                    else
                        code = -1;
                        break;
                    end
                end
                if isfield(settings,'TrigDelay')
                    if settings.TrigDelay >= 0 && settings.TrigDelay <= 2000000
                        pps.TrigDelay = settings.TrigDelay;
                    else
                        code = -1;
                        break;
                    end
                end
                if isfield(settings,'TrigPeriod')
                    if settings.TrigPeriod >= 0 && settings.TrigPeriod <= 2000000
                        pps.TrigPeriod = settings.TrigPeriod;
                    else
                        code = -1;
                        break;
                    end
                end
                if isfield(settings,'ExposureTime')
                    if settings.ExposureTime >= 0 && settings.ExposureTime <= 2000000
                        pps.ExposureTime = settings.ExposureTime;
                        if obj.lockTrigPulseWidth
                            pts = obj.polyTrigSet;
                            pts.TrigPulseWidth = settings.ExposureTime;
                        end
                    else
                        code = -1;
                        break;
                    end
                end
                if isfield(settings,'LEDSelection')
                    if any(settings.LEDSelection == [0,1,2])
                        pps.TrigPeriod = settings.TrigPeriod;
                    else
                        code = -1;
                        break;
                    end
                end
            end
            if code == 0
                settings = cell2mat(struct2cell(pps));
                code = polymex('SetDevPtnSetting',0,int32(settings));
                if code == 0
                    obj.polyPtnSet = pps;
                    if obj.lockTrigPulseWidth
                        settings = cell2mat(struct2cell(pts));
                        code = polymex('SetOutTrigSetting',0,int32(settings));
                        if code == 0
                            obj.polyTrigSet = pts;
                        end
                    end
                end
            end
        end
        
        % Set and update OutTrig Settings - only uses recognized struct fields
        function code = setOutTrigSettings(obj,settings)
            code = 0;
            pts = obj.polyTrigSet;
            for i = 1:1
                if isfield(settings,'Enable')
                    if any(settings.Enable == [0,1])
                        pts.Enable = settings.Enable;
                    else
                        code = -1;
                        break;
                    end
                end
                if isfield(settings,'TrigDelay')
                    if settings.TrigDelay >= 0 && settings.TrigDelay <= 2000000
                        pts.TrigDelay = settings.TrigDelay;
                    else
                        code = -1;
                        break;
                    end
                end
                if isfield(settings,'TrigPulseWidth')
                    if ~obj.lockTrigPulseWidth && settings.TrigPulseWidth >= 0 && settings.TrigPulseWidth <= 2000000
                        pts.TrigPulseWidth = settings.TrigPulseWidth;
                    elseif obj.lockTrigPulseWidth
                        pts.TrigPulseWidth = obj.polyPtnSet.ExposureTime;
                    else
                        code = -1;
                        break;
                    end
                end
            end
            if code == 0
                settings = cell2mat(struct2cell(pts));
                code = polymex('SetOutTrigSetting',0,int32(settings));
                if code == 0
                    obj.polyTrigSet = pts;
                end
            end
        end
        
        % Set and update LED output power 0 - 1000, 1000 = 100%
        function code = SetDevLEDCurrent(obj,r,g,b)
            if ~any([r,g,b] < 0) && ~any([r,g,b] > 1000) %#ok<BDSCA>
                code = polymex('SetDevLEDCurrent',0,r,g,b);
            else
                code = -1;
            end
            if code == -1 && obj.dialog == 1
                warndlg('Polygon LED Setting Failed');
            else
                obj.LEDCurrent = [r,g,b];
            end
        end
        
        % Uploads patterns and images to the Polygon and adjusts settings
        function code = upload(obj,ptns,bitDepth,append,start)
        % Upload accepts patterns in MATLAB Logical or UInt8 data types and
        % uploads them to the Polygon400.  Only one 24-Bit pattern can be
        % uploaded and Upload changes the display mode to Color (0).  All
        % patterns must be 608 pixels in width and 684 pixels in height.
        % Uploading any pattern with bit depth less than 24 will change the
        % display mode back to Pattern (1) but the user designates whether
        % to append or replace patterns.  Multiple patterns are uploaded as
        % a single three dimensional array with the third dimension being
        % the pattern number, ie (x,y,PatternNumber). if start is set
        % to 1, LED currents are set to zero and start pattern is called
        % to prevent the initial flash caused by the call.  If start is set
        % to 0, start pattern is called without modifying LED currents.  If
        % start is set to -1, start pattern is not called.
            if ~any(append == [0,1]) || ~any(start == [-1,0,1])
                % Check for appropriate arguments
                code = -1;
                return;
            end
            if bitDepth == 24  && all(size(ptns) == [684,1824]) % 1824 = 608*3
                % Check for appropriate arguments and pattern size
                if obj.displayMode == 1
                    code = polymex('SetDevDisplayMode',0,0);
                    if code == -1
                        return;
                    end
                    obj.displayMode = 0;
                end
                packed = packImg(ptns,24);
                code = polymex('SetDevBmp',0,bitDepth,packed);
            elseif any(bitDepth == [1,2,4,8]) && all(size(ptns(:,:,1)) == [684,608])
                % Check for appropriate arguments and pattern size
                num = size(ptns,3); % Number of patterns
                if num > 1000
                    code = -1;
                    return;
                end
                pps = obj.polyPtnSet;
                if append == 1
                    start = pps.PtnNumber + 1;
                    % update setting PtnNumber value
                    pps.PtnNumber = start + num - 1;
                else
                    start = 1;
                    % update setting PtnNumber value
                    pps.PtnNumber = num;
                end
                pps.bitDepth = bitDepth;
                % Upload new polyPtnSet to Polygon400
                settings = cell2mat(struct2cell(pps));
                code = polymex('SetDevPtnSetting',0,int32(settings));
                if code == -1
                    warndlg('SetDevPtnSetting failed');
                    return;
                end
                obj.polyPtnSet = pps;
                bytes = 684 * 608 /  (8 / bitDepth); % bytes for packed patterns
                PPB = zeros(bytes,1,'uint8'); % PPB - Packed Pattern Buffer
                for i = start:num+start-1 % Upload patterns
                    PPB(:) = obj.packImg(ptns(:,:,i+1-start),bitDepth);
                    code = polymex('SetDevPtnDef',0,i-1,bitDepth,PPB);
                    if code == -1
                        warndlg(['SetDevPtnDef failed at ',num2str(i)])
                        return;
                    end
                end
            else
                code = -1;
                return;
            end
            if start ~= -1
                if start == 1 % Turn off LEDs for dark start
                    polymex('SetDevLEDCurrent',0,0,0,0);
                end
                code = polymex('StartPattern',0);
                if code == -1
                    return;
                end
                % Restore or re-set LED currents, doesn't interrupt Polygon
                r = obj.LEDCurrent(1);
                g = obj.LEDCurrent(2);
                b = obj.LEDCurrent(3);
                polymex('SetDevLEDCurrent',0,r,g,b);
            end
        end
        
        % Delete function to ensure Polygon400 is properly released
        function delete(obj)
            if obj.connected == 1
                polymex('DisconnectDev',0);
                polymex('UnInitDevice');
                obj.connected = 0;
                clear Polygon400;
            end
        end
    end
end

