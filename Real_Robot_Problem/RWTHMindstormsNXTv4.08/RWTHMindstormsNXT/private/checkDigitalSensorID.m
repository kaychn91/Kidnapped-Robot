function result = checkDigitalSensorID(port, vendorID, vendorRegister, sensorID, sensorRegister, varargin)
% Check the Vendor and SensorID of an I2C Sensor
%
% Syntax
%   result = checkDigitalSensorID(port, vendorID, vendorRegister, 
%               sensorID, sensorRegister)
%   result = checkDigitalSensorID(port, vendorID, vendorRegister,
%               sensorID, sensorRegister, DeviceAddress)
%   result = checkDigitalSensorID(port, vendorID, vendorRegister, 
%               sensorID, sensorRegister, DeviceAddress, NxtHandle)
%
% Description
%   Checks if the Vendor String at 'vendorRegister' of the Sensor Matches
%   the 'vendorID' and checks if the Sensor String at 'sensorRegister' of the Sensor Matches
%   the 'sensorID'.
%   The last argument defines the 'DeviceAddress', the default Value is
%   '2'.
%   'result' is '0' if no Error occured, '-1' if the VendorID is wrong and
%   '-2' if SensorID or VendorID and SensorID are wrong.
%   If a warning should be displayed has to be decided seperatly for every
%   Sensor because e.g. different Version of Sensors might have different
%   SensorIDs.
%
% See also: DigitalSensorCheck
%
% Signature
%   Author: Martin Staas (see AUTHORS)
%   Date: 2013/01/08
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



%% Parameter Check
%check if Device Adress is given
    if nargin > 5
        deviceAdress = uint8(varargin{1});
    else
        deviceAdress = uint8(2);
    end%if
 
%check if Handle is given
    if nargin > 6
        handle = varargin{2};
    else
        handle = COM_GetDefaultNXT;
    end%if
    
% also accept strings as input
    if ischar(port)
        port = str2double(port);
    end%if
    
% get length
   venLength = size(vendorID,2);
   senLength = size(sensorID,2);

%% get IDs
% read Registers
   venID = COM_ReadI2C(port, venLength, deviceAdress, vendorRegister, handle);
   senID = COM_ReadI2C(port, senLength, deviceAdress, sensorRegister, handle);
   
% convert to String
   venID = strtrim(char(venID'));
   senID = strtrim(char(senID'));
   result = 0;

%% Check IDs
% Check VendorID
   if ~strcmp(vendorID, venID)
    result = -1;
   end%if
   
% Check SensorID   
   if ~strcmp(sensorID, senID)
    result = -2;
   end%if
    
end