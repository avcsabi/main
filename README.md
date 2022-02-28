# My Yellow Book README

This is a small Ruby on Rails application that can be used to search UK's Companies House database and saving the
search results in a MySQL database for later use.

## Notes
* The instructions in this readme are for using a MySQL server hosted on the same machine that hosts the application's server.
For a different configuration please contact the author for the detailed additional instructions.
* Basic remote deployment setup using capistrano for a production server is added but needs further configuration specific to the destination machine. Please contact the author for further assistance if you need to deploy to a remote machine using automated tools.
* Security note: The instructions in this readme are for a http server.
For setting up a https server please contact the author for the detailed additional instructions.

## Installation
Steps necessary to get the application up and running:

* Ruby version:
  * Requires ruby-2.5.3
  * Use rvm for an easier setup

* System dependencies:
  * Linux based system preferred
  * MySQL Version >= 5.5.8
    * Please make sure you have a user set up in MySQL that has appropriate rights to create and modify the database that will be used by the application
  * Before continuing to further steps please make sure the project uses the proper ruby version:
    * If you use rvm issue this command in project root in console:
      ```
      rvm list
    * The output should have this line:
      ```
      =* ruby-2.5.3
  * Bundler version >= 2.0.1
  * Other dependencies are installed by running from console from project root:
    ```
    bundle install

* Configuration:
  * Sensitive information like passwords and keys are stored in environment variables. These can be provided as normal environment variables or added to a ".env" file.
  * Please copy "sample.env" file from project root to project root as ".env"
then edit its content to reflect the appropriate values. The sample.env is a template.

* Database creation:
  * In project root in console use command:
    ```
    rake db:create
  * The database name will have a prefix: "my_yellow_book_" followed by the name of the running environment (ex: "production")

* Database initialization:
  * In project root in console use command:
    ```
    rake db:migrate

* Running application's server locally:
after installing all requirements and the database creation and initialization run the application's server from console
from the project root:
  ```
  rails s

After successful installation if you use a browser on the machine that hosts the application's server then
you can access the application using address: http://localhost:3010/

The port in the address must match the port defined by the environment variable MY_YELLOW_BOOK_SRV_PORT
