function grtfmi_make_rtw_hook(hookMethod, modelName, ~, ~, ~, ~, ~)
    if ~strcmp(hookMethod, 'after_make')
        return
    end
    if strcmp(get_param(modelName, 'GenCodeOnly'), 'on')
        return
    end

    [grtfmi_dir, ~, ~] = fileparts(which('grtfmi.tlc'));
    [fmikit_dir, ~, ~] = fileparts(grtfmi_dir);
    % remove FMU build directory from previous build
    if exist('zig-out', 'dir')
        rmdir('zig-out', 's');
    end
    % create the archive directory (uncompressed FMU)
    mkdir('zig-out');

    template_dir = get_param(modelName, 'FMUTemplateDir');
    % copy template files
    if ~isempty(template_dir)
        copyfile(template_dir, 'zig-out');
    end
    cur = pwd;
    if ~strcmp(cur(end-11:end), '_grt_fmi_rtw')
        delete('fmiwrapper.inc');
        return
    end
    % add model.png
    if strcmp(get_param(modelName, 'AddModelImage'), 'on')
        print(['-s' modelName], '-dpng', fullfile(pwd, 'model.png'));
    else
        copyfile(fullfile(grtfmi_dir, 'model.png'), fullfile(pwd, 'model.png'));
    end
    copyfile(fullfile(fmikit_dir, 'include'), fullfile(pwd, 'include'));
    fmi_version         = get_param(modelName, 'FMIVersion');
	fmufunctions = sprintf("fmi%sFunctions.c", fmi_version);
	copyfile(fullfile(grtfmi_dir, fmufunctions), fullfile(pwd, fmufunctions));

    % Copy build.zig with string replacements for variables
    build_zig = fileread(fullfile(grtfmi_dir, 'build.zig'));
    build_zig = strrep(build_zig, '@MODELNAME@', modelName);
    build_zig = strrep(build_zig, '@FMIVERSION@', fmi_version);
    if isempty(find_system(modelName, 'BlockType', 'SimscapeBlock'))
        build_zig = strrep(build_zig, '@SIMSCAPE@', 'false');
    else
        build_zig = strrep(build_zig, '@SIMSCAPE@', 'true');
    end
    build_zig = strrep(build_zig, '@MATLABVERSION@', version('-release'));
    build_zig = strrep(build_zig, '@MATLABPATH@', strrep(matlabroot, '\', '/'));
	f = fopen(fullfile(pwd, 'build.zig'), 'w');
    fwrite(f, build_zig);
    fclose(f);


    
    source_code_fmu     = get_param(modelName, 'SourceCodeFMU');
    

    % CMake

    build_windows       = get_param(modelName, 'CMakeBuildWindows');
    build_linux         = get_param(modelName, 'CMakeBuildLinux');

    build_configuration = get_param(modelName, 'CMakeBuildConfiguration');
    optimization_level  = get_param(modelName, 'CMakeCompilerOptimizationLevel');
    optimization_flags  = get_param(modelName, 'CMakeCompilerOptimizationFlags');
    % copy extracted nested FMUs
    nested_fmus = find_system(modelName, 'LookUnderMasks', 'All', 'FunctionName', 'sfun_fmurun');

    if ~isempty(nested_fmus)
        disp('### Copy nested FMUs')
        for i = 1:numel(nested_fmus)
            nested_fmu = nested_fmus{i};
            unzipdir = FMIKit.getUnzipDirectory(nested_fmu);
            user_data = get_param(nested_fmu, 'UserData');
            dialog = FMIKit.showBlockDialog(nested_fmu, false);
            if user_data.runAsKind == 0
                model_identifier = char(dialog.modelDescription.modelExchange.modelIdentifier);
            else
                model_identifier = char(dialog.modelDescription.coSimulation.modelIdentifier);
            end
            disp(['Copying ' unzipdir ' to resources'])                
            copyfile(unzipdir, fullfile('zig-out', 'resources', model_identifier), 'f');
        end
    end

    
    disp('### Building FMU')
    status = system(["zig build --summary all"]);
    assert(status == 0, 'Failed to build FMU');

end

