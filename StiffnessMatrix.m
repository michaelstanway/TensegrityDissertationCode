classdef StiffnessMatrix
    properties
        node_positions
        connectivity
        force_densities
        youngs_modulus
        cross_sectional_area
    end
    
    methods
        % Constructor method for the StiffnessMatrix class
        % Inputs: node_positions, connectivity, force_densities, youngs_modulus, cross_sectional_area
        function obj = StiffnessMatrix(node_positions, connectivity, force_densities, youngs_modulus, cross_sectional_area)
            obj.node_positions = node_positions;
            obj.connectivity = connectivity;
            obj.force_densities = force_densities;
            obj.youngs_modulus = youngs_modulus;
            obj.cross_sectional_area = cross_sectional_area;
        end
        
        % Compute the linear stiffness matrix of the structure
        % Output: linear_stiffness_matrix - 3Nx3N matrix, where N is the number of nodes
        function linear_stiffness_matrix = computeLinearStiffnessMatrix(obj)
            num_nodes = size(obj.node_positions, 1);
            num_members = size(obj.connectivity, 1);
            linear_stiffness_matrix = zeros(3 * num_nodes);
    
            for member = 1:num_members
                start_node = obj.connectivity(member, 1);
                end_node = obj.connectivity(member, 2);
                member_length = norm(obj.node_positions(end_node, :) - obj.node_positions(start_node, :));
    
                E = obj.youngs_modulus(member);
                A = obj.cross_sectional_area(member);
                k = (E * A) / member_length;
    
                direction = (obj.node_positions(end_node, :) - obj.node_positions(start_node, :)) / member_length;
                k_element = k * (direction' * direction);
    
                indices = [3 * start_node - 2 : 3 * start_node, 3 * end_node - 2 : 3 * end_node];
    
                temp = zeros(length(indices));
                temp(1:3, 1:3) = k_element;
                temp(4:6, 4:6) = k_element;
                temp(1:3, 4:6) = -k_element;
                temp(4:6, 1:3) = -k_element;
    
                linear_stiffness_matrix(indices, indices) = linear_stiffness_matrix(indices, indices) + temp;
            end
        end
    
        % Compute the geometric stiffness matrix of the structure
        % Output: geometric_stiffness_matrix - 3Nx3N matrix, where N is the number of nodes
        function geometric_stiffness_matrix = computeGeometricStiffnessMatrix(obj)
            num_nodes = size(obj.node_positions, 1);
            num_members = size(obj.connectivity, 1);
            geometric_stiffness_matrix = zeros(3 * num_nodes);
        
            for member = 1:num_members
                start_node = obj.connectivity(member, 1);
                end_node = obj.connectivity(member, 2);
                member_length = norm(obj.node_positions(end_node, :) - obj.node_positions(start_node, :));
        
                force_density = obj.force_densities(member);
        
                direction = (obj.node_positions(end_node, :) - obj.node_positions(start_node, :)) / member_length;
                k_element = force_density * (direction' * direction);
        
                indices = [3 * start_node - 2 : 3 * start_node, 3 * end_node - 2 : 3 * end_node];
        
                temp = zeros(length(indices));
                temp(1:3, 1:3) = k_element;
                temp(4:6, 4:6) = k_element;
                temp(1:3, 4:6) = -k_element;
                temp(4:6, 1:3) = -k_element;

                geometric_stiffness_matrix(indices, indices) = geometric_stiffness_matrix(indices, indices) + temp;
            end
        end
    end
end

               

