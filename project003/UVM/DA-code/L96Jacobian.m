function Jac=L96Jacobian(state)
global I J;
state=reshape(state,I,J+1);
X=state(:,1);
dim=I;
Jac=-1*eye(dim);
for i=1:dim
    Jac(i,myMod(i-2,dim))=-X(myMod(i-1,dim));
    Jac(i,myMod(i-1,dim))=X(myMod(i+1,dim))-X(myMod(i-2,dim));
    Jac(i,myMod(i+1,dim))=X(myMod(i-1,dim));
end;
end
