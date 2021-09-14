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

void AAPlatformClient::ResetLoginStatus()
{
	if (ClientStatus == PlatformClientStatus::LoginError) {
		ClientStatus = PlatformClientStatus::SessionCreated;
	}
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
		TSharedRef<IHttpRequest, ESPMode::ThreadSafe> Request = SetupRequestUrl("GET", "http://localhost:4000/api/ping");
		Request = SetupStandardHeaders(Request);
		Request->OnProcessRequestComplete().BindUObject(this, &AAPlatformClient::OnInitialConnectionPingResponse);
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
		


		TSharedRef<IHttpRequest, ESPMode::ThreadSafe> Request = this->SetupRequestUrl("POST", "http://localhost:4000/api/sessions");
		Request = SetupStandardHeaders(Request);
		Request->OnProcessRequestComplete().BindUObject(this, &AAPlatformClient::OnSessionCreateResponse);
		//This is the url on which to process the request
		Request->SetContentAsString(bodySend);
		Request->ProcessRequest();
	}

}

void AAPlatformClient::OnInitialConnectionPingResponse(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful)
{
	FPlatformClientResponse ProcessedResponse = ProcessHttpResponse(Response, bWasSuccessful, "status");
	if (ProcessedResponse.IsError == true) {
		LastError = ProcessedResponse.ResponseBody;
		ClientStatus = PlatformClientStatus::Error;
	}
	else {
		if (ProcessedResponse.ResponseBody == "pong") {
			ClientStatus = PlatformClientStatus::SetupSession;
			ConfigureSession();
		}
		else
		{
			LastError = ProcessedResponse.ResponseBody;
			ClientStatus = PlatformClientStatus::Error;
		}
	}
}

void AAPlatformClient::OnSessionCreateResponse(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful)
{
	FPlatformClientResponse response = ProcessHttpResponse(Response, bWasSuccessful, "key");
	if (response.IsError)
	{
		LastError = response.ResponseBody;
		ClientStatus = PlatformClientStatus::Error;
	}
	else
	{
		UFantasyGameInstance* instance = Cast<UFantasyGameInstance>(this->GetWorld()->GetGameInstance());
		instance->setSessionKey(response.ResponseBody);
		ClientStatus = PlatformClientStatus::SessionCreated;
	}
}

void AAPlatformClient::OnLoginResponse(FHttpRequestPtr Request, FHttpResponsePtr Response, bool bWasSuccessful) {
	FPlatformClientResponse response = ProcessHttpResponse(Response, bWasSuccessful, "token");
	if (response.IsError)
	{
		LastError = response.ResponseBody;
		ClientStatus = PlatformClientStatus::LoginError;
	}
	else
	{

		ClientStatus = PlatformClientStatus::LoginComplete;
		UFantasyGameInstance* instance = Cast<UFantasyGameInstance>(this->GetWorld()->GetGameInstance());
		instance->setLoginKey(response.ResponseBody);
	}
}

void AAPlatformClient::StartLogin(FString username, FString password) {
	if (ClientStatus == PlatformClientStatus::SessionCreated) {


		TSharedPtr<FJsonObject> JsonObject = MakeShareable(new FJsonObject);
		JsonObject->SetStringField("username", username);
		JsonObject->SetStringField("password", password);
		
		FString bodySend;
		TSharedRef<TJsonWriter<>> Writer = TJsonWriterFactory<>::Create(&bodySend);
		FJsonSerializer::Serialize(JsonObject.ToSharedRef(), Writer);


		ClientStatus = PlatformClientStatus::StartLogin;
		TSharedRef<IHttpRequest, ESPMode::ThreadSafe> Request = SetupRequestUrl("post", "http://localhost:4000/api/login");
		Request = SetupStandardHeaders(Request);
		Request = SetupSessionHeader(Request);
		Request->SetContentAsString(bodySend);
		Request->OnProcessRequestComplete().BindUObject(this, &AAPlatformClient::OnLoginResponse);
		Request->ProcessRequest();

	}
	
}




TSharedRef<IHttpRequest, ESPMode::ThreadSafe> AAPlatformClient::SetupRequestUrl(FString verb, FString url) {
	TSharedRef<IHttpRequest, ESPMode::ThreadSafe> Request = Http->CreateRequest();
	//This is the url on which to process the request
	Request->SetURL(url);
	Request->SetVerb(verb);
	return Request;
}
TSharedRef<IHttpRequest, ESPMode::ThreadSafe> AAPlatformClient::SetupStandardHeaders(TSharedRef<IHttpRequest, ESPMode::ThreadSafe> request) {
	request->SetHeader(TEXT("User-Agent"), "X-UnrealEngine-Agent");
	request->SetHeader("Content-Type", TEXT("application/json"));
	return request;
}

TSharedRef<IHttpRequest, ESPMode::ThreadSafe> AAPlatformClient::SetupSessionHeader(TSharedRef<IHttpRequest, ESPMode::ThreadSafe> request) {
	UFantasyGameInstance* instance = Cast<UFantasyGameInstance>(this->GetWorld()->GetGameInstance());
	FString key = instance->getSessionKey();
	request->SetHeader(TEXT("DeviceId"), key);
	return request;
}

TSharedRef<IHttpRequest, ESPMode::ThreadSafe> AAPlatformClient::SetupLoginHeader(TSharedRef<IHttpRequest, ESPMode::ThreadSafe> request)
{
	UFantasyGameInstance* instance = Cast<UFantasyGameInstance>(this->GetWorld()->GetGameInstance());
	FString key = instance->getLoginKey();
	request->SetHeader(TEXT("Authorization"), "Bearer " + key);
	return request;
}


FPlatformClientResponse AAPlatformClient::ProcessHttpResponse(FHttpResponsePtr response, bool bWasSuccessful, FString dataKey, FString errorKey) {
	TSharedPtr<FJsonObject> JsonObject;

	//Create a reader pointer to read the json data
	TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(response->GetContentAsString());
	if (!bWasSuccessful) {
		FPlatformClientResponse ClientResponse;
		ClientResponse.IsError = true;
		ClientResponse.ResponseBody = "Response Code Error";
		return ClientResponse;
	}
	//Deserialize the json data given Reader and the actual object to deserialize
	if (FJsonSerializer::Deserialize(Reader, JsonObject))
	{
		//Get the value of the json object by field name
		//int32 recievedInt = JsonObject->GetIntegerField("customInt");
		if (JsonObject->HasField(errorKey)) {
			FPlatformClientResponse ClientResponse;
			ClientResponse.IsError = true;
			ClientResponse.ResponseBody = JsonObject->GetStringField("errors");
			return ClientResponse;
		}
		else
		{
			if (JsonObject->HasField(dataKey))
			{
				FPlatformClientResponse ClientResponse;
				ClientResponse.IsError = false;
				ClientResponse.ResponseBody = JsonObject->GetStringField(dataKey);
				return ClientResponse;
			}
			else
			{
				FPlatformClientResponse ClientResponse;
				ClientResponse.IsError = true;
				ClientResponse.ResponseBody = "missing dataKey";
				return ClientResponse;
			}
		}

	}
	else
	{
		FPlatformClientResponse ClientResponse;
		ClientResponse.IsError = true;
		ClientResponse.ResponseBody = "Invalid Json Response";
		return ClientResponse;
	}

}

