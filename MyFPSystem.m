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
        NbDigits 
        Base 
        ExponentLower 
        ExponentUpper 
        % ASK: Redundant to define lower and upper?
        RoundingBias
    end
    
    methods
        function obj = MyFPSystem(nbDigits,base,lower,upper,bias)
            obj.NbDigits = nbDigits;
            if ~(base>0) % TODO: implement support for negative bases
                disp('Base must be positive')
                return
            end
            obj.Base = base;
            if ~(bias>0)
                disp('Bias must be positive')
                return
            end
            obj.RoundingBias = bias;
            % Exponent bounds are by default casted to integer
            % TODO: bind them to abs(bound) < abs(IEEE)-5
            % So that we have room for rounding with 5 digits freedom
            obj.ExponentLower = lower;
            obj.ExponentUpper = upper;
        end
    end
end
