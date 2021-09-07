// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"

#include "GameFramework/Actor.h"
#include "Runtime/Online/HTTP/Public/Http.h"
#include "APlatformClient.generated.h"

UENUM()
enum PlatformClientStatus
{
	Error UMETA(DisplayName = "Error"),
	Initializing UMETA(DisplayName = "Initializing"),
	SetupSession UMETA(DisplayName = "Create Session")
};

UCLASS()
class FANTASYGAME_API AAPlatformClient : public AActor
{
	GENERATED_BODY()
	
public:	
	//HttpClient
	FHttpModule* Http;
	UPROPERTY(BlueprintReadOnly, Category = Status)
	TEnumAsByte<PlatformClientStatus> ClientStatus;
	// Sets default values for this actor's properties
	AAPlatformClient();

protected:
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;

public:	
	// Called every frame
	virtual void Tick(float DeltaTime) override;

public: 
	// Api
	UFUNCTION()
	void SendInitialConnectionPing();

	UFUNCTION()
	void ConfigureSession();

	//Async Resposnes
	void OnInitialConnectionPingResponse(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful);
	void OnSessionCreateResponse(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful);
};

