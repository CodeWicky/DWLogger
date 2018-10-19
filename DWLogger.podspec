Pod::Spec.new do |s|
s.name = 'DWLogger'
s.version = '1.0.8'
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.summary = '这是一个日志助手类，他可以帮助你在App中直接查看输出的日志。This is a Log Helper Class which enable you read logs in your App on screen directly.'
s.homepage = 'https://github.com/CodeWicky/DWLogger'
s.authors = { 'codeWicky' => 'codewicky@163.com' }
s.source = { :git => 'https://github.com/CodeWicky/DWLogger.git', :tag => s.version.to_s }
s.requires_arc = true
s.ios.deployment_target = '7.0'
s.source_files = 'DWLogger/**/{DWLogger,DWSearchView,DWLogManager,DWLogView,DWCrashCollector,UIWindow+DWLoggerShake,DWLoggerMacro}.{h,m}'
s.resource = 'DWLogger/**/*.{bundle}'
s.frameworks = 'UIKit'

s.dependency 'DWTableViewHelper', '~> 1.1.7.1'
s.dependency 'DWCheckBox', '~> 1.0.3'

s.subspec 'Dependence' do |d|

d.subspec 'DWFileManager' do |ss|
ss.source_files = 'DWLogger/**/DWFileManager.{h,m}'
ss.public_header_files = 'DWLogger/**/DWFileManager.h'
ss.frameworks = 'UIKit'
end

d.subspec 'DWArrayUtils' do |ss|
ss.source_files = 'DWLogger/**/NSArray+DWArrayUtils.{h,m}'
ss.public_header_files = 'DWLogger/**/NSArray+DWArrayUtils.h'
ss.frameworks = 'UIKit'
end

d.subspec 'DWDeviceUtils' do |ss|
ss.source_files = 'DWLogger/**/UIDevice+DWDeviceUtils.{h,m}'
ss.public_header_files = 'DWLogger/**/UIDevice+DWDeviceUtils.h'
ss.frameworks = 'UIKit'
end

end

end
