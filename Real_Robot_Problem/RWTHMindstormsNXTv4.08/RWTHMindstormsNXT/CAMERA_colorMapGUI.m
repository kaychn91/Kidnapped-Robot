function varargout = CAMERA_colorMapGUI(varargin)
% GUI to create and save a colormap for the NXTCam
%
% Signature
%   Author: Martin Staas (see AUTHORS)
%   Date: 2012/12/06
%   Copyright: 2007-2013, RWTH Aachen University
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

% Last Modified by GUIDE v2.5 06-Dec-2012 16:41:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CAMERA_colorMapGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @CAMERA_colorMapGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before CAMERA_colorMapGUI is made visible.
function CAMERA_colorMapGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CAMERA_colorMapGUI (see VARARGIN)

% Choose default command line output for CAMERA_colorMapGUI
handles.output = hObject;
im = zeros(419,614);
imshow(im);
handles.rect = imrect(handles.axisImage,[10,10,10,10]);
handles.image = im;
handles.selectedColor = 1;
handles.colormap = cell(8,1);
handles.cameraConnected = 0;
for i = 1:8
    handles.colormap{i} = zeros(8,6);
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CAMERA_colorMapGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CAMERA_colorMapGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see guidata)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbuttonAddRegion.
function pushbuttonAddRegion_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonAddRegion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = guidata(hObject);
data.position = getPosition(data.rect);
rectangle('Position',data.position,...
          'EdgeColor','c',...
         'LineWidth',2,'LineStyle','--')
guidata(hObject,data);
getColors(hObject);


% --- Executes on button press in pushbuttonLoadFromCamera.
function pushbuttonLoadFromCamera_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonLoadFromCamera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loadColormap(hObject);

