%--------------------------------------------------------
% Two-Period Consumption Problem (Octave)
%--------------------------------------------------------

clear
clc

%Printing the outputs as a text file if ==1
output_file=0;
%LaTeX Interpreter if ==1 (requires LaTeX to be installed)
latex_interpreter=0;

%Problem Set-up
beta=0.9;
%phi = @(x) -(log(x(1)) + beta*log(x(2)));
function y=phi_fun(x,beta)
 y= -(log(x(1)) + beta*log(x(2))); %negative
endfunction %Octave: not "end" but "endfunction"
phi = @(x) phi_fun(x,beta);

%Constraint
R0=1.05;
a_rhs=1;
%h = @(x) a_rhs-[1, (1/R0)]*x;
function y=h_fun(x,R0,a_rhs) %h(x) >=0
 y=a_rhs-[1, (1/R0)]*x;
endfunction %Octave: not "end" but "endfunction"
h = @(x) h_fun(x,R0,a_rhs);

lb=[0; 0];
ub=[1e10; 1e10];
x0=[0.5; 0.5];

%sqp
[x, obj, info, iter, nf, lambda] = sqp (x0, phi, [], h, lb,ub);
% "@" is needed when the functions phi and h are defined by "function ... endfunction"

if output_file==1
  dfile="two_periods_consumption_sqp.txt";
  if exist(dfile, 'file')
   delete(dfile);
  end
  diary(dfile)
  diary on
end

%Output
fprintf('beta=%.3f, R0=%.3f, A=%.3f\n',beta,R0,a_rhs);
fprintf('Optimal consumption in two periods: %.3f,%.3f\n',x(1),x(2));
fprintf('Lifetime Utility: %.5f\n',-obj);
fprintf('Multiplier (intertemporal budget const): %.5f\n',lambda(1));
fprintf('Multiplier (non-negativity const): %.5f, %.5f\n',lambda(2),lambda(3));

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
contour(x1_mesh, x2_mesh, log(x1_mesh)+beta*log(x2_mesh), [(-obj), (-obj)], 'LineWidth', 1, 'LineColor', 'b');
contour(x1_mesh, x2_mesh, log(x1_mesh)+beta*log(x2_mesh), [0.75*(-obj), 1.25*(-obj)], 'LineWidth', 1, 'LineColor', 'k', 'LineStyle', '--');
plot(x(1),x(2),'ro','LineWidth', 1);
xlim([0,a_rhs]);
ylim([0,R0*a_rhs]);
if latex_interpreter==1
  xlabel('$x_1$','Interpreter','latex','FontSize',12);
  ylabel('$x_2$','Interpreter','latex','FontSize',12);
  title('Two-Period Consumption Problem','Interpreter','latex','FontSize',14);
else
  xlabel('x_1','FontSize',12);
  ylabel('x_2','FontSize',12);
  title('Two-Period Consumption Problem','FontSize',14);
end
