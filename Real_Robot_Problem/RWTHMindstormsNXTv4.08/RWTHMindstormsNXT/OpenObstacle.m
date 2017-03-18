function OpenObstacle(f_sensorport, f_mode, varargin)
% Initializes the NXT Dual Range, Triple Zone Infrared Obstacle sensor, sets correct sensor mode
% (Sensor is also called NXTSumoEyes-v2)
%
% Syntax
%   OpenObstacle(port, mode)
%
%   OpenObstacle(port, mode, handle)
%
% Description
%   OpenObstacle(port, mode) initializes the input mode of NXT obstacle sensor specified by the sensor
%   port and the Range mode. The value port can be addressed by the symbolic constants
%   SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick. The
%   mode represents one of two modes 'SHORT' (for Ranges up to 15 cm) and 'LONG'
%   (for Ranges up to 30 cm). 
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Example
%   OpenObstacle(SENSOR_1, 'ACTIVE');
%   direction = GetObstacle(SENSOR_1);
%   CloseSensor(SENSOR_1);
%
% See also: CloseSensor, GetObstacle, OpenNXT2Color, GetNXT2Color, NXT_SetInputMode, SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4
%
% Signature
%   Author: Martin Staas (see AUTHORS)
%   Date: 2012/10/22
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

%% Check Parameter
    % check if handle is given; if not use default one
    if nargin > 2
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if
    
    if ~strcmpi(f_mode, 'SHORT') && ~strcmpi(f_mode, 'LONG')
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidMode', 'Obstacle sensor mode has to be ''SHORT'' or ''LONG''');
    end
    
    %Translate from SHORT and LONG to ACTIVE and INACTIVE
    if strcmpi(f_mode,'SHORT')
        f_mode = 'ACTIVE';
    end
    if strcmpi(f_mode,'LONG')
        f_mode = 'INACTIVE';
    end

    
    % also accept strings as input
    if ischar(f_sensorport)
        f_sensorport = str2double(f_sensorport);
    end%if

    % invalid sensorport will be catched by NXT_ function

%% Set correct variables (Obstacle sensore is handled like Light sensor)
    f_mode = upper(f_mode);
    sensortype = ['LIGHT_' f_mode]; % switch sensor
    sensormode = 'RAWMODE'; % raw Mode
    
%% Call NXT_SetInputMode function
    NXT_SetInputMode(f_sensorport, sensortype, sensormode, 'dontreply', handle); 

end%function
