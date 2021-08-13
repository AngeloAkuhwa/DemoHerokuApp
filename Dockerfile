FROM mcr.microsoft.com/dotnet/sdk:3.1 AS base
WORKDIR /src
COPY *.sln .
# copy and restore all projects
COPY DemoHerokuApp.Demo/*.csproj DemoHerokuApp.Demo/
RUN dotnet restore DemoHerokuApp.Demo/*.csproj
COPY DemoHerokuApp.Test/*.csproj DemoHerokuApp.Test/
RUN dotnet restore DemoHerokuApp.Test/*.csproj
# Copy everything el se
COPY . .
#Testing
FROM base AS testing
WORKDIR /src/DemoHerokuApp.Demo
RUN dotnet build
#WORKDIR /src/DemoHerokuApp.Demo.Test
WORKDIR /src/DemoHerokuApp.Test
RUN dotnet test

#Publishing
FROM base AS publish
WORKDIR /src/DemoHerokuApp.Demo
RUN dotnet publish -c Release -o /src/publish
#Get the runtime into a folder called app
FROM mcr.microsoft.com/dotnet/aspnet:3.1 AS runtime
WORKDIR /app
COPY --from=publish /src/publish .
#ENTRYPOINT ["dotnet", "DemoHerokuApp.Demo.dll"]
CMD ASPNETCORE_URLS=http://*:$PORT dotnet DemoHerokuApp.Demo.dll
    
    
 