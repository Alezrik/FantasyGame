// Fill out your copyright notice in the Description page of Project Settings.


#include "APlatformClient.h"

#include "Runtime/Networking/Public/Interfaces/IPv4/IPv4Address.h"
#include "Runtime/Sockets/Public/SocketSubsystem.h"
#include "Templates/SharedPointer.h"
#include "FantasyGameInstance.h"


// Sets default values
AAPlatformClient::AAPlatformClient()
{
 	// Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;
	Http = &FHttpModule::Get();
	ClientStatus = PlatformClientStatus::Initializing;
}

// Called when the game starts or when spawned
void AAPlatformClient::BeginPlay()
{
	SendInitialConnectionPing();
	Super::BeginPlay();
	
}

// Called every frame
void AAPlatformClient::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

}

void AAPlatformClient::SendInitialConnectionPing()
{
	if (ClientStatus == PlatformClientStatus::Initializing)
	{
		TSharedRef<IHttpRequest, ESPMode::ThreadSafe> Request = Http->CreateRequest();
		Request->OnProcessRequestComplete().BindUObject(this, &AAPlatformClient::OnInitialConnectionPingResponse);
		//This is the url on which to process the request
		Request->SetURL("http://localhost:4000/api/ping");
		Request->SetVerb("GET");
		Request->SetHeader(TEXT("User-Agent"), "X-UnrealEngine-Agent");
		Request->SetHeader("Content-Type", TEXT("application/json"));
		Request->ProcessRequest();
	}
	
}

void AAPlatformClient::ConfigureSession()
{
	if (ClientStatus == PlatformClientStatus::SetupSession)
	{
		FString cpu = FGenericPlatformMisc::GetCPUBrand();
		FString deviceId = FGenericPlatformMisc::GetDeviceMakeAndModel();
		bool bind = false;
		TSharedRef<FInternetAddr> LocalAddr = ISocketSubsystem::Get(PLATFORM_SOCKETSUBSYSTEM)->GetLocalHostAddr(*GLog, bind);

		FString myLocalIp = LocalAddr->ToString(0);
		TSharedPtr<FJsonObject> JsonObject = MakeShareable(new FJsonObject);
		JsonObject->SetStringField("cpu", cpu);
		JsonObject->SetStringField("deviceid", deviceId);
		JsonObject->SetStringField("localip", myLocalIp);
		FString bodySend;
		TSharedRef<TJsonWriter<>> Writer = TJsonWriterFactory<>::Create(&bodySend);
		FJsonSerializer::Serialize(JsonObject.ToSharedRef(), Writer);
		GEngine->AddOnScreenDebugMessage(1, 2.0f, FColor::Green, "Prepare Session: " + bodySend);
		
		TSharedRef<IHttpRequest, ESPMode::ThreadSafe> Request = Http->CreateRequest();
		Request->OnProcessRequestComplete().BindUObject(this, &AAPlatformClient::OnSessionCreateResponse);
		//This is the url on which to process the request
		Request->SetURL("http://localhost:4000/api/sessions");
		Request->SetVerb("POST");
		Request->SetHeader(TEXT("User-Agent"), "X-UnrealEngine-Agent");
		Request->SetHeader("Content-Type", TEXT("application/json"));
		Request->SetContentAsString(bodySend);
		Request->ProcessRequest();
	}

}

void AAPlatformClient::OnInitialConnectionPingResponse(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful)
{
	if (bWasSuccessful && ClientStatus == PlatformClientStatus::Initializing)
	{
		//Create a pointer to hold the json serialized data
		TSharedPtr<FJsonObject> JsonObject;

		//Create a reader pointer to read the json data
		TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(Response->GetContentAsString());

		//Deserialize the json data given Reader and the actual object to deserialize
		if (FJsonSerializer::Deserialize(Reader, JsonObject))
		{
			//Get the value of the json object by field name
			//int32 recievedInt = JsonObject->GetIntegerField("customInt");
			FString status = JsonObject->GetStringField("status");
			//Output it to the engine
			if (status == "pong" && ClientStatus == PlatformClientStatus::Initializing)
			{
				GEngine->AddOnScreenDebugMessage(1, 2.0f, FColor::Green, "Connection Ready");
				ClientStatus = PlatformClientStatus::SetupSession;
				ConfigureSession();
			}

		}

	}
	else {
		ClientStatus = PlatformClientStatus::Error;
	}
}

void AAPlatformClient::OnSessionCreateResponse(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful)
{
	if (bWasSuccessful && ClientStatus == PlatformClientStatus::SetupSession)
	{
		//Create a pointer to hold the json serialized data
		TSharedPtr<FJsonObject> JsonObject;

		//Create a reader pointer to read the json data
		TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(Response->GetContentAsString());

		//Deserialize the json data given Reader and the actual object to deserialize
		if (FJsonSerializer::Deserialize(Reader, JsonObject))
		{
			//Get the value of the json object by field name
			//int32 recievedInt = JsonObject->GetIntegerField("customInt");
			if (JsonObject->HasField("errors")) {
				GEngine->AddOnScreenDebugMessage(1, 2.0f, FColor::Red, "got err resp:" + JsonObject->GetStringField("errors"));
			}
			else
			{
				FString key = JsonObject->GetStringField("key");
				GEngine->AddOnScreenDebugMessage(1, 2.0f, FColor::Green, "got key resp:" + key);
				UFantasyGameInstance* instance = Cast<UFantasyGameInstance>(this->GetWorld()->GetGameInstance());
				instance->setSessionKey(key);
			}
			
		}

	}
	else {
		GEngine->AddOnScreenDebugMessage(1, 2.0f, FColor::Red, "Error on Session Create");
		ClientStatus = PlatformClientStatus::Error;
	}
}


