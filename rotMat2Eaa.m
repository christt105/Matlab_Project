function [u,angle] = rotMat2Eaa(M)
%ROTMAT2EAA Given a rotation matrix, it returns its euler principal axis and
%angle

angle = acos((trace(M)-1)/2);
if(M == M')
    if(angle == 0)
        u = [0;0;0];
    else
       u = [sqrt((M(1,1)+1)/2);sqrt((M(2,2)+1)/2);sqrt((M(3,3)+1)/2)];
    end
else
    Ux = (M-M')/(2*sin(angle));
    u = [Ux(3,2);Ux(1,3);Ux(2,1)];
    u = u/norm(u);
end 

end