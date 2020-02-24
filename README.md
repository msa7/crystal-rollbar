# crystal-rollbar

An unofficial Crystal-language client and integration layer for the rollbar.com error reporting API.

Based on Rollbar-gem

Features:

- [x] report to Rollbar
- [ ] report about parent exception
- [ ] Kemal integration. Sumbit URL, HTTP variable based on Kemal environment
- [ ] Write example of async error reporting (fiber, sidekiq)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     crystal-rollbar:
       github: msa7/crystal-rollbar
   ```

2. Run `shards install`

## Usage

```crystal
require "crystal-rollbar"

Rollbar.access_token = "rollbar_access_token"
Rollbar.environment = "staging"
Rollbar.framework = "Kemal"
Rollbar.code_version = "0.1"

Rollbar.debug("Debug #{Time.utc}", user_id = "777")

begin
  raise "Error #{Time.utc}"
rescue e
  Rollbar.error(e, user_id = "555")
end
```



## Contributing

1. Fork it (<https://github.com/your-github-user/crystal-rollbar/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Sergey Makridenkov](https://github.com/your-github-user) - creator and maintainer
