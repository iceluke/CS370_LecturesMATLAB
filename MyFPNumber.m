classdef MyFPNumber
    %MYFPNUMBER: Number expressed in previously defined system
    %   
    
    properties
        Sign uint8
        Mantissa uint64
        Exponent uint64
        System MyFPSystem
    end
    
    methods
        function obj = MyFPNumber(real,system)
            obj.System = system;
            % %%%%%%%%%
            % From IEEE 754 double to its binary representation
            ieee = obj.myNum2bin(real);
            ieeeSign = bin2dec(ieee(1));
            % IEEE 754 has exponent bias to avoid sign bit 
            % = 2^(exponentbits-1)-1 (for double = 1023)
            % see https://en.wikipedia.org/wiki/Exponent_bias 
            ieeeExponent = bin2dec(ieee(2:12)) - 1023;
            % in IEEE754 the mantissa corresponds to 1.b0b1b2...bt
            ieeeMantissa = bin2dec(ieee(13:64));
            % %%%%%%%%%
            % Converting to the lecture's representation
            % Using uint64 for Exponent allows for incrementing it
            obj.Sign = ieeeSign; % sign does not change for now as we force positive base
            [obj.Mantissa,obj.Exponent] = obj.euclideanBaseChange(ieeeMantissa,ieeeExponent,obj.System.Base);
        end
    end
    
    methods (Access = private)
        function ieeeBinary = myNum2bin(obj,i) % MATLAB's num2bin is a paid extension
            % We are using multiple inbuilt conversions because...lazyness
            hexForm = num2cell(num2hex(i)); % cell array representation
            hexArray = cellfun(@hex2dec, hexForm, 'UniformOutput',false); % back to dec array
            binArray = cellfun(@dec2bin, hexArray, 'UniformOutput',false);  % into binary representation
            % IEEE 754 double precision is 64 bits long, padding if
            % necessary
            binArray = cellfun(@obj.binaryBytePadding, binArray, 'UniformOutput',false);
            ieeeBinary = strcat(cell2mat(binArray));
        end
        function b = binaryBytePadding(obj,x) %Makes sure a byte is padded by 4 zeros
            b = pad(x,4,'left','0');
        end
        function euclideanBaseChange(obj,mantissa,exponent,destBase)
            % TODO
        end
    end
end

