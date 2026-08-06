%================================================================
% octave_variants_check.m
%
% Runs the five Octave variants that accompany the course and produces
% the numbers quoted for them in the chapters on projection, static
% optimisation and dynamic programming.
%
% Sources, none of which is modified:
%   Gerzensee/Math Camp/Supplementary/codes/consumer_choice_sqp_Octave.m
%   Gerzensee/Math Camp/Supplementary/codes/two_periods_consumption_sqp_Octave.m
%   Gerzensee/Math Camp/Supplementary/codes/Nash_bargaining_sqp_Octave.m
%   Gerzensee/Math Camp/Supplementary/codes/regression_Octave.m
%   Gerzensee/Math Camp/Supplementary/codes/Lucas_Tree_DP_Octave.m
%
% No Octave interpreter is installed on this machine, so each source is
% translated line by line into MATLAB syntax and run here:
%   pkg load statistics        deleted (the toolbox is present)
%   function ... endfunction   local function ... end, or an anonymous handle
%   rng("default")             rng('default')
%   sqp(x0,phi,[],h,lb,ub)     fmincon with the 'sqp' algorithm, the Octave
%                              convention h(x) >= 0 written as -h(x) <= 0
% Nothing else is altered.  What this verifies is what the sources
% compute, not the behaviour of Octave's own sqp implementation.
%
% Run: matlab -batch "run('octave_variants_check.m')" from this folder.
%================================================================

clear
clc
format long g

opts = optimoptions('fmincon','Algorithm','sqp','Display','off', ...
                    'OptimalityTolerance',1e-12,'StepTolerance',1e-14, ...
                    'ConstraintTolerance',1e-12);

%----------------------------------------------------------------
% 1. consumer_choice_sqp_Octave.m
%----------------------------------------------------------------
fprintf('=== consumer_choice_sqp_Octave ===\n');
alpha = 0.7;  A = [1, 1];  b = 1;
phi     = @(x) -(x(1).^alpha).*(x(2).^(1-alpha));
h       = @(x) b - A*x;                    % Octave convention h(x) >= 0
nonlcon = @(x) deal(-h(x), []);            % fmincon convention c(x) <= 0
[x,obj,~,~,lam] = fmincon(phi,[0.1;0.1],[],[],[],[],[0;0],[1e10;1e10],nonlcon,opts);
fprintf('alpha=%.3f, p1=%.3f, p2=%.3f, m=%.3f\n',alpha,A(1),A(2),b);
fprintf('Optimal consumption: %.6f,%.6f\n',x(1),x(2));
fprintf('Utility: %.6f\n',-obj);
fprintf('Multiplier (budget const): %.6f\n',lam.ineqnonlin(1));
fprintf('Multiplier (non-negativity const): %.6f, %.6f\n',lam.lower(1),lam.lower(2));
fprintf('closed form: x*=(%.6f,%.6f), v=lambda=%.6f\n', ...
        alpha*b/A(1), (1-alpha)*b/A(2), alpha^alpha*(1-alpha)^(1-alpha));

%----------------------------------------------------------------
% 2. two_periods_consumption_sqp_Octave.m
%----------------------------------------------------------------
fprintf('\n=== two_periods_consumption_sqp_Octave ===\n');
beta = 0.9;  R0 = 1.05;  a_rhs = 1;
phi2     = @(x) -(log(x(1)) + beta*log(x(2)));
h2       = @(x) a_rhs - [1, (1/R0)]*x;
nonlcon2 = @(x) deal(-h2(x), []);
[x2,obj2,~,~,lam2] = fmincon(phi2,[0.5;0.5],[],[],[],[],[0;0],[1e10;1e10],nonlcon2,opts);
fprintf('beta=%.3f, R0=%.3f, A=%.3f\n',beta,R0,a_rhs);
fprintf('Optimal consumption in two periods: %.6f,%.6f\n',x2(1),x2(2));
fprintf('Lifetime Utility: %.6f\n',-obj2);
fprintf('Multiplier (intertemporal budget const): %.6f\n',lam2.ineqnonlin(1));
c1 = a_rhs/(1+beta);  c2 = beta*R0*a_rhs/(1+beta);
fprintf('closed form: c=(%.6f,%.6f), U=%.6f, lambda=%.6f\n', ...
        c1, c2, log(c1)+beta*log(c2), 1/c1);

