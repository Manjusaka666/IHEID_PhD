%--------------------------------------------------------
% Two-Period Consumption Problem 
%--------------------------------------------------------

clear
clc

%Printing the outputs as a text file if ==1
output_file=0;

%Problem Set-up
beta=0.9;
fun=@(x) -(log(x(1)) + beta*log(x(2)));

R0=1.05;
a_rhs=1;
A=[1 1/R0];
b=[a_rhs];
Aeq=[];
beq=[];
lb=[0; 0];
ub=[];
nonlcon = [];
x0=[0.5; 0.5];

%fmincon
[x,fval,exitflag,output,lambda,grad,hessian] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon);

if output_file==1
  dfile="two_periods_consumption_fmincon.txt";
  if exist(dfile, 'file')
   delete(dfile); 
  end
  diary(dfile)
  diary on
end

%Output
fprintf('beta=%.3f, R0=%.3f, A=%.3f\n',beta,R0,a_rhs);
fprintf('Optimal consumption in two periods: %.3f,%.3f\n',x(1),x(2));
fprintf('Lifetime Utility: %.5f\n',-fval);
fprintf('Multiplier (intertemporal budget const): %.5f\n',lambda.ineqlin);
fprintf('Multiplier (non-negativity const): %.5f, %.5f\n',lambda.lower(1),lambda.lower(2));

if output_file==1
  diary off
end

%Plot
x1_vec=linspace(0, a_rhs, 100);
x2_vec=linspace(0, R0*a_rhs, 100);
[x1_mesh, x2_mesh] = meshgrid(x1_vec, x2_vec);
figure();
hold on;
grid on;
plot(x1_vec, R0*(a_rhs-x1_vec),'k', 'LineWidth', 1); %budget constraint
contour(x1_mesh, x2_mesh, log(x1_mesh)+beta*log(x2_mesh), [(-fval), (- fval)], 'LineWidth', 1, 'LineColor', 'b'); 
contour(x1_mesh, x2_mesh, log(x1_mesh)+beta*log(x2_mesh), [1.25*(-fval), 0.75*(-fval)], 'LineWidth', 1, 'LineColor', 'k', 'LineStyle', '--');
plot(x(1),x(2),'ro','LineWidth', 1);
xlabel('$x_{1}$','Interpreter','latex','FontSize',12);
ylabel('$x_{2}$','Interpreter','latex','FontSize',12);
title('Two-Period Consumption Problem','Interpreter','latex','FontSize',14);
xlim([0,a_rhs]);
ylim([0,R0*a_rhs]);
