angular.module('todoApp').controller "TodoListController", ($scope, Task) ->
  $scope.init = (taskListId) ->
    @taskService = new Task(taskListId)
    $scope.tasks = @taskService.all()

  $scope.addTask = ->
    task = @taskService.create(description: $scope.taskDescription)
    $scope.tasks.unshift(task)
    $scope.taskDescription = ""

  $scope.deleteTask = (task) ->
    @taskService.delete(task)
    $scope.tasks.splice($scope.tasks.indexOf(task), 1)

  $scope.toggleTask = (task) ->
    @taskService.update(task, completed: task.completed)

  $scope.taskEdited = (task) ->
    @taskService.update(task, description: task.description)
