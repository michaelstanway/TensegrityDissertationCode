classdef TensegrityModelling
    properties
        node_positions
        connectivity
        mass_per_unit_length
        g
        tension_members
    end
    
    methods
        % Constructor for TensegrityModelling class
        % Input parameters:
        %   node_positions: Nx3 matrix of nodal coordinates
        %   connectivity: Mx2 matrix representing member connections
        %   mass_per_unit_length: Mx1 vector of member mass per unit length
        %   g: 3x1 vector representing gravitational acceleration
        %   tension_members: Px1 vector of indices of members in tension
        function obj = TensegrityModelling(node_positions, connectivity, mass_per_unit_length, g, tension_members)
            obj.node_positions = node_positions;
            obj.connectivity = connectivity;
            obj.mass_per_unit_length = mass_per_unit_length;
            obj.g = g;
            obj.tension_members = tension_members;
        end

        % Compute equilibrium matrix A
        % Output: equilibrium_matrix - (3N)xM matrix, where N is the number of nodes and M is the number of members
        function equilibrium_matrix = computeEquilibriumMatrix(obj)
            num_nodes = size(obj.node_positions, 1);
            num_members = size(obj.connectivity, 1);
            equilibrium_matrix = zeros(3 * num_nodes, num_members);
        
            % Iterate through members
            for member = 1:num_members
                start_node = obj.connectivity(member, 1);
                end_node = obj.connectivity(member, 2);
        
                % Calculate normalized direction vector of the member
                vec = obj.node_positions(end_node, :) - obj.node_positions(start_node, :);
                vec = vec / norm(vec);
        
                % Populate equilibrium_matrix with the negative and positive direction vectors for the respective nodes
                equilibrium_matrix(3 * start_node - 2 : 3 * start_node, member) = -vec';
                equilibrium_matrix(3 * end_node - 2 : 3 * end_node, member) = vec';
            end
        end
        
        % Compute global mass matrix M_global and gravitational forces F_g
        % Output: 
        %   M_global - (3N)x(3N) mass matrix, where N is the number of nodes
        %   gravitational_forces - (3N)x1 vector of gravitational forces on nodes
        function [M_global, gravitational_forces] = computeGlobalMassMatrixAndGravitationalForces(obj)
            num_nodes = size(obj.node_positions, 1);
            num_members = size(obj.connectivity, 1);
            M_global = zeros(3 * num_nodes);

            % Iterate through members
            for i = 1:num_members
                n1 = obj.connectivity(i, 1);
                n2 = obj.connectivity(i, 2);
                n1_coord = obj.node_positions(n1, :);
                n2_coord = obj.node_positions(n2, :);
                
                % Calculate element length and mass
                element_length = norm(n1_coord - n2_coord);
                element_mass = obj.mass_per_unit_length(i) * element_length;
                
                % Compute element mass matrix
                C = element_mass / 6;
                element_mass_matrix = [2 * C, C; C, 2 * C];
                
                % Indices for adding element mass matrix to M_global
                indices = [3 * n1 - 2 : 3 * n1, 3 * n2 - 2 : 3 * n2];
                
                % Add element mass matrix to M_global
            temp = zeros(length(indices));
            temp(1:2, 1:2) = element_mass_matrix;
            temp(3:4, 3:4) = element_mass_matrix;
            
            M_global(indices, indices) = M_global(indices, indices) + temp;
        end

        % Compute gravitational forces
        G = obj.g;
        gravitational_forces = M_global * G;
    end
    
        % Fix specified nodes by removing corresponding rows from the equilibrium matrix
        % Input: fixed_nodes - vector containing indices of nodes to be fixed
        % Output: fixed_nodes_indices - vector containing indices of fixed nodes in the equilibrium matrix
        function fixed_nodes_indices = fix_nodes(obj, fixed_nodes)
            num_nodes = size(obj.node_positions, 1);
            fixed_nodes_indices = [];
            for i = 1:numel(fixed_nodes)
                fixed_node = fixed_nodes(i);
                fixed_nodes_indices = [fixed_nodes_indices, 3 * fixed_node - 2 : 3 * fixed_node];
            end
        end
        
        % Compute force densities Q
        % Input: fixed_nodes - vector containing indices of nodes to be fixed
        % Output: force_densities - Mx1 vector of force densities, where M is the number of members
        function force_densities = computeForceDensities(obj, fixed_nodes)
            A = obj.computeEquilibriumMatrix();
            [~, gravitational_forces] = obj.computeGlobalMassMatrixAndGravitationalForces();
            F = gravitational_forces;
            
            fixed_nodes_indices = obj.fix_nodes(fixed_nodes);
            
            % Remove rows corresponding to fixed nodes from the equilibrium matrix and force vector
            A_fixed = A;
            A_fixed(fixed_nodes_indices, :) = [];
            F_fixed = F;
            F_fixed(fixed_nodes_indices) = [];
            
            % Check if the system is underdetermined
            if size(A_fixed, 1) < size(A_fixed, 2)
                warning('The system is underdetermined. Finding a least-squares solution for force densities.');
            end
            
            % Check if A_fixed is rank deficient
            rank_A_fixed = rank(A_fixed);
            if rank_A_fixed < size(A_fixed, 2)
                warning('The matrix A_fixed is rank deficient. Finding a least-squares solution for force densities.');
            end
            
            % Solve the linear system AQ = F for force densities (Q) using the pseudoinverse
            force_densities = pinv(A_fixed) * F_fixed;
            
            % Set the force densities of tension elements to positive
            force_densities(obj.tension_members) = abs(force_densities(obj.tension_members));
        end
    end
end

        