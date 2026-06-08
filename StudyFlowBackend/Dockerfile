# ==========================================
# 1. Build & Publish Stage
# ==========================================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore dependencies first (caching optimization)
COPY ["StudyFlowBackend/StudyFlowBackend.csproj", "StudyFlowBackend/"]
RUN dotnet restore "StudyFlowBackend/StudyFlowBackend.csproj"

# Copy the remaining source code
COPY . .

# Build and publish the release build
WORKDIR "/src/StudyFlowBackend"
RUN dotnet publish "StudyFlowBackend.csproj" -c Release -o /app/publish /p:UseAppHost=false

# ==========================================
# 2. Runtime Stage
# ==========================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

# Expose default port (ASP.NET Core 8 defaults to 8080)
EXPOSE 8080

# Configure the app to run on the PORT environment variable provided by Render,
# defaulting to 8080 if not specified.
CMD ["sh", "-c", "dotnet StudyFlowBackend.dll --urls http://0.0.0.0:${PORT:-8080}"]
