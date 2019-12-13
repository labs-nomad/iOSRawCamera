# Install

If you dont have cocoapods installed on your maching

```shell
sudo gem install cocoapods
```

Once you have cocoapods installed cd into your project. If you don't have cocoapods initalized you can init like this

```shell
pod init
```

Now, open the generated podfile and add this project

```ruby
pod 'iOSRawCamera'
```

Finally, install or update the dependencies.

```shell
pod install
```

Now use the workspace file to open xCode.