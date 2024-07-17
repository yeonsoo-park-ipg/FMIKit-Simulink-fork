function grtfmi_make_rtw_hook(hookMethod, modelName, ~, ~, ~, ~, ~)
    if ~strcmp(hookMethod, 'after_make')
        return
    end
    if strcmp(get_param(modelName, 'GenCodeOnly'), 'on')
        return
    end
    disp(modelName)
    [grtfmi_dir, ~, ~] = fileparts(which('grtfmi.tlc'));

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
	fmi_version         = get_param(modelName, 'FMIVersion');
	fmufunctions = sprintf("fmi%sFunctions.c", fmi_version);
	copyfile(fullfile(grtfmi_dir, fmufunctions), fullfile(pwd, fmufunctions));
	copyfile(fullfile(matlabroot, 'rtw/c/src/rt_matrx.c'), fullfile(pwd, 'rt_matrx.c'));
	copyfile(fullfile(grtfmi_dir, 'build.zig'), fullfile(pwd, 'build.zig'));
	copyfile(fullfile(grtfmi_dir, 'copypdb.bat'), fullfile(pwd, 'copypdb.bat'));
	
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

    f = fopen('build.zig', 'r');
    f = strrep(f, 'MODELNAME', modelName);
    fclose(f);
    disp('### Building FMU')
    status = system(["zig build --summary all"]);
    assert(status == 0, 'Failed to build FMU');

end

