node 'puppetclient01' {
  $content = hiera('hello')
  file { '/tmp/foo':
    content => $content
  }
}
