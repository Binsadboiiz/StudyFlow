using Microsoft.EntityFrameworkCore;
using Npgsql.EntityFrameworkCore.PostgreSQL;
using StudyFlowBackend.Data;
using StudyFlowBackend.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();

// Đăng ký DbContext với PostgreSQL
builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")); // Hỗ trợ pgvector
});

// Đăng ký Services
builder.Services.AddScoped<ITaskService, TaskService>();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("http://localhost:5173", "https://localhost:5173")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;

    try
    {
        var dbContext = services.GetRequiredService<AppDbContext>();

        var canConnect = dbContext.Database.CanConnect();

        var urls = app.Urls.Any() ? string.Join(", ", app.Urls) : "Unknow URL";

        Console.WriteLine("=======================================");
        Console.WriteLine($" -Server is running at: {urls}");
        Console.WriteLine($" -Environment: {app.Environment.EnvironmentName}");

        if(canConnect)
        {
            Console.WriteLine(" -Database connection: Success");
        }
        else
        {
            Console.WriteLine(" -Database connection: Failed");
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error occurred while initializing the application: {ex.Message}");
    }
}

app.Run();
