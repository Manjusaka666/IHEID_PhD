%--------------------------------------------------------
% Nash Bargaining
%--------------------------------------------------------

clear
clc

%Printing the outputs as a text file if ==1
output_file=0;

%Problem Set-up
fun=@(x) -x(1)*x(2); %negative

A=[];
b=[];
Aeq=[];
beq=[];
lb=[0; 0];
ub=[];
nonlcon = @const; %non-linear constraint defined below
x0=[0.1; 0.1];

%fmincon
[x,fval,exitflag,output,lambda,grad,hessian] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon);

if output_file==1
  dfile="Nash_bargaining_fmincon.txt";
  if exist(dfile, 'file')
   delete(dfile); 
  end
  diary(dfile)
  diary on
end

%Output
fprintf('Nash Bargaining Solution: %.4f,%.4f\n',x(1),x(2));

if output_file==1
  diary off
end

%Plot
slope_const=-x(1)/x(2); %The slope of the constraint - x1/x2
[x1, x2] = meshgrid(linspace(0, 1, 100), linspace(0, 1, 100));
figure();
hold on;
grid on;
contour(x1, x2, x1.^2 + x2.^2, [1, 1], 'LineWidth', 1, 'LineColor', 'k'); % constraint
contour(x1, x2, x1.*x2, [(-fval), (- fval)], 'LineWidth', 1, 'LineColor', 'b'); 
contour(x1, x2, x1.*x2, [0.75*(-fval), 1.25*(-fval)], 'LineWidth', 1, 'LineColor', 'k', 'LineStyle', '--');
plot(x1(1,:), slope_const*(x1(1,:)-x(1))+x(2),'k','LineWidth', 1);
plot(x(1),x(2),'ro','LineWidth', 1);
xlabel('$x_{1}$','Interpreter','latex','FontSize',12);
ylabel('$x_{2}$','Interpreter','latex','FontSize',12);
title('Nash Bargaining Solution','Interpreter','latex','FontSize',14);
xlim([0,1]);
ylim([0,1]);

%Constraint
function [c,ceq] = const(x)
c = [x(1)^2+x(2)^2-1];
ceq = [];
end