% --- Executes on button press in pushbuttonSave2Camera.
function pushbuttonSave2Camera_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSave2Camera (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveColormap(hObject);

% --- Executes on selection change in listboxRed.
function listboxRed_Callback(hObject, eventdata, handles)
% hObject    handle to listboxRed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxRed contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxRed


% --- Executes during object creation, after setting all properties.
function listboxRed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxRed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listboxGreen.
function listboxGreen_Callback(hObject, eventdata, handles)
% hObject    handle to listboxGreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxGreen contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxGreen


% --- Executes during object creation, after setting all properties.
function listboxGreen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxGreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listboxBlue.
function listboxBlue_Callback(hObject, eventdata, handles)
% hObject    handle to listboxBlue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listboxBlue contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxBlue


% --- Executes during object creation, after setting all properties.
function listboxBlue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxBlue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
val = get(hObject,'Value');
data = guidata(hObject);
imshow(data.image);
data.rect = imrect(data.axisImage,[10,10,20,20]);
data.selectedColor = val;
guidata(hObject,data);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxHighlight.
function checkboxHighlight_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxHighlight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxHighlight
val = get(hObject,'Value');
data = guidata(hObject);
data.position = getPosition(data.rect); %save position
if(val==1)
    highlightColor(hObject);
else
    imshow(data.image);
end
data.rect = imrect(data.axisImage,data.position);%repaint rect
guidata(hObject,data);

% --- Executes when uipanelImage is resized.
function uipanelImage_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanelImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function getColors(hObject)
display('GetColor');
data = guidata(hObject);
im = data.image;
red = [];
green = [];
blue = [];
[red,green,blue] = colormap2rgb(data.colormap{data.selectedColor});
for cols = int16(round(data.position(1))):int16(round(data.position(1)+data.position(3)))
    for rows = int16(round(data.position(2))):int16(round(data.position(2)+data.position(4)))
        %get color from rgb channels
        r = im(rows,cols,1);
        g = im(rows,cols,2);
        b = im(rows,cols,3);
        
        if(numel(find(red == r)) == 0)
            red = [red;r];
        end
        if(numel(find(green == g)) == 0)
            green = [green;g];
        end
        if(numel(find(blue == b)) == 0)
            blue = [blue;b];
        end
    end
end
    sort(red);
    sort(green);
    sort(blue);
    %create colormap
    colmap = colors2colormap(red,green,blue);
    data.colormap{data.selectedColor} = colmap;
    guidata(hObject,data);

   

%color2colormap
function colormap = colors2colormap(red,green,blue)
colormap = zeros(8,6);

%%RED
for i = 1:numel(red)

    idx = int8(ceil((red(i)+1)/16));
    if(idx == 0)
        idx = 1;
    end
    if(idx > 8)
        colormap(idx-8,2) = 1; %we shift this later
    else
        colormap(idx,1) = 1; %we shift this later
    end 
end

%%Green
for i = 1:numel(green)

    idx = int8(ceil((green(i)+1)/16));
    if(idx == 0)
        idx = 1;
    end
    if(idx > 8)
        colormap(idx-8,4) = 1; %we shift this later
    else
        colormap(idx,3) = 1; %we shift this later
    end 
end

%%Blue
for i = 1:numel(blue)

    idx = int8(ceil((blue(i)+1)/16));
    if(idx == 0)
        idx = 1;
    end
    if(idx > 8)
        colormap(idx-8,6) = 1; %we shift this later
    else
        colormap(idx,5) = 1; %we shift this later
    end 
end

function highlightColor(hObject)
data = guidata(hObject);
im = data.image;
[m,n,c] = size(im);
[red,green,blue] = colormap2rgb(data.colormap{data.selectedColor});
for rows = 1:m
    for cols = 1:n
        %get color values
        r = im(rows,cols,1);
        g = im(rows,cols,2);
        b = im(rows,cols,3);
        %check if color should be higlighted
        if(numel(find(red == r)) ~= 0 || numel(find(green == g)) ~= 0 || numel(find(blue == b)) ~= 0)
            im(rows,cols,:) = 255;
        end
    end
end
imshow(im);
printColor(data.colormap{data.selectedColor});

function [r,g,b] = colormap2rgb(colormap)
r = [];
g = [];
b = [];
[m,n] = size(colormap);
for cols = 1:n
    for rows = 1:m
        val = colormap(rows,cols);
        if(val == 1)%color
            tmp = transpose((rows-1)*16:rows*16); %Bit to ColorIntervall
            %tmp = transpose((rows-1)*16+8); %Bit to Color
            if(mod(cols,2) == 0)
                tmp = tmp + 128;
            end
            if(cols < 3)%red
                if(numel(find(r,tmp(2))) == 0)
                    r = [r;tmp];
                end
            else
                if(cols < 5)%green
                    if(numel(find(g,tmp(2))) == 0)
                        g = [g;tmp];
                    end
                else%blue
                    if(numel(find(b,tmp(2))) == 0)
                        b = [b;tmp];
                    end
                end
            end
        end
    end
end

function saveColormap(hObject)
%%first build colormap
colmap = zeros(8,6);
data = guidata(hObject);
[m,n] = size(data.colormap{1});
for cols = 1:n
    for rows = 1:m
        val = 0;
        for i = 1:8
            %each colorset is presented by one of the 8-Bits
            %(2^(i-1)) computes the Decimal represenation of that bit
            val = val + data.colormap{i}(rows,cols)*(2^(i-1));
        end
        colmap(rows,cols) = val;
    end
end
display(colmap);


CAMERA_setColormapUSB(data.cameraObject, colmap)
%Close all
%COM_CloseNXT('all');
%try to open via USB
%handle = COM_OpenNXT();
%set default
%COM_SetDefaultNXT(handle);
%open Camera
%OpenCamera(SENSOR_1,'BLOBS');
%set Colormap
%CAMERA_SetColormap(SENSOR_1,colmap);
pause(1);%wait
%Close all
%COM_CloseNXT('all');
display('Colormap saved');

function loadColormap(hObject)
%Close all
COM_CloseNXT('all');
%try to open via USB
handle = COM_OpenNXT();
%set default
COM_SetDefaultNXT(handle);
%open Camera
OpenCamera(SENSOR_1,'BLOBS');
%set Colormap
colmap = CAMERA_GetColormap(SENSOR_1);
%Close all
COM_CloseNXT('all');

%split up into 8 maps (1 for each bit)
data = guidata(hObject);
[m,n] = size(colmap);
for cols = 1:n
    for rows = 1:m
        bin = dec2bin(colmap(rows,cols),8);       
        for i = 1:8
            if(bin(i) == '1')
               data.colormap{i}(rows,cols) = 1;
            end
        end
    end
end
guidata(hObject,data);
display('Colormap loaded');


% --- Executes on button press in pushbuttonCapture.
function pushbuttonCapture_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCapture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = guidata(hObject);
if(data.cameraConnected == 1)
    display('Capturing image...');
    data.image = CAMERA_DumpFrame(data.cameraObject);
    display('... done!');
    imshow(data.image);
    data.rect = imrect(handles.axisImage,[10,10,10,10]);
    data.colormap = cell(8,1);
    for i = 1:8
        data.colormap{i} = zeros(8,6);
    end
end
guidata(hObject,data);


% --- Executes on button press in pushbuttonConnect.
function pushbuttonConnect_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = guidata(hObject);
portnr = str2double(get(data.editComPort,'String'))
if(portnr < 0 || portnr > 99)
    %display error
end

port = strcat('com' , num2str(portnr));
display('Connecting to camera...');
data.cameraObject = CAMERA_connectToCameraUSB(port);
display('...done!');
data.cameraConnected = 1;
guidata(hObject,data);

function editComPort_Callback(hObject, eventdata, handles)
% hObject    handle to editComPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editComPort as text
%        str2double(get(hObject,'String')) returns contents of editComPort as a double


% --- Executes during object creation, after setting all properties.
function editComPort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editComPort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
data = guidata(hObject);
try
fclose(data.cameraObject);
catch err
end
delete(hObject);

function colorim = printColor(colormap)
[red,green,blue] = colormap2rgb(colormap);
color = zeros(numel(red)*numel(green)*numel(blue),3);
for i = 1:numel(red)
    for j = 1:numel(green)
        for k = 1:numel(blue)
            idx = (i-1)*numel(green)*numel(blue)+(j-1)*numel(blue)+k;
            color(idx,1) = red(i);
            color(idx,2) = green(j);
            color(idx,3) = blue(k);
        end
    end
end
cols = 16;
[a,b] = size(color);
rows = ceil(a/16);
colorim = zeros(15*cols+10,15*rows+10);
figure();
imshow(colorim);
for i = 1:rows
    for j = 1:cols
        idx = (i-1)*15+j;
        curcolor = [color(idx,1)/255,color(idx,2)/255,color(idx,3)/255];
        pos = [(i-1)*15+1,(j-1)*15+1,15,15];
        rectangle('Position',pos,'FaceColor',curcolor)
    end
end
