// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"

#include "GameFramework/Actor.h"
#include "Runtime/Online/HTTP/Public/Http.h"
#include "APlatformClient.generated.h"

UENUM(BlueprintType)
enum class PlatformClientStatus: uint8
{
	Error = 0 UMETA(DisplayName = "Error"),
	Initializing = 1 UMETA(DisplayName = "Initializing"),
	SetupSession = 2 UMETA(DisplayName = "Create Session"),
	SessionCreated = 3 UMETA(DisplayName = "Session Created"),
	StartLogin = 4 UMETA(DisplayName = "Start Login"),
	LoginError = 5 UMETA(DisplayName = "Login Error")
};

USTRUCT(BlueprintType)
struct FPlatformClientResponse {
	GENERATED_BODY()

	UPROPERTY(BlueprintReadOnly)
	bool IsError;

	UPROPERTY(BlueprintReadOnly)
	FString ResponseBody;
};

UCLASS()
class FANTASYGAME_API AAPlatformClient : public AActor
{
	GENERATED_BODY()
	
public:	
	//HttpClient
	FHttpModule* Http;
	UPROPERTY(BlueprintReadOnly, Category = Status)
	PlatformClientStatus ClientStatus;

	UPROPERTY(BlueprintReadOnly, Category = ClientInfo)
	FString sessionKey;
	// Sets default values for this actor's properties
	AAPlatformClient();

	UPROPERTY(BlueprintReadOnly, Category = RequestInfo)
		FString LastError;

	UFUNCTION(BlueprintCallable, Category = Status)
		void ResetLoginStatus();

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

	UFUNCTION(BlueprintCallable)
	void StartLogin(FString username, FString password);


	//Async Resposnes
	void OnInitialConnectionPingResponse(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful);
	void OnSessionCreateResponse(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful);
	void OnLoginResponse(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful);

private:
	TSharedRef<IHttpRequest, ESPMode::ThreadSafe> SetupRequestUrl(FString verb, FString url);
	TSharedRef<IHttpRequest, ESPMode::ThreadSafe> SetupStandardHeaders(TSharedRef<IHttpRequest, ESPMode::ThreadSafe> request);
	TSharedRef<IHttpRequest, ESPMode::ThreadSafe> SetupSessionHeader(TSharedRef<IHttpRequest, ESPMode::ThreadSafe> request);
	FPlatformClientResponse ProcessHttpResponse(FHttpResponsePtr Response, bool bWasSuccessful, FString dataKey, FString errorKey = "errors");
	
};

