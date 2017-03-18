  function s = CAMERA_connectToCameraUSB(com) 
% Connects to the NXTCam over USB
%
% Syntax
%   s = CAMERA_connectToCameraUSB(port) 
%
% Description
%   Connects to the NXTCam over USB and takes care of the configuration of
%   the virtual serial port.
%
% Signature
%   Author: Martin Staas (see AUTHORS)
%   Date: 2012/12/06
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

%create serial object
s = serial(com);

%settings
s.BaudRate = 115200;
s.DataBits = 8;
s.StopBits = 1;
s.Terminator = 'CR';
s.InputBufferSize =  200;

%open the connection
fopen(s);

try
    %Ping Camera
    fprintf(s,'PG');
    out = fscanf(s);
    
    %has this worked?
    if ~strcmpi(out(1:3),'ACK')
        error('MATLAB:RWTHMindstormsNXT:Sensor:invalidMode', 'Could not Ping the Camera, please make sure it is connected to correct com port');
    end
catch err
    %close connection in case of error
    fclose(s); 
    error('MATLAB:RWTHMindstormsNXT:Sensor:unknown', 'An unknown Error occured while fetching the image. Please check that the Camera is connected and try again');
end