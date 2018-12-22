function[R] = Eaa2rotMat(vector, angle)

%Comprobes if vector is column
if(iscolumn(vector) == 0)
    vector = vector';
end

%Makes vector unitary
vector = vector/norm(vector);

I=[1 0 0;0 1 0;0 0 1];

X=[0 -vector(3) vector(2) ; vector(3) 0 -vector(1) ; -vector(2) vector(1) 0 ];

[R] = I * cos(angle)+(1-cos(angle))*(vector*vector')+ X*sin(angle);