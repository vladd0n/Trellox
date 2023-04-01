# Let's implement a TodoListApi using Phoenix framework

## Features roadmap


## Run application

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


### TODO
- Add some new features?
- Add GenServer to the project???

### DONE
- Update tests

- Fix errors:
  * removed the dependency on the template rendering
  * updated TaskController.show/2
  * updated Todos.get_task/1
  * fixed get_task!/1
  * updated Todos.delete_task/1
  * updated TaskController.update/2
  * added tranlsate_error/2

- Test the API with tools like Postman or curl
  * test the GET /api/tasks
  * test the POST /api/tasks
  * test the GET /api/tasks/:id
  * test the PUT /api/tasks/:id
  * test the DELETE /api/tasks/:id

- Set up routes for the Task API
  * define the Task API routes inside 'scope' block

- Create a Task controller to handle API requests
  * create the TaskController file
  * add CRUD actions to the TaskController

- Create a Task context with CRUD operations
  * review the generated Todos context
  * close review the CRUD operations
  * add any additional functionality (list_completed_tasks)

- Set up the database schema and migrations using Ecto
  * review the generated migration file
  * apply the migration to the database 
  * verify the database schema (mix ecto.dump)

- Create a new Ecto schema, migration, and context for the Task model:
  * generate a new Ecto schema, migration, and context for the Task model
  * review the generated Task schema
