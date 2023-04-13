classdef TensegrityComponents
    %TENSEGRITYCOMPONENTS Class to store tensegrity nodes and member properties
    
    properties
        % Node properties
        nodeCoordinates = []
        fixedValue = []
        scale = 1
        numNodes = 0
        
        % Member properties
        startIndex = []
        endIndex = []
        startNodeCoordinates = []
        endNodeCoordinates = []
        numMembers = 0
        
        % Material properties
        memberType = []
        youngsModulus = []
        density = []
        crossSectionalArea = []
        mass_per_unit_length = []
    end

    methods
        function obj = addNode(obj, inputNode, fixed)
            %ADDNODE Adds a new node to the list if it is not a duplicate

            if ~isDuplicateNode(obj, inputNode)
                obj.nodeCoordinates = [obj.nodeCoordinates; inputNode];
                obj.fixedValue = [obj.fixedValue; fixed];
                obj.numNodes = obj.numNodes + 1;
            end
        end
        
        function duplicate = isDuplicateNode(obj, inputNode)
            %ISDUPLICATENODE Checks if a node with the same coordinates already exists
            
            % Initialize duplicate flag to false
            duplicate = false;
        
            % Iterate through all existing nodes and check if any match the inputNode
            for i = 1:size(obj.nodeCoordinates, 1)
                if all(obj.nodeCoordinates(i, :) == inputNode)
                    duplicate = true;
                    break;
                end
            end        
        end
        
        function obj = assignMaterial(obj, input)
            %ASSIGNMATERIAL Assigns the properties of the material in each
            %member
            obj.memberType = [obj.memberType; input.memberType];
            obj.youngsModulus = [obj.youngsModulus; input.youngsModulus];
            obj.density = [obj.density; input.density];
            obj.crossSectionalArea = [obj.crossSectionalArea; input.crossSectionalArea];
            obj.mass_per_unit_length = [obj.mass_per_unit_length; input.mass_per_unit_length];
        end
        
        function obj = addMember(obj, startIndex, endIndex, material)
            %ADDMEMBER Adds a new member to the list if it is not a duplicate

            if ~isDuplicate(obj, startIndex, endIndex)
                % Store the index of the start and end nodes for later use
                obj.startIndex = [obj.startIndex; startIndex];
                obj.endIndex = [obj.endIndex; endIndex];

                % Get the node coordinates for the start and end nodes of the member
                startNode = obj.nodeCoordinates(startIndex,:);
                endNode = obj.nodeCoordinates(endIndex,:);

                % Store the start and end nodes and the properties of the material the member is made from
                obj.startNodeCoordinates = [obj.startNodeCoordinates; startNode];
                obj.endNodeCoordinates = [obj.endNodeCoordinates; endNode];

                if nargin == 4
                    obj = assignMaterial(obj, material);
                end

                obj.numMembers = obj.numMembers + 1;
            end
        end
        
        function duplicate = isDuplicate(obj, startIndex, endIndex)
            %ISDUPLICATE Checks if a member with the same start and end nodes already exists
            
            % Check if the member with the given start and end nodes exists
            duplicate = any((obj.startIndex == startIndex & obj.endIndex == endIndex) | ...
                            (obj.startIndex == endIndex & obj.endIndex == startIndex));
        end

        function obj = removeNode(obj, removedNodeIndex)
            %REMOVENODE Removes a user specified node from the list

            % Check that there have already been some nodes input
            if obj.numNodes == 0
                return
            end

            % Remove the specified node
            obj.nodeCoordinates(removedNodeIndex,:) = [];
            obj.fixedValue(removedNodeIndex,:) = [];
            obj.numNodes = obj.numNodes - 1;
            
            % Remove all members attached to the node
            attachedMembers = [];
            sIndex = obj.startIndex;
            eIndex = obj.endIndex;

            if obj.numMembers == 0
                return
            end

            for i = 1:obj.numMembers
                if sIndex(i) == removedNodeIndex
                    attachedMembers = [attachedMembers i]; 
                elseif eIndex(i) == removedNodeIndex
                    attachedMembers = [attachedMembers i];
                end
            end

            attachedMembers = sort(attachedMembers, 'descend');

            if isempty(attachedMembers)
                return
            else
                for i = 1:length(attachedMembers)
                    obj = removeMember(obj, attachedMembers(i));
                end
            end
        end
    
        function obj = removeMember(obj, removedMemberIndex)
            %REMOVEMEMBER Removes a selected member
            if obj.numMembers == 0
                return
            end
            obj.startIndex(removedMemberIndex) = [];
            obj.endIndex(removedMemberIndex) = [];
            obj.startNodeCoordinates(removedMemberIndex,:) = [];
            obj.endNodeCoordinates(removedMemberIndex,:) = [];
            obj.memberType(removedMemberIndex) = [];
            obj.youngsModulus(removedMemberIndex) = [];
            obj.density(removedMemberIndex) = [];
            obj.crossSectionalArea(removedMemberIndex) = [];
            obj.mass_per_unit_length(removedMemberIndex) = [];
    
            obj.numMembers = obj.numMembers - 1;
        end
    end
end