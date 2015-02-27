name 'zpool'
maintainer 'Optoro'
maintainer_email 'devops@optoro.com'
license 'MIT'
description 'provides a LWRP for managing zpools'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.0.2'

depends 'apt', '>= 2.6.1'
depends 'zfs_linux', '>= 2.0.1'
depends 'zfs', '>= 0.0.5'
