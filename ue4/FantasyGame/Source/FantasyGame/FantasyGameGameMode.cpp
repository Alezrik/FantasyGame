// Copyright Epic Games, Inc. All Rights Reserved.

#include "FantasyGameGameMode.h"
#include "FantasyGameCharacter.h"
#include "UObject/ConstructorHelpers.h"

AFantasyGameGameMode::AFantasyGameGameMode()
{
	// set default pawn class to our Blueprinted character
	static ConstructorHelpers::FClassFinder<APawn> PlayerPawnBPClass(TEXT("/Game/ThirdPersonCPP/Blueprints/ThirdPersonCharacter"));
	if (PlayerPawnBPClass.Class != NULL)
	{
		DefaultPawnClass = PlayerPawnBPClass.Class;
	}
}
