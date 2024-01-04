function grtfmi_make_rtw_hook(hookMethod, modelName, rtwRoot, templateMakefile, buildOpts, buildArgs, buildInfo)
    if ~strcmp(hookMethod, 'after_make')
        return
    end

    current_dir = pwd;

    if strcmp(get_param(modelName, 'GenCodeOnly'), 'on')
        return
    end

    pathstr = which('grtfmi.tlc');
    [grtfmi_dir, ~, ~] = fileparts(pathstr);

    % remove FMU build directory from previous build
    if exist('FMUArchive', 'dir')
        rmdir('FMUArchive', 's');
    end
    % create the archive directory (uncompressed FMU)
    mkdir('FMUArchive');

    template_dir = get_param(modelName, 'FMUTemplateDir');

    % copy template files
    if ~isempty(template_dir)
        copyfile(template_dir, 'FMUArchive');
    end

    % remove fmiwrapper.inc for referenced models
    if ~strcmp(current_dir(end-11:end), '_grt_fmi_rtw')
        delete('fmiwrapper.inc');
        return
    end
    % add model.png
    if strcmp(get_param(modelName, 'AddModelImage'), 'on')
        % create an image of the model
        print(['-s' modelName], '-dpng', fullfile('FMUArchive', 'model.png'));
    else
        % use the generic Simulink logo
        copyfile(fullfile(grtfmi_dir, 'model.png'), fullfile('FMUArchive', 'model.png'));
    end


    source_code_fmu     = get_param(modelName, 'SourceCodeFMU');
    fmi_version         = get_param(modelName, 'FMIVersion');

    % CMake
    cmake_command       = get_param(modelName, 'CMakeCommand');
    cmake_command       = grtfmi_find_cmake(cmake_command);

    build_windows       = get_param(modelName, 'CMakeBuildWindows');
    build_linux         = get_param(modelName, 'CMakeBuildLinux');
    build_darwin        = get_param(modelName, 'CMakeBuildDarwin');

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
            copyfile(unzipdir, fullfile('FMUArchive', 'resources', model_identifier), 'f');
        end
    end

    disp('### Running CMake generator')

    % get model sources
    [custom_include, custom_source, custom_library] = ...
        grtfmi_model_sources(modelName, pwd);

    custom_include = cmake_list(custom_include);
    custom_source  = cmake_list(custom_source);
    custom_library = cmake_list(custom_library);
    custom_define  = cmake_list(regexp(get_param(modelName, 'CustomDefine'), '\s+', 'split'));

    % check for Simscape blocks
    if isempty(find_system(modelName, 'BlockType', 'SimscapeBlock'))
        simscape_blocks = 'off';
    else
        simscape_blocks = 'on';
    end

    [cmake_flags, errmsg] = sprintf('-DMODEL_NAME="%s"', modelName);
    [cmake_flags, errmsg] = sprintf('%s -DMATLAB_ROOT="%s"', cmake_flags, strrep(matlabroot, '\', '/'));
    [cmake_flags, errmsg] = sprintf('%s -DRTW_DIR="%s"', cmake_flags, strrep(pwd, '\', '/'));
    [cmake_flags, errmsg] = sprintf('%s -DARCH="%s"', cmake_flags, computer('arch'));
    [cmake_flags, errmsg] = sprintf('%s -DCUSTOM_INCLUDE="%s"', cmake_flags, custom_include);
    [cmake_flags, errmsg] = sprintf('%s -DCUSTOM_SOURCE="%s"', cmake_flags, custom_source);
    [cmake_flags, errmsg] = sprintf('%s -DCUSTOM_LIBRARY="%s"', cmake_flags, custom_library);
    [cmake_flags, errmsg] = sprintf('%s -DCUSTOM_DEFINE="%s"', cmake_flags, custom_define);
    [cmake_flags, errmsg] = sprintf('%s -DSOURCE_CODE_FMU=%s', cmake_flags, upper(source_code_fmu));
    [cmake_flags, errmsg] = sprintf('%s -DSIMSCAPE="%s"', cmake_flags, upper(simscape_blocks));
    [cmake_flags, errmsg] = sprintf('%s -DFMI_VERSION="%s"', cmake_flags, fmi_version);
    [cmake_flags, errmsg] = sprintf('%s -DCOMPILER_OPTIMIZATION_LEVEL="%s"', cmake_flags, optimization_level);

    % CMake:Windows
    if strcmp(build_windows, 'on')
        target              = 'Windows';
        generator           = get_param(modelName, 'CMakeGeneratorWindows');
        msvc                = contains(generator, 'Visual Studio');
        generator_platform  = get_param(modelName, 'CMakeGeneratorPlatformWindows');
        if ~msvc
            compiler            = get_param(modelName, 'CMakeCompilerWindows');
            make                = get_param(modelName, 'CMakeMakeWindows');
        end
        toolset             = get_param(modelName, 'CMakeToolsetWindows');
        optimization_flags_windows  = get_param(modelName, 'CMakeCompilerOptimizationFlagsWindows');
        [cmake_flags_windows, errmsg] = sprintf('-G "%s"', generator);
        [cmake_flags_windows, errmsg] = sprintf('%s -DCMAKE_SYSTEM_NAME="%s"', cmake_flags_windows, target);
        if msvc
            [cmake_flags_windows, errmsg] = sprintf('%s -DCMAKE_GENERATOR_PLATFORM="%s"', cmake_flags_windows, generator_platform);
        end
        [cmake_flags_windows, errmsg] = sprintf('%s -DTARGET_PLATFORM="%s"', cmake_flags_windows, generator_platform);
        if ~isempty(toolset)
            [cmake_flags_windows, errmsg] = sprintf('%s -T "%s"', cmake_flags_windows, toolset);
        end
        if ~msvc && ~isempty(compiler) && ~isempty(make)
            [cmake_flags_windows, errmsg] = sprintf('%s -DCMAKE_C_COMPILER="%s"', cmake_flags_windows, strrep(compiler, '\', '/'));
            [cmake_flags_windows, errmsg] = sprintf('%s -DCMAKE_MAKE_PROGRAM="%s"', cmake_flags_windows, strrep(make, '\', '/'));
        end
        [cmake_flags_windows, errmsg] = sprintf('%s -DCOMPILER_OPTIMIZATION_FLAGS="%s %s"', cmake_flags_windows, optimization_flags, optimization_flags_windows);
        [cmake_flags_windows, errmsg] = sprintf('%s %s', cmake_flags_windows, cmake_flags);
    
        disp('### Generating project')
    
        [command, errmsg] = sprintf('%s %s "%s"', cmake_command, cmake_flags_windows, strrep(grtfmi_dir, '\', '/'));
        status = system(command);
        assert(status == 0, 'Failed to run CMake generator');

        disp('### Building FMU')
        [command, errmsg] = sprintf('%s --build . --config %s', cmake_command, build_configuration);
        status = system(command);
        assert(status == 0, 'Failed to build FMU');

        rmdir('CMakeFiles', 's');
        delete('CMakeCache.txt');
    end

    % CMake:Linux
    if strcmp(build_linux, 'on')
        target              = 'Linux';
        generator           = get_param(modelName, 'CMakeGeneratorLinux');
        compiler            = get_param(modelName, 'CMakeCompilerLinux');
        make                = get_param(modelName, 'CMakeMakeLinux');
        optimization_flags_linux  = get_param(modelName, 'CMakeCompilerOptimizationFlagsLinux');
        [cmake_flags_linux, errmsg] = sprintf('-G "%s"', generator);
        [cmake_flags_linux, errmsg] = sprintf('%s -DCMAKE_SYSTEM_NAME="%s"', cmake_flags_linux, target);
        [cmake_flags_linux, errmsg] = sprintf('%s -DTARGET_PLATFORM="%s"', cmake_flags_linux, 'x64');
        [cmake_flags_linux, errmsg] = sprintf('%s -DCMAKE_C_COMPILER="%s"', cmake_flags_linux, strrep(compiler, '\', '/'));
        [cmake_flags_linux, errmsg] = sprintf('%s -DCMAKE_MAKE_PROGRAM="%s"', cmake_flags_linux, strrep(make, '\', '/'));
        [cmake_flags_linux, errmsg] = sprintf('%s -DCOMPILER_OPTIMIZATION_FLAGS="%s %s"', cmake_flags_linux, optimization_flags, optimization_flags_linux);
        [cmake_flags_linux, errmsg] = sprintf('%s %s', cmake_flags_linux, cmake_flags);
        
        disp('### Generating project')
        [command, errmsg] = sprintf('%s %s "%s"', cmake_command, cmake_flags_linux, strrep(grtfmi_dir, '\', '/'));
        status = system(command);
        assert(status == 0, 'Failed to run CMake generator');

        disp('### Building FMU')
        [command, errmsg] = sprintf('%s --build . --config %s', cmake_command, build_configuration);
        status = system(command);
        assert(status == 0, 'Failed to build FMU');

        rmdir('CMakeFiles', 's');
        delete('CMakeCache.txt');
    end
    % CMake:Darwin

    if strcmp(build_darwin, 'on')
        target              = 'Linux';
        generator           = get_param(modelName, 'CMakeGeneratorDarwin');
        compiler            = get_param(modelName, 'CMakeCompilerDarwin');
        make                = get_param(modelName, 'CMakeMakeDarwin');
        toolset             = get_param(modelName, 'CMakeToolsetDarwin');
        optimization_flags_darwin  = get_param(modelName, 'CMakeCompilerOptimizationFlagsDarwin');
        [cmake_flags_darwin, errmsg] = sprintf('-G "%s"', generator);
        [cmake_flags_darwin, errmsg] = sprintf('%s -DCMAKE_SYSTEM_NAME="%s"', cmake_flags_darwin, target);
        [cmake_flags_darwin, errmsg] = sprintf('%s -DTARGET_PLATFORM="%s"', cmake_flags_darwin, 'x64');
        [cmake_flags_darwin, errmsg] = sprintf('%s -DCMAKE_C_COMPILER="%s"', cmake_flags_darwin, strrep(compiler, '\', '/'));
        [cmake_flags_darwin, errmsg] = sprintf('%s -DCMAKE_MAKE_PROGRAM="%s"', cmake_flags_darwin, strrep(make, '\', '/'));
        if ~isempty(toolset)
            [cmake_flags_darwin, errmsg] = sprintf('%s -T "%s"', cmake_flags_darwin, toolset);
        end
        [cmake_flags_darwin, errmsg] = sprintf('%s -DCOMPILER_OPTIMIZATION_FLAGS="%s %s"', cmake_flags_darwin, optimization_flags, optimization_flags_darwin);
        [cmake_flags_darwin, errmsg] = sprintf('%s %s', cmake_flags_darwin, cmake_flags);
        
        disp('### Generating project')
        [command, errmsg] = sprintf('%s %s "%s"', cmake_command, cmake_flags_darwin, strrep(grtfmi_dir, '\', '/'));
        status = system(command);
        assert(status == 0, 'Failed to run CMake generator');

        disp('### Building FMU')
        [command, errmsg] = sprintf('%s --build . --config %s', cmake_command, build_configuration);
        status = system(command);
        assert(status == 0, 'Failed to build FMU');

        rmdir('CMakeFiles', 's');
        delete('CMakeCache.txt');
    end

    % copy the FMU to the working directory
    copyfile([modelName '.fmu'], '..');
end

function joined = cmake_list(array)

    if isempty(array)
        joined = '';
        return
    end

joined = array{1};

    for i = 2:numel(array)
        joined = [joined ';' array{i}];  
    end

end
