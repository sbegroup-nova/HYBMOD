function [t,state,jac,hess]=hybodesolver(odesfun,controlfun,eventfun,t0,tf,state,jac,hess,w,batch,projhyb)
t=t0;
hopt=[];

if nargout==2   % only state

    

   while t<tf
        h=min(projhyb.time.TAU,tf-t);
        batch.h = h;
        %??????????????????????????????????????????????????????????
        if ~isempty(eventfun)
            [batch, state] = eventfun(t,batch,state);  %
        end
        if ~isempty(controlfun)
             ucontrol1 = controlfun(t,batch);
        else
            ucontrol1=[];
        end
        [k1_state]=feval(odesfun,t,state,[],[],w,ucontrol1,projhyb);
        %[k1_state, k1_jac, k1_hess]=hybodesfun([],t,state,jac,hess,w,ucontrol1);
        if ~isempty(controlfun)
            ucontrol2 = controlfun(t+h/2,batch);
        else
            ucontrol2=[];
        end
        [k2_state]=feval(odesfun,t+h/2,state+h/2*k1_state,[],[],w,ucontrol2,projhyb);
        %[k2_state, k2_jac, k2_hess]=hybodesfun([],t+h/2,state+h/2*k1_state,jac+h/2*k1_jac,hess+h/2*k1_hess,w,ucontrol2);

        %ucontrol3 = controlfun(t0+h/2,batch);
        [k3_state]=feval(odesfun,t+h/2,state+h/2*k2_state,[],[],w,ucontrol2,projhyb);
        %[k3_state, k3_jac, k3_hess]=hybodesfun([],t+h/2,state+h/2*k2_state,jac+h/2*k2_jac,hess+h/2*k2_hess,w,ucontrol2);
    
        hl=h-h/1e10;
        if ~isempty(controlfun)
            ucontrol4 = controlfun(t+hl,batch); %????????? the term "-h/1e10" has to do with the picewise constant parameterization of controls
        else
            ucontrol4=[];
        end
        
        [k4_state]=feval(odesfun,t+hl,state+hl*k3_state,[],[],w,ucontrol4,projhyb);
        %[k4_state, k4_jac, k4_hess]=hybodesfun([],t+hl,state+hl*k3_state,jac+hl*k3_jac,hess+hl*k3_hess,w,ucontrol4);

        state = state + h*(k1_state/6+k2_state/3+k3_state/3+k4_state/6);
        t = t + h;
    end
elseif nargout==3  %state +jacobian
    while t<tf
        h=min([projhyb.time.TAU,tf-t]);%,hopt]);
        batch.h = h;
      %??????????????????????????????????????????????????????????
        if ~isempty(eventfun)
            [batch, state, dstatedstate] = eventfun(t,batch,state);  %
            jac = dstatedstate * jac;  
        end

        if ~isempty(controlfun)
            ucontrol1 = controlfun(t,batch);
        else
            ucontrol1=[];
        end   
        [k1_state, k1_jac]=feval(odesfun,t,state,jac,[],w,ucontrol1,projhyb);
        %[k1_state, k1_jac, k1_hess]=hybodesfun([],t,state,jac,hess,w,ucontrol1);
        %[k1_state, k1_jac]=feval(odesfun,t,state,jac,[],w,ucontrol1,projhyb);
        
        if ~isempty(controlfun)
            ucontrol2 = controlfun(t+h/2,batch);
        else
            ucontrol2=[];
        end
        [k2_state, k2_jac]=feval(odesfun,t+h/2,state+h/2*k1_state,jac+h/2*k1_jac,[],w,ucontrol2,projhyb);
        %[k2_state, k2_jac, k2_hess]=hybodesfun([],t+h/2,state+h/2*k1_state,jac+h/2*k1_jac,hess+h/2*k1_hess,w,ucontrol2);
        %ucontrol2 = controlfun(t+h/5,batch);
        %[k2_state, k2_jac]=feval(odesfun,t+h/5,state+h/5*k1_state,jac+h/5*k1_jac,[],w,ucontrol2,projhyb);
        
        [k3_state, k3_jac]=feval(odesfun,t+h/2,state+h/2*k2_state,jac+h/2*k2_jac,[],w,ucontrol2,projhyb);
        %[k3_state, k3_jac, k3_hess]=hybodesfun([],t+h/2,state+h/2*k2_state,jac+h/2*k2_jac,hess+h/2*k2_hess,w,ucontrol2);
        %ucontrol3 = controlfun(t+h*3/10,batch);
        %[k3_state, k3_jac]=feval(odesfun,t+h*3/10,state+h*3/40*k1_state+h*9/40*k2_state,jac+h*3/40*k1_jac+h*9/40*k2_state,[],w,ucontrol3,projhyb);
        
        hl=h-h/1e10;
        if ~isempty(controlfun)
            ucontrol4 = controlfun(t+hl,batch); %????????? the term "-h/1e10" has to do with the picewise constant parameterization of controls
        else
            ucontrol4=[];
        end
        [k4_state, k4_jac]=feval(odesfun,t+hl,state+hl*k3_state,jac+hl*k3_jac,[],w,ucontrol4,projhyb);
        %[k4_state, k4_jac, k4_hess]=hybodesfun([],t+hl,state+hl*k3_state,jac+hl*k3_jac,hess+hl*k3_hess,w,ucontrol4);
