function S = appendDropdownOptions(S, nwbNodeStack)

    arguments
        S (1,1) struct
        nwbNodeStack (1,:) nansen.module.nwb.internal.NwbNode
    end

    import nansen.module.nwb.internal.getMetadataInstances
    import nansen.module.nwb.internal.createNewNwbInstance
    import nansen.module.nwb.internal.lookup.getDynamicTableForRegionView    
    
    % Get the full package-prefixed name for the neurodata type on the top
    % of the stack
    propertyName = nwbNodeStack(end).PropertyName;
    propertyType = nwbNodeStack(end).PropertyType;
    fullLinkedTypeName = nwbNodeStack(end).PropertyTypeFullName;

    % Load existing metadata instances for this neurodata type
    metadataInstances = nansen.module.nwb.internal.getMetadataInstances(fullLinkedTypeName);
    metadataInstances = cellstr(metadataInstances);
    
    % Specify custom configuration for a dropdown control.
    dropdownConfig = struct(...
        'AllowNoSelection', true, ...
        'CreateNewItemFcn', @(item, nwbNodes, varargin)...
            nansen.module.nwb.internal.createNewNwbInstance(item, nwbNodeStack, varargin{:}), ...
        'ItemName', propertyType );

    % Prepend the dropdown configuration to the list of instances. 
    % The structeditor will expect this config as the first cell of the
    % cell array.
    metadataInstances = [{dropdownConfig}, metadataInstances]; %#ok<AGROW>

    if isfield(S, propertyName)
        % Add _ to the end of the link name to create the "config" name
        configName = sprintf('%s_', propertyName);
        S.(configName) = metadataInstances;
        if isempty(S.(propertyName))
            % Make sure empty value is a char
            S.(propertyName) = '';
        end
    else
        % I guess this should not happen so throw error if it does
        error('No field for linked type with name ''%s''', propertyName)
    end
end
