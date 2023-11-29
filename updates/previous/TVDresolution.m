function TVDdata = TVDextract(TVDfname)
if strcmp(computer('arch'), 'win64')
    asm_path = 'C:\Program Files (x86)\Telemed\Echo Wave II\Config\Plugins\AutoInt1Client.dll';
else
    asm_path = 'C:\Program Files\Telemed\Echo Wave II\Config\Plugins\AutoInt1Client.dll';
end
% Create assembly
asm = NET.addAssembly(asm_path);
% Create command interface object (CmdInt1)
cmd = AutoInt1Client.CmdInt1();
% Connect to running Echo Wave II 
ret = cmd.ConnectToRunningProgram();
if (ret ~= 0)
    error('Cannot connect to Echo Wave II. Please make sure the software is "Run as administrator".')
end
% Open TVD file (previously saved using Echo Wave II)
cmd.OpenFile(TVDfname);
% Go to first frame
cmd.GoToFrame1n(1, true);
%% Change image filtering
TVDdata.cmPerPixX = cmd.GetUltrasoundPhysicalDeltaX(1);
TVDdata.cmPerPixY = cmd.GetUltrasoundPhysicalDeltaY(1);
end