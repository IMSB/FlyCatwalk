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
		<Item Name="XY Stage" Type="Folder">
			<Item Name="closeDeviceReference.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/closeDeviceReference.vi"/>
			<Item Name="command_center.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/command_center.vi"/>
			<Item Name="command_generator.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/command_generator.vi"/>
			<Item Name="commands.ctl" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/commands.ctl"/>
			<Item Name="device_selector_panel.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/device_selector_panel.vi"/>
			<Item Name="device_selector_panel_actions.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/device_selector_panel_actions.vi"/>
			<Item Name="errors.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/errors.vi"/>
			<Item Name="errors_actions.ctl" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/errors_actions.ctl"/>
			<Item Name="getDeviceInfo.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/getDeviceInfo.vi"/>
			<Item Name="getDeviceList.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/getDeviceList.vi"/>
			<Item Name="getNumDevices.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/getNumDevices.vi"/>
			<Item Name="GlobalXYStage.vi" Type="VI" URL="../XY Stage/XYStage.llb/GlobalXYStage.vi"/>
			<Item Name="homeXYStage.vi" Type="VI" URL="../XY Stage/XYStage.llb/homeXYStage.vi"/>
			<Item Name="info_options.ctl" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/info_options.ctl"/>
			<Item Name="initXYStage.vi" Type="VI" URL="../XY Stage/XYStage.llb/initXYStage.vi"/>
			<Item Name="openDeviceReference.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/openDeviceReference.vi"/>
			<Item Name="RobotPosGUI.vi" Type="VI" URL="../XY Stage/XYStage.llb/RobotPosGUI.vi"/>
			<Item Name="sendReceiveCommand.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/sendReceiveCommand.vi"/>
			<Item Name="setPositionXY.vi" Type="VI" URL="../XY Stage/XYStage.llb/setPositionXY.vi"/>
			<Item Name="setTimeOuts.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/setTimeOuts.vi"/>
			<Item Name="stopXYStage.vi" Type="VI" URL="../XY Stage/XYStage.llb/stopXYStage.vi"/>
			<Item Name="strByteArrayConvert.vi" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/strByteArrayConvert.vi"/>
			<Item Name="utility_actions.ctl" Type="VI" URL="../XY Stage/PerformaxLV_v103.llb/utility_actions.ctl"/>
		</Item>
		<Item Name="flyHolderNew.ctl" Type="VI" URL="../flyHolderNew.ctl"/>
		<Item Name="TestXYRobot.vi" Type="VI" URL="../TestXYRobot.vi"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="vi.lib" Type="Folder">
				<Item Name="subBuildXYGraph.vi" Type="VI" URL="/&lt;vilib&gt;/express/express controls/BuildXYGraphBlock.llb/subBuildXYGraph.vi"/>
				<Item Name="Waveform Array To Dynamic.vi" Type="VI" URL="/&lt;vilib&gt;/express/express shared/transition.llb/Waveform Array To Dynamic.vi"/>
			</Item>
			<Item Name="PerformaxCom.dll" Type="Document" URL="PerformaxCom.dll">
				<Property Name="NI.PreserveRelativePath" Type="Bool">true</Property>
			</Item>
		</Item>
		<Item Name="Build Specifications" Type="Build"/>
	</Item>
</Project>
