%================================================================
% Deterministic Cake-Eating Problem: Value Function Iteration
%================================================================

clear
clc

%LaTeX Interpreter if ==1 (requires LaTeX to be installed if compiled on Octave)
latex_interpreter=0;

%----------------------------------------------------------------
% CRRA Utility Function
%----------------------------------------------------------------
gamma=1; %gamma>0
if gamma==1
 u = @(c)log(c);
else
 u = @(c) (c.^(1-gamma)-1)/(1-gamma);
end

%----------------------------------------------------------------
% Uniform Grid on Cake Size
%----------------------------------------------------------------
dimW=2000;                    %number of nodes
gridW=linspace(0.005,1,dimW); %uniform grid over cake size
% It starts with 0.005 in case u(0) is not well-defined.

%----------------------------------------------------------------
% Defining the Auxiliary Matrix of Consumption
% for Each Combination of Today and Tommorow's States
%----------------------------------------------------------------
% Consumption can be recovered from current and next period states.
% Creating the (dimW,dimW)-matrix such that an (i,j) element is
% the amount of consumption associated with
% w=gridW(i) (current state is the i-th node) and
% w_prime=gridW(j) (next period's state is the j-th node).
% Note that a choice variable is the next-period state.
consumption = gridW'*ones(1,dimW)-ones(dimW,1)*gridW;
consumption(consumption<=0)=0.1^20;
% gridW'*ones(1,dimW) yields the (dimW,dimW) matrix ( gridW' ... gridW' )
% ones(dimW,1)*grid yields the (dimW,dimW) matrix ( gridW; ... gridW )
% Replace non-positive (infeasible) consumption with
% something sufficiently close to zero.

%----------------------------------------------------------------
% Setting Parametric Values for the Value Function Iteration
%----------------------------------------------------------------
beta=0.85;                %Discount Factor
max_iter=30;              %The Maximum Number of Iterations
V=zeros(max_iter+1,dimW); %Value functions

%----------------------------------------------------------------
% Value function Iteration
%----------------------------------------------------------------
tic %start stopwatch timer (optional)
for i=1:max_iter
  [V(i+1,:),index]=max( (u(consumption) + beta*ones(dimW,1)*V(i,:))' );
end %end of for
comp_time=toc; %end stopwatch timer and substitute time into comp_time (optional)
fprintf(' Time: %f seconds.\n', comp_time);

%----------------------------------------------------------------
% Plotting Value functions
%----------------------------------------------------------------
exact_V= ((log(1-beta)/(1-beta))+ (beta/((1-beta)^2))*log(beta))*ones(1,dimW)+ (log(gridW)./(1-beta));
figure()
hold on
grid on
plot(gridW, V,'LineWidth',1);
plot(gridW, exact_V,'k--','LineWidth',1);
hold off
if latex_interpreter==1
  title('Value Function Iteration','Interpreter','latex','Fontsize',14);
  xlabel('Size of Cake','Interpreter','latex','Fontsize',12);
  ylabel('Value','Interpreter','latex','Fontsize',12);
else
  title('Value Function Iteration','Fontsize',14);
  xlabel('Size of Cake','Fontsize',12);
  ylabel('Value','Fontsize',12);
end
