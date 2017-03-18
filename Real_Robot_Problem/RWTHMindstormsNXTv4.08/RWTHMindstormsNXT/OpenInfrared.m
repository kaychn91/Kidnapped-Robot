function OpenInfrared(port, varargin)
% Initializes the HiTechnic infrared seeker sensor, sets correct sensor mode
%
% Syntax
%   OpenInfrared(port)
%
%   OpenInfrared(port, handle)
%
% Description
%   OpenInfrared(port) initializes the input mode of HiTechnic infrared seeker sensor specified by the sensor
%   port. The value port can be addressed by the symbolic constants
%   SENSOR_1 , SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick.
%
%   The last optional argument can be a valid NXT handle. If none is
%   specified, the default handle will be used (call COM_SetDefaultNXT to
%   set one).
%
% Examples
%   OpenInfrared(SENSOR_4);
%   [direction rawData] = GetInfrared(SENSOR_4);
%   CloseSensor(SENSOR_4);
%
% See also: GetInfrared, CloseSensor, NXT_LSGetStatus, NXT_LSRead
%
% Signature
%   Author: Linus Atorf, Martin Staas (see AUTHORS)
%   Date: 2008/09/25
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
    
    NXT_SetInputMode(port, 'LOWSPEED_9V', 'RAWMODE', 'dontreply', handle);
    pause(0.1); % let sensor "power up"...
    
    %check SensorID
    %|result = checkDigitalSensorID(port, vendorID, vendorRegister, 
    %               sensorID, sensorRegister, DeviceAddress, NxtHandle)|
    result   = checkDigitalSensorID(port,'HiTechnc',8,'IR',16,2,handle);
    
    if result == -1
        
       warning('MATLAB:RWTHMindstormsNXT:Sensor:WrongVendorID', ...
            ['VendorID is not Matching!'...
            'It seems like your are trying to open a wrong Sensor' ...
               'Please check if the right Sensor is attached an try again.']);
    elseif result == -2
        result2   =checkDigitalSensorID(port,'HiTechnc',8,'NewIR',16,16,handle);
        if result2 == 0
            handle.IRSensorVersion(port,1);
        end
        
        if result2 == -1
        warning('MATLAB:RWTHMindstormsNXT:Sensor:WrongVendorID', ...
            ['VendorID is not Matching!'...
            'It seems like your are trying to open a wrong Sensor' ...
               'Please check if the right Sensor is attached an try again.']);
        elseif result2 == -2
        warning('MATLAB:RWTHMindstormsNXT:Sensor:WrongSensorID', ...
        ['SensorID ist not matching!'...
        'It seems that your are trying to open a wrong Sensor' ...
           'Please check if the right Sensor is attached an try again.']);
        end
    end   
% %% Build hex command and send it with NXT_LSWrite   
%     %----------------------------------------------------------------------
%     % (see LEGO Mindstorms NXT Ultrasonic Sensor - I2C Communication Protocol)
%     
%     RequestLen = 0; % -> No reply expected
% 
%     I2Cdata(1) = hex2dec('02'); % the default I2C address for a port. 
%     I2Cdata(2) = hex2dec('41'); % STATE_COMMAND
%     I2Cdata(3) = hex2dec('02'); % CONTINUOUS_MEASUREMENT
% 
%     NXT_LSWrite(port, RequestLen, I2Cdata, 'dontreply');
%     
    %--------------------------------------------------------------------
    
%% Flushing data memory (unkown procedure)
    % the following command sequence is not clearly documented but was
    % found to work well!
	NXT_LSGetStatus(port, handle); % flush out data with Poll
    % we request the status-byte so that it doesn't get checked.
    % errors that can occur here are:
    %Packet (reply to LSREAD) contains error message 221: "Communication bus error"
    %Packet (reply to LSREAD) contains error message 224: "Specified
    %channel/connection not configured or busy"
	[a b c] = NXT_LSRead(port, handle);      % flush out data with Poll?
end
