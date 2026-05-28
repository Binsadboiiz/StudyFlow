using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using StudyFlowBackend.DTOs;
using StudyFlowBackend.Services;

namespace StudyFlowBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TasksController : ControllerBase
    {
        private readonly ITaskService _taskService;

        public TasksController(ITaskService taskService)
        {
            _taskService = taskService;
        }

        // Hiện tại tạm thời hardcode userId để test.
        // Sau khi tích hợp Firebase Auth, chúng ta sẽ lấy userId từ JWT Token (User.Claims).
        private string GetCurrentUserId()
        {
            return "test-user-id-123"; 
        }

        [HttpGet]
        public async Task<IActionResult> GetTasks()
        {
            var userId = GetCurrentUserId();
            var tasks = await _taskService.GetTasksByUserIdAsync(userId);
            return Ok(tasks);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetTask(Guid id)
        {
            var userId = GetCurrentUserId();
            var task = await _taskService.GetTaskByIdAsync(id, userId);
            
            if (task == null) return NotFound();
            return Ok(task);
        }

        [HttpPost]
        public async Task<IActionResult> CreateTask([FromBody] CreateTaskDto dto)
        {
            var userId = GetCurrentUserId();
            var createdTask = await _taskService.CreateTaskAsync(userId, dto);
            
            return CreatedAtAction(nameof(GetTask), new { id = createdTask.Id }, createdTask);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTask(Guid id, [FromBody] UpdateTaskDto dto)
        {
            var userId = GetCurrentUserId();
            var updatedTask = await _taskService.UpdateTaskAsync(id, userId, dto);
            
            if (updatedTask == null) return NotFound();
            return Ok(updatedTask);
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTask(Guid id)
        {
            var userId = GetCurrentUserId();
            var result = await _taskService.DeleteTaskAsync(id, userId);
            
            if (!result) return NotFound();
            return NoContent();
        }
    }
}
