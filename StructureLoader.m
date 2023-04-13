classdef StructureLoader < TensegrityComponents
    %STRUCTURE_LOADER Class allowing a user to load a structure into the
    %application

    methods 
        function obj = Load_Structure(obj)
            % Prompt the user to select an Excel file
            [filename, pathname] = uigetfile('*.xlsx', 'Select an Excel file to load the structure from');
        
            % If the user cancels the file selection, exit the function
            if isequal(filename, 0)
                disp('User selected Cancel');
                return;
            end
        
            % Create the full file path
            fullpath = fullfile(pathname, filename);
        
            % Set import options for Sheet 1
            opts = detectImportOptions(fullpath, 'Sheet', 1);
            opts = setvartype(opts, opts.VariableNames, 'char');
            NodeTable = readtable(fullpath, opts);
            
            % Convert text to numbers with high precision
            x_coordinate = str2double(NodeTable.x_coordinate);
            y_coordinate = str2double(NodeTable.y_coordinate);
            z_coordinate = str2double(NodeTable.z_coordinate);
            FixedValue = str2double(NodeTable.FixedValue);
        
            % Add nodes to the structure
            for i = 1:length(x_coordinate)
                obj = obj.addNode([x_coordinate(i), y_coordinate(i), z_coordinate(i)], FixedValue(i));
            end
        
            % Set import options for Sheet 2
            opts = detectImportOptions(filename, 'Sheet', 2);
            opts = setvartype(opts, opts.VariableNames, 'char');
            MemberTable = readtable(filename, opts);
        
            % Convert text to numbers with high precision
            StartNode = str2double(MemberTable.StartNode);
            EndNode = str2double(MemberTable.EndNode);
            MemberType = MemberTable.MemberType;
            YoungsModulus = str2double(MemberTable.YoungsModulus);
            mass_per_unit_length = str2double(MemberTable.MassPerUnitLength);
            Density = str2double(MemberTable.Density);
            CrossSectionalArea = str2double(MemberTable.CrossSectionalArea);
        
            % Add members to the structure
            for i = 1:length(StartNode)
                material.memberType = MemberType(i);
                material.youngsModulus = YoungsModulus(i);
                material.density = Density(i);
                material.mass_per_unit_length = mass_per_unit_length(i);
                material.crossSectionalArea = CrossSectionalArea(i);
                obj = obj.addMember(StartNode(i), EndNode(i), material);
            end
        end
            
        function obj = Save_Structure(obj)
            % Node properties
            nodeCoordinates = obj.nodeCoordinates;
            x_coordinate = nodeCoordinates(:,1);
            y_coordinate = nodeCoordinates(:,2);
            z_coordinate = nodeCoordinates(:,3);
            FixedValue = obj.fixedValue;
            
            % Member properties
            StartNode = obj.startIndex;
            EndNode = obj.endIndex;
            MemberType = obj.memberType;
            YoungsModulus = obj.youngsModulus;
            MassPerUnitLength = obj.mass_per_unit_length;
            Density = obj.density;
            CrossSectionalArea = obj.crossSectionalArea;
        
            % Create tables
            NodeTable = table(x_coordinate, y_coordinate, z_coordinate, FixedValue);
            MemberTable = table(StartNode, EndNode, MemberType, YoungsModulus, Density, CrossSectionalArea, MassPerUnitLength);
        
            % Save tables to Excel file in different sheets
            writetable(NodeTable, "SavedStructure.xlsx", 'Sheet', 1);
            writetable(MemberTable, "SavedStructure.xlsx", 'Sheet', 2);
        end
    end
end