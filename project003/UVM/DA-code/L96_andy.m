function dstate=L96_andy(~,state,params)
I = params{1};
J = params{2};
h=state(end-3);b=state(end-2);c=state(end-1);F=state(end);
state=reshape(state(1:end-4),I,J+1);

X=state(:,1);

state(:,1)=X(mod(-1:I-2,I)+1).*(X(mod(1:I,I)+1)-X(mod(-2:I-3,I)+1))-X+F*ones(I,1)-(h*c/b)*sum(state(:,2:end),2);

IJ=I*J;
Ys=reshape(state(:,2:end)',1,IJ);
Xs=reshape(ones(I,J)'*diag(X),1,IJ);

Ys=-c*b*Ys(mod(1:IJ,IJ)+1).*(Ys(mod(2:IJ+1,IJ)+1)-Ys(mod(-1:IJ-2,IJ)+1)) -c*Ys+(h*c/b)*Xs;

state(:,2:end)=reshape(Ys,J,I)';

dstate=[reshape(state,numel(state),1);(0*(1:4))'];
end