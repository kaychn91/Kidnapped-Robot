function CAMERA_SetColormap(port, colmap, varargin)
% Sets the Colormap of the NXTCam on given Port
%
% Syntax
%   CAMERA_SetColormap(port, colormap) 
%
%   CAMERA_SetColormap(port, colormap, handle) 
%
% Description
%   CAMERA_SetColormap(port, colormap)  sets the bit coded colormap of
%   NXTCam to 'colormap'. The Colormap consist of 48 byte.
%   Each of RGB Color is assigned 16 bytes for that color and every bit 
%   show if the Object number should contain that Color.
%   Each 16 color Bytes represent absolute color value ranges.
%   The first Byte of Red has the Range from 0 to 15, if we want to Track
%   an Object that has this Color Value we can set the appropiate bit (0-7)
%   to one.
%
%   Note:
%       If you want to know about how exactly colormaps work have a look 
%       at the documentation of your NXTCam or the Colormap Reference which
%       both can be found at: http://www.mindsensors.com/
%
%
% Example
%
%  OpenCamera(SENSOR_1);
%  colormap = CAMERA_GetColormap(SENSOR_1);
%  colormap(1,1) = 1; %set first Bit of Red 0 - 15
%  CAMERA_SetColormap(SENSOR_1, colormap);
%  CloseSensor(SENSOR_1);
%
% See also: OpenCamera, CAMERA_GetColormap, CloseSensor
%
% Signature
%   Author: Martin Staas
%   Date: 2012/10/30
%   Copyright: 2007-2013, RWTH Aachen University
%
%
% ***********************************************************************************************
% *  This file is part of the RWTH - Mindstorms NXT Toolbox.                                    *
% *                                                                                             *
% *  The RWTH - Mindstorms NXT Toolbox is free software: you can redistribute it and/or modify  *
% *  it under the terms of the GNU General Public License as published by the Free Software     *
% *  Foundation, either version 3 of the License, or (at your option) any later version.        *
% *                                                                                             *
% *  The RWTH - Mindstorms NXT Toolbox is distributed in the hope that it will be useful,       *
% *  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS  *
% *  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.             *
% *                                                                                             *
% *  You should have received a copy of the GNU General Public License along with the           *
% *  RWTH - Mindstorms NXT Toolbox. If not, see <http://www.gnu.org/licenses/>.                 *
% ***********************************************************************************************

%% Parameter check

    % check if handle is given; if not use default one
    if nargin > 2
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if
    
    % also accept strings as input
    if ischar(port)
        port = str2double(port);
    end%if
    
    %check Dimension
    colSize = size(colmap);
    if (colSize(1) ~= 8 || colSize(2) ~= 6)
        return
    end

    %check values
    if(max(max(colmap)) > 255 || min(min(colmap)) < 0)
        return
    end
    %disable Tracking first (0x44 = 'D')
    I2Cdata = hex2dec(['02'; '41'; '44']);
    NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle); 
    waitUntilI2CReady(port, handle);
    %% Write Data
    %write colormap to Register 0x80 - 0xAF
    for i = 1:6
        reg = 128 + (i-1)*8;
        hexreg = dec2hex(reg);
        val1 = dec2hex(colmap(1,i),2);
        val2 = dec2hex(colmap(2,i),2);
        val3 = dec2hex(colmap(3,i),2);
        val4 = dec2hex(colmap(4,i),2);
        val5 = dec2hex(colmap(5,i),2);
        val6 = dec2hex(colmap(6,i),2);
        val7 = dec2hex(colmap(7,i),2);
        val8 = dec2hex(colmap(8,i),2);
        I2Cdata = hex2dec(['02'; hexreg; val1; val2; val3; val4; val5; val6; val7; val8]);
        NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle);
        waitUntilI2CReady(port, handle);
        pause(0.2); %needed to prevent that some bits are skipped
    end
    
    %% Send Data
    % Send 'Send the color map to NXTCam Engine' Command ('S',0x53)
    I2Cdata = hex2dec(['02'; '41'; '53']);
    NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle);    
    waitUntilI2CReady(port, handle);
    %enable Tracking again (0x45 = 'E')
    I2Cdata = hex2dec(['02'; '41'; '45']);
    NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle); 
    waitUntilI2CReady(port, handle);
    
    
    