%--------------------------------------------------------
% Nash Bargaining (Octave)
%--------------------------------------------------------

clear
clc

%Printing the outputs as a text file if ==1
output_file=0;
%LaTeX Interpreter if ==1 (requires LaTeX to be installed)
latex_interpreter=0;

lb=[0, 0];
ub=[1, 1];
x0=[0.1, 0.1];

%Constraint h(x) >=0
%h=@(x) 1-x(1)^2-x(2)^2;
function y = h(x)
  y = 1-x(1)^2-x(2)^2;
endfunction

%Problem Set-up
%phi=@(x) -x(1)*x(2);
function y=phi(x)
  y= -x(1)*x(2); %negative
endfunction

%sqp
[x, obj, info, iter, nf, lambda] = sqp (x0, @phi, [], @h, lb,ub);
% "@" is needed when the functions phi and h are defined by "function ... endfunction"

if output_file==1
  dfile="Nash_bargaining_sqp.txt";
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
contour(x1, x2, x1.*x2, [(-obj), (-obj)], 'LineWidth', 1, 'LineColor', 'b');
contour(x1, x2, x1.*x2, [0.75*(-obj), 1.25*(-obj)], 'LineWidth', 1, 'LineColor', 'k', 'LineStyle', '--');
plot(x1(1,:), slope_const*(x1(1,:)-x(1))+x(2),'k','LineWidth', 1);
plot(x(1),x(2),'ro','LineWidth', 1);
if latex_interpreter==1
  xlabel('$x_1$','Interpreter','latex','FontSize',12);
  ylabel('$x_2$','Interpreter','latex','FontSize',12);
  title('Nash Bargaining Solution','Interpreter','latex','FontSize',14);
else
  xlabel('x_1','FontSize',12);
  ylabel('x_2','FontSize',12);
  title('Nash Bargaining Solution','FontSize',14);
end
xlim([0,1]);
ylim([0,1]);
