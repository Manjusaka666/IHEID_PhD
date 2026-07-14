%--------------------------------------------------------
% Consumer Choice (Octave)
%--------------------------------------------------------

clear
clc

%Printing the outputs as a text file if ==1
output_file=0;
%LaTeX Interpreter if ==1 (requires LaTeX to be installed)
latex_interpreter=1;

%Problem Set-up
alpha=0.7;
%phi = @(x) -(x(1).^alpha).*(x(2).^(1-alpha));
function y = phi_fun(x, alpha)
  y = -(x(1).^alpha).*(x(2).^(1-alpha)); %negative
endfunction %Octave: not "end" but "endfunction"
phi = @(x) phi_fun(x, alpha);

%Constraint: we consider the inequality constraint h(x) >=0
A=[1, 1]; %A=[p1, p2]
b=[1];    %b=m
h = @(x) b - A*x;
%function y = h_fun(x, A, b)
%  y = b - A*x;
%endfunction %Octave: not "end" but "endfunction"
%h = @(x) h_fun(x, A, b);

lb=[0; 0];
ub=[1e10, 1e10];
x0=[0.1; 0.1];

%sqp
[x, obj, info, iter, nf, lambda] = sqp (x0, phi, [], h, lb,ub);


if output_file==1
  dfile="consumer_choice_sqp.txt";
  if exist(dfile, 'file')
    delete(dfile);
  end
  diary(dfile)
  diary on
end

%Output
fprintf('alpha=%.3f, p1=%.3f, p2=%.3f, m=%.3f\n',alpha,A(1),A(2),b);
fprintf('Optimal consumption: %.3f,%.3f\n',x(1),x(2));
fprintf('Utility: %.5f\n',-obj);
fprintf('Multiplier (budget const): %.5f\n',lambda(1));
fprintf('Multiplier (non-negativity const): %.5f, %.5f\n',lambda(2),lambda(3));

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
contour(x1_mesh, x2_mesh, (x1_mesh.^alpha).*(x2_mesh.^(1-alpha)), [(-obj), (-obj)], 'LineWidth', 1, 'LineColor', 'b');
contour(x1_mesh, x2_mesh, (x1_mesh.^alpha).*(x2_mesh.^(1-alpha)), [0.75*(-obj), 1.25*(-obj)], 'LineWidth', 1, 'LineColor', 'k', 'LineStyle', '--');
plot(x(1),x(2),'ro','LineWidth', 1);
xlim([0,b/A(1)]);
ylim([0,b/A(2)]);
if latex_interpreter==1
  xlabel('$x_1$','Interpreter','latex','FontSize',12);
  ylabel('$x_2$','Interpreter','latex','FontSize',12);
  title('Consumer Choice','Interpreter','latex','FontSize',14);
else
  xlabel('x_1','FontSize',12);
  ylabel('x_2','FontSize',12);
  title('Consumer Choice','FontSize',14);
end
