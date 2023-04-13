classdef NaturalFrequencies
    properties
        tangent_stiffness_matrix
        mass_matrix
    end
    
    methods
        % Constructor method
        function obj = NaturalFrequencies(tangent_stiffness_matrix, mass_matrix)
            obj.tangent_stiffness_matrix = tangent_stiffness_matrix;
            obj.mass_matrix = mass_matrix;
        end
        
        % Method to compute natural frequencies
        function frequencies = computeNaturalFrequencies(obj)
            % Compute the total tangent stiffness matrix
            K_total = obj.tangent_stiffness_matrix;
            
            % Calculate the eigenvalues and eigenvectors of the system
            [eigenvectors, eigenvalues] = eig(K_total, obj.mass_matrix);
            
            % Extract the diagonal elements of the eigenvalue matrix
            eigenvalues = diag(eigenvalues);
            
            % Filter out the real eigenvalues
            real_eigenvalues = eigenvalues(imag(eigenvalues) == 0);
            
            % Sort the real eigenvalues in ascending order
            sorted_real_eigenvalues = sort(real_eigenvalues);
            
            % Retain only the positive real eigenvalues
            positive_real_eigenvalues = sorted_real_eigenvalues(sorted_real_eigenvalues > 0);
            
            % Compute the natural frequencies in Hz
            frequencies = sqrt(positive_real_eigenvalues) / (2 * pi);
        end
    end
end
