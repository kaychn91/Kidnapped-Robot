function zone = GetObstacle(port, varargin)
% Reads the current value of the Dual Range, Triple Zone Infrared Obstacle Detector for NXT (NXTSumoEyes-v2)
%
% Syntax
%   direction = GetObstacle(port)
%
%   direction = GetObstacle(port, handle)
%
% Description
%   direction = GetObstacle(port) returns a Number from 0 to 3 which
%   represent the three Zones where an Object can be detected.
%   2 means the left, 1 the center and 3 the right Zone and 0 means no
%   Obstacle found.
%   The given port number specifies the connection port. The value port can be
%   addressed by the symbolic constants SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to
%   the labeling on the NXT Brick.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Examples
%   OpenObstacle(SENSOR_1, 'ACTIVE');
%   zone = GetObstacle(SENSOR_1);
%   CloseSensor(SENSOR_1);
%
% Note: 
% (from the official documentation)
% This distance of the Ranges changes based on NXT battery power
% and load on the batteries (such as running/stalled motors) at the
% time of reading and reflectivity of the obstacle, e.g. a white paper
% obstacle is detectable at a farther distance than a dark object.
% Detection range of very dark objects is reduced considerably (to
% half or third).
%
% See also: OpenObstacle, CloseSensor, NXT_GetInputValues, SENSOR_1, SENSOR_2, SENSOR_3, SENSOR_4
%
% Signature
%   Author: Rainer Schnitzler, Martin Staas (see AUTHORS)
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

%% check if handle is given; if not use default one
    if nargin > 1
        handle = varargin{1};
    else
        handle = COM_GetDefaultNXT;
    end%if
    
%% Call NXT_GetInputValues function
    in = NXT_GetInputValues(port, handle);

%% Check valid-flag, re-request data if necessary
    if ~in.Valid
        % init timeout-counter
        startTime = clock();
        timeOut = 0.3; % in seconds
        % loop until valid
        while (~in.Valid) && (etime(clock, startTime) < timeOut)
            in = NXT_GetInputValues(port, handle);
        end%while
        % check if everything is ok now...
        if ~in.Valid
            warning('MATLAB:RWTHMindstormsNXT:Sensor:invalidData', ...
                   ['Returned sensor data marked invalid! ' ...
                    'Make sure the sensor is properly connected and configured to a supported mode. ' ...
                    'Disable this warning by calling  warning(''off'', ''MATLAB:RWTHMindstormsNXT:Sensor:invalidData'')']);
        end%if
    end%if
    
%% Return Zone
    value = double(in.RawADVal);
    
    if value == 1023 %no obstacle
        zone = 0;
    elseif (value > 300 && value < 400) %Center
        zone = 1;
    elseif (value > 600) %Left
        zone = 2;
    else
        zone = 3; % Right
    end
    
    
% 	    value = (in.NormalizedADVal)*100 / 1023;
% 	    if(value > 30 && value < 36)%left
% 	        direction = 0;
% 	    elseif(value > 63 && value < 69)%right
% 	        direction = 2;
% 	    elseif(value > 74 && value < 80)%center
% 	        direction = 1;
%       else %no obstacle
%            direction = 0;
% 	    end
% 	end  
end    
    