%         ucontrol4= controlfun(t+h*4/5,batch);
%         [k4_state, k4_jac]=feval(odesfun,t+h*4/5,state+h*44/45*k1_state-h*56/12*k2_state+h*32/9*k3_state,jac+h*44/45*k1_jac-h*56/12*k2_jac+h*32/9*k3_jac,[],w,ucontrol4,projhyb);

%         ucontrol5= controlfun(t+h*8/9,batch);
%         [k5_state, k5_jac]=feval(odesfun,t+h*8/9,state+h*19372/6561*k1_state-h*25360/2187*k2_state+h*64448/6561*k3_state-h*212/729*k4_state,jac+h*19372/6561*k1_jac-h*25360/2187*k2_jac+h*64448/6561*k3_jac-h*212/729*k4_jac,[],w,ucontrol5,projhyb);
% 
%         hl=h-h/1e100;
%         ucontrol6= controlfun(t+hl,batch);
%         [k6_state, k6_jac]=feval(odesfun,t+h,state+h*9017/3168*k1_state-h*355/33*k2_state+h*46732/5247*k3_state+h*49/176*k4_state-h*5103/18656*k5_state,jac+h*9017/3168*k1_jac-h*355/33*k2_jac+h*46732/5247*k3_jac+h*49/176*k4_jac-h*5103/18656*k5_jac,[],w,ucontrol6,projhyb);
%         
%         [k7_state, k7_jac]=feval(odesfun,t+h,state+h*35/384*k1_state+h*500/1113*k3_state+h*125/192*k4_state-h*2187/6784*k5_state+h*11/84*k6_state,jac+h*35/384*k1_jac+h*500/1113*k3_jac+h*125/192*k4_jac-h*2187/6784*k5_jac+h*11/84*k6_jac,[],w,ucontrol6,projhyb);

        state = state + h*(k1_state/6+k2_state/3+k3_state/3+k4_state/6);
        jac =   jac   + h*(k1_jac/6  +k2_jac/3  +k3_jac/3  +k4_jac/6);
%         state = state + h*(k1_state*35/384+k3_state*500/1113+k4_state*125/192-k5_state*2187/6784+k6_state*11/84)
%         jac = jac + h*(k1_jac*35/384+k3_jac*500/1113+k4_jac*125/192-k5_jac*2187/6784+k6_jac*11/84);
%         
%         z_state=state + h*(k1_state*5179/57600+k3_state*7571/16695+k4_state*393/640-k5_state*92097/339200+k6_state*187/2100+k7_state*1/40);
%         Atol=1e-7;
%         Reltol=1e-5;
%         s=Atol+max(state,z_state).*Reltol;
%         err=sqrt((((state-z_state)./s).^2)/length(state));
%         hopt=h/max(err);
        t = t + h;
    end

elseif nargout==4   %state +jacobian + hessian    % NOT IMPLEMENTED
    while t<tf
        h=min(projhyb.time.TAU,tf-t);
        batch.h = h;
         %??????????????????????????????????????????????????????????
         % NOT IMPLEMENTED
        if ~isempty(eventfun)
            [batch, state, dstatedstate] = eventfun(t,batch,state);  %
            jac = dstatedstate * jac;  
        end

        if ~isempty(controlfun)
             ucontrol1 = controlfun(t,batch);
        else
            ucontrol1=[];
        end  
        [k1_state, k1_jac, k1_hess]=feval(odesfun,t,state,jac,hess,w,ucontrol1,projhyb);
        %[k1_state, k1_jac, k1_hess]=hybodesfun([],t,state,jac,hess,w,ucontrol1);

        if ~isempty(controlfun)
            ucontrol2 = controlfun(t+h/2,batch);
        else
            ucontrol2=[];
        end
        [k2_state, k2_jac, k2_hess]=feval(odesfun,t+h/2,state+h/2*k1_state,jac+h/2*k1_jac,hess+h/2*k1_hess,w,ucontrol2,projhyb);
        %[k2_state, k2_jac, k2_hess]=hybodesfun([],t+h/2,state+h/2*k1_state,jac+h/2*k1_jac,hess+h/2*k1_hess,w,ucontrol2);

        %ucontrol3 = controlfun(t0+h/2,batch);
        [k3_state, k3_jac, k3_hess]=feval(odesfun,t+h/2,state+h/2*k2_state,jac+h/2*k2_jac,hess+h/2*k2_hess,w,ucontrol2,projhyb);
        %[k3_state, k3_jac, k3_hess]=hybodesfun([],t+h/2,state+h/2*k2_state,jac+h/2*k2_jac,hess+h/2*k2_hess,w,ucontrol2);

        hl=h-h/1e10;
        if ~isempty(controlfun)
            ucontrol4 = controlfun(t+hl,batch); %????????? the term "-h/1e10" has to do with the picewise constant parameterization of controls
        else
            ucontrol4=[];
        end
        [k4_state, k4_jac, k4_hess]=feval(odesfun,t+hl,state+hl*k3_state,jac+hl*k3_jac,hess+hl*k3_hess,w,ucontrol4,projhyb);
        %[k4_state, k4_jac, k4_hess]=hybodesfun([],t+hl,state+hl*k3_state,jac+hl*k3_jac,hess+hl*k3_hess,w,ucontrol4);


        state = state + h*(k1_state/6+k2_state/3+k3_state/3+k4_state/6);
        jac =   jac   + h*(k1_jac/6  +k2_jac/3  +k3_jac/3  +k4_jac/6);
        hess =  hess  + h*(k1_hess/6 +k2_hess/3 +k3_hess/3 +k4_hess/6);    
        t = t + h;
    end
end



end