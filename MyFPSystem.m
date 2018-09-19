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
            if ~(base>0) % TODO: implement support for negative bases
                         % would just have to take care of sign bit
                disp('Base must be positive')
                return
            end
            obj.Base = base;
            % Exponent bounds are by default casted to integer
            % TODO: bind them to abs(bound) < abs(IEEE)-5
            % So that we have room for rounding with 5 digits freedom
            obj.ExponentLower = uint16(lower);
            obj.ExponentUpper = uint16(upper);
        end
    end
end

