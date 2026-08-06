%================================================================
% pi_vs_vi_data.m
%
% Generates the coordinates embedded in Figures/pi-vs-vi.tex and the
% numbers quoted in Remark "Which algorithm to use" of the chapter on
% discrete-time dynamic programming.
%
% The figure is the numerical content of part (ii) of the theorem on
% policy iteration: started from the value W_0 of one stationary policy,
% the policy iterates dominate the value iterates from the same W_0 at
% every step.
%
% The problem is a randomly generated finite Markov decision problem.
% Transition rows are normalised cubes of uniforms so that the chains are
% not close to uniform; rewards are uniform on [0,1].  The seed is fixed
% so that the figure is reproducible.
%
% Output: pi-vs-vi.dat, four columns
%           m   ||W_m-V||_inf (policy)   ||W_m-V||_inf (value)   beta^m ||W_0-V||_inf
% which are the rows of the three \addplot tables in Figures/pi-vs-vi.tex.
%
% Run: matlab -batch "run('pi_vs_vi_data.m')" from this folder.
%================================================================

clear
clc
rng(3);

%----------------------------------------------------------------
% Problem
%----------------------------------------------------------------
nS   = 40;      % states
nA   = 8;       % actions available at every state
beta = 0.95;    % discount factor
K    = 45;      % sweeps plotted

r = rand(nS,nA);
P = zeros(nS,nA,nS);
for s = 1:nS
    for a = 1:nA
        v = rand(1,nS).^3;
        P(s,a,:) = v/sum(v);
    end
end

Tmax = @(W) max( r + beta*reshape(reshape(P,[],nS)*W(:),nS,nA), [], 2 )';
Ph   = @(h) cell2mat(arrayfun(@(s) squeeze(P(s,h(s),:))',1:nS,'uni',0)');
Wpol = @(h) ((eye(nS)-beta*Ph(h))\arrayfun(@(s) r(s,h(s)),1:nS)')';

%----------------------------------------------------------------
% Reference limit
%----------------------------------------------------------------
V = zeros(1,nS);
for i = 1:20000, V = Tmax(V); end

%----------------------------------------------------------------
% Both algorithms from the same starting function W_0 = W^{h_0}
%----------------------------------------------------------------
h0 = ones(1,nS);
W0 = Wpol(h0);

e_pi = zeros(1,K);  e_vi = zeros(1,K);
Wc = W0;  hc = h0;  Vi = W0;  settled = 0;
for m = 1:K
    Vi = Tmax(Vi);
    e_vi(m) = max(abs(Vi-V));

    Q = r + beta*reshape(reshape(P,[],nS)*Wc(:),nS,nA);
    [~,hn] = max(Q,[],2);  hn = hn';
    % tie-breaking: keep the incumbent action where it is already optimal
    for s = 1:nS
        if abs(Q(s,hc(s))-max(Q(s,:))) < 1e-14, hn(s) = hc(s); end
    end
    if isequal(hn,hc) && settled == 0, settled = m; end
    hc = hn;  Wc = Wpol(hc);
    e_pi(m) = max(abs(Wc-V));
end

env = max(abs(W0-V))*beta.^(1:K);

%----------------------------------------------------------------
% Report
%----------------------------------------------------------------
fprintf('states %d, actions %d, beta %.2f\n',nS,nA,beta);
fprintf('policy sequence constant from step %d\n', settled);
fprintf('policy iteration errors, first six: %s\n', mat2str(e_pi(1:6),3));
fprintf('value  iteration errors, first six: %s\n', mat2str(e_vi(1:6),3));
fprintf('value iteration error after %d sweeps: %.4f\n', K, e_vi(K));
fprintf('policy iteration floor: %.3e\n', e_pi(K));
fprintf('dominance e_pi <= e_vi at every step: %d\n', all(e_pi <= e_vi + 1e-12));
fprintf('value iterates below the envelope at every step: %d\n', all(e_vi <= env + 1e-12));

%----------------------------------------------------------------
% Figure coordinates
%----------------------------------------------------------------
fid = fopen('pi-vs-vi.dat','w');
for m = 1:K
    fprintf(fid,'%d %.10e %.10e %.10e\n', m, ...
            max(e_pi(m),1e-16), max(e_vi(m),1e-16), env(m));
end
fclose(fid);
fprintf('wrote pi-vs-vi.dat with %d rows\n',K);
