node 'puppetclient02' {
  $content = hiera('hello')
  file { '/tmp/foo':
    content => $content
  }
}
