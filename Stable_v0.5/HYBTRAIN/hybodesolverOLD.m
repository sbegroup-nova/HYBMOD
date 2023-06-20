function [t,state,jac,hess]=hybodesolver(odesfun,controlfun,t0,tf,state,jac,hess,w,upars,DT,DTmin,DTmax)

for t=t0:DT:tf-DT/10;

    h=min(DT,tf-DT/10-t);
    
    ucontrol1 = feval(controlfun,t,upars);
   
    [k1_state, k1_jac, k1_hess]=feval(odesfun,t,state,jac,hess,w,ucontrol1);

    ucontrol2 = controlfun(t+h/2,upars);
    [k2_state, k2_jac, k2_hess]=feval(odesfun,t+h/2,state+h/2*k1_state,jac+h/2*k1_jac,hess+h/2*k1_hess,w,ucontrol2);

    %ucontrol3 = controlfun(t0+h/2,upars);
    [k3_state, k3_jac, k3_hess]=feval(odesfun,t+h/2,state+h/2*k2_state,jac+h/2*k2_jac,hess+h/2*k2_hess,w,ucontrol2);

    ucontrol4 = controlfun(t+h,upars);
    [k4_state, k4_jac, k4_hess]=feval(odesfun,t+h,state+h*k3_state,jac+h*k3_jac,hess+h*k3_hess,w,ucontrol4);


    state = state + h*(k1_state/6+k2_state/3+k3_state/3+k4_state/6);
    jac =   jac   + h*(k1_jac/6  +k2_jac/3  +k3_jac/3  +k4_jac/6);
    hess =  hess  + h*(k1_hess/6 +k2_hess/3 +k3_hess/3 +k4_hess/6);
    
    t = t + h;
end

ucontrol5 = controlfun(t,upars);
[k5_state, k5_jac, k5_hess]=feval(odesfun,t,state,jac,hess,w,ucontrol5);
state = state + DT/10*k5_state;
jac =   jac   + DT/10*k5_jac;
hess =  hess  + DT/10*k5_hess;
t=t+DT/10;

end