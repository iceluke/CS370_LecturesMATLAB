classdef MyFPSystem
    %MyFPSystem: Quadruple to represent a FP System
    %   Four integer parameters:
    %       - Beta (Base)
    %       - t (NbDigits)
    %       - L (lowest exponent value)
    %       - U (upper exponent value)
    %   For instance, IEEE Single corresponds to:
    %       {2, 24, -126, 127}
    
    properties
        NbDigits uint16
        Base int16
        ExponentLower int16
        ExponentUpper int16
    end
    
    methods
        function obj = MyFPSystem(nbDigits,base,lower,upper)
            obj.NbDigits = nbDigits;
            obj.Base = base;
            obj.ExponentLower = lower;
            obj.ExponentUpper = upper;
        end
    end
end

