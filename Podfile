# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'mySwiftCoin' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # List core (BTCollectionView) dependencies
  pod 'Then'
  pod 'MJRefresh'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SnapKit'
  # Vendored (git HTTPS→SSH rewrite blocks CocoaPods clone) — https://github.com/octree/Stockee
  pod 'Stockee', :path => 'Vendor/Stockee'

  target 'mySwiftCoinTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'mySwiftCoinUITests' do
    # Pods for testing
  end

end
