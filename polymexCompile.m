function polymexCompile()
a = ~exist('MT_Polygon400_SDK.dll','file');
b = ~exist('MT_Polygon400_SDK.h','file');
c = ~exist('MT_Polygon400_SDK.lib','file');
d = ~exist('polymex.cpp','file');

if any([a,b,c,d])
    disp('File(s) Not Found:')
    if a
        disp('MT_Polygon400_SDK.dll');
    end
    if b
        disp('MT_Polygon400_SDK.h');
    end
    if c
        disp('MT_Polygon400_SDK.lib');
    end
    if d
        disp('polymex.cpp');
    end
    return;
end

mex -lMT_Polygon400_SDK polymex.cpp