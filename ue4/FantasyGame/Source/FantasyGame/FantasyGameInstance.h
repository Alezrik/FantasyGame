// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "Engine/GameInstance.h"
//#include <FantasyGame/PlatformClient.h>

#include "FantasyGameInstance.generated.h"

/**
 * 
 */
UCLASS()
class FANTASYGAME_API UFantasyGameInstance : public UGameInstance
{
	GENERATED_BODY()

	public:
		void setSessionKey(FString key) {
			SessionKey = key;
		};
		UFUNCTION(BlueprintCallable)
		FString getSessionKey() {
			return SessionKey;
		}
private:
		FString SessionKey;

		/*UPROPERTY()
		UPlatformClient* platformClient;

	virtual void Init() {
		platformClient = NewObject<UPlatformClient>();
		}*/
		
};
