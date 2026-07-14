%========================================================
% Lucas Tree Model
%========================================================

clear
clc

gamma=1.0;      %Coefficient of Constant Risk Aversion
beta=0.95;      %Discount Factor
alpha=0.9;      %\log y_{t+1}= \alpha \log y_{t} + \sigma \varepsilon_{t}
sigma=0.1;      %Standard deviation for the Log-Normal Distribution

%Grid for y
%Since we cannot just have a state space [0,\infty), we consider [y_min, y_max]
ssd=sigma/sqrt(1-alpha^2);          %The standard deviation for \log y_{t}
y_min=exp(-4*ssd);                  %The minimum of the grid
y_max=exp(4*ssd);                   %The maximum of the grid
dim_y=100;                          %Grid size for the vector of y
y_vec=linspace(y_min,y_max,dim_y);  %Grid for y 

%Realizations of y_t (to compute/approximate integrals)
%Two equivalent ways
%epsilon: (1,500)-vector, iid standard normal
%r_ln:    (1,500)-vector, iid log-normal with (mean,sd)=(0,sigma)
rng('default');     %Initialize the random number generator
epsilon=normrnd(0,1,1,500); %Statistics and Machine Learning Toolbox
rng('default');     %Initialize the random number generator
r_ln=lognrnd(0,sigma,1,500); %Statistics and Machine Learning Toolbox
%Note: r_ln=exp(sigma*epsilon);
%      y_{t+1} = y^{\alpha}_{t} \exp ( \sigma \varepsilon_{t} )

%h(y) = beta* int u'(G(y,z)) G(y,z) phi(dz)
h=zeros(1,dim_y);
for i=1:dim_y
 h(i) = beta* mean(((y_vec(i)^alpha).*r_ln).^(1-gamma));   
end

f=zeros(1,dim_y);          %f
f_new=zeros(1,dim_y);      %Tf

max_iter=2000;             %The Maximum Number of Iterations
toler=0.1^4;               %Tolerance Value
converge=0;    
% converge is a binary variable, where it takes 1 when the value
% function iteration ended within the maximum number of rounds (max_iter).

tic %start stopwatch timer (optional)
for ell=1:max_iter
 for i=1:dim_y 
  f_new(i) = h(i) +  beta* mean( interp1(y_vec,f,(y_vec(i).^alpha).*r_ln,'spline') ); 
 end   %end of for i=1:dim_N
 %
 if norm(f_new-f,Inf)<toler %alternative: if max(abs(f_new-f))<toler
  converge=1;
  break;
 end %end of if
 %
 f=f_new;
end
comp_time=toc; %end stopwatch timer and substitute time into comp_time (optional)

price=f.*y_vec.^gamma;

%Convergence
if converge==1
 fprintf('The value function iteration converged with %d iterations.\n', ell);
 fprintf('The value function iteration took %f seconds.\n', comp_time);
else 
 fprintf('The value function iteration did not converge.\n');
end

%Plot
figure()
hold on
plot(y_vec,price,'LineWidth',2);
if gamma==1
 plot(y_vec,(beta/(1-beta))*y_vec,'--','LineWidth',2);
end
grid on
hold off
xlabel('$y$','Interpreter','latex','FontSize',12);
ylabel('$p$','Interpreter','latex','FontSize',12);
title('Equlibrium Pricing Function $p$','Interpreter','latex','FontSize',14);
xlim([y_min, y_max]);
