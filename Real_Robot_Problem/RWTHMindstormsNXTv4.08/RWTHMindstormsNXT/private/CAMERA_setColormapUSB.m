function CAMERA_setColormapUSB(camObj, colmap)
% Send the Colormap to the Camera
%
% Syntax
%   CAMERA_setColormapUSB(camObj, colmap)
%
% Description
%   This Function first disables Tracking, than build the command to send
%   the colormap and sens the colomap to the camera.
%   When finished Tracking is enabled again.
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


%disable Tracking
fprintf(camObj,'DT');
out = fscanf(camObj);
   if ~strcmpi(out(1:3),'ACK')
        error('MATLAB:RWTHMindstormsNXT:Sensor:disableTracking', 'Could not disable Tracking.');
   end
    
pause(0.5);

%build Command
cmd = 'SM';
[m,n] = size(colmap);
for cols = 1:n
    for rows = 1:m
        cmd = [cmd ' '];   
        cmd = [cmd dec2hex(colmap(rows,cols))];     
    end
end
%send colormap
 fprintf(camObj,cmd);
 out = fscanf(camObj);

if ~strcmpi(out(1:3),'ACK')
   error('MATLAB:RWTHMindstormsNXT:Sensor:senderoor', 'Could not send colormap to Camera.');
end

%enable Tracking
 fprintf(camObj,'ET');
out = fscanf(camObj);
   if ~strcmpi(out(1:3),'ACK')
        error('MATLAB:RWTHMindstormsNXT:Sensor:enableTracking', 'Could not enable Tracking.');
   end