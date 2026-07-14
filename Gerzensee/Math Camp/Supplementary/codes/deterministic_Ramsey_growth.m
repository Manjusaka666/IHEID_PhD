%================================================================
% Deterministic Ramsey Growth Model
%================================================================

clear
clc

%Printing the outputs as a text file if ==1
output_file=0;

%LaTeX Interpreter if ==1 (requires LaTeX to be installed if compiled on Octave)
latex_interpreter=0;

%----------------------------------------------------------------
% CRRA Utility Function (c.^(1-gamma)-1)/(1-gamma)
%----------------------------------------------------------------
gamma=1.0; %gamma>0
if gamma==1
  u = @(c) log(c);
else
  u = @(c) (c.^(1-gamma)-1)./(1-gamma);
end

%----------------------------------------------------------------
% Paremeters
%----------------------------------------------------------------
beta=0.9;      %discount factor
A=1;           %Solow Residual
alpha=0.30;    %capital elasticity of output
delta=0.25;    %depreciation rate

%----------------------------------------------------------------
% Grid on Capital (State Variable: Current Capital Level)
%----------------------------------------------------------------
k_ss=((alpha*A)/(1/beta-(1-delta)))^(1/(1-alpha)); %steady state capital
c_ss=A*k_ss^alpha-delta*k_ss;         %steady-state consumption
k_min=0.25*k_ss;                      %minimum node
k_max=1.75*k_ss;                      %maximum node
dimK=1000;                            %number of nodes
gridK=linspace(k_min,k_max,dimK);     %uniform grid over capital

