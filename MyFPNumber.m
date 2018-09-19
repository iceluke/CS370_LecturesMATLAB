classdef MyFPNumber
    %MYFPNUMBER: Number expressed in previously defined system
    %   
    
    properties
        DoubleVal
        IEEESign
        IEEEExponent
        IEEEMantissa
        Sign uint8
        Mantissa uint64
        Exponent uint64
        System MyFPSystem
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
            obj.IEEEMantissa = bin2dec(ieee(13:64));
            % %%%%%%%%%
            % Converting to the lecture's representation in custom system
            % Using uint64 for Exponent allows for incrementing it
            obj.Sign = obj.IEEESign; % sign does not change for now as we force positive base
            % Building temporary mantissa and exponent that we will
            % constrain to length afterwards
            [obj.Mantissa,obj.Exponent] = obj.euclideanBaseChange();
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
        function [m,e] = euclideanBaseChange(obj)
            % We build a destination polynomial, index i holding the
            % coefficient for decrementing exponent values of the base
            % Adding more size in the lower side to prepare for the rounding bias
            
            workingNumber = obj.DoubleVal;
            % Basic Euclidean Division
            workingExp = obj.System.ExponentUpper;
            range = abs(obj.System.ExponentUpper-obj.System.ExponentLower)
            range = range + obj.System.RoundingBias
            destCoefficients = zeros(1,range);
            for c = 1:range
                % This is very rough for now, using doubles everywhere
                % #evil Euclidean Division Error here
                divisor = exp(double(workingExp * log(double(obj.System.Base)))) % WARNING Probably wrong with float exp error...
                quotient = floor(workingNumber./divisor)
                workingNumber = mod(workingNumber,divisor) % working number becomes remainder
                destCoefficients(c) = quotient
                workingExp = workingExp - 1;
            end
            % Now need to find the first non-zero coefficient
            % Its index will correspond to the biggest exponent value
            firstNonZero = find(destCoefficients,1);
            largestNonZeroCoeff = obj.System.ExponentUpper - firstNonZero;
            % We can create a temporary mantissa (in our system it is
            % 0.d1d2d3...dn )
            m = destCoefficients(firstNonZero:length(destCoefficients));
            % And a temporary exponent
            e = largestNonZeroCoeff + 1; % to compensate for the division by base implied by mantissa starting with zero
        end
    end
end

