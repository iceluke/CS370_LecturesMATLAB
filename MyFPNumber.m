classdef MyFPNumber
    %MYFPNUMBER: Number expressed in previously defined system
    %   
    
    properties
        DoubleVal
        IEEESign
        IEEEExponent
        IEEEMantissa
        IEEEBinMantissa
        System MyFPSystem
        Sign uint8
        Mantissa uint64
        Exponent uint64
    end
    
    methods
        function obj = MyFPNumber(real,system)
            obj.DoubleVal = real;
            obj.System = system;
            % %%%%%%%%%
            % From IEEE 754 double to its binary representation
            ieee = obj.myNum2bin(real);
            obj.IEEESign = bin2dec(ieee(1));
            % IEEE 754 has exponent bias to avoid sign bit 
            % = 2^(exponentbits-1)-1 (for double = 1023)
            % see https://en.wikipedia.org/wiki/Exponent_bias 
            obj.IEEEExponent = bin2dec(ieee(2:12)) - 1023;
            % in IEEE754 the mantissa corresponds to 1.b0b1b2...bt
            obj.IEEEBinMantissa = ieee(13:64);
            obj.IEEEMantissa = bin2dec(ieee(13:64));
            % %%%%%%%%%
            % Converting to the lecture's representation in custom system
            % Using uint64 for Exponent allows for incrementing it
            obj.Sign = obj.IEEESign; % sign does not change for now as we force positive base
            % Building temporary mantissa and exponent that we will
            % constrain to length afterwards
            [obj.Exponent, obj.Mantissa] = obj.euclideanBaseChange();
        end
    end
    
    methods (Access = private)
        function binaryForm = myNum2bin(obj,i) % MATLAB's num2bin is a paid extension
            % We are using multiple inbuilt conversions because...lazyness
            hexForm = num2cell(num2hex(i)); % cell array representation
            hexArray = cellfun(@hex2dec, hexForm, 'UniformOutput',false); % back to dec array
            binArray = cellfun(@dec2bin, hexArray, 'UniformOutput',false);  % into binary representation
            binArray = cellfun(@obj.binaryBytePadding, binArray, 'UniformOutput',false); % byte padding
            binaryForm = strcat(cell2mat(binArray));
        end
        function b = binaryBytePadding(~,x) %Makes sure a byte is padded by 4 zeros
            b = pad(x,4,'left','0');
        end
        function [e,m] = euclideanBaseChange(obj)
            % We build a destination polynomial, index i holding the
            % coefficient for decrementing exponent values of the base
            % Adding more size in the lower side to prepare for the rounding bias
            intWorkingNumber = floor(obj.DoubleVal);
            flWorkingNumber = obj.DoubleVal-intWorkingNumber; % this is where we risk losing info
            maxRange = abs(obj.System.ExponentLower-obj.System.ExponentUpper);
            % Destination Series
            intDestCoefficients = [];
            flDestCoefficients = [];
            % ED Integer Part
            while true
               quotient = floor(intWorkingNumber./obj.System.Base);
               remainder = mod(intWorkingNumber,obj.System.Base);
               intWorkingNumber = quotient;
               intDestCoefficients = horzcat(remainder,intDestCoefficients);
               if quotient==0, break; end
            end
            % ED Float Part (TODO: bring int/float into 1 function?)
            % This part does not always terminate, so we limit
            maxFloatRange = maxRange + obj.System.RoundingBias;
            i = 1;
            while true
                multiplied = flWorkingNumber * obj.System.Base;
                intPart = floor(multiplied);
                flPart = multiplied - intPart;
                flWorkingNumber = flPart;
                flDestCoefficients = horzcat(flDestCoefficients,intPart);
                i = i +1;
                if i==maxFloatRange, break; end
                if flPart==0, break; end
            end
            % We can guess the exponent
            % the leading coeff has exponent e-1 but we'll divide by base in order to obtain a 0.d1d2d3 term
            e = length(intDestCoefficients);
            m = horzcat(intDestCoefficients,flDestCoefficients); % truncating for now
            m = m(1:maxRange);
        end
    end
end
