function OpenCamera(port, mode, varargin)
% Initializes the Vision Subsystem v4 for NXT (NXTCam-v4)
%
% Syntax
%   status = OpenCamera(port, mode)
%
% Description
%   OpenCamera(port, mode) initializes the camera on Port
%   SENSOR_1, SENSOR_2, SENSOR_3 and SENSOR_4 analog to the labeling on the NXT Brick.
%   Mode can be set to "BLOBS" to Track up to 8 different coloured Objects
%   or to "LINE" to Track a Line.
%   
%
% Example
%   OpenCamera(SENSOR_2, "BLOBS");
%   objects[] = GetCamera(SENSOR_2)
%   CloseSensor(SENSOR_2);
%
% See also: GetCamera, CloseSensor
%
% Signature
%   Author: Martin Staas (see AUTHORS)
%   Date: 2012/10/23
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
        handle = varargin{2};
    else
        handle = COM_GetDefaultNXT;
    end%if
    
    % also accept strings as input
    if ischar(port)
        port = str2double(port);
    end%if
    
    if ~strcmpi(mode, 'BLOBS') && ~strcmpi(mode, 'LINE')
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidMode', 'Camera sensor mode has to be ''BLOBS'' or ''LINE''');
    end

%% Set sensor mode    
    NXT_SetInputMode(port, 'LOWSPEED', 'RAWMODE', 'dontreply', handle);

    
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

    
    % CAMADDR               0x02
    % NXTCAM_REG_CMD        0x41
    % NXTCAM_REG_COUNT      0x42
    % NXTCAM_REG_DATA       0x43
    
%% Boot the sensor
    % request nothing, initialize Camera with disabled Tracking ('D' 0x44 )
    I2Cdata = hex2dec(['02'; '41'; '44']);
    NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle);    
    
    waitUntilI2CReady(port, handle);
    
    %check SensorID
    %|result = checkDigitalSensorID(port, vendorID, vendorRegister, 
    %               sensorID, sensorRegister, DeviceAddress, NxtHandle)|
    result   = checkDigitalSensorID(port,'mndsnsrs',8,'NXTCAM',16,2,handle);
    if result == -1
       warning('MATLAB:RWTHMindstormsNXT:Sensor:WrongVendorID', ...
            ['VendorID is not Matching!'...
            'It seems like your are trying to open a wrong Sensor' ...
               'Please check if the right Sensor is attached an try again.']);
        return;
    elseif result == -2
       warning('MATLAB:RWTHMindstormsNXT:Sensor:WrongSensorID', ...
        ['SensorID ist not matching!'...
        'It seems that your are trying to open a wrong Sensor' ...
           'Please check if the right Sensor is attached an try again.']);
        return;
    end
    
    if strcmpi(mode, 'LINE')
        %% Set to Line mode
        % request nothing, set to LINE mode ('L' 0x4C )
        I2Cdata = hex2dec(['02'; '41'; '4C']);
        NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle)
        
        %% Do not Sort
        % request nothing, set 'do not sort' ('X' 0x58 )
        waitUntilI2CReady(port, handle);
        I2Cdata = hex2dec(['02'; '41'; '58']);
        NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle);
    else
        %% Set to BLOB mode
        % request nothing, set to BLOB mode ('B' 0x42 )
        I2Cdata = hex2dec(['02'; '41'; '42']);
        NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle)
        
        %% Sort by Color
        % request nothing, set 'sort by color' ('U' 0x55 )
        waitUntilI2CReady(port, handle);
        I2Cdata = hex2dec(['02'; '41'; '55']);
        NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle);
    end
    
   %% Enable Tracking
   % request nothing, initialize  Tracking ('E' 0x45 )
   waitUntilI2CReady(port, handle);
   I2Cdata = hex2dec(['02'; '41'; '45']);
   NXT_LSWrite(port, 0, I2Cdata, 'dontreply', handle);
   pause(1); %wait for Camera to start tracking   
end%function

