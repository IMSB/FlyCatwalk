<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="12008004">
	<Item Name="My Computer" Type="My Computer">
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="catWalkArduinoNew.vi" Type="VI" URL="../catWalkArduinoNew.vi"/>
		<Item Name="icon.ico" Type="Document" URL="../../../../SciTrackSSVN/Trackit studies/humidity sensor/installer/icon.ico"/>
		<Item Name="playInactivitySound.vi" Type="VI" URL="../playInactivitySound.vi"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="user.lib" Type="Folder">
				<Item Name="CatWalkLabviewDLL.dll" Type="Document" URL="/&lt;userlib&gt;/OpenCVImProc/CatWalkLabviewDLL.dll"/>
				<Item Name="CatWalkLabviewDLLd.dll" Type="Document" URL="/&lt;userlib&gt;/OpenCVImProc/CatWalkLabviewDLLd.dll"/>
			</Item>
			<Item Name="vi.lib" Type="Folder">
				<Item Name="Acquire Semaphore.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Acquire Semaphore.vi"/>
				<Item Name="Check if File or Folder Exists.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/libraryn.llb/Check if File or Folder Exists.vi"/>
				<Item Name="Color to RGB.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/colorconv.llb/Color to RGB.vi"/>
				<Item Name="DialogType.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/DialogType.ctl"/>
				<Item Name="Error Cluster From Error Code.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Error Cluster From Error Code.vi"/>
				<Item Name="General Error Handler.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/General Error Handler.vi"/>
				<Item Name="Get Semaphore Status.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Get Semaphore Status.vi"/>
				<Item Name="Image Type" Type="VI" URL="/&lt;vilib&gt;/vision/Image Controls.llb/Image Type"/>
				<Item Name="IMAQ Copy" Type="VI" URL="/&lt;vilib&gt;/vision/Management.llb/IMAQ Copy"/>
				<Item Name="IMAQ Create" Type="VI" URL="/&lt;vilib&gt;/vision/Basics.llb/IMAQ Create"/>
				<Item Name="IMAQ Dispose" Type="VI" URL="/&lt;vilib&gt;/vision/Basics.llb/IMAQ Dispose"/>
				<Item Name="IMAQ Image Datatype to Image Cluster.vi" Type="VI" URL="/&lt;vilib&gt;/vision/DatatypeConversion.llb/IMAQ Image Datatype to Image Cluster.vi"/>
				<Item Name="IMAQ Image.ctl" Type="VI" URL="/&lt;vilib&gt;/vision/Image Controls.llb/IMAQ Image.ctl"/>
				<Item Name="IMAQ Overlay Rectangle" Type="VI" URL="/&lt;vilib&gt;/vision/Overlay.llb/IMAQ Overlay Rectangle"/>
				<Item Name="IMAQ ReadFile" Type="VI" URL="/&lt;vilib&gt;/vision/Files.llb/IMAQ ReadFile"/>
				<Item Name="IMAQ SetImageSize" Type="VI" URL="/&lt;vilib&gt;/vision/Basics.llb/IMAQ SetImageSize"/>
				<Item Name="IMAQ Write BMP File 2" Type="VI" URL="/&lt;vilib&gt;/vision/Files.llb/IMAQ Write BMP File 2"/>
				<Item Name="IMAQ Write File 2" Type="VI" URL="/&lt;vilib&gt;/vision/Files.llb/IMAQ Write File 2"/>
				<Item Name="IMAQ Write Image And Vision Info File 2" Type="VI" URL="/&lt;vilib&gt;/vision/Files.llb/IMAQ Write Image And Vision Info File 2"/>
				<Item Name="IMAQ Write JPEG File 2" Type="VI" URL="/&lt;vilib&gt;/vision/Files.llb/IMAQ Write JPEG File 2"/>
				<Item Name="IMAQ Write JPEG2000 File 2" Type="VI" URL="/&lt;vilib&gt;/vision/Files.llb/IMAQ Write JPEG2000 File 2"/>
				<Item Name="IMAQ Write PNG File 2" Type="VI" URL="/&lt;vilib&gt;/vision/Files.llb/IMAQ Write PNG File 2"/>
				<Item Name="IMAQ Write TIFF File 2" Type="VI" URL="/&lt;vilib&gt;/vision/Files.llb/IMAQ Write TIFF File 2"/>
				<Item Name="IMAQdx.ctl" Type="VI" URL="/&lt;vilib&gt;/userdefined/High Color/IMAQdx.ctl"/>
				<Item Name="LabVIEW Interface for Arduino.lvlib" Type="Library" URL="/&lt;vilib&gt;/LabVIEW Interface for Arduino/LabVIEW Interface for Arduino.lvlib"/>
				<Item Name="NI_Vision_Acquisition_Software.lvlib" Type="Library" URL="/&lt;vilib&gt;/vision/driver/NI_Vision_Acquisition_Software.lvlib"/>
				<Item Name="NI_Vision_Development_Module.lvlib" Type="Library" URL="/&lt;vilib&gt;/vision/NI_Vision_Development_Module.lvlib"/>
				<Item Name="Obtain Semaphore Reference.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Obtain Semaphore Reference.vi"/>
				<Item Name="Particle Parameters" Type="VI" URL="/&lt;vilib&gt;/vision/Image Controls.llb/Particle Parameters"/>
				<Item Name="Read From Spreadsheet File (DBL).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Read From Spreadsheet File (DBL).vi"/>
				<Item Name="Read From Spreadsheet File (I64).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Read From Spreadsheet File (I64).vi"/>
				<Item Name="Read From Spreadsheet File (string).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Read From Spreadsheet File (string).vi"/>
				<Item Name="Read From Spreadsheet File.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Read From Spreadsheet File.vi"/>
				<Item Name="Release Semaphore Reference.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Release Semaphore Reference.vi"/>
				<Item Name="Release Semaphore.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Release Semaphore.vi"/>
				<Item Name="RemoveNamedSemaphorePrefix.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/RemoveNamedSemaphorePrefix.vi"/>
				<Item Name="Semaphore RefNum" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Semaphore RefNum"/>
				<Item Name="Semaphore Refnum Core.ctl" Type="VI" URL="/&lt;vilib&gt;/Utility/semaphor.llb/Semaphore Refnum Core.ctl"/>
				<Item Name="Simple Error Handler.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Simple Error Handler.vi"/>
				<Item Name="subFile Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/express/express input/FileDialogBlock.llb/subFile Dialog.vi"/>
				<Item Name="Three Button Dialog.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Three Button Dialog.vi"/>
				<Item Name="VISA Configure Serial Port" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/VISA Configure Serial Port"/>
				<Item Name="VISA Configure Serial Port (Instr).vi" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/VISA Configure Serial Port (Instr).vi"/>
				<Item Name="VISA Configure Serial Port (Serial Instr).vi" Type="VI" URL="/&lt;vilib&gt;/Instr/_visa.llb/VISA Configure Serial Port (Serial Instr).vi"/>
				<Item Name="Write To Spreadsheet File (DBL).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write To Spreadsheet File (DBL).vi"/>
				<Item Name="Write To Spreadsheet File (I64).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write To Spreadsheet File (I64).vi"/>
				<Item Name="Write To Spreadsheet File (string).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write To Spreadsheet File (string).vi"/>
				<Item Name="Write To Spreadsheet File.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write To Spreadsheet File.vi"/>
			</Item>
			<Item Name="CalculateFPS.vi" Type="VI" URL="../../../../../../../Program Files (x86)/National Instruments/LabVIEW 2012/examples/IMAQ/IMAQdx Examples.llb/CalculateFPS.vi"/>
			<Item Name="cleanUpOpenCVIP.vi" Type="VI" URL="../../../Cpp Libraries/CatWalkLabviewDLL/labview code/cleanUpOpenCVIP.vi"/>
			<Item Name="closeArduinoNew.vi" Type="VI" URL="../new arduino/closeArduinoNew.vi"/>
			<Item Name="closeDeviceReference.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/closeDeviceReference.vi"/>
			<Item Name="crop.vi" Type="VI" URL="../../image acquisition/crop.vi"/>
			<Item Name="deleteTempFiles.vi" Type="VI" URL="../../image acquisition/deleteTempFiles.vi"/>
			<Item Name="detectFlyMultiImages.vi" Type="VI" URL="../../image acquisition/detectFlyMultiImages.vi"/>
			<Item Name="disableServosArduinoNew.vi" Type="VI" URL="../new arduino/disableServosArduinoNew.vi"/>
			<Item Name="downsample.vi" Type="VI" URL="../../image acquisition/downsample.vi"/>
			<Item Name="errors.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/errors.vi"/>
			<Item Name="errors_actions.ctl" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/errors_actions.ctl"/>
			<Item Name="extractBodyOpenCVIP.vi" Type="VI" URL="../../../Cpp Libraries/CatWalkLabviewDLL/labview code/extractBodyOpenCVIP.vi"/>
			<Item Name="flyVideoAcquisition.vi" Type="VI" URL="../../image acquisition/flyVideoAcquisition.vi"/>
			<Item Name="getBGOpenCVIP.vi" Type="VI" URL="../../../Cpp Libraries/CatWalkLabviewDLL/labview code/getBGOpenCVIP.vi"/>
			<Item Name="getFrameOpenCVIP.vi" Type="VI" URL="../../../Cpp Libraries/CatWalkLabviewDLL/labview code/getFrameOpenCVIP.vi"/>
			<Item Name="getWSIOpenCVIP.vi" Type="VI" URL="../../../Cpp Libraries/CatWalkLabviewDLL/labview code/getWSIOpenCVIP.vi"/>
			<Item Name="GlobalArduinoNew.vi" Type="VI" URL="../new arduino/GlobalArduinoNew.vi"/>
			<Item Name="GlobalBaslerCamera.vi" Type="VI" URL="../../image acquisition/GlobalBaslerCamera.vi"/>
			<Item Name="GlobalLB.vi" Type="VI" URL="../GlobalLB.vi"/>
			<Item Name="GlobalStatus.vi" Type="VI" URL="../GlobalStatus.vi"/>
			<Item Name="GlobalValves.vi" Type="VI" URL="../GlobalValves.vi"/>
			<Item Name="GlobalXYStage.vi" Type="VI" URL="../XY Stage/XYStage.llb/GlobalXYStage.vi"/>
			<Item Name="initArduinoNew.vi" Type="VI" URL="../new arduino/initArduinoNew.vi"/>
			<Item Name="initBaslerCamera.vi" Type="VI" URL="../../image acquisition/initBaslerCamera.vi"/>
			<Item Name="InitializeOpenCVIP.vi" Type="VI" URL="../../../Cpp Libraries/CatWalkLabviewDLL/labview code/InitializeOpenCVIP.vi"/>
			<Item Name="initImageCluster.vi" Type="VI" URL="../../image acquisition/initImageCluster.vi"/>
			<Item Name="initXYStage.vi" Type="VI" URL="../XY Stage/XYStage.llb/initXYStage.vi"/>
			<Item Name="niimaqdx.dll" Type="Document" URL="niimaqdx.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="nivision.dll" Type="Document" URL="nivision.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="nivissvc.dll" Type="Document" URL="nivissvc.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="OpenCvGlobals.vi" Type="VI" URL="../../../Cpp Libraries/CatWalkLabviewDLL/labview code/OpenCvGlobals.vi"/>
			<Item Name="openDeviceReference.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/openDeviceReference.vi"/>
			<Item Name="PerformaxCom.dll" Type="Document" URL="PerformaxCom.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
			<Item Name="Play Sound.vi" Type="VI" URL="../../../../../../../Program Files (x86)/National Instruments/LabVIEW 2012/examples/dll/sound/playsnd.llb/Play Sound.vi"/>
			<Item Name="playFinishSound.vi" Type="VI" URL="../playFinishSound.vi"/>
			<Item Name="playSounds.vi" Type="VI" URL="../playSounds.vi"/>
			<Item Name="queueImages.vi" Type="VI" URL="../../image acquisition/queueImages.vi"/>
			<Item Name="readAnalysisOutput.vi" Type="VI" URL="../readAnalysisOutput.vi"/>
			<Item Name="readLightBarriersNew.vi" Type="VI" URL="../new arduino/readLightBarriersNew.vi"/>
			<Item Name="resetTempFolder.vi" Type="VI" URL="../../image acquisition/resetTempFolder.vi"/>
			<Item Name="RobotPosGUI.vi" Type="VI" URL="../XY Stage/XYStage.llb/RobotPosGUI.vi"/>
			<Item Name="saveBackground.vi" Type="VI" URL="../../image acquisition/saveBackground.vi"/>
			<Item Name="saveImageData.vi" Type="VI" URL="../../image acquisition/saveImageData.vi"/>
			<Item Name="saveImages.vi" Type="VI" URL="../../image acquisition/saveImages.vi"/>
			<Item Name="sendReceiveCommand.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/sendReceiveCommand.vi"/>
			<Item Name="setPositionXY.vi" Type="VI" URL="../XY Stage/XYStage.llb/setPositionXY.vi"/>
			<Item Name="setServoArduinoNew.vi" Type="VI" URL="../new arduino/setServoArduinoNew.vi"/>
			<Item Name="setTimeOuts.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/setTimeOuts.vi"/>
			<Item Name="setValveArduinoNew.vi" Type="VI" URL="../new arduino/setValveArduinoNew.vi"/>
			<Item Name="setValvesArduinoNew.vi" Type="VI" URL="../new arduino/setValvesArduinoNew.vi"/>
			<Item Name="setValvesArduinosSinglePuffNew.vi" Type="VI" URL="../new arduino/setValvesArduinosSinglePuffNew.vi"/>
			<Item Name="setValvesPuffedArduinoNew.vi" Type="VI" URL="../new arduino/setValvesPuffedArduinoNew.vi"/>
			<Item Name="setXYToNextPosition.vi" Type="VI" URL="../XY Stage/XYStage.llb/setXYToNextPosition.vi"/>
			<Item Name="shakeServoArduinoNew.vi" Type="VI" URL="../new arduino/shakeServoArduinoNew.vi"/>
			<Item Name="stopBaslerCamera.vi" Type="VI" URL="../../image acquisition/stopBaslerCamera.vi"/>
			<Item Name="stopXYStage.vi" Type="VI" URL="../XY Stage/XYStage.llb/stopXYStage.vi"/>
			<Item Name="strByteArrayConvert.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/strByteArrayConvert.vi"/>
			<Item Name="subtractBackground.vi" Type="VI" URL="../../image acquisition/subtractBackground.vi"/>
			<Item Name="writeBrightestToFile.vi" Type="VI" URL="../writeBrightestToFile.vi"/>
		</Item>
		<Item Name="Build Specifications" Type="Build">
			<Item Name="catWalkArduinoNew" Type="EXE">
				<Property Name="App_copyErrors" Type="Bool">true</Property>
				<Property Name="App_INI_aliasGUID" Type="Str">{05AC99AC-DA3A-4D2B-BB20-9DE0B2220619}</Property>
				<Property Name="App_INI_GUID" Type="Str">{2731A970-B0AC-4B0B-8EE1-A5CB55CE39DB}</Property>
				<Property Name="Bld_buildCacheID" Type="Str">{78D3670D-0DE6-4AF1-A8AF-0E449F299ABB}</Property>
				<Property Name="Bld_buildSpecName" Type="Str">catWalkArduinoNew</Property>
				<Property Name="Bld_excludeInlineSubVIs" Type="Bool">true</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">../builds/NI_AB_PROJECTNAME/catWalkArduinoNew</Property>
				<Property Name="Bld_localDestDirType" Type="Str">relativeToCommon</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Bld_previewCacheID" Type="Str">{A170B352-1CAE-42A2-8629-2946C368FB98}</Property>
				<Property Name="Destination[0].destName" Type="Str">catWalkArduinoNew.exe</Property>
				<Property Name="Destination[0].path" Type="Path">../builds/NI_AB_PROJECTNAME/catWalkArduinoNew/catWalkArduinoNew.exe</Property>
				<Property Name="Destination[0].preserveHierarchy" Type="Bool">true</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">Support Directory</Property>
				<Property Name="Destination[1].path" Type="Path">../builds/NI_AB_PROJECTNAME/catWalkArduinoNew/data</Property>
				<Property Name="DestinationCount" Type="Int">2</Property>
				<Property Name="Exe_iconItemID" Type="Ref">/My Computer/icon.ico</Property>
				<Property Name="Source[0].itemID" Type="Str">{5ACE53D2-F23D-493E-99EF-12233E229DAE}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].itemID" Type="Ref">/My Computer/catWalkArduinoNew.vi</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">VI</Property>
				<Property Name="SourceCount" Type="Int">2</Property>
				<Property Name="TgtF_fileDescription" Type="Str">catWalkArduinoNew</Property>
				<Property Name="TgtF_fileVersion.major" Type="Int">1</Property>
				<Property Name="TgtF_internalName" Type="Str">catWalkArduinoNew</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">Copyright © 2013 </Property>
				<Property Name="TgtF_productName" Type="Str">catWalkArduinoNew</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{AE8DD2CD-23BA-4339-92CD-F1F22C1B37C7}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">catWalkArduinoNew.exe</Property>
			</Item>
		</Item>
	</Item>
</Project>
