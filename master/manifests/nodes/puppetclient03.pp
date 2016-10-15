node 'puppetclient03' {
  $content = hiera('hello')
  file { '/tmp/foo':
    content => $content
  }
}
