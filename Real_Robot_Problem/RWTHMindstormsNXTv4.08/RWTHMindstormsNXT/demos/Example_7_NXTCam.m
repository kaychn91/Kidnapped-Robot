%% Example 7: NXTCam support
% Track Objects with the NXTCam
%
% This Example shows how you can use the Toolbox to Track Objects with the NXTCam
%
% Signature
%
% *  Author: Martin Staas
% *  Date: 2013/06/04
% *  License: BSD
% *  RWTH - Mindstorms NXT Toolbox: http://www.mindstorms.rwth-aachen.de

%% verify that the RWTH - Mindstorms NXT toolbox is installed.
if verLessThan('RWTHMindstormsNXT', '4.08');
    error(strcat('This program requires the RWTH - Mindstorms NXT Toolbox ' ...
        ,'version 4.08 or greater. Go to http://www.mindstorms.rwth-aachen.de '...
        ,'and follow the installation instructions!'));
end%if

%% Prepare
COM_CloseNXT all
close all
clear all

%% Connect to NXT via USB 
handle = COM_OpenNXT();
COM_SetDefaultNXT(handle);

%%Open the Camera
OpenCamera(SENSOR_1,'BLOBS');
pause(0.5);

%%Set params
frames 	= 0;
objectPos  = zeros(8,2);
thresh  = 100;
alpha   = 0.15;
tic;
colors  = ['r','g','b','y','m','c','b','r'];
markers = ['.','*','.','*','.','*','.','*'];
trackPoints   = zeros(20,2);
filtered = 0;

%%Run for 5000 Frames
 for j = 1:5000
        frames = frames + 1;%count Frames
        clf
        rectangle('Position',[0,0,250,250])%draw border
        hold on
        %%Get Objects from the Camera
        [nrObj obj] = GetCamera(SENSOR_1);

        %%Print general Information
        text(10,240,['\it{Nr. of Objects:}',int2str(nrObj)]) 
        text(10,230,['\it{Frame:}',int2str(j)]) 
        text(10,210,['\it{Filtered:}',int2str(filtered)]) 
    
        %%filter objects by size to reduce noise effects and get new Position
        filteredNr = 0;
        for i = 1:size(obj,1)  
            if(abs((obj(i,2)-obj(i,4))*(obj(i,3)-obj(i,5))) > thresh)
                idx = obj(i,1) + 1;
                objectPos(idx,:) = [(objectPos(idx,1)*(1-alpha) + ((obj(i,2) + obj(i,4))/2)*alpha) (objectPos(idx,2)*(1-alpha) + ((obj(i,3) + obj(i,5))/2)*alpha)];
            else
                filteredNr = filteredNr +1;
            end
        end%end for
        newPos = objectPos;
        trackPoints = [trackPoints(2:end,:);newPos(1,:)];
        filtered = filtered + filteredNr;

        %%plot Objects
        for i = 1:size(objectPos,1);
            if((objectPos(i,1) + objectPos(i,2)) > 0)
                plot(objectPos(i,1),143-objectPos(i,2),[colors(i) markers(i)],'MarkerSize',20)
            end
        end
        plot(trackPoints(:,1),143-trackPoints(:,2),'r-');
        hold off

        %%compute and plot FPS
        if(toc > 1)
            fps = frames/toc;
            text(10,220,['\it{FPS:}',int2str(uint8(fps))]) 
        end
        if(toc > 10)
            tic;
            frames = 0;
        end
         pause(0.01);
 end
%% Clean up
CloseSensor(SENSOR_1);
COM_CloseNXT('all');


