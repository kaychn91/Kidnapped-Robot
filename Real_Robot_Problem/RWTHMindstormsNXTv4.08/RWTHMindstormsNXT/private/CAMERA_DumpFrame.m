function im = CAMERA_DumpFrame(s)
% Fetches a Frame from the Camera
%
% Syntax
%   im = CAMERA_DumpFrame(s)
%
% Description
%   Sends a DumpFrame command to the Camera and computes the incoming data
%   packets. Afterwards the so build Bayer Image is converted to RGB Space.
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

    %%% WriteCommand: 'DF\r' dump frame
    fprintf(s,'DF');
    out = fscanf(s);

    if ~strcmpi(out(1:3),'ACK')
        error('MATLAB:RWTHMindstormsNXT:Sensor:disableTracking', 'Could not disable Tracking');
    end
    
    %prepare Image 176x144 Pixel in Bayer Pattern
    bayerImage = zeros(144,176);

    %%% Read 72 packets with 173 Pixels + 2 Bytes (0x0B , Line Number)
    %%%   High nibble: Green pixel value of the even rows
    %%%   Low nibble: Red or Blue pixel value of the odd rows
    for i = 1:72
        %Read
        linepair = [];
        linepair = fread(s,179,'uchar');
        
        hex = dec2hex(linepair);
        %%% Arrange in 'grbg' Matrix 
        %get Line number
        line = hex2dec(hex(2,:))*2;
        
        %add 2 Lines to Bayer Image
        for j = 1:176
            bayerImage(line+1,j) =   uint8(hex2dec(hex(j,1)))*16;
            bayerImage(line+2,j) =   uint8(hex2dec(hex(j,2)))*16;
        end
        

    end
    
    %%% demosaic
    im = demosaic(uint8(bayerImage),'grbg');