%----------------------------------------------------------------
% Consumption and Current Utility Matrices
%----------------------------------------------------------------
% Consumption can be recovered from current and next period capital.
% Creating the (dimK,dimK)-matrix such that an (i,j) element is
% the amount of consumption associated with
% k=gridK(i) (current state is the i-th node) and
% k_prime=gridK(j) (next period's state is the j-th node).
% Note that a choice variable is the next-period state.
consumption = A*(gridK'*ones(1,dimK)).^alpha + (1-delta)*gridK'*ones(1,dimK)-ones(dimK,1)*gridK;
util=zeros(dimK,dimK);
for i=1:dimK
 for j=1:dimK
  if consumption(i,j)>0
   util(i,j)=u(consumption(i,j));
  else
   util(i,j)=u(consumption(2,1))-10^3;
  end
 end
end
%alternative
%util = ( u(consumption(2,1)) - 10^3 ) .* ones(dimK,dimK);
%mask = consumption > 0;
%util(mask) = u(consumption(mask));

%----------------------------------------------------------------
% Setting Parametric Values for the Value Function Iteration
%----------------------------------------------------------------
max_iter=1000;  %The Maximum Number of Iterations
toler=0.1^10;   %Tolerance Value
converge=0;
% converge is a binary variable, where it takes 1 when the value
% function iteration ended within the maximum number of rounds (max_iter).
% This is optional.

%----------------------------------------------------------------
% Initialize the Value Function (Initial Guess)
%----------------------------------------------------------------
% V is a (1, dim_K)-matrix with (1,i)-th element denoting
% the value (of a candidate value function)
% associated with state being i (precisely, gridK(i)).
% Here, simply let V be the vector of zero.
V=zeros(1,dimK);

tic %start stopwatch timer (optional)
for i=1:max_iter
  %Compute the LHS of the Bellman equation newV
  [newV,index]=max( (util + beta*ones(dimK,1)*V)' );
  %
  if norm(newV-V,Inf)<toler %alternative: if max(abs(newV-V))<toler
    converge=1;
    break;
  end %end of if
  V=newV;
  %
end %end of for i=1:max_iter
num_policy=A*gridK.^alpha+(1-delta)*gridK-gridK(index); %Policy function (c=w-w')
comp_time=toc; %end stopwatch timer and substitute time into comp_time (optional)

%----------------------------------------------------------------
% Checking Whether the Value Function Converged (Optional)
%----------------------------------------------------------------
if output_file==1
  dfile="deterministic_Ramsey_growth.txt";
  if exist(dfile, 'file')
    delete(dfile);
  end
  diary(dfile)
  diary on
end

if converge==1
  fprintf('The value function iteration converged with %d iterations.\n', i);
  fprintf('The value function iteration took %f seconds.\n', comp_time);
else
  fprintf('The value function iteration did not converge.\n');
end

if output_file==1
  diary off
end

%----------------------------------------------------------------
% Plotting Policy Function
%----------------------------------------------------------------
figure()
if delta==1 && gamma==1
 exact_policy=(1-alpha*beta)*A*gridK.^alpha;
 hold on
 plot(gridK,num_policy,'LineWidth',1);
 plot(gridK,exact_policy,'--','LineWidth',1);
 hold off
 if latex_interpreter==1
   legend('Numerical','Analytical','Location','southeast','Interpreter','latex');
 else
   legend('Numerical','Analytical','Location','southeast');
 end
else
 plot(gridK,num_policy,'LineWidth',1);
end
grid on
axis([min(gridK) max(gridK) 0.95*min(num_policy) 1.05*max(num_policy)]);
if latex_interpreter==1
  title('Optimal Policy Function','Interpreter','latex','FontSize',14);
  xlabel('Capital','Interpreter','latex','FontSize',12);
  ylabel('Consumption','Interpreter','latex','FontSize',12);
else
  title('Optimal Policy Function','FontSize',14);
  xlabel('Capital','FontSize',12);
  ylabel('Consumption','FontSize',12);
end

%----------------------------------------------------------------
% Plotting Value function
%----------------------------------------------------------------
figure()
if delta==1 && gamma==1
 exact_V= (1/(1-beta))*( (alpha*beta/(1-alpha*beta))*log(alpha*beta) + log(1-alpha*beta)+log(A)/(1-alpha*beta) )+(alpha/(1-alpha*beta))*log(gridK);
 hold on
 plot(gridK,V,'LineWidth',1);
 plot(gridK,exact_V,'--','LineWidth',1);
 hold off
 if latex_interpreter==1
   legend('Numerical','Analytical','Location','southeast','Interpreter','latex');
 else
   legend('Numerical','Analytical','Location','southeast');
 end
else
 plot(gridK,V,'LineWidth',1);
end
grid on
axis([min(gridK) max(gridK) min(V) max(V)]);
if latex_interpreter==1
  title('Value Function','Interpreter','latex','FontSize',14);
  xlabel('Capital','Interpreter','latex','FontSize',12);
  ylabel('Value','Interpreter','latex','FontSize',12);
else
  title('Value Function','FontSize',14);
  xlabel('Capital','FontSize',12);
  ylabel('Value','FontSize',12);
end

%----------------------------------------------------------------
% Computing Optimal Consumption/Capital Paths
%----------------------------------------------------------------
num_sim=2;            %number of simulations
num_period=30+1;      %number of periods for each simulation
Kindex=zeros(num_sim,num_period);  %node index
Ksim=zeros(num_sim,num_period);    %value of capital
Csim=zeros(num_sim,num_period);    %value of consumption
%
Ksim(1,1)=0.5*k_ss;   %initial capital level for the first simulation
Ksim(2,1)=1.5*k_ss;   %initial capital level for the second simulation

for i=1:num_sim
 for t=1:num_period
 %Find the node closest to a given state
 [~, Kindex(i,t)]=min(abs(Ksim(i,t)-gridK));
 %Capital and consumption at time t
 Ksim(i,t)=gridK(Kindex(i,t));
 Csim(i,t)=num_policy(Kindex(i,t));
 if t<num_period
  Ksim(i,t+1)=A*Ksim(i,t).^alpha+(1-delta)*Ksim(i,t)-Csim(i,t);
 end
 end
end

for i=1:num_sim
 figure()
 hold on
 plot(0:num_period-1,Csim(i,:),'LineWidth',1);
 plot(0:num_period-1,c_ss*ones(1,num_period),'--','LineWidth',1);
 grid on
 hold off
 if latex_interpreter==1
   xlabel('Period','Interpreter','latex','FontSize',12);
   ylabel('Consumption','Interpreter','latex','FontSize',12);
   title('Optimal Consumption Path','Interpreter','latex','FontSize',14);
   %legend('Optimal Path','Steady State','location','best','Interpreter','latex');
 else
   xlabel('Period','FontSize',12);
   ylabel('Consumption','FontSize',12);
   title('Optimal Consumption Path','FontSize',14);
   %legend('Optimal Path','Steady State','location','best');
 end
end

for i=1:num_sim
 figure()
 hold on
 plot(0:num_period-1,Ksim(i,:),'LineWidth',1);
 plot(0:num_period-1,k_ss*ones(1,num_period),'--','LineWidth',1);
 grid on
 hold off
 if latex_interpreter==1
   xlabel('Period','Interpreter','latex','FontSize',12);
   ylabel('Capital','Interpreter','latex','FontSize',12);
   title('Optimal Capital Path','Interpreter','latex','FontSize',14);
   %legend('Optimal Path','Steady State','location','best','Interpreter','latex');
 else
   xlabel('Period','FontSize',12);
   ylabel('Capital','FontSize',12);
   title('Optimal Capital Path','FontSize',14);
   %legend('Optimal Path','Steady State','location','best');
 end
end

figure()
hold on
plot(Ksim(1,:),Csim(1,:),'->','LineWidth',1);
plot(Ksim(2,:),Csim(2,:),'<-','LineWidth',1);
plot(gridK,A*gridK.^alpha-delta*gridK,'LineWidth',1);
plot(gridK,A*gridK.^alpha+(1-delta)*gridK-k_ss,'LineWidth',1);
plot(k_ss,c_ss,'ko','LineWidth',1);
grid on
hold off
xlim([k_min k_max]);
ylim([0.25*c_ss, 1.75*c_ss]);
if latex_interpreter==1
  xlabel('$k$','Interpreter','latex','FontSize',12);
  ylabel('$c$','Interpreter','latex','FontSize',12);
  legend('$k_{0}=0.5 k^{\ast}$','$k_{0}=1.5 k^{\ast}$','$\Delta k_{t+1}=0$','$\Delta c_{t+1}=0$','$(k^{\ast},c^{\ast})$','Interpreter','latex','location','northwest');
  title('Ramsey Growth Model: Phase Diagram','Interpreter','latex','FontSize',14);
else
  xlabel('k','FontSize',12);
  ylabel('c','FontSize',12);
  legend('k_0 =0.5 k*','k_0=1.5 k*','\Delta k_{t+1}=0','\Delta c_{t+1}=0','(k*,c*)','location','northwest');
  title('Ramsey Growth Model: Phase Diagram','FontSize',14);
end
