YoungsModulus = [2030000000 2030000000 2030000000 2030000000 2030000000 2030000000 2030000000 2030000000 2030000000 2030000000 2030000000 2030000000 2030000000 2030000000 2900000000 2900000000 2900000000 2900000000];
CrossSectionalArea = [0.00002 0.00002 0.00002 0.000016 0.000016 0.000016 0.000016 0.00002 0.00002 0.00002 0.000016 0.000016 0.00002 0.00002 0.000000385 0.000000385 0.000000385 0.000000385];
mass_per_unit_length = [0.022 0.022 0.022 0.0176 0.0176 0.0176 0.0176 0.022 0.022 0.022 0.0176 0.0176 0.022 0.022 0.00044275 0.00044275 0.00044275 0.00044275];

node_positions = [0 0 0;
                  0 6 0;
                  5.196152423 3 0;
                  3.696152423 3 0;
                  3 3 2.5;
                  2 3 2.5;
                  1.5 3 2.5;
                  0 0 1.8;
                  0 6 1.8;
                  5.196152423 3 1.8;
                  0 3 1.8;
                  1.5 3 0.1;
                  2 3 0.1;
                  2.5 3 0.1];

connectivity = [1 2; 1 3; 3 4;  4 5;  5 6; 6 7; 11 12; 8 10; 8 11; 11 9; 12 13; 13 14; 9 10; 2 3; 1 8; 2 9; 3 10; 6 13];
num_nodes = height(node_positions);
g = zeros(3 * size(node_positions, 1), 1);
g(3:3:end) = -9.81; % Set the gravitational acceleration to -9.81 m/s² for each node in the z-direction (assuming the Z-axis as vertical)



tension_members = [15, 16, 17, 18]; % Replace with the actual indices of tension elements in your structure
tensegrity_model = TensegrityModelling(node_positions, connectivity, mass_per_unit_length, g, tension_members);

% Fix the specified nodes
fixed_nodes = [1, 2, 3, 4]; % Example: fixing nodes 1 and 2
fixed_nodes_indices = tensegrity_model.fix_nodes(fixed_nodes);

% Compute the equilibrium matrix
equilibrium_matrix = tensegrity_model.computeEquilibriumMatrix();

% Compute the global mass matrix and gravitational forces
[M_global, gravitational_forces] = tensegrity_model.computeGlobalMassMatrixAndGravitationalForces();

% Compute the force densities
force_densities = tensegrity_model.computeForceDensities(fixed_nodes);

% Create a StiffnessMatrix object
stiffness_matrix = StiffnessMatrix(node_positions, connectivity, force_densities, YoungsModulus, CrossSectionalArea);

% Compute the linear stiffness matrix
linear_stiffness_matrix = stiffness_matrix.computeLinearStiffnessMatrix();

% Compute the geometric stiffness matrix
geometric_stiffness_matrix = stiffness_matrix.computeGeometricStiffnessMatrix();

% Calculate the tangent stiffness matrix
tangent_stiffness_matrix = linear_stiffness_matrix + geometric_stiffness_matrix;

% Generate the R matrix
all_nodes = 1:num_nodes; % A list of all nodes
free_nodes = setdiff(all_nodes, fixed_nodes); % Find the free nodes by excluding the fixed nodes
R = generateRigidBodyModes(fixed_nodes, free_nodes, num_nodes);

% Compute reduced matrices
M_reduced = R' * M_global * R;
K_reduced = R' * tangent_stiffness_matrix * R;

% Create a NaturalFrequencies object
natural_frequencies_obj = NaturalFrequencies(K_reduced, M_reduced);

% Compute the natural frequencies
natural_frequencies = natural_frequencies_obj.computeNaturalFrequencies();

% Display the results
disp('Natural Frequencies:');
disp(natural_frequencies);

function [R] = generateRigidBodyModes(~, free_nodes, num_nodes)
    R = zeros(3 * num_nodes, length(free_nodes) * 6);
    col_idx = 1;

    for node_idx = free_nodes
        idx = (node_idx - 1) * 3 + 1;

        % Translations (x, y, and z)
        R(idx, col_idx) = 1;
        R(idx + 1, col_idx + 1) = 1;
        R(idx + 2, col_idx + 2) = 1;

        % Rotations (around x, y, and z)
        R(idx + 1, col_idx + 3) = 1;
        R(idx + 2, col_idx + 4) = -1;
        R(idx, col_idx + 5) = 1;
        R(idx + 2, col_idx + 6) = 1;
        R(idx, col_idx + 7) = -1;
        R(idx + 1, col_idx + 8) = 1;

        col_idx = col_idx + 6;
    end
end