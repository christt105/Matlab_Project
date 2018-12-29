function [q] = rotMat2quat(R)
%ROTMAT2QUAT Given a rotation matrix returns quaternion
%   Detailed explanation goes here
q = [1 0 0 0]';
R_diag = [R(1,1),R(2,2),R(3,3)];
if(trace(R)>=0)
    q_den = sqrt(1 + R(1,1) + R(2,2) + R(3,3));
    q(1) = q_den;
    q(2) = (R(3,2)-R(2,3))/q_den;
    q(3) = (R(1,3)-R(3,1))/q_den;
    q(4) = (R(2,1)-R(1,2))/q_den;
else
    if(R(1,1) == max(R_diag))
        q_den = sqrt(1 + R(1,1) - R(2,2) - R(3,3));
        q(1) = (R(3,2)-R(2,3))/q_den;
        q(2) = q_den;
        q(3) = (R(2,1)+R(1,2))/q_den;
        q(4) = (R(1,3)+R(3,1))/q_den;   
    elseif(R(2,2) == max(R_diag))
        q_den = sqrt(1 - R(1,1) + R(2,2) + R(3,3));
        q(1) = (R(1,3)-R(3,1))/q_den;
        q(2) = (R(2,1)+R(1,2))/q_den;
        q(3) = q_den;
        q(4) = (R(3,2)+R(2,3))/q_den;
    elseif(R(3,3) == max(R_diag))
        q_den = sqrt(1 - R(1,1) - R(2,2) + R(3,3));
        q(1) = (R(2,1)-R(1,2))/q_den;
        q(2) = (R(1,3)+R(3,1))/q_den;
        q(3) = (R(3,2)+R(2,3))/q_den;
        q(4) = q_den;      
    end
end
q = q/2;
end

