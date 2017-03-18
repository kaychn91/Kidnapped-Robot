function [number objects] = GetCamera(port, varargin)
% Reads Blobs from Vision Subsystem v4 for NXT (NXTCam-v4)
%
% Syntax
%   [number objects] = GetCam(port)
%
%   [number objects] = GetCam(port, handle)   
%
% Description
%   Number is the number of currently tracked lines/objects.
%   objects consists of one line of 5 numbers for any tracked in the form
%   [colour upper-left-X upper-left-Y lower-left-X lower-left-Y].
%
%   The given port number specifies the connection port. The value port can be
%   addressed by the symbolic constants SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to
%   the labeling on the NXT Brick.
%
% Note:
%
%   As factory default the cam lens is set for optimal focus between 2 and
%   4 feet (60-120 cm). The cam is shipped with a default colourmap to
%   track a light source (e.g. white LED-light) as objects. 
%   Tracking stops after 9 sec. without reading tracking information.
%

% 
%
% Example
%   OpenCam(SENSOR_2);
%   [num obj] = GetCam(SENSOR_2);
%   % get tracking info of 1st object
%   colour = obj(1,1);
%   upper = [obj(1,2) obj(1,3)];
%   lower = [obj(1,4) obj(1,4)];
%   CloseSensor(SENSOR_2);
%
% See also: OpenCamera, CloseSensor
%
% Signature
%   Author: Martin Broich, Rainer Schnitzler, Martin Staas
%   Date: 2012/10/29
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
    
    if (port < 0) || (port > 3)
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidPort', 'NXT sensor port must be between 0 and 3, port %d is invalid...', port);
    end%if    
    
    
%Camera Registers
% CAMADDR               0x02
% NXTCAM_REG_CMD        0x41
% NXTCAM_REG_COUNT      0x42
% NXTCAM_REG_DATA       0x43
   
%% Get Blob Count
    waitUntilI2CReady(port, handle);
    % read 1 byte from register 0x42
    number = COM_ReadI2C(port, 1, uint8(2), uint8(66));
    if(length(number) < 1)
        error('MATLAB:RWTHMindstormsNXT:Sensor:cameraerror', 'Camera error.');
    end
        
    if(number == 78) %Tracking not enabled properly (When does this happen???
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidMode', 'Camera sensor mode not set properly, please try to set it again.');
    end
    if(number < 0 || number > 8)
        number = 0;
    end
    objects = zeros(number,5);
    
%% Get Blobs
    for i = 1:number
        %read 5 bytes from register NXTCAM_REG_DATA+(i-1)*5
        reg = hex2dec('43') + (i-1)*5;
        objects(i,:) = COM_ReadI2C(port, 5, uint8(2), uint8(reg));
    end

    
    
end%function
