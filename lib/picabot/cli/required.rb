Picabot::CLI.parse do
  separator <<-DESC
Required
--------

These flags are required for the first launch.
You need to set them only once, though.

DESC
  option :token, 'hex', 'Generate it at https://github.com/settings/tokens/new'
  option :user, 'name', "Your (or your bot's) GitHub username"
end
