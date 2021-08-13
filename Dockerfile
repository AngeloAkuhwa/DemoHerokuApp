FROM mcr.microsoft.com/dotnet/sdk:5.0 AS base
WORKDIR /src
COPY *.sln .
# copy and restore all projects
COPY MainMarket.Presentation/*.csproj MainMarket.Presentation/
COPY MainMarket.Application/*.csproj MainMarket.Application/
COPY MainMarket.Domain/*.csproj MainMarket.Domain/
COPY MainMarket.Identity/*.csproj MainMarket.Identity/
COPY MainMarket.Infrastructure/*.csproj MainMarket.Infrastructure/
COPY MainMarket.Persistence/*.csproj MainMarket.Persistence/
RUN dotnet restore
# Copy everything else
COPY . .
#Testing
FROM base AS testing
WORKDIR /src/MainMarket.Presentation
WORKDIR /src/MainMarket.Application
WORKDIR /src/MainMarket.Domain
WORKDIR /src/MainMarket.Identity
WORKDIR /src/MainMarket.Infrastructure
WORKDIR /src/MainMarket.Persistence
RUN dotnet build
#WORKDIR /src/MainMarket.Test
RUN dotnet test
#Publishing
FROM base AS publish
WORKDIR /src/MainMarket.Presentation
RUN dotnet publish -c Release -o /src/publish
#Get the runtime into a folder called app
FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS runtime
WORKDIR /app
COPY --from=publish /src/publish .
COPY --from=publish /src/MainMarket.Identity/Seed/AppUser.json /MainMarket.Identity/Seed/AppUser.json
COPY --from=publish /src/MainMarket.Persistence/EntitySeeder/SeederFiles/Category.json /MainMarket.Persistence/EntitySeeder/SeederFiles/Category.json
COPY --from=publish /src/MainMarket.Persistence/EntitySeeder/SeederFiles/SubCategories.json /MainMarket.Persistence/EntitySeeder/SeederFiles/SubCategories.json
COPY --from=publish /src/MainMarket.Persistence/EntitySeeder/SeederFiles/Stores.json /MainMarket.Persistence/EntitySeeder/SeederFiles/Stores.json
#ENTRYPOINT ["dotnet", "FacilityManagement.Services.API.dll"]
CMD ASPNETCORE_URLS=http://*:$PORT dotnet MainMarket.Presentation.dll
    
    
 