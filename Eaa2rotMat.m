function [M] = Eaa2rotMat(u,angle)
%EAA2ROTMAT Given an euler angle(radians) and vector, it returns its rotation matrix
%   ATTENTION: angle must be in radians

% %Comprobes if vector is column
if(iscolumn(u) == 0)
    u = u';
end
    
u = u/norm(u);

R1 = eye(3)*cos(angle);
R2 = (1-cos(angle))*(u*u');
R3 = sin(angle)*[0 -u(3) u(2); u(3) 0 -u(1); -u(2) u(1) 0];

M = R1+R2+R3;
end