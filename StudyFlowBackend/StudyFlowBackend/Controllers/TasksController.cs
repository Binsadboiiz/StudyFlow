using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using StudyFlowBackend.DTOs;
using StudyFlowBackend.Services;
using StudyFlowBackend.Utils;
using System.Collections.Generic;
using Microsoft.AspNetCore.Authorization;

namespace StudyFlowBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class TasksController : ControllerBase
    {
        private readonly ITaskService _taskService;
        private readonly IUserUtils _userUtils;

        public TasksController(ITaskService taskService, IUserUtils userUtils)
        {
            _taskService = taskService;
            _userUtils = userUtils;
        }

        [HttpGet]
        public async Task<IActionResult> GetTasks()
        {
            var userId = _userUtils.GetCurrentUserId();
            if (string.IsNullOrEmpty(userId)) 
                return Unauthorized(ApiResponse<object>.ErrorResponse("Unauthorized"));

            var tasks = await _taskService.GetTasksByUserIdAsync(userId);
            return Ok(ApiResponse<IEnumerable<TaskDto>>.SuccessResponse(tasks));
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetTask(Guid id)
        {
            var userId = _userUtils.GetCurrentUserId();
            if (string.IsNullOrEmpty(userId)) 
                return Unauthorized(ApiResponse<object>.ErrorResponse("Unauthorized"));

            var task = await _taskService.GetTaskByIdAsync(id, userId);
            
            if (task == null) 
                return NotFound(ApiResponse<object>.ErrorResponse("Task not found"));
                
            return Ok(ApiResponse<TaskDto>.SuccessResponse(task));
        }

        [HttpPost]
        public async Task<IActionResult> CreateTask([FromBody] CreateTaskDto dto)
        {
            var userId = _userUtils.GetCurrentUserId();
            if (string.IsNullOrEmpty(userId)) 
                return Unauthorized(ApiResponse<object>.ErrorResponse("Unauthorized"));

            var createdTask = await _taskService.CreateTaskAsync(userId, dto);
            
            return CreatedAtAction(nameof(GetTask), new { id = createdTask.Id }, 
                ApiResponse<TaskDto>.SuccessResponse(createdTask, "Task created successfully"));
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateTask(Guid id, [FromBody] UpdateTaskDto dto)
        {
            var userId = _userUtils.GetCurrentUserId();
            if (string.IsNullOrEmpty(userId)) 
                return Unauthorized(ApiResponse<object>.ErrorResponse("Unauthorized"));

            var updatedTask = await _taskService.UpdateTaskAsync(id, userId, dto);
            
            if (updatedTask == null) 
                return NotFound(ApiResponse<object>.ErrorResponse("Task not found"));
                
            return Ok(ApiResponse<TaskDto>.SuccessResponse(updatedTask, "Task updated successfully"));
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTask(Guid id)
        {
            var userId = _userUtils.GetCurrentUserId();
            if (string.IsNullOrEmpty(userId)) 
                return Unauthorized(ApiResponse<object>.ErrorResponse("Unauthorized"));

            var result = await _taskService.DeleteTaskAsync(id, userId);
            
            if (!result) 
                return NotFound(ApiResponse<object>.ErrorResponse("Task not found"));
                
            return Ok(ApiResponse<object>.SuccessResponse(null, "Task deleted successfully"));
        }
    }
}
