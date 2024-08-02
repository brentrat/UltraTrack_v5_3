function new_bk_size = set_block_size(bk_size_old)

%% initialize text var for the inputs
text_prompt = {'Set block size for optic flow (in pixels)', 'Default 21 71', 'Height', 'Width'};

%% create the object to handle
    % Create a figure window
    fig = figure('Units', 'normalized', 'Position', [0.5 0.5 0.3 0.4], ...
        'Name', 'Set Block Size', 'NumberTitle', 'off');

    uicontrol('Style', 'text', 'String', text_prompt{1}, ...
        'Units', 'normalized', 'Position', [0.15 0.8 0.7 0.1],'FontSize',14);
    uicontrol('Style', 'text', 'String', text_prompt{2}, ...
        'Units', 'normalized', 'Position', [0.25 0.65 0.5 0.1],'FontSize',14,'FontWeight','bold');
    
    % Create input fields 
    %width
    uicontrol('Style', 'text', 'String', text_prompt{3}, ...
        'Units', 'normalized', 'Position', [0.1 0.5 0.3 0.1],'FontSize',14);
    input1Edit = uicontrol('Style', 'edit', 'Units', 'normalized', ...
        'Position', [0.4 0.5 0.3 0.1],'String',bk_size_old(1),'Callback', @input1Callback,'FontSize',14);

    % height
    uicontrol('Style', 'text', 'String', text_prompt{4}, ...
        'Units', 'normalized', 'Position', [0.1 0.3 0.3 0.1],'FontSize',14);
    input2Edit = uicontrol('Style', 'edit', 'Units', 'normalized', ...
        'Position', [0.4 0.3 0.3 0.1],'String',bk_size_old(2),'Callback', @input2Callback,'FontSize',14);

    
   
    % Create OK button
    okButton = uicontrol('Style', 'pushbutton', 'String', 'OK', ...
        'Units', 'normalized', 'Position', [0.3 0.05 0.4 0.15], ...
        'Callback', @okButtonCallback);

  %% Initialize output variables
    new_bk_size = bk_size_old;

  %% Callback function for width
    function input1Callback(hObject, ~)
        % Enforce numeric input only
        input = get(hObject, 'String');
        input = str2double(input);
        if isempty(input) || isnan(input) || mod(input,2) ~= 1 || input < 5
            set(hObject, 'String',  bk_size_old(1) );
            errordlg('Input must be an odd number > 3', 'Error', 'modal');
        end
    end

 %% Callback function for height
   function input2Callback(hObject, ~)
        % Enforce numeric input only
        input = get(hObject, 'String');
        input = str2double(input);
        if isempty(input) || isnan(input) || mod(input,2) ~= 1 || input < 5
            set(hObject, 'String', bk_size_old(2) );
            errordlg('Input must be an odd number > 3', 'Error', 'modal');
        end
    end

  %% Callback function for OK button
    function okButtonCallback(~, ~)
        %scaling_factor = str2double(get(input2Edit, 'String')) / 100;
        new_bk_size(1) = str2double(get(input1Edit, 'String'));
        new_bk_size(2) = str2double(get(input2Edit, 'String'));
       
        % Close the figure
        close(fig);
    end

    % Wait for the figure to close
    uiwait(fig);

end