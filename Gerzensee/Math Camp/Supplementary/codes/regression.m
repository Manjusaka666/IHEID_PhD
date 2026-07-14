%--------------------------------------------------------
% Regression
%--------------------------------------------------------

clear
clc

%Printing the outputs as a text file if ==1
output_file=0;

%Sample size
n=500;

%True parameter values
beta_1=1;
beta_2=3;
beta_vec=[beta_1 beta_2]';  %(2,1)-vector

%Generating observations
rng(0);          %Random number generator (MATLAB)
x=randn(n,1);    %(n,1)-vector of iid standard normal independent variables
e=randn(n,1);    %(n,1)-vector of iid standard normal error terms
X=[ones(n,1) x]; %(n,2)-maxtrix
y=X*beta_vec+e;  %(n,1)-vector

%Estimating best beta
beta_hat=inv(X'*X)*X'*y; %or: beta_hat=(X'*X)\(X'*y); Projection
beta_hat_2=regress(y,X); %MATLAB function regress

%Creating the regression line for Figure
x_min=-4;
x_max=4;
x_ax=linspace(x_min,x_max,100);

if output_file==1
  dfile ='regression.txt';
  if exist(dfile, 'file') 
    delete(dfile); 
  end
  diary("regression.txt")
  diary on
end

%Output (Command Window)
fprintf('Projection: beta=(%f,%f)\n',beta_hat(1),beta_hat(2));
fprintf('MATLAB Function regress: beta=(%f,%f)\n',beta_hat(1),beta_hat(2));

if output_file==1
  diary off
end

%Figure
figure()
hold on
plot(x,y,'.'); %or: scatter(x,y); 
plot(x_ax,beta_hat(1)+beta_hat(2)*x_ax);
hold off
xlabel('$x$','Interpreter','latex','FontSize',12);
ylabel('$y$','Interpreter','latex','FontSize',12);
xlim([x_min x_max]);
ylim([beta_1+beta_2*x_min beta_1+beta_2*x_max]);
title('Regression: Example','Interpreter','latex','FontSize',14);
%Putting the regression equation into the figure
reg_eq=sprintf('$y$ = %.3f + %.3f $x$',beta_hat(1),beta_hat(2));
text(-3.75,2,reg_eq,'Interpreter','latex','FontSize',12);