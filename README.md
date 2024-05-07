# get_testflight_testers plugin

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-get_testflight_testers`, add it to your project by running:

```bash
fastlane add_plugin get_testflight_testers
```

## About get_testflight_testers


Just add the following to your `fastlane/Fastfile`

```ruby
# Default setup
lane :clean do
  get_testflight_testers
end

# This won't delete out inactive testers, but just print them
lane :clean do
  get_testflight_testers(dry_run: true)
end

```


## Issues and Feedback

Make sure to update to the latest _fastlane_.

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
