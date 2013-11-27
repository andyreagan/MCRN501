function dstate=L96(t,state,params)
global I;global J;
state=reshape(state,I,J+1);
IJ=I*J;

X=state(:,1);
h=params(1);c=params(2);b=params(3);F=params(4);

state(:,1)=X(mod(-1:I-2,I)+1).*(X(mod(1:I,I)+1)-X(mod(-2:I-3,I)+1))-X+F*ones(I,1)-...
        (h*c/b)*sum(state(:,2:end),2);

IJ=I*J;
Ys=zeros(1,IJ);
Xs=zeros(1,IJ);
%Ys is the outer ring of fast oscillators
for i=1:I
        Ys((i-1)*J+1:i*J)=state(i,2:end);
        Xs((i-1)*J+1:i*J)=X(i,1)*ones(1,J);
end;

Ys=-c*b*Ys(mod(1:IJ,IJ)+1).*(Ys(mod(2:IJ+1,IJ)+1)-Ys(mod(-1:IJ-2,IJ)+1))...
        -c*Ys+(h*c/b)*Xs;

for i=1:I
        state(i,2:end)=Ys((i-1)*J+1:i*J);
end;

dstate=reshape(state,1,numel(state));
end
