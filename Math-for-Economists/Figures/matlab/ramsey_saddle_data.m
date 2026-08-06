%================================================================
% ramsey_saddle_data.m
%
% Generates the coordinates embedded in Figures/ramsey-phase.tex: the
% global stable manifold of the continuous-time Ramsey system of
% Remark "Saddle-path stability" in the chapter on continuous time.
%
% System, with logarithmic utility so that gamma(c) == 1:
%       kdot = k^alpha - delta k - c
%       cdot = c ( alpha k^(alpha-1) - delta - rho )
% Parameters alpha = 0.3, delta = 0.1, rho = 0.05, as in the figure.
%
% The stable manifold is computed by integrating the system BACKWARDS in
% time from two points placed at distance 1e-9 from the steady state along
% the eigenvector of the negative eigenvalue.  Backward integration is the
% right direction: reversing time turns the stable eigenvalue lambda_s < 0
% into -lambda_s > 0, which carries the solution away from the steady state
% along the manifold, and turns the unstable eigenvalue lambda_u > 0 into
% -lambda_u < 0, so any component off the manifold contracts.  The manifold
% is therefore attracting for the reversed flow and the computation is
% numerically stable, which it would not be in forward time.
%
% Output: ramsey-saddle.dat, two columns k and c, the rows of the
% \addplot table for the stable arm in Figures/ramsey-phase.tex.
%
% Run: matlab -batch "run('ramsey_saddle_data.m')" from this folder.
%================================================================

clear
clc

alpha = 0.3;  delta = 0.1;  rho = 0.05;

%----------------------------------------------------------------
% Steady state and golden-rule stock
%----------------------------------------------------------------
kstar = (alpha/(rho+delta))^(1/(1-alpha));
cstar = kstar^alpha - delta*kstar;
kgold = (alpha/delta)^(1/(1-alpha));
fprintf('k* = %.6f, c* = %.6f, k^g = %.6f\n', kstar, cstar, kgold);

%----------------------------------------------------------------
% Jacobian at the steady state.  The (2,1) entry is c* f''(k*), which is
% negative because f is strictly concave; the determinant is therefore
% negative and the eigenvalues are real and of opposite sign.
%----------------------------------------------------------------
fpp = alpha*(alpha-1)*kstar^(alpha-2);
J   = [rho, -1; cstar*fpp, 0];
fprintf('f''''(k*) = %.6f\n', fpp);
fprintf('J = [%.6f %.6f ; %.6f %.6f]\n', J(1,1),J(1,2),J(2,1),J(2,2));
fprintf('trace %.6f, determinant %.6f\n', trace(J), det(J));

[Vec,Lam] = eig(J);
lam = diag(Lam);
[~,is] = min(lam);  [~,iu] = max(lam);
lam_s = lam(is);  lam_u = lam(iu);
v = Vec(:,is);  v = v/v(1);            % normalise to unit step in k
fprintf('eigenvalues %.6f and %.6f\n', lam_s, lam_u);
fprintf('stable eigenvector (1, %.6f): slope dc/dk at the steady state\n', v(2));
fprintf('half-life of the stable mode %.4f\n', log(2)/abs(lam_s));

%----------------------------------------------------------------
% Backward integration along the stable eigenvector, in both directions
%----------------------------------------------------------------
F = @(t,z) [ z(1)^alpha - delta*z(1) - z(2);
             z(2)*( alpha*z(1)^(alpha-1) - delta - rho ) ];
G = @(t,z) -F(t,z);                    % the reversed flow

kmin = 0.02;  kmax = 8.40;
stop = odeset('RelTol',1e-12,'AbsTol',1e-14, ...
              'Events',@(t,z) leaveBox(t,z,kmin,kmax));

eps0 = 1e-9;
[~,Zlo] = ode45(G,[0 400],[kstar;cstar] - eps0*v, stop);
[~,Zhi] = ode45(G,[0 400],[kstar;cstar] + eps0*v, stop);

arm = [flipud(Zlo); Zhi];              % ordered by increasing k
fprintf('backward orbit reaches k = %.4f below and k = %.4f above\n', ...
        Zlo(end,1), Zhi(end,1));

%----------------------------------------------------------------
% Checks
%----------------------------------------------------------------
% invariance: the chord slope between consecutive points must agree with
% the slope cdot/kdot of the vector field at their midpoint
mid   = (arm(1:end-1,:)+arm(2:end,:))/2;
chord = diff(arm(:,2))./diff(arm(:,1));
fld   = arrayfun(@(i) [0 1]*F(0,mid(i,:)')/([1 0]*F(0,mid(i,:)')), 1:size(mid,1))';
far   = abs(mid(:,1)-kstar) > 1e-3;      % the ratio is 0/0 at the rest point
fprintf('invariance: max relative gap between chord slope and cdot/kdot %.2e\n', ...
        max(abs(chord(far)-fld(far))./max(abs(fld(far)),1e-12)));
fprintf('monotone in k: %d ; c > 0 throughout: %d\n', ...
        all(diff(arm(:,1))>0), all(arm(:,2)>0));

kdot0 = arm(:,1).^alpha - delta*arm(:,1) - arm(:,2);
below = arm(:,1) < kstar - 1e-6;  above = arm(:,1) > kstar + 1e-6;
fprintf('kdot > 0 on the arm left of k*: %d ; kdot < 0 right of k*: %d\n', ...
        all(kdot0(below)>0), all(kdot0(above)<0));

% the arm lies below the kdot=0 locus left of k* and above it right of k*
locus = arm(:,1).^alpha - delta*arm(:,1);
fprintf('arm below the kdot=0 locus left of k*: %d ; above it right of k*: %d\n', ...
        all(arm(below,2)<locus(below)), all(arm(above,2)>locus(above)));

% tangency at the steady state, checked on the closest points
d  = abs(arm(:,1)-kstar);
nr = d < 0.05 & d > 1e-8;
sl = (arm(nr,2)-cstar)./(arm(nr,1)-kstar);
fprintf('slope near the steady state in [%.6f, %.6f], eigenvector slope %.6f\n', ...
        min(sl), max(sl), v(2));

%----------------------------------------------------------------
% Figure coordinates: thin to a readable number of points
%----------------------------------------------------------------
sel = unique([1, round(linspace(1,size(arm,1),160)), size(arm,1)]);
fid = fopen('ramsey-saddle.dat','w');
for i = sel
    fprintf(fid,'%.6f %.6f\n', arm(i,1), arm(i,2));
end
fclose(fid);
fprintf('wrote ramsey-saddle.dat with %d rows, k from %.4f to %.4f\n', ...
        numel(sel), arm(sel(1),1), arm(sel(end),1));

%----------------------------------------------------------------
% Event: stop when the orbit leaves the plotting box
%----------------------------------------------------------------
function [val,ister,dir] = leaveBox(~,z,kmin,kmax)
    val   = [z(1)-kmin; z(1)-kmax; z(2)-1e-6];
    ister = [1;1;1];
    dir   = [0;0;0];
end
