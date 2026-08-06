%================================================================
% vfi_error_data.m
%
% Generates the coordinates embedded in Figures/vfi-error.tex and the
% numbers quoted in Remark "What the numerical solution adds" of the
% chapter on discrete-time dynamic programming.
%
% Source program: Gerzensee/Math Camp/Supplementary/codes/DP_cake_eating.m
% That file is NOT modified.  Its recursion is reproduced here under two
% encodings of the cells in which no positive consumption is feasible:
%
%   (a) the sentinel of the supplied code,
%           consumption(consumption<=0) = 0.1^16;
%   (d) minus infinity on those cells, together with the analytic value
%       of Proposition "Cake eating: closed form" at the lowest node,
%       which is the boundary condition the truncated state space needs.
%
% Encoding (b), minus infinity alone, is deliberately included in the
% report below: it fails, because the second node's only feasible
% continuation is the lowest node, so the value -Inf propagates upwards
% and every node becomes -Inf.
%
% Output: vfi-error.dat, five columns
%           w   |V-V*| (a)   |h-h*| (a)   |V-V*| (d)   |h-h*| (d)
% which are the rows of the four \addplot tables in Figures/vfi-error.tex.
%
% Run: matlab -batch "run('vfi_error_data.m')" from this folder.
%================================================================

clear
clc

%----------------------------------------------------------------
% Grid and parameters, taken from DP_cake_eating.m
%----------------------------------------------------------------
dimW  = 2000;
gridW = linspace(0.001,1,dimW);
beta  = 0.85;
max_iter = 1000;

%----------------------------------------------------------------
% Closed form of Proposition "Cake eating: closed form"
%   V(w) = log(1-beta)/(1-beta) + beta*log(beta)/(1-beta)^2 + log(w)/(1-beta)
%   h(w) = (1-beta)*w
%----------------------------------------------------------------
A0      = (log(1-beta)/(1-beta)) + (beta/((1-beta)^2))*log(beta);
exact_V = A0*ones(1,dimW) + log(gridW)./(1-beta);
exact_h = (1-beta)*gridW;

%----------------------------------------------------------------
% Consumption matrix: (i,j) entry is gridW(i) - gridW(j)
%----------------------------------------------------------------
raw = gridW'*ones(1,dimW) - ones(dimW,1)*gridW;

U_a = log(max(raw,0.1^16));  U_a(raw<=0) = log(0.1^16);   % encoding (a)
U_b = log(raw);              U_b(raw<=0) = -Inf;          % encoding (b)/(d)

%----------------------------------------------------------------
% Value function iteration under each encoding
%----------------------------------------------------------------
tol_supplied = 0.1^16;                    % the tolerance in the source
tol_target   = 1e-8;                      % target accuracy on V
tol_repaired = tol_target*(1-beta)/beta;  % the tolerance that certifies it

[V_a,idx_a,it_a] = vfi(U_a,beta,max_iter,tol_supplied,dimW,[]);
[V_d,idx_d,it_d] = vfi(U_b,beta,max_iter,tol_repaired,dimW,exact_V(1));

% Encoding (b) needs one sweep per node for -Inf to reach the top of the
% grid, so it is run for dimW+100 sweeps rather than max_iter.
[V_b,~    ,it_b] = vfi(U_b,beta,dimW+100,tol_supplied,dimW,[]);

pol_a = gridW - gridW(idx_a);
pol_d = gridW - gridW(idx_d);

%----------------------------------------------------------------
% Report: every number quoted in the remark
%----------------------------------------------------------------
hi = gridW>=0.1;
fprintf('--- (a) sentinel 1e-16, tolerance 1e-16 -------------------------\n');
fprintf('iterations                              %d\n', it_a);
fprintf('lowest node: policy c = %.6f, V = %.4f (exact %.4f)\n', ...
        pol_a(1), V_a(1), exact_V(1));
