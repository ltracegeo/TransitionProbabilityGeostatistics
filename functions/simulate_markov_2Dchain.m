function [simulation] = simulate_markov_2Dchain(P_hor, P_ver, prior_map, initial_facies)

n_facies = size(P_ver,1);

% If input of prior map probability 
I = size(prior_map,1);
J = size(prior_map,2);    

simulation = zeros(I,J);
if nargin < 4
    initial_facies = round(rand*n_facies + 0.5);    
    simulation(1,:) = simulate_markov_chain(P_hor,J,initial_facies,1);                         
else
    simulation(1,:) = initial_facies;
end
    

% Simulate the first chain for the first line
for i = 2:I
    %% CMC - it sucks
    %initial_facies = round(rand*n_facies + 0.5);
    %[prior_trace] = calculate_markov_horizontal_probability(P_hor, prior_map(:,j,:), simulation(:,j-1));
    %simulation(:,j) = simulate_markov_chain(P_ver,I,initial_facies,1,prior_trace);           

    %% Proposed methodology - random sequential horizontal sampling conditioned to the simulation on top.
    random_path = randperm(length(1:J));
    
    % Simulate the first facies at a random position conditioned to the top
    i1 = random_path(1);
    probabilities = P_ver(simulation(i-1,i1),:).*reshape(prior_map(i,i1,:),1,n_facies);
    probabilities = probabilities./sum(probabilities);
    facies = find( rand < cumsum( probabilities ));
    simulation(i,i1) = facies(1);        
        
    % Simulate the second facies at a random position conditioned to the top and to the fisrt
    i2 = random_path(2);    
    P_temp = P_hor^abs(i2-i1);
    probabilities = P_temp(simulation(i,i1)) .* P_ver(simulation(i-1,i2),:).*reshape(prior_map(i,i2,:),1,n_facies);
    probabilities = probabilities./sum(probabilities);
    facies = find( rand < cumsum( probabilities ));
    simulation(i,i2) = facies(1);            
    
    % Simulate all the other facies in a random sequence conditioned to the top and the closest facies in the horizontal direction
    for j = random_path(3:end)
        indexes_simulated = find( simulation(i,:)~=0 );
        distances = abs( j - indexes_simulated + 0.1 );
        minimos = sort(distances);
        minimos = minimos(1:2);
                
        i1 = find(distances == minimos(1));
        P1 = P_hor^minimos(1);
        i2 = find(distances == minimos(2));
        P2 = P_hor^minimos(2);
        
        probabilities = P1(simulation(i,indexes_simulated(i1)),:) .* P2(simulation(i,indexes_simulated(i2)),:)  .* P_ver(simulation(i-1,j),:) .* reshape(prior_map(i,j,:),1,n_facies);        
        probabilities = probabilities(1,:)./sum(probabilities(1,:));
        facies = find( rand < cumsum( probabilities ));

        simulation(i,j) = facies(1);                    
        
        %imagesc(simulation)
        %drawnow
    end   
    
    
end

end