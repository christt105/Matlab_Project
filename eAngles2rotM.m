function rotM =  eAngles2rotM(phi, theta, psy)

%EANGLES2ROTM Given an euler angles(degrees), it returns its rotation matrix
%   ATTENTION: euler angles must be in degrees!

rotM = zeros(3,3);

% Sin/cos - Angle phi
sin_1 = sind(phi);
cos_1 = cosd(phi);

% Sin/cos - Angle theta
sin_2 = sind(theta);
cos_2 = cosd(theta);

% Sin/cos - Angle psy
sin_3 = sind(psy);
cos_3 = cosd(psy);

% First row
rotM(1,1) = cos_2*cos_3;
rotM(1,2) = cos_3*sin_2*sin_1 - cos_1*sin_3;
rotM(1,3) = cos_3*cos_1*sin_2 + sin_3*sin_1;

% Second row
rotM(2,1) =  sin_3*cos_2;
rotM(2,2) =  sin_3*sin_2*sin_1 + cos_1*cos_3;
rotM(2,3) =  sin_3*sin_2*cos_1 - cos_3*sin_1;

% Third row
rotM(3,1) = -sin_2;
rotM(3,2) =  cos_2*sin_1;
rotM(3,3) =  cos_2*cos_1;



end