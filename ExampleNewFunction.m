function out = ExampleNewFunction(varargin)
if ischar(varargin{1})
    out{1} = 'Empty Example New Function';
    out{2} = 2;
else
    out = [];
    disp('You ran the Empty Example New Function');
    disp(varargin{3})
    dsip(varargin{4})
end