fprintf('value error at the lowest node          %.4f\n', abs(V_a(1)-exact_V(1)));
fprintf('value error over nodes 2..N (max)       %.4f\n', max(abs(V_a(2:end)-exact_V(2:end))));
fprintf('value error over w >= 0.1 (max)         %.4f\n', max(abs(V_a(hi)-exact_V(hi))));
fprintf('value error at w = 1                    %.4f\n', abs(V_a(end)-exact_V(end)));
fprintf('policy error over nodes 2..N (max)      %.6f\n', max(abs(pol_a(2:end)-exact_h(2:end))));

fprintf('\n--- (b) -Inf alone, no boundary condition -----------------------\n');
fprintf('sweeps %d ; nodes still finite: %d of %d\n', ...
        it_b, sum(isfinite(V_b)), dimW);
fprintf('the -Inf reaches one further node per sweep, so after %d sweeps\n', dimW);
fprintf('every node has value -Inf and the encoding is unusable\n');

fprintf('\n--- (d) -Inf with the analytic value at the lowest node ---------\n');
fprintf('iterations                              %d\n', it_d);
fprintf('lowest node: policy c = %.6f, V = %.4f\n', pol_d(1), V_d(1));
fprintf('value error over nodes 2..N (max)       %.4f\n', max(abs(V_d(2:end)-exact_V(2:end))));
fprintf('value error over w >= 0.1 (max)         %.6f\n', max(abs(V_d(hi)-exact_V(hi))));
fprintf('value error at w = 1                    %.6f\n', abs(V_d(end)-exact_V(end)));
fprintf('policy error over nodes 2..N (max)      %.6e\n', max(abs(pol_d(2:end)-exact_h(2:end))));
fprintf('grid spacing                            %.6e\n', gridW(2)-gridW(1));

%----------------------------------------------------------------
% Contraction rate, measured
%----------------------------------------------------------------
N = 45;  e = zeros(1,N);  W = zeros(1,dimW);
for m = 1:N
    W = max( (U_a + beta*ones(dimW,1)*W)' );
    e(m) = max(abs(W(2:end)-V_a(2:end)));
end
fprintf('\nmeasured log error ratio (m=10 to 30)   %.6f   (log beta = %.6f)\n', ...
        log(e(30)/e(10))/20, log(beta));

%----------------------------------------------------------------
% Floating-point resolution of the supplied stopping rule
%----------------------------------------------------------------
fprintf('largest |V| under (a) %.4f, eps there %.3e, tolerance %.1e\n', ...
        max(abs(V_a)), eps(max(abs(V_a))), tol_supplied);

%----------------------------------------------------------------
% Figure coordinates: 120 log-spaced nodes, first node omitted
%----------------------------------------------------------------
sel = unique(round(logspace(log10(2),log10(dimW),120)));
fid = fopen('vfi-error.dat','w');
for k = sel
    fprintf(fid,'%.6f %.6e %.6e %.6e %.6e\n', gridW(k), ...
            abs(V_a(k)-exact_V(k)), abs(pol_a(k)-exact_h(k))+1e-12, ...
            abs(V_d(k)-exact_V(k)), abs(pol_d(k)-exact_h(k))+1e-12);
end
fclose(fid);
fprintf('\nwrote vfi-error.dat with %d rows, w from %.6f to %.6f\n', ...
        numel(sel), gridW(sel(1)), gridW(sel(end)));

%----------------------------------------------------------------
% Value function iteration.  bnd, when non-empty, holds the lowest node
% at a prescribed value after every sweep (the Dirichlet condition).
%----------------------------------------------------------------
function [V,index,iters] = vfi(U,beta,max_iter,toler,dimW,bnd)
    V = zeros(1,dimW);
    if ~isempty(bnd), V(1) = bnd; end
    index = ones(1,dimW);
    iters = max_iter;
    for i = 1:max_iter
        [newV,index] = max( (U + beta*ones(dimW,1)*V)' );
        if ~isempty(bnd), newV(1) = bnd; end
        if norm(newV-V,Inf) < toler
            V = newV;  iters = i;  break
        end
        V = newV;  iters = i;
    end
end
