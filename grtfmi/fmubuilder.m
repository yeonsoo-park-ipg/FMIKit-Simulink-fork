function fmubuilder(mdl)
	mdl = load_system(mdl);
	set_param(mdl, 'SystemTargetFile', 'grtfmi.tlc');
    set_param(mdl, 'CMakeBuildWindows', 'on');
    set_param(mdl, 'CMakeBuildLinux', 'on');
    set_param(mdl, 'CMakeBuildDarwin', 'off');
	set_param(mdl, 'CMakeGeneratorWindows', 'Visual Studio 17 2022');
	set_param(mdl, 'CMakeGeneratorPlatformWindows', 'x64');
    set_param(mdl, 'CMakeGeneratorLinux', 'Unix Makefiles');
    set_param(mdl, 'CMakeCompilerLinux', 'C:\msys-2023\x86_64-linux\bin\linux-gcc.exe');
    set_param(mdl, 'CMakeMakeLinux', 'C:\msys-2023\usr\bin\make.exe');
	slbuild(mdl);
end


