function colmap = CAMERA_GetColormap(port, varargin)
% Returns the Colormap of the NXTCam at a given Port
%
% Syntax
%   colormap = CAMERA_GetColormap(port) 
%
%   colormap = CAMERA_GetColormap(port, handle) 
%
% Description
%   colormap = CAMERA_GetColormap(port)  returns the bit codec colormap
%   that is currently set in the NXTCam. The Colormap consist of 48 byte.
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
%  CloseSensor(SENSOR_1);
%
% See also: OpenCamera, CAMERA_SetColormap, CloseSensor
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
    if nargin > 1
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if
    
    % also accept strings as input
    if ischar(port)
        port = str2double(port);
    end%if
    
    %% Request Data
    % Send 'Get the Color map from NXTCam Engine' Command ('G',0x47)
    I2Cdata = hex2dec(['02'; '41'; '47']);
    NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle);    
    
    waitUntilI2CReady(port, handle);
    pause(0.5);
    %% Read Data
    %read 48 bytes from register 0x80
    colmap = [];
    for i = 1:6
        reg = 128 + (i-1)*8;
        buf = COM_ReadI2C(port, 8, uint8(2), uint8(reg));
        colmap = [colmap buf];
    end
    
    
    