Pod::Spec.new do |s|
  s.name         = "RAReorderableLayout"
  s.version      = "0.1.0"
  s.summary      = "A UICollectionView layout which you can move items with drag and drop."
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage     = "https://github.com/ra1028"
  s.author       = { "ra1028" => "r.fe51028.r@gmail.com" }
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/ra1028/RAReorderableLayout.git", :tag => "0.1.0" }
  s.requires_arc = true
  s.source_files =  'RAReorderableLayout/*.swift'
end
