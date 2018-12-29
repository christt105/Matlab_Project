function [ang,unitary] = rotMat2Eaa(R)
%function [ang,axis] = rotMat2Eaa(R)
%   That given a rotation matrix returns its respective euler principal column axis and angle in radians.
I = eye(3);
t = trace(R);
ang = acosd((t-1)*0.5);

if ang == 0 %If angle equals 0 axis is not moving, so axis = [0, 0, 0]
   axis = [0 0 0]';

elseif ang == 180 %We know that uu' = (R+I)/2
   M_uut = (R+I)/2; 
   axis = [sqrt(M_uut(1,1)) sqrt(M_uut(2,2)) sqrt(M_uut(3,3))]'; 
   %We know that sqrt returns +- arguments and the answer is not true at
   %all, we musn't use the diagonal values...

else
Ux = ((R-R')/(2*sind(ang)));
axis = [Ux(3,2) Ux(1,3) Ux(2,1)]';
end

if ang == 0
    unitary = axis;
else
    unitary = axis / norm(axis);

end