function i=myMod(i,s)
% disp([i,s])
if i<1
    i=s+i;
elseif i>s
    i=myMod(i-s,s);
end;
% disp(i)
% disp('----------')
end