// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;

public class FantasyGame : ModuleRules
{
	public FantasyGame(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

		PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore", "HeadMountedDisplay" });
	}
}
