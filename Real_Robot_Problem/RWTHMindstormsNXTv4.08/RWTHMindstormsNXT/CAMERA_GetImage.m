function image = CAMERA_GetImage(com)
% Returns an Image from the NXTCam

%
% Syntax
%   image = CAMERA_GetImage(port) 
%
%   image = CAMERA_GetImage(port, handle) 
%
% Description
%   Returns an Image from the Vision Subsystem v4 for NXT (NXTCam-v4)
%
%       
% Note:
% The camera has to be connected directly via USB!
%
% Example
%
%  image = CAMERA_GetImage(SENSOR_1);
%
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
    %%% Get image via Serial port, see: serial, fopen, fclose, fread, fprintf 
    %open serial Port
    CAMERA_connectToCameraUSB(com);
    try
    image = CAMERA_DumpFrame(s);
    fclose(s);
    catch err
        fclose(s);
        error('MATLAB:RWTHMindstormsNXT:Sensor:unknown', 'An unknown Error occured while fetching the image. Please check that the Camera is connected and try again');
    end

    
    
    