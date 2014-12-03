Pod::Spec.new do |s|
  s.name             = "RAReorderableLayout"
  s.version          = "0.1.0"
  s.summary          = "UICollecitonViewLayout for implementation of reordering cells"
  s.homepage         = "https://github.com/ra1028"
  s.license          = 'MIT'
  s.author           = { "Ryo Aoyama" => "r.fe51028.r@gmail.com" }
  s.source           = { :git => "https://github.com/ra1028/RAReorderableLayout.git", :tag => '0.0.1' }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'RAReorderableTripletLayout/*.swift'
  }
end
