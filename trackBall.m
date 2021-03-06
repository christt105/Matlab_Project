function varargout = trackBall(varargin)
% TRACKBALL MATLAB code for trackBall.fig
%      TRACKBALL, by itself, creates a new TRACKBALL or raises the existing
%      singleton*.
%
%      H = TRACKBALL returns the handle to a new TRACKBALL or the handle to
%      the existing singleton*.
%
%      TRACKBALL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKBALL.M with the given input arguments.
%
%      TRACKBALL('Property','Value',...) creates a new TRACKBALL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trackBall_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trackBall_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trackBall

% Last Modified by GUIDE v2.5 29-Dec-2018 20:55:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trackBall_OpeningFcn, ...
                   'gui_OutputFcn',  @trackBall_OutputFcn, ...
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


% --- Executes just before trackBall is made visible.
function trackBall_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trackBall (see VARARGIN)
set(hObject,'Color', [0.302;0.749;0.929]);
set(hObject,'WindowButtonDownFcn',{@my_MouseClickFcn,handles.axes1});
set(hObject,'WindowButtonUpFcn',{@my_MouseReleaseFcn,handles.axes1});
axes(handles.axes1);

SetInitialQuaternion([1 0 0 0]');
SetRotationMatrix(eye(3),handles);
handles.Cube=DrawCube(eye(3));

set(handles.axes1,'CameraPosition',...
    [0 0 5],'CameraTarget',...
    [0 0 -5],'CameraUpVector',...
    [0 1 0],'DataAspectRatio',...
    [1 1 1]);

set(handles.axes1,'xlim',[-3 3],'ylim',[-3 3],'visible','off','color','none');

% Choose default command line output for trackBall
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trackBall wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trackBall_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function my_MouseClickFcn(obj,event,hObject)

handles=guidata(obj);
xlim = get(handles.axes1,'xlim');
ylim = get(handles.axes1,'ylim');
mousepos=get(handles.axes1,'CurrentPoint');
xmouse = mousepos(1,1);
ymouse = mousepos(1,2);

if xmouse > xlim(1) && xmouse < xlim(2) && ymouse > ylim(1) && ymouse < ylim(2)
    set(handles.figure1,'WindowButtonMotionFcn',{@my_MouseMoveFcn,hObject});
    radius = 50;
    
    %% Holroyd's arcball
     if((xmouse.^2+ymouse.^2) < 0.5*radius.^2)        
         Z = sqrt(radius.^2 - xmouse.^2 - ymouse.^2);
         m0 = [xmouse, ymouse, Z]';
         
     else 
         Z =  (radius.^2)/2*sqrt(xmouse.^2 + ymouse.^2);
         m0 = [xmouse, ymouse, Z]'/sqrt(xmouse.^2 + ymouse.^2+Z.^2);
     end
     
     
     %% Saving clicked mouse coords
     SetInitialVector(m0);
    
    set(handles.figure1,'WindowButtonMotionFcn',{@my_MouseMoveFcn,hObject});
end
guidata(hObject,handles)

function my_MouseReleaseFcn(obj,event,hObject)
handles=guidata(hObject);
set(handles.figure1,'WindowButtonMotionFcn','');
guidata(hObject,handles);

function my_MouseMoveFcn(obj,event,hObject)

handles=guidata(obj);
xlim = get(handles.axes1,'xlim');
ylim = get(handles.axes1,'ylim');
mousepos=get(handles.axes1,'CurrentPoint');
xmouse = mousepos(1,1);
ymouse = mousepos(1,2);

if xmouse > xlim(1) && xmouse < xlim(2) && ymouse > ylim(1) && ymouse < ylim(2)

    %%% DO things
    % use with the proper R matrix to rotate the cube
    
     radius = 50;
   
     %% Holroyd's arcball
     if((xmouse.^2+ymouse.^2) < 0.5*radius.^2)        
         Z = sqrt(radius.^2 - xmouse.^2 - ymouse.^2);
         m1 = [xmouse, ymouse, Z]';
         
     else 
         Z =  (radius.^2)/(2*sqrt(xmouse.^2 + ymouse.^2));
         m1 = radius * [xmouse, ymouse, Z]'/norm(xmouse.^2 + ymouse.^2+Z.^2);
     end
     
    %% Loading previous mouse coords
    m0 = GetInitialVector();
    q0 = GetInitialQuaternion();
    
     %% Quaternion from two vectors
    axis = cross(m0, m1); % Obtain axis
    angle = acosd((m1'*m0)/(norm(m1)*norm(m0))); % Obtain angle
    axis = axis / norm(axis);
    q1 = [cosd(angle/2),sin(angle/2) * axis']';
    q1 = quat_normalize(q1);
    q1 = multiplyQuat(q1,q0);
    R = quat2RotMat(q1);
    %R = Eaa2rotMat(axis, angle); % Build Rotation Matrix
    SetInitialVector(m1);
    SetInitialQuaternion(q1);
    %% Rotate the Cube
    handles.Cube = RedrawCube(R,handles.Cube);
    SetRotationMatrix(R, handles);
%     R = [1 0 0; 0 -1 0;0 0 -1];
%     handles.Cube = RedrawCube(R,handles.Cube);
     %% Saving clicked mouse coords
     
     %SetInitialQuaternion([1 0 0 0]')
    
end
guidata(hObject,handles);

function h = DrawCube(R)

M0 = [    -1  -1 1;   %Node 1
    -1   1 1;   %Node 2
    1   1 1;   %Node 3
    1  -1 1;   %Node 4
    -1  -1 -1;  %Node 5
    -1   1 -1;  %Node 6
    1   1 -1;  %Node 7
    1  -1 -1]; %Node 8

M = (R*M0')';


x = M(:,1);
y = M(:,2);
z = M(:,3);


con = [1 2 3 4;
    5 6 7 8;
    4 3 7 8;
    1 2 6 5;
    1 4 8 5;
    2 3 7 6]';

x = reshape(x(con(:)),[4,6]);
y = reshape(y(con(:)),[4,6]);
z = reshape(z(con(:)),[4,6]);

c = 1/255*[255 248 88;
    0 0 0;
    57 183 225;
    57 183 0;
    255 178 0;
    255 0 0];

h = fill3(x,y,z, 1:6);

for q = 1:length(c)
    h(q).FaceColor = c(q,:);
end

function h = RedrawCube(R,hin)

h = hin;
c = 1/255*[255 248 88;
    0 0 0;
    57 183 225;
    57 183 0;
    255 178 0;
    255 0 0];

M0 = [    -1  -1 1;   %Node 1
    -1   1 1;   %Node 2
    1   1 1;   %Node 3
    1  -1 1;   %Node 4
    -1  -1 -1;  %Node 5
    -1   1 -1;  %Node 6
    1   1 -1;  %Node 7
    1  -1 -1]; %Node 8

M = (R*M0')';


x = M(:,1);
y = M(:,2);
z = M(:,3);


con = [1 2 3 4;
    5 6 7 8;
    4 3 7 8;
    1 2 6 5;
    1 4 8 5;
    2 3 7 6]';

x = reshape(x(con(:)),[4,6]);
y = reshape(y(con(:)),[4,6]);
z = reshape(z(con(:)),[4,6]);

for q = 1:6
    h(q).Vertices = [x(:,q) y(:,q) z(:,q)];
    h(q).FaceColor = c(q,:);
end

function SetInitialVector(v)
global initial_v;
initial_v = v;

function v = GetInitialVector()
global initial_v;
v = initial_v;

function SetInitialQuaternion(q)
global prev_q;
prev_q = q;

function q = GetInitialQuaternion()
global prev_q;
q = prev_q;

% --- Executes on button press in button_euler_angles.
function button_euler_angles_Callback(hObject, eventdata, handles)
% hObject    handle to button_euler_angles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
phi = str2double(get(handles.euler_angle_a,'String'));
theta = str2double(get(handles.euler_angle_b,'String'));
psi = str2double(get(handles.euler_angle_c,'String'));

[R] = eAngles2rotM(phi,theta,psi);

SetInitialQuaternion(SetRotationMatrix(R, handles));

handles.Cube = RedrawCube(R,handles.Cube);

% --- Executes on button press in button_axis_angle.
function button_axis_angle_Callback(hObject, eventdata, handles)
% hObject    handle to button_axis_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
angle = str2double(get(handles.euler_angleaxis_angle,'String'));
euler_axis = [str2double(get(handles.euler_angleaxis_x,'String'));
                str2double(get(handles.euler_angleaxis_y,'String'));
                str2double(get(handles.euler_angleaxis_z,'String'))];
            
if(angle == 0 || sqrt(euler_axis(1)^2+euler_axis(2)^2+euler_axis(3)^2) == 0)
    [R] = eye(3);
else
    [R] = Eaa2rotMat(euler_axis,deg2rad(angle));
end

SetInitialQuaternion(SetRotationMatrix(R, handles));

handles.Cube = RedrawCube(R,handles.Cube);

% --- Executes on button press in button_quaternion.
function button_quaternion_Callback(hObject, eventdata, handles)
% hObject    handle to button_quaternion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
quat = [str2double(get(handles.quaternion_q0_0,'String'));
        str2double(get(handles.quaternion_q0_1,'String'));
        str2double(get(handles.quaternion_q0_2,'String'));
        str2double(get(handles.quaternion_q0_3,'String'))];
    
quat = quat_normalize(quat);

[R] = quat2RotMat(quat);

SetInitialQuaternion(SetRotationMatrix(R, handles));

handles.Cube = RedrawCube(R,handles.Cube);


% --- Executes on button press in button_rotation_vector.
function button_rotation_vector_Callback(hObject, eventdata, handles)
% hObject    handle to button_rotation_vector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
v_x = str2double(get(handles.rotation_vector_x,'String'));
v_y = str2double(get(handles.rotation_vector_y,'String'));
v_z = str2double(get(handles.rotation_vector_z,'String'));

vec = [v_x, v_y, v_z]';

if(norm(vec) == 0)
    R = eye(3);
else
    R = V2rotMat(vec);
end

SetInitialQuaternion(SetRotationMatrix(R, handles));

handles.Cube = RedrawCube(R,handles.Cube);


% --- Executes on button press in button_reset.
function button_reset_Callback(hObject, eventdata, handles)
% hObject    handle to button_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SetInitialQuaternion([1 0 0 0]');
SetInitialVector([0 0 0]');
%Build identity rotation matrix
 R = eye(3);
 
 SetInitialQuaternion(SetRotationMatrix(R, handles));
 
handles.Cube = RedrawCube(R,handles.Cube);

function [q] = SetRotationMatrix(R, handles)
% Update all input guide text and returns rotation quaternion

decimals = 5;
% Set Rotation matrix text
set(handles.rotmat_1_1,'string',round(R(1,1),decimals));
set(handles.rotmat_1_2,'string',round(R(1,2),decimals));
set(handles.rotmat_1_3,'string',round(R(1,3),decimals));
set(handles.rotmat_2_1,'string',round(R(2,1),decimals));
set(handles.rotmat_2_2,'string',round(R(2,2),decimals));
set(handles.rotmat_2_3,'string',round(R(2,3),decimals));
set(handles.rotmat_3_1,'string',round(R(3,1),decimals));
set(handles.rotmat_3_2,'string',round(R(3,2),decimals));
set(handles.rotmat_3_3,'string',round(R(3,3),decimals));

% Euler angle/axis
[angle, u] = rotMat2Eaa(R);
set(handles.euler_angleaxis_angle,'String',angle);
set(handles.euler_angleaxis_x,'String',round(u(1),decimals));
set(handles.euler_angleaxis_y,'String',round(u(2),decimals));
set(handles.euler_angleaxis_z,'String',round(u(3),decimals));

% Euler angles
[phi1,phi2,theta1,theta2,psi1,psi2,flag] = rotM2eAngles(R);
set(handles.euler_angle_a,'String',round(phi1,decimals));
set(handles.euler_angle_b,'String',round(theta1,decimals));
set(handles.euler_angle_c,'String',round(psi1,decimals));

% Quaternion
q = rotMat2quat(R);
set(handles.quaternion_q0_0,'String',round(q(1),decimals));
set(handles.quaternion_q0_1,'String',round(q(2),decimals));
set(handles.quaternion_q0_2,'String',round(q(3),decimals));
set(handles.quaternion_q0_3,'String',round(q(4),decimals));

% Rotation vector
v = Eaa2V(angle,u);
set(handles.rotation_vector_x,'String',round(v(1),decimals));
set(handles.rotation_vector_y,'String',round(v(2),decimals));
set(handles.rotation_vector_z,'String',round(v(3),decimals));

function rotmat_1_1_Callback(hObject, eventdata, handles)
% hObject    handle to rotmat_1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotmat_1_1 as text
%        str2double(get(hObject,'String')) returns contents of rotmat_1_1 as a double


% --- Executes during object creation, after setting all properties.
function rotmat_1_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotmat_1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end



function rotmat_2_1_Callback(hObject, eventdata, handles)
% hObject    handle to rotmat_2_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotmat_2_1 as text
%        str2double(get(hObject,'String')) returns contents of rotmat_2_1 as a double

% --- Executes during object creation, after setting all properties.
function rotmat_2_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotmat_2_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotmat_3_1_Callback(hObject, eventdata, handles)
% hObject    handle to rotmat_3_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotmat_3_1 as text
%        str2double(get(hObject,'String')) returns contents of rotmat_3_1 as a double


% --- Executes during object creation, after setting all properties.
function rotmat_3_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotmat_3_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotmat_1_2_Callback(hObject, eventdata, handles)
% hObject    handle to rotmat_1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotmat_1_2 as text
%        str2double(get(hObject,'String')) returns contents of rotmat_1_2 as a double


% --- Executes during object creation, after setting all properties.
function rotmat_1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotmat_1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotmat_2_2_Callback(hObject, eventdata, handles)
% hObject    handle to rotmat_2_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotmat_2_2 as text
%        str2double(get(hObject,'String')) returns contents of rotmat_2_2 as a double


% --- Executes during object creation, after setting all properties.
function rotmat_2_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotmat_2_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotmat_3_2_Callback(hObject, eventdata, handles)
% hObject    handle to rotmat_3_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotmat_3_2 as text
%        str2double(get(hObject,'String')) returns contents of rotmat_3_2 as a double


% --- Executes during object creation, after setting all properties.
function rotmat_3_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotmat_3_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotmat_1_3_Callback(hObject, eventdata, handles)
% hObject    handle to rotmat_1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotmat_1_3 as text
%        str2double(get(hObject,'String')) returns contents of rotmat_1_3 as a double


% --- Executes during object creation, after setting all properties.
function rotmat_1_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotmat_1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotmat_2_3_Callback(hObject, eventdata, handles)
% hObject    handle to rotmat_2_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotmat_2_3 as text
%        str2double(get(hObject,'String')) returns contents of rotmat_2_3 as a double


% --- Executes during object creation, after setting all properties.
function rotmat_2_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotmat_2_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotmat_3_3_Callback(hObject, eventdata, handles)
% hObject    handle to rotmat_3_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotmat_3_3 as text
%        str2double(get(hObject,'String')) returns contents of rotmat_3_3 as a double


% --- Executes during object creation, after setting all properties.
function rotmat_3_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotmat_3_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotation_vector_x_Callback(hObject, eventdata, handles)
% hObject    handle to rotation_vector_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotation_vector_x as text
%        str2double(get(hObject,'String')) returns contents of rotation_vector_x as a double


% --- Executes during object creation, after setting all properties.
function rotation_vector_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotation_vector_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotation_vector_y_Callback(hObject, eventdata, handles)
% hObject    handle to rotation_vector_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotation_vector_y as text
%        str2double(get(hObject,'String')) returns contents of rotation_vector_y as a double


% --- Executes during object creation, after setting all properties.
function rotation_vector_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotation_vector_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rotation_vector_z_Callback(hObject, eventdata, handles)
% hObject    handle to rotation_vector_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotation_vector_z as text
%        str2double(get(hObject,'String')) returns contents of rotation_vector_z as a double


% --- Executes during object creation, after setting all properties.
function rotation_vector_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotation_vector_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function quaternion_q0_0_Callback(hObject, eventdata, handles)
% hObject    handle to quaternion_q0_0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quaternion_q0_0 as text
%        str2double(get(hObject,'String')) returns contents of quaternion_q0_0 as a double


% --- Executes during object creation, after setting all properties.
function quaternion_q0_0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quaternion_q0_0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function quaternion_q0_1_Callback(hObject, eventdata, handles)
% hObject    handle to quaternion_q0_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quaternion_q0_1 as text
%        str2double(get(hObject,'String')) returns contents of quaternion_q0_1 as a double


% --- Executes during object creation, after setting all properties.
function quaternion_q0_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quaternion_q0_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function quaternion_q0_2_Callback(hObject, eventdata, handles)
% hObject    handle to quaternion_q0_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quaternion_q0_2 as text
%        str2double(get(hObject,'String')) returns contents of quaternion_q0_2 as a double


% --- Executes during object creation, after setting all properties.
function quaternion_q0_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quaternion_q0_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function quaternion_q1_0_Callback(hObject, eventdata, handles)
% hObject    handle to quaternion_q1_0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quaternion_q1_0 as text
%        str2double(get(hObject,'String')) returns contents of quaternion_q1_0 as a double


% --- Executes during object creation, after setting all properties.
function quaternion_q1_0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quaternion_q1_0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function quaternion_q1_1_Callback(hObject, eventdata, handles)
% hObject    handle to quaternion_q1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quaternion_q1_1 as text
%        str2double(get(hObject,'String')) returns contents of quaternion_q1_1 as a double


% --- Executes during object creation, after setting all properties.
function quaternion_q1_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quaternion_q1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function quaternion_q1_2_Callback(hObject, eventdata, handles)
% hObject    handle to quaternion_q1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quaternion_q1_2 as text
%        str2double(get(hObject,'String')) returns contents of quaternion_q1_2 as a double


% --- Executes during object creation, after setting all properties.
function quaternion_q1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quaternion_q1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function quaternion_q0_3_Callback(hObject, eventdata, handles)
% hObject    handle to quaternion_q0_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quaternion_q0_3 as text
%        str2double(get(hObject,'String')) returns contents of quaternion_q0_3 as a double


% --- Executes during object creation, after setting all properties.
function quaternion_q0_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quaternion_q0_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function quaternion_q1_3_Callback(hObject, eventdata, handles)
% hObject    handle to quaternion_q1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quaternion_q1_3 as text
%        str2double(get(hObject,'String')) returns contents of quaternion_q1_3 as a double


% --- Executes during object creation, after setting all properties.
function quaternion_q1_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quaternion_q1_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function euler_angleaxis_angle_Callback(hObject, eventdata, handles)
% hObject    handle to euler_angleaxis_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of euler_angleaxis_angle as text
%        str2double(get(hObject,'String')) returns contents of euler_angleaxis_angle as a double


% --- Executes during object creation, after setting all properties.
function euler_angleaxis_angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to euler_angleaxis_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function euler_angleaxis_x_Callback(hObject, eventdata, handles)
% hObject    handle to euler_angleaxis_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of euler_angleaxis_x as text
%        str2double(get(hObject,'String')) returns contents of euler_angleaxis_x as a double


% --- Executes during object creation, after setting all properties.
function euler_angleaxis_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to euler_angleaxis_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function euler_angleaxis_y_Callback(hObject, eventdata, handles)
% hObject    handle to euler_angleaxis_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of euler_angleaxis_y as text
%        str2double(get(hObject,'String')) returns contents of euler_angleaxis_y as a double


% --- Executes during object creation, after setting all properties.
function euler_angleaxis_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to euler_angleaxis_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function euler_angleaxis_z_Callback(hObject, eventdata, handles)
% hObject    handle to euler_angleaxis_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of euler_angleaxis_z as text
%        str2double(get(hObject,'String')) returns contents of euler_angleaxis_z as a double


% --- Executes during object creation, after setting all properties.
function euler_angleaxis_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to euler_angleaxis_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function euler_angle_a_Callback(hObject, eventdata, handles)
% hObject    handle to euler_angle_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of euler_angle_a as text
%        str2double(get(hObject,'String')) returns contents of euler_angle_a as a double


% --- Executes during object creation, after setting all properties.
function euler_angle_a_CreateFcn(hObject, eventdata, handles)
% hObject    handle to euler_angle_a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function euler_angle_b_Callback(hObject, eventdata, handles)
% hObject    handle to euler_angle_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of euler_angle_b as text
%        str2double(get(hObject,'String')) returns contents of euler_angle_b as a double


% --- Executes during object creation, after setting all properties.
function euler_angle_b_CreateFcn(hObject, eventdata, handles)
% hObject    handle to euler_angle_b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function euler_angle_c_Callback(hObject, eventdata, handles)
% hObject    handle to euler_angle_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of euler_angle_c as text
%        str2double(get(hObject,'String')) returns contents of euler_angle_c as a double


% --- Executes during object creation, after setting all properties.
function euler_angle_c_CreateFcn(hObject, eventdata, handles)
% hObject    handle to euler_angle_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
