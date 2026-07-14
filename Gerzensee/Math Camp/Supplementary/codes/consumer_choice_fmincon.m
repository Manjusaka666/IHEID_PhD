%--------------------------------------------------------
% Consumer Choice
%--------------------------------------------------------

clear
clc

%Printing the outputs as a text file if ==1
output_file=0;

%Problem Set-up
alpha=0.7;
fun=@(x) -(x(1).^alpha).*(x(2).^(1-alpha)); %minimizing (-u)

A=[1, 1]; %A=[p1, p2]
b=[1];    %b=[m]
Aeq=[];
beq=[];
lb=[0; 0];
ub=[];
nonlcon = [];
x0=[0.1; 0.1];

%fmincon
[x,fval,exitflag,output,lambda,grad,hessian] = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon);

if output_file==1
  dfile="consumer_choice_fmincon.txt";
  if exist(dfile, 'file')
    delete(dfile); 
  end
  diary(dfile)
  diary on
end

%Output
fprintf('alpha=%.3f, p1=%.3f, p2=%.3f, m=%.3f\n',alpha,A(1),A(2),b);
fprintf('Optimal consumption: %.3f,%.3f\n',x(1),x(2));
fprintf('Utility: %.5f\n',-fval);
fprintf('Multiplier (budget const): %.5f\n',lambda.ineqlin);
fprintf('Multiplier (non-negativity const): %.5f, %.5f\n',lambda.lower(1),lambda.lower(2));

if output_file==1
  diary off
end

%Plot
x1_vec=linspace(0, b/A(1), 100);
x2_vec=linspace(0, b/A(2), 100);
[x1_mesh, x2_mesh] = meshgrid(x1_vec, x2_vec);
figure();
hold on;
grid on;
plot(x1_vec, (b-A(1)*x1_vec)/A(2),'k', 'LineWidth', 1); %budget constraint
contour(x1_mesh, x2_mesh, (x1_mesh.^alpha).*(x2_mesh.^(1-alpha)), [(-fval), (- fval)], 'LineWidth', 1, 'LineColor', 'b'); 
contour(x1_mesh, x2_mesh, (x1_mesh.^alpha).*(x2_mesh.^(1-alpha)), [0.75*(-fval), 1.25*(-fval)], 'LineWidth', 1, 'LineColor', 'k', 'LineStyle', '--');
plot(x(1),x(2),'ro','LineWidth', 1);
xlabel('$x_{1}$','Interpreter','latex','FontSize',12);
ylabel('$x_{2}$','Interpreter','latex','FontSize',12);
title('Consumer Choice','Interpreter','latex','FontSize',14);
xlim([0,b/A(1)]);
ylim([0,b/A(2)]);
