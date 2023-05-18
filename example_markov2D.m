

addpath('functions')

n_facies = 3;

% Horizontal transition matrix (MUST BE SYMMETRIC * * * * *)
P_hor = [0.8 0.1 0.1;
         0.1 0.8 0.1;
         0.1 0.1 0.8];

%% Vertical transition matrix
% Example 1 - Anisotropic transition probabilities
P_ver = [0.8 0.2 0.0;
         0.15 0.7 0.15;
         0.1 0.1 0.8];     		 

% Example 1 - Isotropic transition probabilities
%P_ver = P_hor;



% Simulation grid size
I = 200;
J = 300;
prior_map = ones(I,J,n_facies);
     

[simulation] = simulate_markov_2Dchain(P_hor, P_ver, prior_map);

figure
imagesc(simulation)