%----------------------------------------------------------------
% 3. Nash_bargaining_sqp_Octave.m
%----------------------------------------------------------------
fprintf('\n=== Nash_bargaining_sqp_Octave ===\n');
phi3     = @(x) -x(1)*x(2);
h3       = @(x) 1 - x(1)^2 - x(2)^2;       % the frontier in the source is a circle
nonlcon3 = @(x) deal(-h3(x), []);
[x3,obj3,~,~,lam3] = fmincon(phi3,[0.1,0.1],[],[],[],[],[0,0],[1,1],nonlcon3,opts);
fprintf('Nash Bargaining Solution: %.6f,%.6f\n',x3(1),x3(2));
fprintf('product = %.6f, multiplier = %.6f\n',-obj3,lam3.ineqnonlin(1));
fprintf('closed form: (%.6f,%.6f), product %.6f, multiplier %.6f\n', ...
        1/sqrt(2), 1/sqrt(2), 0.5, 0.5);

%----------------------------------------------------------------
% 4. regression_Octave.m
%----------------------------------------------------------------
fprintf('\n=== regression_Octave ===\n');
n = 500;  beta_vec = [1 3]';
rng(0);
x4 = randn(n,1);
e4 = randn(n,1);
X4 = [ones(n,1) x4];
y4 = X4*beta_vec + e4;
beta_hat   = inv(X4'*X4)*X4'*y4;   %#ok<MINV>  as written in the source
beta_hat_2 = regress(y4,X4);
fprintf('Projection: beta=(%f,%f)\n',beta_hat(1),beta_hat(2));
fprintf('regress:    beta=(%f,%f)\n',beta_hat_2(1),beta_hat_2(2));
fprintf('max |projection - regress| = %.3e\n',max(abs(beta_hat-beta_hat_2)));
fprintf(['note: the second fprintf of the source is labelled regress but ' ...
         'prints beta_hat, not beta_hat_2\n']);

%----------------------------------------------------------------
% 5. Lucas_Tree_DP_Octave.m
%----------------------------------------------------------------
fprintf('\n=== Lucas_Tree_DP_Octave ===\n');
gam = 1.0;  bet = 0.95;  alph = 0.9;  sig = 0.1;
ssd   = sig/sqrt(1-alph^2);
y_vec = linspace(exp(-4*ssd),exp(4*ssd),100);
dim_y = numel(y_vec);
epsilon = normrnd(0,1,1,500);           %#ok<NASGU>  unseeded in the source, unused
rng('default');                          % the source seeds only what follows
r_ln = lognrnd(0,sig,1,500);
hvec = zeros(1,dim_y);
for i = 1:dim_y
    hvec(i) = bet*mean(((y_vec(i)^alph).*r_ln).^(1-gam));
end
f = zeros(1,dim_y);  f_new = zeros(1,dim_y);
converge = 0;  toler = 0.1^4;
tic
for ell = 1:2000
    for i = 1:dim_y
        f_new(i) = hvec(i) + bet*mean( interp1(y_vec,f, ...
                   (y_vec(i).^alph).*r_ln,'spline','extrap') );
    end
    if norm(f_new-f,Inf) < toler, converge = 1; break, end
    f = f_new;
end
comp_time = toc;
price = f.*y_vec.^gam;
exact = (bet/(1-bet))*y_vec;
if converge == 1
    fprintf('The value function iteration converged with %d iterations.\n',ell);
    fprintf('The value function iteration took %f seconds.\n',comp_time);
else
    fprintf('The value function iteration did not converge.\n');
end
fprintf('max |price - beta*y/(1-beta)| = %.6f (relative %.4f%%)\n', ...
        max(abs(price-exact)), 100*max(abs(price-exact)./exact));
