# LINE Bot - Todo List

This app allows you to create and manage your todos all through the LINE app by utilizing the LINE Login API and LINE Messaging API.

References:

- https://developers.line.me/en/docs/line-login/getting-started/
- https://developers.line.me/en/docs/messaging-api/getting-started/

To run in development mode:

1. Create a Messaging API at [https://developers.line.me/console](https://developers.line.me/console)
2. Create a LINE Login API at [https://developers.line.me/console](https://developers.line.me/console)
3. `git clone https://github.com/chakritp/todo-list-line.git`
4. run `bundle install`
5. run `rails db:create`
6. run `rails db:migrate`
7. Set the following environment variables:
	- `REDIRECT_URI`
	- `STATE`
	- `LINE_CHANNEL_ID`
	- `LINE_CHANNEL_SECRET`
	- `LINE_LOGIN_CHANNEL_SECRET`
	- `LINE_CHANNEL_TOKEN`

8. Run `rails s` (listening on port 3000) by default 
9. Scan the QR code of the bot and send messages on LINE to begin interacting with it

To run tests:

1. run `bundle exec rspec`